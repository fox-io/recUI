-- $Id: core.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
-- Please place a source's filter in -either- whitelist or blacklist, but not both.
-- An exception is made for the special source filter "author" and "all_chat".
-- While you "can" apply both whitelist and blacklist filters to the same source, it is pointless to do so.
local debug_mode = false

-- If a source is added to the whitelist, only messages containing the pattens will be let through.
local filters = {
	["whitelist"] = {
		["battleground"]	= {},
		["general"]		= {},
		["guild"]		= {},
		["trade"]		= {
						[1] = "wts",
						[2] = "wtb",
						[3] = "selling",
						[4] = "buying",
						[5] = "inscription",
						[6] = "scribe",
						[7] = "alchemist",
						[8] = "alchemy",
						[9] = "enchant",
						[10] = "blacksmith",
						[11] = "leatherwork",
						[12] = " +lw +",
						[13] = "tailor",
						[14] = "lfw",
						[15] = "engineer",
						[16] = "wtt",
						[17] = "trading",
						-- Temp
						[18] = "sfk",
						[19] = "holiday",
						[20] = "hummel"
					},
		["localdefense"]	= {},
		["lookingforgroup"]	= {},
		["party"]		= {},
		["raid"]		= {},
		["say"]			= {},
		["whisper"]		= {},
		["yell"]		= {},
		-- Special "all" source prevents any source from displaying messages containing the patterns.
		["all"]			= {},
		-- Special "author" source allows specific authors to not be tested against any white or blacklist.
		["author"]		= {},
	},

	-- If a source is added to the blacklist, only messages which do NOT contain the patterns will be let through.
	["blacklist"] = {
		["battleground"]	= {},
		["general"]		= {
						[1] = "lfg",
						[2] = "guild",
						[3] = "recruiting",
					},
		["guild"]		= {
						[1] = "wintertime",	-- WinterTime addon spam.
					},
		["trade"]		= {
						[1] = ".*",	-- Prevent all trade messges. (whitelist rules apply)
					},
		["localdefense"]	= {
						[1] = ".*",	-- Prevent all local defense messages. (whitelist rules apply)
					},
		["lookingforgroup"]	= {
						[1] = ".*",	-- Prevent all lfg messages. (whitelist rules apply)
					},
		["party"]		= {},
		["raid"]		= {},
		["say"]			= {
						[1] = "fart",
						[2] = "$shit",
						[3] = " shit",
						[4] = "fuck",
						[5] = "fag",
						[6] = "fat ass",
						[7] = "ass fat",
						[8] = "boob",
					},
		["whisper"]		= {
						[1] = "susan",
					},
		["yell"]		= {
						[1] = ".*",
					},
		-- Special "all" source prevents any source from displaying messages containing the patterns.
		["all"]			= {
						[1] = " anal ",
						[2] = "penis"
					},
		-- Special "author" source prevents any messages from the authors in the list from displaying.
		["author"]		= {
						[1] = "Ballverine",	-- Political talk
						[2] = "Akindra",	-- Political talk
						[3] = "Dysheer",	-- Political talk
						[4] = "Eledes",		-- Trolling, rude
						[5] = "Rpfgtsdie",	-- Troll name, Spamming vent in general chat.
						[6] = "Cutegirlirl",-- ERP troll.
						[7] = "Yseriehh",	-- ERP troll.
						[8] = "Niamiah",	-- ERP troll.
		},
	}
}

-- Table to store author names as messages are processed.
--[[author_timers = {}
local function time_check(author, squelch_time)
	-- If we have this author in our table, then that means we need to check their last message time.
	if author_timers[author] then
		-- CurrentTime - stored time gives us how long it has been since their last message.
		-- If this value is less than the requested squelch time, then we filter out the message.
		-- If it has not been long enough, we simply pass through as though the author were not listed in our table.
		if (GetTime() - author_timers[author]) < squelch_time then
			if debug_mode then print("Frequency squelch", author, squelch_time, GetTime() - author_timers[author]) end
			return true
		end
	end
	
	-- Store/update this author in our table, with a timestamp of when this message was processed, and allow message to pass this filter.
	author_timers[author] = GetTime()
	if debug_mode then print("Set frequency marker", author, squelch_time, author_timers[author]) end
	return false
end--]]

local function message_check(list_type, message_type, msg)
	if msg and filters[list_type] and filters[list_type][message_type] then
		for _, v in pairs(filters[list_type][message_type]) do
			if string.find(msg, v) then
				return true
			end
		end
	end
	return false
end

local function filter(self, event, msg, author, _, _, _, _, _, _, channel_name)
	-- Auto-whitelist messages by yourself.
	if author == UnitName("player") then return false end
	
	local source
	local lowercase_msg = string.lower(msg)
	
	-- Create a source based on message event type.
	if event == "CHAT_MSG_CHANNEL" then
		source = string.lower(channel_name)
		if string.find(source, "trade") then source = "trade"
		elseif string.find(source, "general") then source = "general"
		elseif string.find(source, "defense") then source = "localdefense"
		elseif string.find(source, "looking") then source = "lookingforgroup"
		end
	elseif event == "CHAT_MSG_BATTLEGROUND" or event == "CHAT_MSG_BATTLEGROUND_LEADER" then
		source = "battleground"
	elseif event == "CHAT_MSG_GUILD" then
		source = "guild"
	elseif event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER" or event == "CHAT_MSG_RAID_WARNING" then
		source = "raid"
	elseif event == "CHAT_MSG_PARTY" then
		source = "party"
	elseif event == "CHAT_MSG_SAY" then
		source = "say"
	elseif event == "CHAT_MSG_WHISPER" then
		source = "whisper"
	elseif event == "CHAT_MSG_YELL" then
		source = "yell"
	end
	
	-- Is author whitelisted?
	if message_check("whitelist", "author", author) then
		if debug_mode then print("Message allowed, author whitelist", author, lowercase_msg) end
		return false
	end
	
	-- Is message global whitelisted?
	if message_check("whitelist", "all_chat", lowercase_msg) then
		if debug_mode then print("Message allowed, all_chat whitelist", lowercase_msg) end
		return false
	end
	
	-- Is author blacklisted?
	if message_check("blacklist", "author", author) then
		if debug_mode then print("Message blocked, author blacklist", author, lowercase_msg) end
		return true
	end
	
	-- Is message global blacklisted?
	if message_check("blacklist", "all_chat", lowercase_msg) then
		if debug_mode then print("Message blocked, all_chat blacklist", lowercase_msg) end
		return true
	end
	
	-- If source was not set yet, then we are not filtering it
	if not source then
		if debug_mode then print("Message allowed, no source to filter on", lowercase_msg) end
		return false
	end
	
	-- Squelch authors based on time since last message.
	--if (source == "trade" or source == "lookingforgroup") and time_check(author, 300) then
		--if debug_mode then print("Message blocked, author frequency", author, lowercase_msg) end
		--return true
	--end
	--if (source == "yell") and time_check(author, 60) then
		--if debug_mode then print("Message blocked, author frequency", author, lowercase_msg) end
		--return true
	--end
	
	-- Is message whitelisted?
	if message_check("whitelist", source, lowercase_msg) then
		if debug_mode then print("Message allowed, source whitelist", author, source, lowercase_msg) end
		return false
	end
	
	-- Is message source-based blacklisted?
	if message_check("blacklist", source, lowercase_msg) then
		if debug_mode then print("Message blocked, source blacklist", author, source, lowercase_msg) end
		return true
	end
	
	-- Message passed all available filters!
	if debug_mode then print("Message allowed, passed filters", author, lowercase_msg) end
	return false
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND_LEADER", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", filter)

local f = CreateFrame("Frame")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event, ...)
	if event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_WORLD" then
		if GetZoneText() == "Lion's Pride Inn" or GetZoneText() == "Goldshire" then
			ChatFrame_RemoveMessageGroup(ChatFrame1, "EMOTE")
			ChatFrame_RemoveMessageGroup(ChatFrame1, "MONSTER_SAY")
			ChatFrame_RemoveMessageGroup(ChatFrame1, "MONSTER_EMOTE")
			ChatFrame_RemoveMessageGroup(ChatFrame1, "MONSTER_YELL")
		else
			ChatFrame_AddMessageGroup(ChatFrame1, "EMOTE")
			ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_SAY")
			ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_EMOTE")
			ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_YELL")
		end
	end
end)