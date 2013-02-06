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
_R.Player.Skills = {}
_R.Player.Stats = {}
_R.Player.Experience = {}
_R.Player.Resources = {}

function GM:PlayerInitialSpawn(ply)
	ply:SetTeam( 1 )--Set Team

	ply.Stats = GM.Config.DefaultStats
	ply.Food = 100
	ply.Tiredness = 100
	ply.Water = 100
	ply.AFK = false

	ply:SetWalkSpeed(GM.Config.Walkspeed)--Set Speed
	ply:SetRunSpeed(CalculateRunSpeed( ply ))


end

function CalculateRunSpeed( ply )
	return (GM.Config.Runspeed * math.sqrt(ply.Stats.Agility/10))
end

function GM:PlayerLoadout( ply ) 
 
    if ply:Team() == 1 then 

    	ply:StripWeapons()
    	ply:StripAmmo() 
    	for k,v in pairs(GM.Config.StartingWeapons) do
    		ply:Give(v)
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

//Chat Commands
GM.Commands = {}

function RunChatCommand( ply , text, public )
	if string.sub(text, 1, 1) == GM.Config.ChatCommandPrefix then
		local args = string.Explode(" ", string.sub(text, 2))
		local cmd = args[1]
		table.remove(args, 1)
		if GM.Commands[cmd] then
			GM.Commands[cmd].func( ply, args )
			return "" 
		end
	end
end

function GM:PlayerSay ( ply , text, public )
	RunChatCommand( ply , text, public )
end

function GM.AddCommand(command, func, description)
    concommand.Add("stranded_" .. command, function(ply, cmd, args)
        func(ply, args)
    end)
    GM.Commands[command] = {
        desc = description,
        func = func
    }
end


//Factions
GM.Factions = {
	{ 
		name = "Default_Faction",
		id=1,
		password = ""
	}
}
GM.FactionsCount= 1

function CreateFaction( ply, tbl )
	if # tbl == 5 or # tbl == 4 then
		local fname = tbl[1]
		local color = 	{
			red=math.Clamp(tonumber(tbl[2]),0,255),
			green=math.Clamp(tonumber(tbl[3]),0,255),
			blue=math.Clamp(tonumber(tbl[4]),0,255)
		}
		if tbl[5] and tbl[5] ~= "" then
			local fpassword = tbl[5]
		else
			local fpassword = ""
		end
		for k,v in pairs(GM.Factions) do
			if v.name == fname then ply:ChatPrint("Name in Use") return end
		end
		GM.FactionsCount = GM.FactionsCount + 1
		GM.Factions[GM.FactionsCount]= {
			name = fname,
			id=GM.FactionsCount,
			password=fpassword
		}
		team.SetUp( GM.FactionSCount, fname, Color( color.red, color.green, color.blue, 255 ) ) 
		ply:SetTeam(GM.NumTribes)
		ply:ChatPrint("Faction :" .. fname .. " Created!")
	else
		ply:ChatPrint("Incorrect Syntax! Syntax is: /CreateFaction Name Red Green Blue Password(Optional)")
	end
end
GM.AddCommand("CreateFaction", CreateFaction, "Create A Faction")

function JoinFaction( ply, tbl )
	if # tbl == 1 or # tbl == 2 then
		for k,v in pairs(GM.Factions) do
			if tbl[1] == v.name then
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
					end
				end --End Password
			else
				ply:ChatPrint("Failed to join Faction, Invalid Name")
			end
		end --End For
	else 
		ply:ChatPrint("Incorrect Syntax! Syntax is: /JoinFaction Name Password(Optional)")
	end
end
GM.AddCommand("JoinFaction", JoinFaction, "Join A Faction")

function LeaveFaction( ply, tbl )
	local f = team.GetName( ply:Team() )
	ply:SetTeam(1)
	ply:ChatPrint("You Left "..f)
end
GM.AddCommand("LeaveFaction", LeaveFaction, "Leave Your Current Faction")

function AFK( ply, tbl )
	ply:Freeze(!ply.AFK)
	ply.AFK = !ply.AFK
end
GM.AddCommand("AFK", AFK, "Go afk derp")


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
		self:IncrementStat(GM.Config.SkilltoStat[skill])
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
	self.Stats[skill]=self.Stats[skill]+1
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