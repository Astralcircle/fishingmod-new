fishingmod.AddCatch{
	friendly = "Annoying Country Radio",
	type = "fishing_mod_catch_annoying_radio",
	rareness = 1000, 
	yank = 100, 
	mindepth = 100, 
	maxdepth = 20000,
	expgain = 25,
	levelrequired = 2,
	remove_on_release = false,
	value = 50,
	bait = {
		"models/props_radiostation/radio_antenna01_stay.mdl",
		--"models/props_misc/antenna03.mdl",
	},
}

fishingmod.AddCatch{
	friendly = "Random Radio",
	type = "fishing_mod_catch_radio",
	rareness = 2000, 
	yank = 100, 
	mindepth = 100, 
	maxdepth = 20000,
	expgain = 50,
	levelrequired = 2,
	remove_on_release = false,
	value = 50,
	bait = {
		"models/props_radiostation/radio_antenna01_stay.mdl",
		--"models/props_misc/antenna03.mdl",
	},
}


local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"



if SERVER then

	function ENT:Initialize()

		self:SetModel("models/props_lab/citizenradio.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self.sound = CreateSound(self, "ambient/music/country_rock_am_radio_loop.wav")
		self.sound:SetSoundLevel(150)
		self.sound:ChangeVolume(500)
		self.sound:Play()
		self.sound:ChangePitch(math.random(100,110))
	end

	function ENT:Use()
		self.sound:Play()
		self.sound:ChangePitch(math.random(100,110))
	end

	function ENT:OnTakeDamage()
		self.sound:Play()
		self.sound:ChangePitch(math.random(100,110))
		self.shot = 100
	end

	function ENT:Think()
	
		if self.shot and self.shot <=100 then
			for key, entity in pairs(ents.FindInSphere(self:GetPos(), 20)) do
				if entity:GetModel() and string.find(entity:GetModel():lower(), "wrench") then
					local effectdata = EffectData()
					effectdata:SetOrigin( self:GetPos() + (self:GetUp() * 5) )
					effectdata:SetMagnitude( 4 )
					effectdata:SetScale( 1 )
					effectdata:SetRadius( 1 ) 
					util.Effect( "Sparks", effectdata )
					entity:Remove()
					self.shot = 101
					self.sound:ChangePitch(self.shot)
				end
			end
		end
		
		if self.shot and self.shot <=100 then
			self.shot = math.Clamp(self.shot - 1, 0, 255)
			self.sound:ChangePitch(self.shot)
		end
		self:NextThink(CurTime())
		return true
	end

	function ENT:OnRemove()
		self.sound:Stop()
	end
	
end

scripted_ents.Register(ENT, "fishing_mod_catch_annoying_radio", true)

local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

if SERVER then

	function ENT:Initialize()
		local musics = {"ambient/guit1.wav",
		"ambient/Opera.wav",
		"ambient/music/bongo.wav",
		"ambient/music/country_rock_am_radio_loop.wav",
		"ambient/music/cubanmusic1.wav",
		"ambient/music/dustmusic1.wav",
		"ambient/music/dustmusic2.wav",
		"ambient/music/dustmusic3.wav",
		"ambient/music/flamenco.wav",
		"ambient/music/latin.wav",
		"ambient/music/mirame_radio_thru_wall.wav",
		"ambient/music/piano1.wav",
		"ambient/music/piano2.wav",
		{"ui/gamestartup1.mp3",70},
		{"ui/gamestartup2.mp3",241},
		{"ui/gamestartup3.mp3",37},
		{"ui/gamestartup4.mp3",136},
		{"ui/gamestartup5.mp3",84},
		{"ui/gamestartup6.mp3",102},
		{"ui/gamestartup7.mp3",100},
		{"ui/gamestartup8.mp3",111},
		{"ui/gamestartup9.mp3",89},
		{"music/VLVX_song22.mp3",194},
		{"music/VLVX_song23.mp3",166},
		{"music/VLVX_song24.mp3",127},
		{"music/portal_4000_degrees_kelvin.mp3",61},
		{"music/portal_still_alive.mp3",176}
		}
		self:SetModel("models/props_lab/citizenradio.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		local song = table.Random(musics)
		if type(self.song) == "table" then
			self.Restart = CurTime() + self.song[2]
			self.Duration = self.song[2]
			self.song = self.song[1]
		end
		self.sound = CreateSound(self, self.song)
		self.sound:SetSoundLevel(150)
		self.sound:ChangeVolume(500)
		self.sound:Play()
		self.sound:ChangePitch(math.random(100,110))
	end

	function ENT:Use()
		self.sound:Play()
		self.sound:ChangePitch(math.random(100,110))
	end

	function ENT:OnTakeDamage()
		self.sound:Play()
		self.sound:ChangePitch(math.random(100,110))
		self.shot = 100
		if self.Duration then self.Remaining = self.Restart - CurTime() end
	end

	function ENT:Think()
	
		if self.shot and self.shot <=100 then
			for key, entity in pairs(ents.FindInSphere(self:GetPos(), 20)) do
				if entity:GetModel() and string.find(entity:GetModel():lower(), "wrench") then
					local effectdata = EffectData()
					effectdata:SetOrigin( self:GetPos() + (self:GetUp() * 5) )
					effectdata:SetMagnitude( 4 )
					effectdata:SetScale( 1 )
					effectdata:SetRadius( 1 ) 
					util.Effect( "Sparks", effectdata )
					entity:Remove()
					self.shot = 101
					self.sound:ChangePitch(self.shot)
					self.Restart = CurTime() + self.Remaining
				end
			end
		end
		
		if self.shot and self.shot <=100 then
			self.shot = math.Clamp(self.shot - 1, 0, 255)
			self.sound:ChangePitch(self.shot)
		end
		//print(self.Restart - CurTime())
		if (!self.shot or self.shot > 100) and self.Restart and self.Restart <= CurTime() then
			//print("Restart")
			self.sound:Stop()
			self.sound:Play()
			self.Restart = CurTime() + self.Duration
		end
		self:NextThink(CurTime())
		return true
	end

	function ENT:OnRemove()
		self.sound:Stop()
	end
	
end

scripted_ents.Register(ENT, "fishing_mod_catch_radio", true)





