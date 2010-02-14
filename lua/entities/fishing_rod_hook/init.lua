AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/meathook001a.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType(MOVETYPE_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(60)
		phys:SetDamping(1,1)
		phys:Wake()
	end

	self.last_velocity = Vector(0)
	self.last_angular_velocity = Vector(0)
	
	self.physical_rope = constraint.Elastic( self, self.bobber, 0, 0, Vector(0,1.2,6), Vector(0,0,4), 6000, 1200, 0, "", 0, 1 )
	self.physical_rope:Fire("SetSpringLength", 50)

	fish_hook = self
end

function ENT:StartTouch(entity)
	if fishingmod.IsBait(entity) or entity:GetClass() == "gmod_dynamite" then
		self:HookBait(entity)
	end
end

function ENT:HookBait(bait)
	if not IsValid(self.dt.bait) then
		bait:SetPos(self:GetPos())
		self.dt.bait = bait
		constraint.Weld(self, self.dt.bait)
	end
end

function ENT:DropBait()
	if IsValid(self.dt.bait) then
		constraint.RemoveConstraints(self.dt.bait, "Weld")
		self.dt.bait = nil
	end
end

function ENT:GetHookedBait()
	return IsValid(self.dt.bait) and self.dt.bait or false
end

function ENT:Hook( entitytype, data )
	if IsValid(self.dt.hooked) then return end
	if IsValid(self.dt.bait) then
		self.dt.bait:Remove()
	end
	
	data = data or {}
		
	if IsValid(type(entitytype) == "Entity" and entitytype or false) then
		self.dt.hooked = type
		self.dt.hooked:SetNWString("fishingmod friendly", data.friendly or "Unknown")
		self.dt.hooked:SetNWBool("fishingmod catch", true)
		self.dt.hooked:SetNWFloat("fishingmod size", data.size)
		self.dt.hooked.remove_on_release = data.remove_on_release
		self.dt.hooked.is_catch = true
		self.dt.hooked.data = data
		self.dt.hooked.data.caught = os.time()
		self.dt.hooked.data.owner = self.bobber.rod:GetPlayer():Nick()
		
		entitytype:SetPos(self:GetPos())
		entitytype:SetOwner(self)
		entitytype.is_catch = true
		if entitytype:IsNPC() then
			entitytype.oldmovetype = entitytype:GetMoveType()
			entitytype:SetMoveType(MOVETYPE_NONE)
			entitytype:SetParent(self)
		else
			constraint.Weld(entitytype, self, 0, 0, data.force or 2000)
		end
		fishingmod.SetClientInfo(entitytype)
	else
		local random_entity = data.type
		local entity = ents.Create(entitytype or random_entity or "")
		if not IsValid(entity) then
			entity = ents.Create("prop_physics")
			entity:SetModel(entitytype or random_entity or "error.mdl")
		end
		entity.data = data
		entity.data.caught = os.time()
		entity.data.owner = self.bobber.rod:GetPlayer():Nick()
		entity:SetPos(self:GetPos())
		entity:SetOwner(self)
		entity:Spawn()
		if entity:IsNPC() then
			entity:SetParent(self)
			entity.oldmovetype = entity:GetMoveType()
			entity:SetMoveType(MOVETYPE_NONE)
		else
			constraint.Weld(entity, self, 0, 0, data.force or 2000)
		end
		self.dt.hooked = entity
		self.dt.hooked:SetNWString("fishingmod friendly", data.friendly or "Unknown")
		self.dt.hooked:SetNWBool("fishingmod catch", true)
		self.dt.hooked:SetNWFloat("fishingmod size", data.size)
		self.dt.hooked.remove_on_release = data.remove_on_release
		self.dt.hooked.is_catch = true
		fishingmod.SetClientInfo(entity)
	end
end

function ENT:GetHookedEntity()
	return IsValid(self.dt.hooked) and self.dt.hooked or false
end

function ENT:UnHook()
	if IsValid(self.dt.hooked) then
		if self.dt.hooked.remove_on_release then
			self.remove_on_release = self.dt.hooked
		end
		self.dt.hooked:SetOwner()
		if self.dt.hooked:IsNPC() then
			self.dt.hooked:SetAngles(Angle(0))
			self.dt.hooked:SetMoveType(self.dt.hooked.oldmovetype)
			self.dt.hooked:SetParent()
		else
			constraint.RemoveConstraints(self.dt.hooked, "Weld")
		end
		self.dt.hooked = nil
	end
end

function ENT:OnRemove()
	if IsValid(self.dt.hooked) then
		self.dt.hooked:SetParent()
	end
	self.physical_rope:Remove()
end

function ENT:Think()
	if self.dt.hooked.remove_on_release then
		self.remove_on_release = self.dt.hooked
	end
	if not constraint.FindConstraint(self.dt.hooked, "Weld") and not self.dt.hooked:IsNPC() then
		self.dt.hooked = nil
	end
	if self.dt.hooked and not IsValid(self.dt.hooked) then
		self.dt.hooked = nil
	end
	if IsValid(self.remove_on_release) and not self.dt.hooked then
		if self.remove_on_release:WaterLevel() >= 1 then
			local effect_data = EffectData()
			effect_data:SetOrigin(self.remove_on_release:GetPos())
			effect_data:SetScale(self.remove_on_release:BoundingRadius())
			util.Effect("gunshotsplash", effect_data)
			self.remove_on_release:Remove()
		end
	end
	self:NextThink(CurTime())
	return true
end