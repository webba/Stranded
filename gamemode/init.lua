DeriveGamemode( "sandbox" )

//Client side lua files
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

//Includes
include("shared.lua")
include("config.lua")

//Player
local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")
PlayerMeta.Skills = {}
PlayerMeta.Stats = {}
PlayerMeta.Experience = {}
PlayerMeta.Resources = {}


function FirstSpawn( ply )
 
    ply:SetTeam( 1 )--Set Team

	self:PlayerLoadout(ply)--Set Loadout

	ply.Stats = GM.Config.DefaultStats
	ply.Food = 100
	ply.Tiredness = 100
	ply.Water = 100
	ply.AFK = false

	ply:SetWalkSpeed(GM.Config.Walkspeed)--Set Speed
	ply:SetRunSpeed(CalculateRunSpeed( ply ))
 
end 
hook.Add( "PlayerInitialSpawn", "FirstSpawn", FirstSpawn )

function CalculateRunSpeed( ply )
	return (GM.Config.Runspeed * math.sqrt(ply.Stats.Agility/10))
end

function DefaultLoadout( ply ) 
 
    if ply:Team() == 1 then 

    	ply:StripWeapons()
    	ply:StripAmmo() 
    	for k,v in pairs(GM.Config.StartingWeapons) do
    		ply:Give(v)
    	end
    	 
    end 
 
end
hook.Add( "PlayerLoadout", "DefaultLoadout", DefaultLoadout)

function PlayerNeeds()
	for k, ply in pairs(player.GetAll()) do
		if ply:Alive() and not ply.AFK then
			if ply.Food > 0 then ply.Food = math.Clamp(ply.Food-1, 0, 100)
			if ply.Water > 0 then ply.Water = math.Clamp(ply.Water-1, 0, 100)
			if ply.Tiredness > 0 then ply.Tiredness = math.Clamp(ply.Tiredness-1, 0, 100)
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


//Factions
GM.Factions = {
	{ 
		name = "Default_Faction"
		id=1
		password = ""
	}
}
GM.FactionsCount = 1

function CreateFaction( ply, tbl )
	if # tbl == 5 or # tbl == 4 then
		local fname = tbl[1]
		local color = 	{
			red=math.Clamp(tonumber(tbl[2]),0,255)
			green=math.Clamp(tonumber(tbl[3]),0,255)
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
			name = fname
			id=GM.FactionsCount
			password=fpassword
		}
		team.SetUp( GM.FactionSCount, fname, Color( color.red, color.green, color.blue, 255 ) ) 
		ply:SetTeam(GAMEMODE.NumTribes)
		ply:ChatPrint("Faction :" .. fname .. " Created!")
	else
		ply:ChatPrint("Incorrect Syntax! Syntax is: /CreateFaction Name Red Green Blue Password(Optional)")
	end
end
AddChatCommand("/CreateFaction", CreateFaction)
concommand.Add( "stranded_createfaction", CreateFaction)

function JoinFaction( ply, tbl )
	if # tbl == 1 or # tbl == 2 then
		for k,v in pairs(GM.Factions) do
			if tbl[1] == v.name then
				if tbl[2] then --Password
					if tbl[2]==v.password then 
						ply:SetTeam(v.id) 
						ply:ChatPrint("Joined: "..v.name)
					else
						ply:ChatPrint("Failed to join Faction, Incorrect Password")
					end
				else
					if v.password="" then 
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
AddChatCommand("/JoinFaction", JoinFaction)
concommand.Add( "stranded_joinfaction", JoinFaction)

function LeaveFaction( ply, tbl )
	local f = team.GetName( ply:Team() )
	ply:SetTeam(1)
	ply:ChatPrint("You Left "..f)
end
AddChatCommand("/LeaveFaction", LeaveFaction)
concommand.Add( "stranded_leavefaction", LeaveFaction)

//Chat Commands
GM.ChatCommands = {}

function RunChatCommand( ply , text, public )
	local chattext = string.Explode(" ", text)
	local args = chattext 
	table.remove(args, 1)
	for k,v in pairs(GM.ChatCommands) do
		if ( v.cmd == chattext[1] ) then
			v.func( ply, args )
			return "" 
		end 
	end
end
hook.Add( "PlayerSay", "ChatCommand", RunChatCommand )

function AddChatCommand( com, funct )
	for k,v in pairs(ChatCommands) do
		if cmd == v.cmd then return end
	end
	GM.ChatCommands[cmd] = {
		cmd = cmd,
		func = funct,
	}
end

function AFK( ply, tbl )
	if ply.AFK then 
		ply:Freeze(false)
		ply.AFK = false
	elseif not ply.AFK then 
		ply:Freeze(true)
		ply.AFK = true
	end
end
AddChatCommand("/AFK", AFK)
concommand.Add( "stranded_afk", AFK)


//XP/Level System 
function PlayerMeta:HasSkill( skill )
	if not self.Skills[skill] then self.Skills[skill]=0 end
end


function PlayerMeta:SetSkill( skill, level )
	self:HasSkill(skill)
	self.Skills[skill]=level

end

function PlayerMeta:IncrementSkill( skill )
	self:HasSkill()
	self:SetSkill(skill, self.Skills[skill]+1)
	if self.Skills[skill] % 10 == 0 then
		self:IncrementStat(GM.Config.SkilltoStat[skill])
	end
end

function PlayerMeta:HasSkillXP( skill )
	if not self.Experience[skill] then self.Skills[skill]=0 end
end

function PlayerMeta:SetXP( skill, level )
	self:HasSkillXP(skill)
	self.Experience[skill]=level
end

function PlayerMeta:IncrementXP( skill, ammount )
	self:HasSkillXP()
	self:SetExperience(skill, self.Experience[skill]+ammount)
	if self.Experience[skill] >= 100 then
		self:IncrementSkill(skill)
		self.Experience[skill] = 0
	end
end


function PlayerMeta:IncrementStat( skill )
	self.Stats[skill]=self.Stats[skill]+1
end

//Resources System
function PlayerMeta:SetResource( resource, int )
	if !self.Resources[resource] then self.Resources[resource] = 0 end
	self.Resources[resource] = int
end

function PlayerMeta:GetTotalResources()
	local n=0
	for k,v in pairs(self.Resorces) do
		n=n+v
	end
	return n
end

function PlayerMeta:AddResorce( resource, int )
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

function PlayerMeta:RemoveResource(resource,int)
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

function PlayerMeta:DropResource(resource,int)
	local ammount = self:RemoveResource(resource, int)
	local tr = self.:GetEyeTrace()
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