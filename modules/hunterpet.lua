local _, recUI = ...

local data = {
	["Bread"] = {
		["Basic"] = {4540,4541,4542,4544,4601,8950,16169,19301,19696,20857,23160,24072,27855,28486,29394,29449,30816,33246,33449,35950,38428,42428,42429,42430,42431,42432,42433,42434,42778,44609},
		["Bonus"] = {2683,3666,17197,21254,32721,33043},
		["Combo"] = {13724,19301,34780},
		["Conjured"]	= {1113,1114,1487,5349,8075,8076,22895,22019,34062,43518,43523},
	},
	["Cheese"] = {
		["Basic"] = {414,422,1707,2070,3927,8932,17406,27857,29448,30458,33443,35952,44607,44608,44749},
		["Bonus"] = {3665,12218,34065},
	},
	["Fish"] = {
		["Basic"] = {787,1326,4592,4593,4594,5095,6299,6316,6458,6887,8364,8957,12238,13930,13933,13935,16766,19996,21552,27661,27858,29452,33048,33451,35285,35951,41729,43571,43646,43647,44049,44071},
		["Bonus"] = {5476,5527,12216,13927,13928,13929,13931,13932,13934,16971,21072,21217,27662,27663,27664,27665,27666,27667,30155,33052,33867,34767,34769,39691,42942,42993,42996,42998,42999,43000,43268,43652},
		["Combo"] = {2682,33053,34759,34760,34761,34762,34763,34764,34768,37466},
		["Raw"] 	= {2674,2675,4603,4655,5468,5503,5504,6289,6291,6303,6308,6317,6361,6362,7974,8365,12206,13754,13755,13756,13758,13759,13760,13888,13889,21071,21153,24477,27422,27425,27429,27435,27437,27438,27439,33823,33824,36782,41800,41801,41802,41803,41805,41806,41807,41808,41809,41810,41812,41813,41814},
	},
	["Fruit"] = {
		["Basic"] = {4536,4537,4538,4539,4602,4656,5057,8953,11415,16168,19994,21030,21031,21033,22324,27856,29450,35948,35949,37252,40356,43087},
		["Bonus"] = {11584,11950,13810,20516,24009,32721},
		["Combo"] = {20031,28112},
	},
	["Fungus"] = {
		["Basic"] = {4604,4605,4606,4607,4608,8948,27859,29453,30355,33452,35947,41751},
		["Bonus"] = {18254,24008,24539},
		["Combo"] = {3448},
	},
	["Meat"] = {
		["Basic"] = {117,2287,2679,2681,2685,3770,3771,4599,5478,6807,6890,7097,8952,9681,11444,17119,17407,17408,19223,19224,19304,19305,19306,19995,21235,23495,27854,29451,30610,32685,33254,33454,34747,35794,35953,38427,38706,40202,40358,40359,44072},
		["Bonus"] = {1017,2680,2684,2687,2888,3220,3664,3726,3727,3728,3729,4457,5472,5474,5477,5479,5480,12209,12210,12213,12224,13851,17222,18045,20074,21023,22645,24105,27635,27636,27651,27655,27657,27658,27659,27660,29292,31672,31673,33023,33024,33025,33026,33872,34063,34064,34410,34749,34749,34750,34751,34752,34754,34755,34756,34757,34758,35563,35565,42779,42994,42995},
		["Raw"] = {723,729,769,1015,1080,1081,2251,2672,2673,2677,2886,2924,3173,3404,3667,3712,3730,3731,5465,5467,5469,5470,5471,12037,12184,12202,12203,12204,12205,12208,12223,20424,21024,22644,23676,27668,27669,27671,27674,27677,27678,27681,27682,31670,31671,33120,34736,35562,43009,43010,43011,43012,43013},
	}
}

local ids = {}
setmetatable(ids, {
	__index = function(t,i)
		if type(i) == "number" then
			t[i] = i
			return i
		elseif type(i) ~= "string" then
			t[i] = false
			return
		end
		local id = tonumber(i:match("item:(%d+)"))
		t[i] = id
		return id
	end,
})

local CALL_PET        = GetSpellInfo(883)
local DISMISS_PET     = GetSpellInfo(2641)
local FEED_PET        = GetSpellInfo(6991)
local FEED_PET_EFFECT = GetSpellInfo(1539)
local MEND_PET        = GetSpellInfo(136)
local REVIVE_PET      = GetSpellInfo(982)

local combat, dead, dirty, debuffed, feeding, happy, improved, mending, pet, wounded, warned
local best, conj, diet = {}, {}, {}

------------------------------------------------------------------------

local recPetCare = CreateFrame("Frame")
recPetCare:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, ...) end end)
recPetCare:RegisterEvent("ADDON_LOADED")

function recPetCare:ADDON_LOADED(addon)
	if addon ~= "recUI" then return end
	
	if select(2, UnitClass("player")) ~= "HUNTER" then
		self:UnregisterAllEvents()
		return DisableAddOn("recPetCare")
	end

	self.db = {
		["warnFood"] = true,
		["useBonus"] = false,
		["useRaw"] = false,
		["showFood"] = true,
		["mendThreshold"] = 0.75,
		["useConjured"] = true,
		["mendModifier"] = "shift",
		["warnHungry"] = true,
		["useCombo"] = false,
		["feedHappy"] = true,
		["dismissModifier"] = "ctrl",
	}

	if recPetCareStrings then recPetCareStrings = nil end

	self:UnregisterEvent("ADDON_LOADED")
	self.ADDON_LOADED = nil

	if IsLoggedIn() then
		self:PLAYER_LOGIN(true)
	else
		self:RegisterEvent("PLAYER_LOGIN")
	end
end

function recPetCare:PLAYER_LOGIN(delayed)

	warned = GetTime()

	self:RegisterEvent("BAG_UPDATE")
	self:RegisterEvent("CHARACTER_POINTS_CHANGED")
	self:RegisterEvent("PLAYER_TALENT_UPDATE")
	self:RegisterEvent("PLAYER_ALIVE")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_UNGHOST")
	self:RegisterEvent("UI_ERROR_MESSAGE")
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("UNIT_PET")

	if not InCombatLockdown() then
		self:RegisterEvent("UNIT_AURA")
		self:RegisterEvent("UNIT_HAPPINESS")
	end

	if delayed then
		self:UNIT_PET("player")
		self:BAG_UPDATE()
	end

	self:CHARACTER_POINTS_CHANGED()

	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
end

------------------------------------------------------------------------

function recPetCare:BAG_UPDATE()

	dirty = true
	if not InCombatLockdown() then
		self:Scan()
	end
end

------------------------------------------------------------------------

function recPetCare:CHARACTER_POINTS_CHANGED()

	improved = select(5, GetTalentInfo(1, 10)) > 0

end

recPetCare.PLAYER_TALENT_UPDATE = recPetCare.CHARACTER_POINTS_CHANGED

------------------------------------------------------------------------

function recPetCare:PLAYER_ALIVE()
	if UnitIsGhost("player") then return end

	self:Edit()
end

recPetCare.PLAYER_UNGHOST = recPetCare.PLAYER_ALIVE

------------------------------------------------------------------------

function recPetCare:PLAYER_REGEN_DISABLED()

	self:UnregisterEvent("UNIT_AURA")
	self:UnregisterEvent("UNIT_HAPPINESS")

	combat = true
	self:Edit()
end

function recPetCare:PLAYER_REGEN_ENABLED()

	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("UNIT_HAPPINESS")

	combat = false
	self:UNIT_AURA("pet")
	self:UNIT_HAPPINESS("pet")
	self:UNIT_HEALTH("pet")
	self:Edit()
end

------------------------------------------------------------------------

local ERR_PET_SPELL_NOTDEAD = PETTAME_NOTDEAD.."."
function recPetCare:UI_ERROR_MESSAGE(message)

	if message == ERR_PET_SPELL_DEAD then
		dead = true
		self:Edit()
	elseif message == ERR_PET_SPELL_NOTDEAD then
		dead = false
		self:Edit()
	end
end

------------------------------------------------------------------------

function recPetCare:UNIT_AURA(unit)
	if unit ~= "pet" then return end

	local wasFeeding, wasMending = feeding, mending
	feeding, mending = nil, nil

	feeding = select(7, UnitBuff("pet", FEED_PET_EFFECT))
	mending = select(7, UnitBuff("pet", MEND_PET))

	if wasFeeding and not feeding then
		self:UNIT_HAPPINESS("pet")
		self:Edit()
	end
	if wasMending and not mending then
		self:UNIT_HEALTH("pet")
		self:Edit()
	end

	if improved then
		if UnitDebuff("pet", 1, 1) then
			if not debuffed then
				debuffed = true
				self:Edit()
			end
		else
			if debuffed then
				debuffed = false
				self:Edit()
			end
		end
	end
end

------------------------------------------------------------------------

function recPetCare:UNIT_HAPPINESS(unit)
	if unit ~= "pet" or dead or (feeding and (GetTime() - feeding < 0)) then return end

	local happiness = GetPetHappiness()
	if not happiness then return end
	if self.db.warnHungry then
		if happiness == 1 then
			if (GetTime() - warned) > 60 then
				print(format("|cFFABD473recUI Pet:|r %s is very hungry!", UnitName("pet")))
				warned = GetTime()
			end
		elseif happiness == 2 then
			if (GetTime() - warned) > 120 then
				print(format("|cFFABD473recUI Pet:|r %s is hungry.", UnitName("pet")))
				warned = GetTime()
			end
		end
	end

	if not happy then
		happy = happiness
		self:Edit()
	elseif happy ~= happiness then
		self:Edit()
	end
end

------------------------------------------------------------------------

function recPetCare:UNIT_HEALTH(unit)
	if unit ~= "pet" then return end

	local hp, maxhp = UnitHealth("pet"), UnitHealthMax("pet")
	if not dead and hp <= 0 and UnitIsDead("pet") then
		dead = true
		self:Edit()
	elseif dead and hp > 0 then
		dead = false
		self:Edit()
	elseif not wounded and hp / maxhp <= self.db.mendThreshold then
		wounded = true
		self:Edit()
	elseif wounded and hp / maxhp > self.db.mendThreshold then
		wounded = false
		self:Edit()
	end
end

------------------------------------------------------------------------

function recPetCare:UNIT_PET(unit)
	if unit ~= "player" then return end

	local family = UnitCreatureFamily("pet")
	if family and select(2, HasPetUI()) then
		if family ~= pet then
			pet = family
			self:Diet()
		else
			local count = 0
			for k in pairs(diet) do
				count = count + 1
			end
			if count == 0 then
				self:Diet()
			end
		end
		self:UNIT_HEALTH("pet")
		if not InCombatLockdown() then
			self:Scan()
		else
			self:BAG_UPDATE()
		end
	else
		self:Edit()
	end
end

------------------------------------------------------------------------

function recPetCare:Diet()
	local foods = { GetPetFoodTypes() }
	if #foods == 0 then
		return
	end


	-- clear previous diet list
	for k, v in pairs(diet) do diet[k] = nil end

	-- fill diet list with edible foods from database
	for i, v in ipairs(foods) do
		if data[v]["Basic"] then
			for j, id in ipairs(data[v]["Basic"]) do
				diet[id] = true
			end
		end
		if self.db.useBonus and data[v]["Bonus"] then
			for j, id in ipairs(data[v]["Bonus"]) do
				diet[id] = true
			end
		end
		if self.db.useCombo and data[v]["Combo"] then
			for j, id in ipairs(data[v]["Combo"]) do
				diet[id] = true
			end
		end
		if self.db.useRaw and data[v]["Raw"] then
			for j, id in ipairs(data[v]["Raw"]) do
				diet[id] = true
			end
		end
		if self.db.useConjured then
			if data[v]["Conjured"] then
				for j, id in ipairs(data[v]["Conjured"]) do
					diet[id] = true
					conj[id] = true
				end
			end
		else
			for id in pairs(conj) do
				conj[id] = nil
			end
		end
	end

end

------------------------------------------------------------------------

local BAGTYPE_AMMO = select(7, GetAuctionItemClasses())
local BAGTYPE_CONTAINER = select(3, GetAuctionItemClasses())
local BAGTYPE_SUBTYPE = select(1, GetAuctionItemSubClasses(3))

local function IsSpecialBag(bag)
	if bag <= 0 then return end
	local link = GetInventoryItemLink("player", ContainerIDToInventoryID(bag))
	if link then
		local type, subtype = select(6, GetItemInfo(link))
		return (type == BAGTYPE_AMMO) or (type == BAGTYPE_CONTAINER and subtype ~= BAGTYPE_SUBTYPE)
	end
end

function recPetCare:Scan()
	local petlvl = UnitLevel("pet")
	if petlvl and petlvl > 0 then
		if diet == {} then
			self:Diet()
		end
		for k, v in pairs(best) do best[k] = nil end
		for bag = 0, 4 do
			if bag == 0 or not IsSpecialBag(bag) then
				for slot = 1, GetContainerNumSlots(bag) do
					local link = GetContainerItemLink(bag, slot)
					local id = link and ids[link]
					local name = link and GetItemInfo(link) or "Unknown"
					if id and diet[id] then
						local lvl = select(4, GetItemInfo(link)) or 0
						if lvl < (petlvl - 30) then
							diet[id] = nil
						else
							local qty = select(2, GetContainerItemInfo(bag, slot))
							local cat = math.floor(((petlvl - lvl) / 10) + 0.5)
							if cat < 1 then cat = 1 end
							if (not best.id)		-- no best yet
							or (cat < best.cat)		-- closer to pet's level than best
							or (conj[id])			-- conjured food has priority
							or (lvl < best.lvl and qty - best.qty <= 5) -- lower level within level group
							or (qty < best.qty) then -- lower quantity within level group
								best.id = id; best.lvl = lvl; best.cat = cat; best.qty = qty; best.bag = bag; best.slot = slot
							end
						end
					end
				end
			end
		end
		if not best.id and UnitName("pet") ~= "Unknown" and self.db.warnFood and GetTime() - warned > 240 then
			print(format("|cFFABD473recUI Pet:|r You don't have any food for %s.", UnitName("pet")))
			warned = GetTime()
		end
		self:Edit()
	end
end

------------------------------------------------------------------------

function recPetCare:Edit()
	if InCombatLockdown() then return end

	local macroID = GetMacroIndexByName("AutoPet")
	if not macroID then
		return
	end

	local body = "#showtooltip"
	if UnitAffectingCombat("player") then
		body = body.."\n/cast [target=pet,dead][nopet,mod:"..self.db.mendModifier.."] "..REVIVE_PET.."; [nopet] "..CALL_PET.."; [mod:"..self.db.dismissModifier.."] "..DISMISS_PET.."; "..MEND_PET
	elseif dead then
		body = body.."\n/cast "..REVIVE_PET
	elseif not pet or not select(2, HasPetUI()) then
		body = body.."\n/cast [target=pet,dead][mod:"..self.db.mendModifier.."] "..REVIVE_PET.."; "..CALL_PET
	elseif debuffed and not (improved or (mending and (GetTime() - mending < 0))) then
		body = body.."\n/cast [mod:"..self.db.dismissModifier.."] "..DISMISS_PET.."; "..MEND_PET
	elseif wounded and not (mending and (GetTime() - mending < 0)) then
		body = body.."\n/cast [mod:"..self.db.dismissModifier.."] "..DISMISS_PET.."; "..MEND_PET
	else
		local happiness = GetPetHappiness() or 0
		local eating = feeding and (GetTime() - feeding < 0)
		if not eating and best.id and self.db.showFood and (happiness < 3 or self.db.feedHappy) then
			body = body.." [mod:"..self.db.dismissModifier.."] "..DISMISS_PET.."; [mod:"..self.db.mendModifier.."] "..MEND_PET.."; item:"..best.id
		end
		body = body.."\n/cast [mod:"..self.db.dismissModifier.."] "..DISMISS_PET.."; [mod:"..self.db.mendModifier.."] "..MEND_PET.."; "..FEED_PET
		if not eating and best.bag and best.slot and (happiness < 3 or self.db.feedHappy) then
			body = body.."\n/use [nomod] "..best.bag.." "..best.slot
		end
	end

	EditMacro(macroID, "AutoPet", 1, body, 1, 1)
end

------------------------------------------------------------------------