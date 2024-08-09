function fishingmod.DefaultUIColors()
	return {
		["ui_text"] = Color(255, 255, 255, 255),
		["ui_text_caught"] = Color(0, 255, 0, 255),
		["ui_text_bg"] = Color(160, 160, 160, 255),
		["ui_button_selected"] = Color(0, 0, 0, 144),
		["ui_button_deselected"] = Color(0, 0, 0, 72),
		["ui_button_hovered"] = Color(120, 120, 120, 144),
		["ui_button_pressed"] = Color(0, 0, 0, 50),
		["ui_background"] = Color(0, 0, 0, 225),
		["xp_bar_fg"] = Color(0, 200, 0, 255),
		["xp_bar_bg"] = Color(255, 255, 255, 55),
		["xp_bar_text"] = Color(0, 0, 0, 255),
		["crosshair_color"] = Color(255,255,255,127),
	}
end
local translation = {
	["ui_text"] = "General Text",
	["ui_text_caught"] = "Catch Text",
	["ui_text_bg"] = "Background Text",
	["ui_button_selected"] = "Selected Button",
	["ui_button_deselected"] = "Button De-selected",
	["ui_button_hovered"] = "Button Hovered",
	["ui_button_pressed"] = "Button Pressed",
	["ui_background"] = "Background",
	["xp_bar_fg"] = "XP Bar Foreground",
	["xp_bar_bg"] = "XP Bar Background",
	["xp_bar_text"] = "XP Bar Text",
	["crosshair_color"] = "Crosshair",
 -- both ways
	["General Text"] = "ui_text",
	["Catch Text"] = "ui_text_caught",
	["Background Text"] = "ui_text_bg",
	["Selected Button"] = "ui_button_selected",
	["Button De-selected"] = "ui_button_deselected",
	["Button Hovered"] = "ui_button_hovered",
	["Button Pressed"] = "ui_button_pressed",
	["Background"] = "ui_background",
	["XP Bar Foreground"] = "xp_bar_fg",
	["XP Bar Background"] = "xp_bar_bg",
	["XP Bar Text"] = "xp_bar_text",
	["Crosshair"] = "crosshair_color",
}
local fishingmod_data_path, fishingmod_data_file_name = "fishingmod", "/ui_color_data.txt"
function fishingmod.SaveUIColors()
    if not file.Exists(fishingmod_data_path, "DATA") then
        file.CreateDir(fishingmod_data_path)
	end
	local new_data = {}
	local return_data = fishingmod.DefaultUIColors()
	if fishingmod.ColorTable then
		for k, v in pairs(fishingmod.ColorTable) do
			new_data[k] = tostring(v.r) .. " " .. tostring(v.g) .. " " .. tostring(v.b) .. " ".. tostring(v.a)
		end
		table.Merge(return_data, new_data)
	end
	file.Write(fishingmod_data_path .. fishingmod_data_file_name, util.TableToJSON(return_data, false))
	new_data = nil
end

function fishingmod.LoadUIColors()
	return fishingmod.DefaultUIColors()
end

fishingmod.ColorTable = fishingmod.LoadUIColors()


if not fishingmod.ColorTable then
	fishingmod.ColorTable = fishingmod.DefaultUIColors()
end

local fishingmod_sprite_minus, a = Material("sprites/key_13")
local fishingmod_sprite_plus, a = Material("sprites/key_12")
fishingmod_sprite_minus:SetInt("$flags", 2097152)
fishingmod_sprite_plus:SetInt("$flags", 2097152)

local col_green = Color(0, 255, 0)
local col_white = Color(255, 255, 255)

local margin = 3

local background = fishingmod.DefaultUIColors().ui_background
local ui_text = fishingmod.DefaultUIColors().ui_text
local button_not_selected = fishingmod.DefaultUIColors().ui_text_bg
local ui_button_hovered = fishingmod.DefaultUIColors().ui_button_hovered
local nopres = fishingmod.DefaultUIColors().ui_button_deselected
local pres = fishingmod.DefaultUIColors().ui_button_pressed
local master_x, master_y = 354, 224

local PANEL = {} -- Main panel

function PANEL:Init()
	if fishingmod.ColorTable then
		background = fishingmod.ColorTable.ui_background or background
		ui_text = fishingmod.ColorTable.ui_text or ui_text
		button_not_selected = fishingmod.ColorTable.ui_text_bg or button_not_selected
		ui_button_hovered = fishingmod.ColorTable.ui_button_hovered or ui_button_hovered
		nopres = fishingmod.ColorTable.ui_button_deselected or nopres
		pres = fishingmod.ColorTable.ui_button_pressed or pres
	end
	self:MakePopup()
	self:SetDeleteOnClose(false)
	self:SetSizable(true)
	self:SetTitle("Рыбалка")
	self.lblTitle:SetTextColor(ui_text)
	self:ShowCloseButton(false)
	self:SetSize(master_x, master_y)
	self:Center()

	self.baitshop = vgui.Create("Fishingmod:BaitShop", self)
	
	fishingmod.BaitIcons = self.baitshop:GetItems()
	
	self.upgrade = vgui.Create("Fishingmod:Upgrade", self)

	self.convertation = vgui.Create("Fishingmod:Customization", self)

	local xpx, xpy = self:GetSize()

	local upgrades_button = vgui.Create("DButton", self) -- upgrades
	local baits_button = vgui.Create("DButton", self) -- baits shop
	local convertation_button = vgui.Create("DButton", self) -- customization tab

	upgrades_button.selected = true
	baits_button.selected = false
	upgrades_button:SetPos(margin, 24)
	upgrades_button:SetSize((xpx - margin * 2) / margin, 22)
	upgrades_button:SetText("Улучшения")
	function upgrades_button.Think()
		xpx, xpy = self:GetSize()
		upgrades_button:SetSize((xpx - margin * 2) / margin, 22)
	end
	upgrades_button:SetTextColor(ui_text)
	upgrades_button.DoClick = function()
		upgrades_button:SetColor(ui_text)
		baits_button:SetColor(nopres)
		convertation_button:SetColor(nopres)

		baits_button:SetTextColor(button_not_selected)
		convertation_button:SetTextColor(button_not_selected)

		upgrades_button.selected = true
		baits_button.selected = false
		convertation_button.selected = false

		self.convertation:Hide()
		self.upgrade:Show()
		self.baitshop:Hide()
	end
	upgrades_button.Paint = function(self, w, h)
		if self.selected then
			upgrades_button:SetColor(ui_text)
		elseif not self.selected then
			upgrades_button:SetColor(button_not_selected)
		end
		if upgrades_button:IsHovered() then
			surface.SetDrawColor(background.r, background.g, background.b, background.a)
		elseif upgrades_button.selected then
			surface.SetDrawColor(background.r, background.g, background.b, background.a)
		else
			surface.SetDrawColor(nopres.r, nopres.g, nopres.b, nopres.a)
		end
		surface.DrawRect(0, 0, w, h)
	end

	baits_button:SetPos(margin + (xpx - margin * 2) / margin, 24) -- baits shop start of conf
	baits_button:SetSize((xpx - margin * 2) / margin, 22)
	function baits_button.Think()
		xpx, xpy = self:GetSize()
		baits_button:SetSize((xpx - margin * 2) / margin, 22)
		baits_button:SetPos(margin + (xpx - margin * 2) / margin, 24)
	end
	baits_button:SetText("Магазин наживок")
	baits_button:SetTextColor(button_not_selected)
	baits_button.DoClick = function()
		baits_button:SetColor(ui_text)
		upgrades_button:SetColor(nopres)
		convertation_button:SetColor(nopres)

		upgrades_button:SetTextColor(button_not_selected)
		convertation_button:SetTextColor(button_not_selected)

		upgrades_button.selected = false
		baits_button.selected = true
		convertation_button.selected = false

		self.convertation:Hide()
		self.upgrade:Hide()
		self.baitshop:Show()
	end
	baits_button.Paint = function(self, w, h)
		if self.selected then
			baits_button:SetColor(ui_text)
		elseif not self.selected then
			baits_button:SetColor(button_not_selected)
		end
		if baits_button:IsHovered() then
			surface.SetDrawColor(background.r, background.g, background.b, background.a)
		elseif baits_button.selected then
			surface.SetDrawColor(background.r, background.g, background.b, background.a)
		else
			surface.SetDrawColor(nopres.r, nopres.g, nopres.b, nopres.a)
		end
		surface.DrawRect(0, 0, w, h)
	end


	convertation_button:SetPos(margin + (xpx - margin * 2) / margin, 24) -- baits shop start of conf
	convertation_button:SetSize((xpx - margin * 2) / margin, 22)
	
	function convertation_button.Think()
		xpx, xpy = self:GetSize()
		if xpx % margin == 2 then -- odd widths
			convertation_button:SetSize(math.Round((xpx - margin * 2) / margin) + 1 , 22)
			convertation_button:SetPos(margin - 1 + (xpx - margin * 2) / margin * 2 , 24)
		elseif xpx % margin == 1  then
			convertation_button:SetSize(math.Round((xpx - margin * 2) / margin) + 1, 22)
			convertation_button:SetPos(margin + (xpx - margin * 2) / margin * 2 , 24)
		else
			convertation_button:SetSize(math.Round((xpx - margin * 2) / margin) , 22)
			convertation_button:SetPos(margin + (xpx - margin * 2) / margin * 2 , 24)
		end
	end
	convertation_button:SetText("Обмен")
	convertation_button:SetTextColor(button_not_selected)
	convertation_button.DoClick = function()
		convertation_button:SetColor(ui_text)
		upgrades_button:SetColor(nopres)
		baits_button:SetColor(nopres)

		upgrades_button:SetTextColor(button_not_selected)
		baits_button:SetTextColor(button_not_selected)

		upgrades_button.selected = false
		baits_button.selected = false
		convertation_button.selected = true

		self.convertation:Show()
		self.upgrade:Hide()
		self.baitshop:Hide()

	end
	convertation_button.Paint = function(self, w, h)
		if self.selected then
			convertation_button:SetColor(ui_text)
		elseif not self.selected then
			convertation_button:SetColor(button_not_selected)
		end
		if(convertation_button:IsHovered()) then
			surface.SetDrawColor(background.r, background.g, background.b, background.a)
		elseif(convertation_button.selected) then
			surface.SetDrawColor(background.r, background.g, background.b, background.a)
		else
			surface.SetDrawColor(nopres.r, nopres.g, nopres.b, nopres.a)
		end
		surface.DrawRect(0, 0, w, h)
	end


	function self:Paint()
		surface.SetTextColor(ui_text.r, ui_text.g, ui_text.b, ui_text.a)
		surface.SetDrawColor(background.r, background.g, background.b, background.a)
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
		return true
	end
	local close_button = vgui.Create("DButton", self)
	local x, y = self:GetSize()
	close_button.ButtonW = 60
	close_button:SetSize(close_button.ButtonW, 18)
	close_button:SetText("Закрыть")
	close_button:SetTextColor(ui_text)
	close_button:SetPos(x - close_button.ButtonW - margin, margin)
	close_button.DoClick = function()
		self:Close()
	end
	function self:OnSizeChanged(x, y)
		close_button:SetPos(math.max(x - close_button.ButtonW - margin, margin), margin)
		close_button:SetSize(math.min(close_button.ButtonW, x - margin * 2) , 18 )
	end
	close_button.Paint = function(self, w, h)
		self:GetParent().lblTitle:SetTextColor(ui_text)
		close_button:SetTextColor(ui_text)
		if(close_button:IsDown() ) then
			surface.SetDrawColor(pres.r, pres.g, pres.b, pres.a)
		elseif(close_button:IsHovered()) then
			surface.SetDrawColor(ui_button_hovered.r, ui_button_hovered.g, ui_button_hovered.b, ui_button_hovered.a)
		else
			surface.SetDrawColor(background.r, background.g, background.b, background.a)
		end
		surface.DrawRect(0, 0, w, h)
	end
	
	function self.baitshop:Paint()
		surface.SetDrawColor(background.r, background.g, background.b, background.a)
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
		return true
	end
	
	fishingmod.UpdateSales()
end

vgui.Register( "Fishingmod:ShopMenu", PANEL, "DFrame" )


-- Upgrade Tab 
local PANEL = {}

function PANEL:Init()
	local x, y = self:GetParent():GetSize()
	self:SetSize(x - margin * 2 , y - margin - 46)
	function self:Think()
		x, y = self:GetParent():GetSize()
		self:SetSize(x - margin * 2, y - margin - 46 )
	end
	self:SetPos(margin, 46)
	self:SetPadding(10)
	function self:Paint()
		surface.SetTextColor(ui_text.r, ui_text.g, ui_text.b, ui_text.a)
		surface.SetDrawColor(background.r, background.g, background.b, background.a)
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
		self.money:SetTextColor(ui_text)
		return true
	end

	self.money = vgui.Create("DLabel", self)
	self.money:SetTextColor(ui_text)
	self.money.Think = function(self) self:SetText("Деньги: " .. math.Round(LocalPlayer().fishingmod.money)) end
	
	self:AddItem(self.money)
	
	self.length = vgui.Create("Fishingmod:UpgradeButton", self)
	self.length:SetType("Длинна удочки:", "length", "rod_length", fishingmod.RodLengthPrice)

	self:AddItem(self.length)
	
	self.stringlength = vgui.Create("Fishingmod:UpgradeButton", self)
	self.stringlength:SetType("Длинна лески:", "string_length", "string_length", fishingmod.StringLengthPrice)

	self:AddItem(self.stringlength)
	
	self.reelspeed = vgui.Create("Fishingmod:UpgradeButton", self)
	self.reelspeed:SetType("Скорость катушки:", "reel_speed", "reel_speed", fishingmod.ReelSpeedPrice)
	self:AddItem(self.reelspeed)
	
	self.force = vgui.Create("Fishingmod:UpgradeButton", self)
	self.force:SetType("Сила крюка:", "force", "hook_force", fishingmod.HookForcePrice)
	self:AddItem(self.force)
end

vgui.Register("Fishingmod:Upgrade", PANEL, "DPanelList")
	
	
	
-- Bait Shop tab
local PANEL = {}

function PANEL:Init()
	
	local x, y = self:GetParent():GetSize()
	self:SetSize(x - margin * 2, y - margin - 46)
	function self:Think()
		x, y = self:GetParent():GetSize()
		self:SetSize(x - margin * 2, y - margin - 46)
	end
	self:SetPos(margin, 46)
	self:EnableHorizontal(true)
	self:EnableVerticalScrollbar(true)
	self:SetVisible(false)
	local tol_tab = {}
	local model_seen = {}
	for key, data in pairs(fishingmod.BaitTable) do -- sorting by level required because it was semi-random before
		if(not model_seen[data.models[1]]) then
			model_seen[data.models[1]] = true -- the system is wack so i beat it back
			tol_tab[#tol_tab + 1] = {
				price = data.price,
				name = key,
				model = data.models[1],
				levelrequired = data.levelrequired
			}
		end
	end
	table.SortByMember(tol_tab, "levelrequired", true)

	-- Add baits
	for key, data in pairs(tol_tab) do
		local level = LocalPlayer().fishingmod.level
		local icon = vgui.Create("Fishingmod:SpawnIcon")
		icon:SetModel(data.model)
		icon:SetToolTip("This bait cost " .. data.price .. " and\nit is a_ level " .. data.levelrequired .. " bait.")
		icon:SetSize(58, 58)
		
		fishingmod.BaitTable[data.name].icon = icon
		
		if(level < data.levelrequired) then
			icon:SetGray(true)
		else
			icon.DoClick = function()
				RunConsoleCommand("fishing_mod_buy_bait", data.name)
			end
		end
		self:AddItem(icon)
	end
		
end

vgui.Register("Fishingmod:BaitShop", PANEL, "DPanelList")


-- Customization tab
local PANEL = {}

function PANEL:Init()
	local x, y = self:GetParent():GetSize()
	self:SetSize(x - margin * 2, y - margin - 46)
	self:SetPos(margin, 46)
	self:SetVisible(false)
	function self:Think()
		x, y = self:GetParent():GetSize()
		self:SetSize(x - margin * 2, y - margin - 46)
		if fishingmod.ColorTable then
			background = fishingmod.ColorTable.ui_background or background
			ui_text = fishingmod.ColorTable.ui_text or ui_text
			button_not_selected = fishingmod.ColorTable.ui_text_bg or button_not_selected
			ui_button_hovered = fishingmod.ColorTable.ui_button_hovered or ui_button_hovered
			nopres = fishingmod.ColorTable.ui_button_deselected or nopres
			pres = fishingmod.ColorTable.ui_button_pressed or pres
		else
			fishingmod.ColorTable = fishingmod.DefaultUIColors()
		end
	end

	self.helptext = vgui.Create("DLabel", self)
	self.helptext:SetText("Обменник поинтов рыбалки на обычные поинты!")
	self.helptext:SetContentAlignment(5)
	
	self:AddItem(self.helptext)

	---
	
	self.empty = vgui.Create("DPanel", self)

	function self.empty:Paint() return true end

	local fishpoints = vgui.Create("DTextEntry", self.empty)
	local classicpoints = vgui.Create("DTextEntry", self.empty)

	fishpoints:Dock(LEFT)
	fishpoints.AllowInput = function(self, text)
		if not string.match(text, "%d") then
			return true
		end

		timer.Simple(0, function()
			classicpoints:SetValue(math.floor(tonumber(self:GetValue()) / 500))
		end)
	end

	local tothis = vgui.Create("DLabel", self.empty)

	tothis:Dock(FILL)
	tothis:SetText(">>>")
	tothis:SetContentAlignment(5)

	classicpoints:Dock(RIGHT)
	classicpoints.AllowInput = function(self, text)
		if not string.match(text, "%d") then
			return true
		end

		timer.Simple(0, function()
			fishpoints:SetValue(math.floor(tonumber(self:GetValue()) * 500))
		end)
	end

	self:AddItem(self.empty)

	do
		self.helppanel = vgui.Create("DPanel", self)

		function self.helppanel:Paint() return true end
	
		local firsthelp = vgui.Create("DLabel", self.helppanel)
	
		firsthelp:Dock(LEFT)
		firsthelp:SetText("Отдадите")
		firsthelp:SetContentAlignment(5)
	
		local twohelp = vgui.Create("DLabel", self.helppanel)
	
		twohelp:Dock(RIGHT)
		twohelp:SetText("Получите")
		twohelp:SetContentAlignment(5)
	
		self:AddItem(self.helppanel)
	end

	self.convertbutton = vgui.Create("DButton", self)
	self.convertbutton:SetText("Обменять")

	function self.convertbutton:OnMousePressed(keycode)
		if keycode ~= MOUSE_LEFT then return end

		net.Start("Fishingmod:ConvertPoints")
		net.WriteInt(fishpoints:GetValue(), 32)
		net.SendToServer()
	end

	self.convertbutton.Paint = function(self, w, h)
		self:SetTextColor(ui_text)
		if self:IsDown() then
			surface.SetDrawColor(pres.r, pres.g, pres.b, pres.a)
		elseif self:IsHovered() then
			surface.SetDrawColor(ui_button_hovered.r, ui_button_hovered.g, ui_button_hovered.b, ui_button_hovered.a)
		else
			surface.SetDrawColor(background.r, background.g, background.b, background.a)
		end
		surface.DrawRect(0, 0, w, h)
	end	

	self:AddItem(self.convertbutton)
end

vgui.Register("Fishingmod:Customization", PANEL, "DPanelList")




------------- Helper components --------------
	
-- Upgrade button
local PANEL = {}

function PANEL:Init()
	self.left = vgui.Create("DButton", self)
	self.left:SetSize(24, 20)
	self.left:SetTooltip("+0")
	self.left.DoClick = function()
		RunConsoleCommand("fishingmod_downgrade_"..self.command, "1")
	end
	
	self.right = vgui.Create("DButton", self)
	self.right:SetSize(24, 20)
	self.right.DoClick = function()
		RunConsoleCommand("fishingmod_upgrade_"..self.command, "1")
	end
	
	self.rightlabel = vgui.Create("DLabel", self)
	self.rightlabel:SetTextColor(ui_text)
	self.rightlabel:SetSize(100, 30)
	
	self.leftlabel = vgui.Create("DLabel", self)
	self.leftlabel:SetTextColor(ui_text)
	self.leftlabel:SetSize(100, 30)
	
	self.left:Dock(LEFT)
	self.leftlabel:SetPos(30, - 2)
	self.rightlabel:SetPos(130, - 2)
	self.right:Dock(RIGHT)
	local selfleft = self.left
	function self.left:Paint() -- 'sell' skill button
		surface.SetFont("DebugFixed")
		surface.SetTextColor(ui_text.r, ui_text.g, ui_text.b, ui_text.a)
		if(selfleft:IsDown()) then
			surface.SetDrawColor(pres.r, pres.g, pres.b, pres.a)
		elseif(selfleft:IsHovered()) then
			surface.SetDrawColor(ui_button_hovered.r, ui_button_hovered.g, ui_button_hovered.b, ui_button_hovered.a)
		else
			surface.SetDrawColor(0, 0, 0, 100)
		end
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
		surface.SetDrawColor(ui_text)
		surface.SetMaterial(fishingmod_sprite_minus)
		surface.DrawTexturedRect(1, 1, self:GetWide() - 2, self:GetTall() - 2)
		return true
	end
	local selfright = self.right
	function self.right:Paint() -- buy skill button
		surface.SetFont("DebugFixed")
		surface.SetTextColor(ui_text.r, ui_text.g, ui_text.b, ui_text.a)

		if(selfright:IsDown()) then
			surface.SetDrawColor(pres.r, pres.g, pres.b, pres.a)
		elseif(selfright:IsHovered()) then
			surface.SetDrawColor(ui_button_hovered.r, ui_button_hovered.g, ui_button_hovered.b, ui_button_hovered.a)
		else
			surface.SetDrawColor(0, 0, 0, 100)
		end
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
		surface.SetDrawColor(ui_text)
		surface.SetMaterial(fishingmod_sprite_plus)
		surface.DrawTexturedRect(1, 1, self:GetWide() - 2, self:GetTall() - 2)
		return true
	end
end

function PANEL:SetType(friendly, type, command, loss)
	self.friendly = friendly
	self.command = command
	self.type = type
	self.right:SetTooltip("-"..loss)
	self.set = true
	self.leftlabel:SetText(self.friendly)
end

function PANEL:Think()
	if not self.set then return end
	self.rightlabel:SetTextColor(ui_text)
	self.leftlabel:SetTextColor(ui_text)
	self.rightlabel:SetText(LocalPlayer().fishingmod[self.type])
end

vgui.Register("Fishingmod:UpgradeButton", PANEL)


-- Markup Tooltip
local PANEL = {}

function PANEL:Init()
	self.percent = 0
end

function PANEL:SetSale(multiplier)
	self.percent = math.Round((-multiplier + 1) * 100)
end

function PANEL:SetGray(bool)
	self.Grey = bool
end

function PANEL:PaintOver(w, h)
	self.BaseClass.PaintOver(self, w, h)

	draw.SimpleText( self.percent.."% OFF", "DermaDefault", 5, 3, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
	draw.SimpleText( self.percent.."% OFF", "DermaDefault", 4, 2, HSVToColor(math.Clamp(self.percent + 40, 0, 160), 1, 1), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
	if self.Grey then draw.RoundedBox( 6, 0, 0, 58, 58, Color( 100, 100, 100, 200 ) ) end
end

vgui.Register("Fishingmod:SpawnIcon", PANEL, "SpawnIcon")




function fishingmod.UpdateSales()
	for key, bait in pairs(fishingmod.BaitTable) do
		local levelrequired = fishingmod.CatchTable[key].levelrequired
		local saleprice = math.Round(bait.price * bait.multiplier)
		local sale = "Эта наживка сейчас стоит " .. math.Round(bait.price * bait.multiplier) .. "!\nЕё первоначальная цена " .. bait.price .. "."
		
		if saleprice == 0 then
			sale = "Эта наживка бесплатна! "
		end
		
		if IsValid(bait.icon) then
			bait.icon:SetToolTip(sale .. "\nВам нужно иметь уровень " .. levelrequired .. " или выше чтобы использовать эту наживку.")
			bait.icon:SetSale(bait.multiplier)
		end
	end
end
