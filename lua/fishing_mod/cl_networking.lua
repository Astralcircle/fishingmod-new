fishingmod.InfoTable = fishingmod.InfoTable or {}
fishingmod.InfoTable.Catch = fishingmod.InfoTable.Catch or {}
fishingmod.InfoTable.Bait = fishingmod.InfoTable.Bait or {}

local function FriedToFriendly(number)
	if number == 0 then
		return "вообще не приготовленный"
	elseif number < 200 then
		return "очень слабо прожаренный"
	elseif number < 300 then
		return "слабой прожарки"
	elseif number < 500 then
		return "средней прожарки"
	elseif number < 600 then
		return "почти прожаренный"
	elseif number < 700 then
		return "прожаренный"
	elseif number < 900 then
		return "почти сгорел" 
	elseif number <= 1000 then
		return "сгорел"
	end
end

net.Receive("Fishingmod:BaitPrices", function()
	local name = net.ReadString()
	local multiplier = net.ReadFloat()
	if not fishingmod.BaitTable[name] then return end
	fishingmod.BaitTable[name].multiplier = multiplier
	if fishingmod.UpdateSales then
		fishingmod.UpdateSales()
	end
end)


local function UpdatePlayer(ply) 
	
	local exp = net.ReadDouble()
	local catch = net.ReadDouble()
	local money = net.ReadDouble()
	local length = net.ReadInt(16)
	local reel_speed = net.ReadInt(16)
	local string_length = net.ReadInt(16)
	local force = net.ReadInt(16)
	local spawned = net.ReadBool()
	ply.fishingmod = ply.fishingmod or {}
	if not ply.fishingmod then return end
	ply.fishingmod.length = length
	ply.fishingmod.reel_speed = reel_speed
	ply.fishingmod.string_length = string_length
	ply.fishingmod.force = force
	
	ply.fishingmod.money = money
	ply.fishingmod.level = fishingmod.ExpToLevel(exp)
	ply.fishingmod.last_level = ply.fishingmod.level
	ply.fishingmod.percent = fishingmod.PercentToNextLevel(exp)
	ply.fishingmod.expleft = fishingmod.ExpLeft(exp)
	ply.fishingmod.exp = exp
	ply.fishingmod.catches = catch

	if ply.fishingmod.level ~= 0 and ply.fishingmod.last_level ~= ply.fishingmod.level and not spawned then
		ply:EmitSound("ambient/levels/canals/windchime2.wav", 100, 200)
	end
end

local function UpdatePlayerWait(ply,time)
	if time<CurTime() then return end
	if IsValid(ply) and ply:IsPlayer() then
		ply.fishingmod = ply.fishingmod or {}
		if ply.fishingmod then
			--print("Delayed update",ply)
			UpdatePlayer(ply)
			return
		end
	end
	timer.Simple(0.5,function() 
		UpdatePlayerWait(ply,time)
	end)
end

net.Receive("Fishingmod:Player", function() 
	local ply = net.ReadEntity()
	if not IsValid(ply) or not ply:IsPlayer() or not ply.fishingmod then
		UpdatePlayerWait(ply,CurTime()+5)
	end
	UpdatePlayer(ply)
end)

net.Receive("Fishingmod:Catch", function() 
	local entity = net.ReadInt(16)
	local friendly = net.ReadString()
	local caught = net.ReadInt(32)
	local owner = net.ReadString()
	local fried = net.ReadInt(16)
	local value = net.ReadInt(32)
	
	value = value == 0 and "????" or value
	if(UndercorateNick) then
		owner = UndercorateNick(owner)
	elseif(EasyChat) then
		owner = ec_markup.Parse(owner):GetText()
	end
	fishingmod.InfoTable.Catch[entity] = {
		friendly = friendly,
		caught = caught,
		owner = owner,
		cooked = FriedToFriendly(fried),
		value = value,
	}
	local text = Format([[Этот улов называется %s
и он %s
%s выловил его
{TIME}
Вы можете продать этот улов 
нажав кнопку перезарядки за $%s.]],
	friendly,
	FriedToFriendly(fried),
	owner,
	value
	)
	local time
	if os.prettydate then
		time = (os.prettydate(math.Round((os.time() - caught) / 60) * 60) or "") ..' ago'
	else
		time = string.gsub(os.date("on %A, the $%d of %B, %Y, at %I:%M%p", caught), "$(%d%d)", function(n) return n..STNDRD(tonumber(n)) end)
	end
	local text = string.gsub(text, "{TIME}", time)
	fishingmod.InfoTable.Catch[entity].text = text
end)

net.Receive("Fishingmod:Bait", function() 
	local entity = net.ReadInt(16)
	local owner = net.ReadString()
	
	local ply = game.SinglePlayer() and LocalPlayer() or player.GetByUniqueID(owner)
	
	if not IsValid(ply) then return end

	fishingmod.InfoTable.Bait[entity] = {
		owner = owner,
	}
	local nameparse = ply:Nick()
	if(UndercorateNick) then
		nameparse = UndercorateNick(nameparse)
	elseif(EasyChat) then
		nameparse = ec_markup.Parse(nameparse):GetText()
	end
	local text = Format([[
		This bait is owned by %s.
	]],
	nameparse
	)
	fishingmod.InfoTable.Bait[entity].text = text
end)

hook.Add("Tick", "Fishingmod.CleanInfo:Tick", function()
	for key, value in pairs(fishingmod.InfoTable.Catch) do
		if not IsValid(Entity(key)) then
			fishingmod.InfoTable.Catch[key] = nil
		end
	end
	for key, value in pairs(fishingmod.InfoTable.Bait) do
		if not IsValid(Entity(key)) then
			fishingmod.InfoTable.Bait[key] = nil
		end
	end
end)
