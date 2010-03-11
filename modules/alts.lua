local _, ns = ...
--------------------------------------------------------
-- RecAltInfo (c)2009-2010 Recluse <john.d.mann@gmail.com>
--
-- Stores information about your alts, compiling the data
-- into an informative display.
--------------------------------------------------------

-- Some variables we will need.
local event_frame, db, my_name, my_realm, my_faction = CreateFrame("Frame")

local function UpdateInfo(self, event, ...)
	-- Short reference to player's saved var table
	local my = db[my_realm][my_faction][my_name]

	-- Force client to show time played
	if event == "PLAYER_ENTERING_WORLD" then
		RequestTimePlayed()

	-- Store total time played
	elseif event == "TIME_PLAYED_MSG" then
		my.played = ...
	end

	-- Update saved vars
	my.money = GetMoney() or 0
	my.level = UnitLevel("player") or 0
	my.class = UnitClass("player")
	_, my.race = UnitRace("player")
end

local function PrettyMoney(copper)
	-- Converts a single integer representing an amount of copper into a readable form such as:
	-- 1g 2c 3s (in full color)
	local gold		= floor(	copper / 10000)
	local silver	= floor(mod(copper / 100,	100))
	copper			= floor(mod(copper / 1,		100))

	return string.format("|cFFFFD700%dg|r |cFFC7C7CF%ds|r |cFFEDA55F%dc|r", gold or 0, silver or 0, copper or 0)
end

local function PrettyTime(seconds)
	-- Converts a single integer representing an amount of seconds into a readable form such as:
	-- 1 years, 2 months, 3 weeks, 4 days, 5 hours, 6 minutes, 7 seconds
	local years		= floor(	seconds / 31536000)
	local months	= floor(mod(seconds / 2592000,	12))
	local weeks		= floor(mod(seconds / 604800,	4.3))
	local days		= floor(mod(seconds / 86400,	7))
	local hours		= floor(mod(seconds / 3600,		24))
	local minutes	= floor(mod(seconds / 60,		60))
		  seconds	= floor(mod(seconds / 1,		60))

	--[[return string.format("%s%s%s%s%s%s%s",
		years	> 0	and	string.format("%d |4year:years;, ",		years)		or "",
		months	> 0	and	string.format("%d |4month:months;, ",	months)		or "",
		weeks	> 0	and	string.format("%d |4week:weeks;, ",		weeks)		or "",
		days	> 0	and	string.format("%d |4day:days;, ",		days)		or "",
		hours	> 0	and	string.format("%d |4hour:hours;, ",		hours)		or "",
		minutes > 0	and	string.format("%d |4minute:minutes;, ",	minutes)	or "",
		seconds > 0	and	string.format("%d |4second:seconds;",	seconds)	or ""
	)--]]
	return string.format("%s%s%s%s%s%s%s",
		years   > 0 and string.format("%dy, ", years  ) or "",
		months  > 0 and string.format("%dm, ", months ) or "",
		weeks   > 0 and string.format("%dw, ", weeks  ) or "",
		days    > 0 and string.format("%dd, ", days   ) or "",
		hours   > 0 and string.format("%dh, ", hours  ) or "",
		minutes > 0 and string.format("%dm, ", minutes)	or "",
		seconds > 0 and string.format("%ds",   seconds)	or ""
	)
end

local output_frame = CreateFrame("Frame", "raioutputframe", UIParent)
output_frame:SetPoint("TOP", 0, -10)
output_frame:SetHeight(660)
output_frame:SetWidth(695)
output_frame:SetMovable(true)
output_frame:EnableMouse(true)
output_frame:RegisterForDrag("LeftButton")
output_frame:SetUserPlaced(true)
output_frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
output_frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
output_frame:SetFrameStrata("TOOLTIP")
output_frame.bg = CreateFrame("Frame", nil, output_frame)
output_frame.bg:SetPoint("TOPLEFT", -10, 10)
output_frame.bg:SetPoint("BOTTOMRIGHT", 10, -10)
output_frame.bg:SetBackdrop(recUI.media.backdropTable)
output_frame.bg:SetFrameStrata("HIGH")
output_frame.bg:SetBackdropColor(.15, .15, .15, 1)
output_frame.bg:SetBackdropBorderColor(0, 0, 0)
output_frame:Hide()

local function character_line(name, money, played, level, realm, faction, race, class)
	local line = CreateFrame("Frame", "railine"..name..money..played..level, output_frame)
	line:SetHeight(12)
	line.realm = line:CreateFontString(nil, "OVERLAY")
	line.realm:SetFont(ns.media.font, 9, nil)
	line.realm:SetText(realm)
	line.realm:SetJustifyH("LEFT")
	line.realm:SetPoint("LEFT")
	line.realm:SetWidth(130)
	line.faction = line:CreateFontString(nil, "OVERLAY")
	line.faction:SetFont(ns.media.font, 9, nil)
	line.faction:SetText(faction)
	if faction == "Alliance" then
		line.faction:SetTextColor(0, .5, 1)
	elseif faction == "Horde" then
		line.faction:SetTextColor(1, .2, .2)
	else
		line.faction:SetTextColor(1, 1, 1)
	end
	line.faction:SetJustifyH("LEFT")
	line.faction:SetPoint("LEFT", line.realm, "RIGHT")
	line.faction:SetWidth(55)
	line.name = line:CreateFontString(nil, "OVERLAY")
	line.name:SetFont(ns.media.font, 9, nil)
	line.name:SetText(name)
	line.name:SetJustifyH("LEFT")
	line.name:SetPoint("LEFT", line.faction, "RIGHT")
	line.name:SetWidth(85)
	line.level = line:CreateFontString(nil, "OVERLAY")
	line.level:SetFont(ns.media.font, 9, nil)
	line.level:SetText(level)
	if type(level) ~= "string" then
		if level == 80 then
			line.level:SetTextColor(1, .2, .2)
		elseif level < 80 and level > 69 then
			line.level:SetTextColor(1, .5, 0)
		elseif level < 70 and level > 59 then
			line.level:SetTextColor(1, 1, 0)
		end
	end
	line.level:SetJustifyH("RIGHT")
	line.level:SetPoint("LEFT", line.name, "RIGHT")
	line.level:SetWidth(30)
	line.class = line:CreateFontString(nil, "OVERLAY")
	line.class:SetFont(ns.media.font, 9, nil)
	line.class:SetText(class or " ")
	line.class:SetJustifyH("LEFT")
	line.class:SetPoint("LEFT", line.level, "RIGHT", 10, 0)
	line.class:SetWidth(80)
	line.race = line:CreateFontString(nil, "OVERLAY")
	line.race:SetFont(ns.media.font, 9, nil)
	line.race:SetText(race or " ")
	line.race:SetJustifyH("LEFT")
	line.race:SetPoint("LEFT", line.class, "RIGHT")
	line.race:SetWidth(50)
	line.money = line:CreateFontString(nil, "OVERLAY")
	line.money:SetFont(ns.media.font, 9, nil)
	line.money:SetText(type(money) == "string" and money or PrettyMoney(money))
	line.money:SetJustifyH("RIGHT")
	line.money:SetPoint("LEFT", line.race, "RIGHT")
	line.money:SetWidth(100)
	line.played = line:CreateFontString(nil, "OVERLAY")
	line.played:SetFont(ns.media.font, 9, nil)
	line.played:SetText(type(played) == "string" and played or PrettyTime(played))
	line.played:SetJustifyH("RIGHT")
	line.played:SetPoint("LEFT", line.money, "RIGHT")
	line.played:SetWidth(155)
	return line
end

local function DisplayData(data_type)
	-- Sanity check
	if not data_type then return end
	
	local display_data = {}
	
	local id = (#display_data or 0) + 1
	display_data[id] = character_line("Name", "Money", "/played", "Level", "Realm", "Faction", "Race", "Class")
	display_data[id]:SetPoint("TOPLEFT", ((id == 1) and output_frame) or display_data[id-1], ((id == 1) and "TOPLEFT") or "BOTTOMLEFT", 0, 0)
	display_data[id]:SetPoint("TOPRIGHT", ((id == 1) and output_frame) or display_data[id-1], ((id == 1) and "TOPRIGHT") or "BOTTOMRIGHT", 0, 0)
	display_data[id]:Show()
	local id = (#display_data or 0) + 1
	display_data[id] = character_line(" ", " ", " ", " ", " ", " ", " ", " ")
	display_data[id]:SetPoint("TOPLEFT", ((id == 1) and output_frame) or display_data[id-1], ((id == 1) and "TOPLEFT") or "BOTTOMLEFT", 0, 0)
	display_data[id]:SetPoint("TOPRIGHT", ((id == 1) and output_frame) or display_data[id-1], ((id == 1) and "TOPRIGHT") or "BOTTOMRIGHT", 0, 0)
	display_data[id]:Show()

	-- Initialize the variables we will need
	local total_value, realm_value, faction_value, character_value = 0, 0, 0, 0
	local total_average, realm_average, faction_average = 0, 0, 0
	local total_characters, realm_characters, faction_characters = 0, 0, 0
	local total_played, total_money, total_level = 0, 0, 0
	local total_alliance, total_horde = 0, 0

	for realm, factions in pairs(db) do
		for faction, characters in pairs(factions) do
			for character, data in pairs(characters) do

				-- Do not try to add in values which do not exist
				if data[data_type] then

					if realm == my_realm then

						-- If this is the player's realm, then add this value to the realm total
						realm_value = realm_value + data[data_type]
						-- Add one character to our realm total
						realm_characters = realm_characters + 1

						if faction == my_faction then

							-- If this is the player's faction, then add this value to the faction total
							faction_value = faction_value + data[data_type]
							-- Add one character to our faction total
							faction_characters = faction_characters + 1

							if character == my_name then

								-- If this is our character, then use its value as the character's value
								character_value = data[data_type]
							end
						end
					end

					-- As long as there is a value, add it to the global total
					total_value = total_value + data[data_type]
					-- Add one character to our account total
					total_characters = total_characters + 1
					
					output_frame:Show()
					local id = (#display_data or 0) + 1
					total_played = total_played + data.played
					total_money = total_money + data.money
					total_level = total_level + data.level
					if faction == "Alliance" then
						total_alliance = total_alliance + 1
					else
						total_horde = total_horde + 1
					end
					display_data[id] = character_line(character, data.money, data.played, data.level, realm, faction, data.race, data.class)
					display_data[id]:SetPoint("TOPLEFT", ((id == 1) and output_frame) or display_data[id-1], ((id == 1) and "TOPLEFT") or "BOTTOMLEFT", 0, 0)
					display_data[id]:SetPoint("TOPRIGHT", ((id == 1) and output_frame) or display_data[id-1], ((id == 1) and "TOPRIGHT") or "BOTTOMRIGHT", 0, 0)
					display_data[id]:Show()
				end
			end
		end
	end

	-- Generate averages
	total_average = total_value/total_characters
	realm_average = realm_value/realm_characters
	faction_average = faction_value/faction_characters

	-- Since money is stored as copper, we need to convert it into an easier to read format.
	if data_type == "money" then
		total_average	= PrettyMoney(total_average)
		total_value		= PrettyMoney(total_value)
		realm_average	= PrettyMoney(realm_average)
		realm_value		= PrettyMoney(realm_value)
		faction_average	= PrettyMoney(faction_average)
		faction_value	= PrettyMoney(faction_value)
		character_value	= PrettyMoney(character_value)

	-- Since time is stored in seconds, we need to convert it into an easier to read format.
	elseif data_type == "played" then
		total_average	= PrettyTime(total_average)
		total_value		= PrettyTime(total_value)
		realm_average	= PrettyTime(realm_average)
		realm_value		= PrettyTime(realm_value)
		faction_average	= PrettyTime(faction_average)
		faction_value	= PrettyTime(faction_value)
		character_value	= PrettyTime(character_value)
	end

	-- Display the data in the chat box.
	print(string.format("|cFF00FF00RecAltInfo:|r %s",						data_type))
	print(string.format("|cFF00FF00Account:|r %s \n(avg: %s, %s characters)",	total_value, total_average, total_characters))
	print(string.format("|cFF00FF00Realm:|r %s \n(avg: %s, %s characters)",	realm_value, realm_average, realm_characters))
	print(string.format("|cFF00FF00Faction:|r %s \n(avg: %s, %s characters)",	faction_value, faction_average, faction_characters))
	print(string.format("|cFF00FF00Character:|r %s",							character_value))
	
	local id = (#display_data or 0) + 1
	display_data[id] = character_line(" ", " ", " ", " ", " ", " ")
	display_data[id]:SetPoint("TOPLEFT", ((id == 1) and output_frame) or display_data[id-1], ((id == 1) and "TOPLEFT") or "BOTTOMLEFT", 0, 0)
	display_data[id]:SetPoint("TOPRIGHT", ((id == 1) and output_frame) or display_data[id-1], ((id == 1) and "TOPRIGHT") or "BOTTOMRIGHT", 0, 0)
	display_data[id]:Show()
	
	local id = (#display_data or 0) + 1
	display_data[id] = character_line("Total", total_money, total_played, total_level, string.format("%d characters", total_characters), string.format("|cFF%02x%02x%02x%dA|r  |cFF%02x%02x%02x%dH|r", 0*255, .5*255, 1*255, total_alliance, 1*255, .2*255, .2*255, total_horde))
	display_data[id]:SetPoint("TOPLEFT", ((id == 1) and output_frame) or display_data[id-1], ((id == 1) and "TOPLEFT") or "BOTTOMLEFT", 0, 0)
	display_data[id]:SetPoint("TOPRIGHT", ((id == 1) and output_frame) or display_data[id-1], ((id == 1) and "TOPRIGHT") or "BOTTOMRIGHT", 0, 0)
	display_data[id]:Show()
	
	local id = (#display_data or 0) + 1
	display_data[id] = character_line("Average", floor(total_money/total_characters), floor(total_played/total_characters), floor(total_level/total_characters), " ", " ")
	display_data[id]:SetPoint("TOPLEFT", ((id == 1) and output_frame) or display_data[id-1], ((id == 1) and "TOPLEFT") or "BOTTOMLEFT", 0, 0)
	display_data[id]:SetPoint("TOPRIGHT", ((id == 1) and output_frame) or display_data[id-1], ((id == 1) and "TOPRIGHT") or "BOTTOMRIGHT", 0, 0)
	display_data[id]:Show()
	
	output_frame:Show()
	
	-- Clean up
	display_data = nil
end

local command_list = {
	["level"]  = true,
	["money"]  = true,
	["played"] = true
}

local function SlashCommand(cmd)
	-- Might as well update before we bother showing information.
	UpdateInfo()

	-- Call the command if it is valid
	if command_list[cmd] then
		DisplayData(cmd)

	else
	-- Print help
		print("RecAltInfo: Commands")
		for command, _ in pairs(command_list) do
			print(string.format("/rai %s", command))
		end
	end
end

local function AddonLoaded()
	if arg1 ~= "recAltInfo" then return end

	-- Remove any events that we are watching (sanity)
	event_frame:UnregisterAllEvents()

	-- Get the information about the player that we will need to save their data
	my_name = UnitName("player")
	my_realm = GetRealmName()
	my_faction = UnitFactionGroup("player")

	-- Create a saved variable table for this realm/faction/character if it does not exist.
	if my_name and my_realm and my_faction then
		RecAltInfoDB = RecAltInfoDB or {}
		db = {}
		if not db[my_realm] then db[my_realm] = {} end
		if not db[my_realm][my_faction] then db[my_realm][my_faction] = {} end
		if not db[my_realm][my_faction][my_name] then db[my_realm][my_faction][my_name] = {} end
	else
		-- This should not happen, but if it does, then we need to know about it.
		print("RecAltInfo: ERROR #1 Inform author.")
		return
	end

	-- Change the function called OnEvent, and register events which will trigger a data update
	event_frame:SetScript("OnEvent", UpdateInfo)
	--event_frame:RegisterEvent("PLAYER_LOGOUT")	-- Tried this, but didn't seem to work as it should have.
	event_frame:RegisterEvent("PLAYER_MONEY")
	event_frame:RegisterEvent("PLAYER_LEVEL_UP")
	event_frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	event_frame:RegisterEvent("TIME_PLAYED_MSG")

	-- Set up the slash command
	SlashCmdList["RECALTINFO"] = SlashCommand
	SLASH_RECALTINFO1 = "/rai"
	SLASH_RECALTINFO2 = "/recaltinfo"

	-- Give it a swift kick in the rear to get started.
	UpdateInfo()
end

-- Since we are dealing with saved variables and whatnot, we need to wait until RAI is ready for us.
event_frame:SetScript("OnEvent", AddonLoaded)
event_frame:RegisterEvent("ADDON_LOADED")
