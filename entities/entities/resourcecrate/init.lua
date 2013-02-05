AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()
    self.Entity:SetModel("models/items/item_item_crate.mdl")
 	self.Entity.Resources = {}
 end

--Called when an entity starts touching this SENT.
--Return: Nothing
function ENT:StartTouch(entEntity)
	//if entEntity:GetClass() == "gms_resourcedrop" and entEntity.Type == self.Entity.Type then
	//	big_gms_combineresource(self,entEntity)
	//end
	//if entEntity:GetClass() == "gms_buildsite" and (entEntity.Costs[self.Entity.Type] != nil and entEntity.Costs[self.Entity.Type] > 0) then
	//	gms_addbuildsiteresource(self,entEntity)
	//end
end
