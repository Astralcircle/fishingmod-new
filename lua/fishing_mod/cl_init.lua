fishingmod = fishingmod or {}

surface.CreateFont("fixed_height_font", {
	font = "Verdana",
	extended = false,
	size = 13,
	weight = 3000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont("fixed_name_font", {
	font = "Verdana",
	extended = false,
	size = 15,
	weight = 3000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
})

include("cl_networking.lua")
include("cl_shop_menu.lua")

fishingmod.ColorTable = fishingmod.LoadUIColors()
fishingmod.CatchTable = {}

function fishingmod.AddCatch(data)
	data.value = data.value or 0
	fishingmod.CatchTable[data.friendly] = data
end

function fishingmod.RemoveCatch(name)
	fishingmod.CatchTable[name] = nil
end

for _, name in ipairs(file.Find("fishing_mod/catch/*.lua", "LUA")) do
	include("fishing_mod/catch/" .. name)
end

hook.Add("InitPostEntity", "Init Fish Mod", function()
	RunConsoleCommand("fishing_mod_request_init")
	
	FMOldCalcVehicleThirdPersonView = FMOldCalcVehicleThirdPersonView or GAMEMODE.CalcVehicleThirdPersonView

	function GAMEMODE:CalcVehicleThirdPersonView(vehicle, ply, position, angles, fov)
		if ply:GetFishingRod() and IsValid(ply:GetNWEntity("weapon seat")) then
			local eyeangles = ply:EyeAngles()
			local view = {}

			view.origin = ply:GetShootPos() + 
				(eyeangles:Right() * 50) + 
				(Angle(0, eyeangles.y, 0):Forward() * -150) + 
				(Angle(0, 0, eyeangles.z):Up() * 20)
			
			
			view.angles = Angle(math.Clamp(eyeangles.p -30, -70, 15), eyeangles.y, 0)		
			
			return view
		end

		return FMOldCalcVehicleThirdPersonView(self, vehicle, ply, position, angles, fov)
	end
end)

local ui_text = fishingmod.DefaultUIColors().ui_text
local bg = fishingmod.DefaultUIColors().ui_background
local crosshair = fishingmod.DefaultUIColors().crosshair_color

hook.Add("HUDPaint", "Fishingmod:HUDPaint", function()
	local entity = LocalPlayer():GetEyeTrace().Entity

	if IsValid(entity) then
		local fmredirect = entity:GetNWEntity("FMRedirect")

		if IsValid(fmredirect) then
			entity = fmredirect
		else
			entity = nil
		end
	else
		entity = nil
	end

	if entity ~= nil then
		local xy = (entity:LocalToWorld(entity:OBBCenter())):ToScreen()
		local text_height, text_width
		local pad = 3

		xy_x = xy.x
		xy_y = math.min(math.max(64, xy.y), ScrH() - 64)
			
		if (entity:GetPos() - LocalPlayer():GetShootPos():Length()) < 120 then
			local entindex = entity:EntIndex()
			local data = fishingmod.InfoTable.Catch[entindex]

			if data then
				local data_text = data.text

				if data_text then
					data_text = string.Replace(string.Replace(data_text, "\t", ""), "  ", " ")
					surface.SetFont("fixed_height_font")
					surface.SetDrawColor(ui_text.r, ui_text.g, ui_text.b, ui_text.a)
	
					text_height, text_width = surface.GetTextSize(data_text)
					text_height, text_width = text_height + 8, text_width + 8
	
					surface.SetDrawColor(bg.r, bg.g, bg.b, bg.a)
					surface.DrawRect(xy_x - text_height / 2 - pad, xy_y - text_width / 2 - 1 - pad, text_height + pad * 2, text_width + pad * 2)
					surface.DrawRect(xy_x - text_height / 2 + 3 - pad, xy_y - text_width / 2 - 1 + 3 - pad, text_height - 6 + pad * 2, text_width - 6 + pad * 2)
	
					draw.DrawText(data_text, "fixed_height_font", xy_x, xy_y - (text_width / 2), ui_text, 1)
				end
			end
				
			data = fishingmod.InfoTable.Bait[entindex]

			if data then
				local data_text = data.text

				if data_text then
					surface.SetFont("fixed_height_font")
					surface.SetDrawColor(bg.r, bg.g, bg.b, bg.a)
	
					text_height, text_width = surface.GetTextSize(string.Replace(string.Replace(data_text, "\t", ""), "\n", ""))
					text_height, text_width = text_height + 8, text_width + 8
	
					surface.DrawRect(xy_x - text_height / 2 - pad, xy_y - text_width / 2 - 1 - pad + 16, text_height + pad * 2, text_width + pad)
					surface.DrawRect(xy_x - text_height / 2 + 3 - pad, xy_y - text_width / 2 + 2 - pad + 16, text_height - 6 + pad * 2, text_width - 6 + pad)
	
					draw.DrawText(string.Replace(data_text, "\t", ""), "fixed_height_font", xy_x, xy_y - (text_width / 2) + 15, ui_text, 1)
				end
			end
		end
	end

	local wep = LocalPlayer():GetActiveWeapon()

	if IsValid(wep) and wep:GetClass() == "weapon_fishing_rod" then
		surface.SetDrawColor(crosshair.r, crosshair.g, crosshair.b, crosshair.a)

		local xy = LocalPlayer():GetEyeTraceNoCursor().HitPos:ToScreen()

		local xy_x = xy.x
		local xy_y = xy.y

		surface.DrawRect( xy_x, xy_y + 5, 1, 10)
		surface.DrawRect( xy_x, xy_y - 14, 1, 10)

		surface.DrawRect( xy_x + 5, xy_y, 10, 1 )
		surface.DrawRect( xy_x - 14, xy_y, 10, 1 )
	end
end)

local force_b = 1

concommand.Add("fishing_mod_b_opens_always", function(ply, cmd, args)
	if isnumber(tonumber(args[1])) then
		force_b = math.Clamp(math.Round(args[1]), 0, 1)
	end
end)

hook.Add("Think", "Fishingmod.Keys:Think", function()
	if LocalPlayer():GetFishingRod() and not vgui.CursorVisible() then
		if input.IsKeyDown(KEY_B) and force_b == 1 then
			local menu = fishingmod.UpgradeMenu

			if IsValid(menu) and not menu:IsVisible() then
				menu:SetVisible(true)
				menu:MakePopup()
			end
		end

		if input.IsKeyDown(KEY_E) then
			RunConsoleCommand("fishing_mod_drop_bait")
		end

		if input.IsKeyDown(KEY_R) then
			RunConsoleCommand("fishing_mod_drop_catch")
		end	
	end
end)

hook.Add("ShouldDrawLocalPlayer", "Fishingmod:ShouldDrawLocalPlayer", function(ply)
	if ply:GetFishingRod() then
		return true
	end
end)

timer.Create("Fishingmod:Tick", 2, 0, function()
	for _, entity in ents.Iterator() do
		if entity:GetNWBool("fishingmod scalable") then
			entity:SetModelScale(entity:GetNWFloat("fishingmod scale", 1), 0)
		end

		local size = entity:GetNWFloat("fishingmod size")

		if entity:GetNWBool("in fishing shelf") and size ~= 0 then
			entity:SetModelScale(size / entity:BoundingRadius(), 0)
		end
	end
end)

local vector_mins = Vector(-4, -4, -4)
local vector_maxs = Vector(4, 4, 4)

hook.Add("CalcView", "Fishingmod:CalcView", function(ply, offset, angles, fov)
	if GetViewEntity() ~= ply then return end

	local fishingRod = ply:GetFishingRod()

	if fishingRod and not ply:InVehicle() then

		local eyeangles = ply:EyeAngles()
		local view = {}

		view.origin		= offset
		view.angles		= angles
		view.fov		= fov

		local startview = ply:GetShootPos() + 
			(eyeangles:Right() * 70) + 
			(Angle(0, eyeangles.y, 0):Forward() * -120 ) +
			(Angle(0, 0, eyeangles.r):Up() * -( 10 + ( 180 - 256 * (math.min(view.angles.p, 150 - 90) + 90) / 180) ))
		
		local fbobber

		if fishingRod.GetBobber ~= nil then
			local bobber = fishingRod:GetBobber()

			if IsValid(bobber) then
				fbobber = bobber
			end
		end

		local fhook

		if fishingRod.GetHook ~= nil then
			local gethook = fishingRod:GetHook()

			if IsValid(gethook) then
				fhook = gethook
			end
		end

		local tr = util.TraceHull({
			start = offset,
			endpos = startview,
			filter = {ply, fishingRod, fbobber, fhook},
			mins = vector_mins,
			maxs = vector_maxs,
		})

		view.origin = tr.HitPos
		view.angles.p = math.Clamp(view.angles.p - 40, -90, 20)

		return view

	end
end)