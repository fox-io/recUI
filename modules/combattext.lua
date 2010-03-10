--Initialization Steps

-- Make our addons namespace.
_G["RecSCT"] = {}
RecSCT.player = false
RecSCT.pet = false

RecSCT.spam_grouped = {}	-- Stores spam which has been processed into groups.
RecSCT.spam_ready = {}		-- Stores spam which has left the queue.
RecSCT.spam_queue = {}		-- Stores spam which has been queued.
RecSCT.energize_queue = {}	-- Stores energize spam which has been queued.

RecSCT.empty_strings = {}	-- Recycled strings
RecSCT.empty_tables = {}	-- Recycled tables

RecSCT.strings_empty = {}	-- Stores recycled animation strings.

RecSCT.school_colors = {
	[0] = "FFFFFF",
	[1] = "FFFF00",
	[2] = "FFE57F",
	[4] = "FF7F00",
	[8] = "4CFF4C",
	[16] = "7FFFFF",
	[32] = "7F7FFF",
	[64] = "FF7FFF",
}

RecSCT.power_colors = {
	[-2]	= "00FF00",	-- Health
	[0]		= "0000FF",	-- Mana
	[1]		= "FF0000",	-- Rage
	[2]		= "643219",	-- Focus
	[3]		= "FFFF00",	-- Energy
	[4]		= "00FFFF",	-- Happiness
	[5]		= "323232",	-- Runes
	[6]		= "005264",	-- Runic Power
}

RecSCT.miss_printable = {
	["MISS"]	= "Missed",
	["DODGE"]	= "Dodged",
	["BLOCK"]	= "Blocked",
	["DEFLECT"]	= "Deflected",
	["EVADE"]	= "Evaded",
	["IMMUNE"]	= "Immune",
	["PARRY"]	= "Parried",
	["REFLECT"]	= "Reflected",
	["RESIST"]	= "Resisted",
	["ABSORB"]	= "Absorbed"
}

RecSCT.environment_printable = {
	["DROWNING"]	= "Drowning",
	["FALLING"]		= "Falling",
	["FATIGUE"]		= "Fatigued",
	["FIRE"]		= "Fire",
	["LAVA"]		= "Lava",
	["SLIME" ]		= "Slime"
}

RecSCT.anim_strings = {
	["outgoing"] = {},
	["outgoingcrit"] = {},
	["incoming"] = {},
	["incomingcrit"] = {},
	["notification"] = {},
	["notificationcrit"] = {}
}

RecSCT.scroll_area_frames = {
	["outgoing"] = true,
	["outgoingcrit"] = true,
	["incoming"] = true,
	["incomingcrit"] = true,
	["notification"] = true,
	["notificationcrit"] = true
}

RecSCT.event_handlers = {
}

-- Constants
RecSCT.constants = {
	BLANK = "",
	MINUS = "-",
	PLUS = "+",
	WHITE = "FFFFFF",
	OUTGOING = "outgoing",
	INCOMING = "incoming",
	NOTIFICATION = "notification",
	DEBUFF = "DEBUFF",
	STACK_FORMAT = "%sx ",
	MISS = "Miss",
	PET = "(Pet)",
	TARGET_FORMAT = " %s",
	MISS_FORMAT = " (%s)",
	CRIT = "(Crit)",
	CRUSHING = "(Crushing)",
	GLANCING = "(Glancing)",
	EXTRA_AMOUNT = "(%s %s)",
	OVERKILL = "overkill",
	RESISTED = "resisted",
	BLOCKED = "blocked",
	ABSORBED = "absorbed",
	HOT = "(HoT)",
	BUFF = "BUFF",
	DOT = "(DoT)",
}

-- Plugins (not required for core operation) (Plugin settings are at the end of this file)
RecSCT.enable_combat_notice			= true		-- Will show "+ Combat" or "- Combat" when you enter/exit combat.
RecSCT.enable_loot_items			= false		-- Will show any items looted.
RecSCT.enable_loot_money			= false		-- Will show any cash looted.
RecSCT.enable_experience			= false		-- Will show experience gains.
RecSCT.enable_reputation			= false		-- Will show reputation gains.
RecSCT.enable_honor					= false		-- Will show honor gains.
RecSCT.enable_debuffs				= true		-- Will show debuffs (gain/fade, NOT damage from them).
RecSCT.enable_killing_blow			= false		-- Will show "Killing Blow" notices.
RecSCT.enable_buffs					= true		-- Will show buffs (gain/fade)
RecSCT.enable_damage				= true		-- Will show damage
RecSCT.enable_healing				= true		-- Will show healing
RecSCT.enable_power					= true		-- Will show power gains.
RecSCT.enable_misses				= true		-- Will show misses, as well as full absorbs, full block, etc.
RecSCT.enable_environmental			= true		-- Will show environmental damage (lava, falling etc)

-- Name shortening settings
RecSCT.shorten_player_names			= 4			-- Max number of characters to display. 0:Show full name.
RecSCT.shorten_npc_names			= 8			-- Max number of characters to display. 0:Show full name.
RecSCT.shorten_ability_names		= 8			-- Max number of characters to display. 0:Show full name.
RecSCT.show_outgoing_target			= 0			-- 0:Show no names, 1:Names that are not your target, 2:Show all names
RecSCT.show_incoming_source			= 0			-- 0:Show no names, 1:Names that are not your target, 2:Show all names
RecSCT.show_notification_source		= 0			-- 0:Show no names, 1:Names that are not your target, 2:Show all names

-- Font Settings
RecSCT.font							= recMedia.fontFace.NORMAL
RecSCT.font_flags					= "OUTLINE"	-- Some text can be hard to read without it.
RecSCT.font_size_normal				= 10
RecSCT.font_size_crit				= 30

-- Scrollframe Settings
RecSCT.scrollframe_height			= 200		-- Height of each scrollframe.

-- Animation Settings
RecSCT.animation_duration			= 5			-- Time it takes for an animation to complete. (in seconds)
RecSCT.animations_per_scrollframe	= 10		-- Maximum number of displayed animations in each scrollframe.
RecSCT.animation_vertical_spacing	= 8			-- Minimum spacing between animations.

-- Spam Settings
RecSCT.spam_queue_time				= 0.5		-- Length of time to wait before displaying events in order to catch spammy ones.
RecSCT.energize_queue_time			= 4			-- A slower spam queue allows for -really- spammy events to wait longer for grouping.
RecSCT.energize_spells				= {			-- Spells which should go into the energize queue instead of spam queue.
	["Replenishment"] = true,
	["Judgement of Wisdom"] = true,
	["Glyph of Seal of Blood"] = true,
	["Aspect of the Viper"] = true,
	["Invigoration"] = true,
	["Vampiric Embrace"] = true,
}

--[[ NYI
RecSCT.plugin_settings = {}
if RecSCT.enable_debuffs then
	RecSCT.plugin_settings["debuffs"] = {
		-- Outgoing Debuffs
		["enable_outgoing"]							= true,
		["outgoing_destination_name"]				= 1,
		["outgoing_destination_name_max_length"]	= 8,
		["outgoing_scrollframe"]					= "outgoing",
		-- Incoming Debuffs
		["enable_incoming"]							= true,
		["incoming_source_name"]					= 1,
		["outgoing_source_name_max_length"]			= 8,
		["incoming_scrollframe"]					= "incoming",
	}
end--]]

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX--
-- DO NOT EDIT BELOW THIS WARNING UNLESS YOU KNOW WTF YOU ARE DOING! --
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX--
RecSCT.animation_speed				= 1			-- Modifies animation_duration.  1 = 100%
RecSCT.animation_delay				= 0.015		-- Frequency of animation updates. (in seconds)
RecSCT.animation_movement_speed		= RecSCT.animation_duration / RecSCT.scrollframe_height
RecSCT.spam_processing_time			= 0.3		-- How often un-queued spam is processed.

--[[ NYI Settings
RecSCT.animation_style = "scrollup"
RecSCT.show_overhealing = 0
--]]

-- Utilities

-- Determines what type the GUID passed in is (used for shortening names)
local guid_types = {[0]="player", [3]="npc", [4]="pet", [5]="vehicle"}
function RecSCT:GetUnitType(guid)
	return guid_types[tonumber(guid:sub(5,5), 16)%8] or nil
end

-- Removes the pvp realm from players, if there is one
function RecSCT:RemovePvPRealm(name, guid)
	if RecSCT:GetUnitType(guid) == "player" then
		return (string.find(name, "-", 1, true)) and string.gsub(name, "(.-)%-.*", "%1 [*]") or name
	end
	return name
end

-- Shortens names of abilities
function RecSCT:ShortenAbilityName(ability)
	if not ability then return "" end
	if RecSCT.shorten_ability_names > 0 then
		if string.len(ability) <= RecSCT.shorten_ability_names then return ability end
		if string.find(ability, " ") then
			ability = string.gsub(ability, "(%a)[%l]*[%s%-]*", "%1")
		else
			ability = string.sub(ability, 1, RecSCT.shorten_ability_names)
		end
	end
	return ability
end

-- Shortens names of units
function RecSCT:ShortenUnitName(name, guid)
	if not name or not guid then return "" end
	local guid_type = RecSCT:GetUnitType(guid)
	if guid_type then
		if guid_type == "player" or guid_type == "pet" then
			if RecSCT.shorten_player_names > 0 and string.len(name) > RecSCT.shorten_player_names then
				return string.sub(name, 1, RecSCT.shorten_player_names)
			else
				return name
			end
		elseif RecSCT.shorten_npc_names > 0 and string.len(name) > RecSCT.shorten_npc_names then
			return string.sub(name, 1, RecSCT.shorten_npc_names)
		else
			return name
		end
	end
	return name
end

-- joins all strings in ... together with delimiter, skipping strings which are ""
function RecSCT:Implode(delimiter, ...)
	local more, i, out
    while (more or not i) do
		i = (i or 0) + 1
        more = select(i, ...)
        out = (out or "")..((more and more ~= "") and ((i>1 and delimiter or "")..more) or "")
    end
    return out
end

-- Clears the contents of a table (does not do subtables)
function RecSCT:EraseTable(t)
	for key in next, t do t[key] = nil end
end

-- need plugins for these:
			-- eventType notes
			--"miss" "power" "interrupt" "aura"
			--"enchant" "dispel" "cast" "extraattacks"

		--["SPELL_DISPEL"] = true,
		--["SPELL_STOLEN"] = true,
		--["SPELL_DISPEL_FAILED"] = true,
		--["SPELL_INTERRUPT"] = true,
		--["SWING_EXTRA_ATTACKS"] = true,
		--["SPELL_INTERRUPT"] = true,
		--["SPELL_RESURRECT"] = true,
		--["ENCHANT_APPLIED"] = true,
		--["ENCHANT_REMOVED"] = true,
		--["SPELL_DRAIN"] = true,
		--["SPELL_LEECH"] = true,
		--["SWING_INSTAKILL"] = true,
		--["RANGE_INSTAKILL"] = true,
		--["SPELL_INSTAKILL"] = true,
		--["SPELL_CAST_START"] = true,
		--["SPELL_CAST_SUCCESS"] = true,
		--["SPELL_SUMMON"] = true,
		--["SPELL_AURA_BROKEN_SPELL"] = true,
		--["SPELL_CREATE"] = true,
		--["SPELL_CAST_FAILED"] = true,
		--["SPELL_PERIODIC_LEECH"] = true,
		--["SPELL_AURA_BROKEN"] = true,
		--["SPELL_AURA_REFRESH"] = true,

function RecSCT:ParseEvent(...)
	local e
	if #RecSCT.empty_tables and #RecSCT.empty_tables > 0 then
		e = table.remove(RecSCT.empty_tables, 1)
	else
		e = {}
	end
	RecSCT:EraseTable(e)

	-- Insert common args
	e.timestamp, e.event, e.source_guid, e.source_name, e.source_flags, e.dest_guid, e.dest_name, e.dest_flags = ...
	-- Process damage events
	if e.event == "SWING_DAMAGE" then
		e.type = "damage"
		e.amount, e.overkill_amount, e.damage_type, e.resist_amount, e.block_amount, e.absorb_amount, e.crit, e.glancing, e.crushing = select(9, ...)
	-- Process environmental events
	elseif e.event == "ENVIRONMENTAL_DAMAGE" then
		e.type = "environmental"
		e.hazard_type, e.amount, e.overkill_amount, e.damage_type, e.resist_amount, e.block_amount, e.absorb_amount, e.crit, e.glancing, e.crushing = select(9, ...)
	elseif string.find(e.event, "DAMAGE$") or e.event == "DAMAGE_SHIELD" or e.event == "DAMAGE_SPLIT" then
		if e.event == "RANGE_DAMAGE" then e.range = true
		elseif e.event == "SPELL_PERIODIC_DAMAGE" then e.dot = true
		elseif e.event == "DAMAGE_SHIELD" then e.damage_shield = true end
		e.type = "damage"
		e.skill_id, e.skill_name, e.skill_school, e.amount, e.overkill_amount, e.damage_type, e.resist_amount, e.block_amount, e.absorb_amount, e.crit, e.glancing, e.crushing = select(9, ...)
	-- Process miss events
	elseif e.event == "SWING_MISSED" then
		e.type = "miss"
		e.miss_type, e.amount = select(9, ...)
	elseif e.event == "SPELL_DISPEL_FAILED" then
		e.type = "miss"; e.miss_type = "RESIST"
		e.skill_id, e.skill_name, e.skill_school, e.extra_skill_id, e.extra_skill_name, e.extra_skill_school = select(9, ...)
	elseif string.find(e.event, "MISSED$") then
		if e.event == "DAMAGE_SHIELD_MISSED" then e.damage_shield = true
		elseif e.event == "RANGE_MISSED" then e.range = true end
		e.type = "miss"
		e.skill_id, e.skill_name, e.skill_school, e.miss_type, e.amount = select(9, ...)
	-- Process healing events
	elseif string.find(e.event, "HEAL$") then
		if e.event == "SPELL_PERIODIC_HEAL" then e.hot = true end
		e.type = "heal"
		e.skill_id, e.skill_name, e.skill_school, e.amount, e.overheal_amount, e.absorb_amount, e.crit = select(9, ...)
	-- Process power events.
	elseif e.event == "SPELL_ENERGIZE" or e.event == "SPELL_PERIODIC_ENERGIZE" then
		e.type = "power"; e.gain = true
		e.skill_id, e.skill_name, e.skill_school, e.amount, e.power_type = select(9, ...)
	elseif e.event == "SPELL_DRAIN" or e.event == "SPELL_LEECH" or e.event == "SPELL_PERIODIC_DRAIN" or e.event == "SPELL_PERIODIC_LEECH" then
		if string.find(e.event, "DRAIN$") then e.drain = true else e.leech = true end
		e.type = "power"
		e.skill_id, e.skill_name, e.skill_school, e.amount, e.power_type, e.extra_amount = select(9, ...)
	-- Process interrupt events.
	elseif e.event == "SPELL_INTERRUPT" then
		e.type = "interrupt"
		e.skill_id, e.skill_name, e.skill_school, e.extra_skill_id, e.extra_skill_name, e.extra_skill_school = select(9, ...)
	-- Process aura events.
	elseif e.event == "SPELL_AURA_APPLIED" or e.event == "SPELL_AURA_APPLIED_DOSE" or e.event == "SPELL_AURA_REMOVED" or e.event == "SPELL_AURA_REMOVED_DOSE" then
		if string.find(e.event, "REMOVED") then e.fade = true end
		e.type = "aura"
		e.skill_id, e.skill_name, e.skill_school, e.aura_type, e.amount = select(9, ...)
		if not string.find(e.event, "DOSE$") then e.amount = 1 end
	elseif string.find(e.event, "^ENCHANT") then
		if e.event == "ENCHANT_REMOVED" then e.fade = true end
		e.type = "enchant"
		e.skill_name, e.item_id, e.item_name = select(9, ...)
	elseif e.event == "SPELL_DISPEL" or e.event == "SPELL_STOLEN" then
		e.type = "dispel"
		e.skill_id, e.skill_name, e.skill_school, e.extra_skill_id, e.extra_skill_name, e.extra_skill_school, e.aura_type = select(9, ...)
	elseif e.event == "PARTY_KILL" then
		e.type = "kill"
	elseif e.event == "SPELL_EXTRA_ATTACKS" then
		e.type = "extraattacks"
		e.skill_id, e.skill_name, e.skill_school, e.amount = select(9, ...)
	end

	-- If the event failed, recycle the table now.
	if e and e.type then
		return e
	else
		RecSCT:EraseTable(e)
		RecSCT.empty_tables[(#RecSCT.empty_tables or 0)+1] = e
		return nil
	end
end

function RecSCT:HandleCombatEvent(...)
	local we_dont_care = true
	local event = select(2, ...)
	local source = select(3, ...)
	local dest = select(6, ...)
	if not RecSCT.pet and UnitGUID("pet") then RecSCT.pet = UnitGUID("pet") end
	if source ~= RecSCT.player and source ~= RecSCT.pet and dest ~= RecSCT.player and dest ~= RecSCT.pet then return end
	for module, event_table in pairs(RecSCT.event_handlers) do
		if event_table[event] then
			we_dont_care = false
			break
		end
	end
	if we_dont_care then return end

	-- Get event data
	local e = RecSCT:ParseEvent(...)
	if not e then return end

	-- We need to parse our battleground realms, if present, and shorten names if requested
	if e.dest_name and e.dest_guid then e.dest_name = RecSCT:RemovePvPRealm(e.dest_name, e.dest_guid) end
	if e.source_name and e.source_guid then e.source_name = RecSCT:RemovePvPRealm(e.source_name, e.source_guid) end

	-- Queue events for spam if needed.
	for module, event_table in pairs(RecSCT.event_handlers) do
		if event_table[e.event] then
			local queue_type = RecSCT[module].Queue(e)
			if queue_type then
				local queue_table = string.format("%s_queue", queue_type)
				if not e.queued then
					e.queued = true
					e.plugin = module
					RecSCT[queue_table][(#RecSCT[queue_table] or 0) +1] = e
				else
					-- More than one output? Make a copy.
					local f = table.remove(RecSCT.empty_tables,1) or {}
					RecSCT:EraseTable(f)
					for k,v in pairs(e) do
						f[k] = e[k]
					end
					f.plugin = module
					RecSCT[queue_table][(#RecSCT[queue_table] or 0) +1] = f
				end
			else
				RecSCT:GenerateText(e)
			end
		end
	end
	if e.queued then return end

	-- Recycle table when done.
	RecSCT:EraseTable(e)
	RecSCT.empty_tables[(#RecSCT.empty_tables or 0)+1] = e
end

--[[-------------------------------------------------------------------
							   RecSCT
	Some settings have easy access just below this comment block.

	To pipe text in, use this global function:
		RecSCT:AddText(text, crit, scrollarea)
			- text = output text (color it before you send it in, if it
			  needs to be done)
			- crit = any value or nil.  Causes the text to show larger
			  than the other text (by default)
			- scrollarea = "outgoing", "incoming", or "notification" (by default)

TODO:
	*	Need to tableize and recycle event string output parsing?
	*	Don't merge melee with melee-generated effects?
	*	Better (GUID?) check for notification aura event sources.
	*	Allow (more) independent control over scroll area settings.
	*	OnUpdate script(s) need to be removed when there is no animation
		occuring, as it is useless.
	*	Fontstrings need to be stored directly into the tables, rather
		than the current (old) method of being attached to a unique frame.
	*	Lots of other little things which I'm not even going to bother
		listing until I get closer to implementing them! =D
----------------------------------------------------------------------]]

-- To handle events
local event = CreateFrame("Frame")
local last_use = 0

-- Scroll area creation
local function CreateScrollArea(id, height, x_pos, y_pos, textalign)
	-- Make our normal area
	local sa = CreateFrame("Frame", nil, UIParent)
	--[[ Temporary - used to see where the frames are, if needed
	sa:SetBackdrop({ bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], edgeFile = nil, edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0} })
	sa:SetBackdropColor(0, 0, 0, 1) --]]
	sa:SetWidth(1)
	sa:SetHeight(height)
	sa:SetPoint("BOTTOM", UIParent, "BOTTOM", x_pos, y_pos)
	sa.textalign = textalign
	RecSCT.scroll_area_frames[id] = sa

	-- Make our crit area
	local sac = CreateFrame("Frame", nil, UIParent)
	sac:SetWidth(1)
	sac:SetHeight(height)
	sac:SetPoint("BOTTOM", UIParent, "BOTTOM", x_pos, y_pos)
	sac.textalign = textalign
	RecSCT.scroll_area_frames[string.format("%scrit", id)] = sac
end

--[[This function pushes older fontstrings up higher if adding a new one
	would cause it to overlap.  This occurs -before- we insert the new
	text into the fontstring table, but after it is created. --]]
local function CollisionCheck(newtext)
	local destination_scroll_area = RecSCT.anim_strings[newtext.scrollarea]
	local current_animations = #destination_scroll_area
	if current_animations > 0 then -- Only if there are already animations running

		-- Scale the per pixel time based on the animation speed.
		local perPixelTime = RecSCT.animation_movement_speed / newtext.animationSpeed
		local curtext = newtext -- start with our new string
		local previoustext, previoustime

		-- cycle backwards through the table of fontstrings since our newest ones have the highest index
		for x = current_animations, 1, -1 do
			previoustext = destination_scroll_area[x]

			if not newtext.crit then
				-- Calculate the elapsed time for the top point of the previous display event.
				-- TODO: Does this need to be changed since we anchor LEFT and not TOPLEFT?
				previoustime = previoustext.totaltime - (previoustext.fontSize + RecSCT.animation_vertical_spacing) * perPixelTime

				--[[If there is a collision, then we set the older fontstring to a higher animation time
					Which 'pushes' it upward to make room for the new one--]]
				if (previoustime <= curtext.totaltime) then
					previoustext.totaltime = curtext.totaltime + (previoustext.fontSize + RecSCT.animation_vertical_spacing) * perPixelTime
				else
					return -- If there was no collision, then we can safely stop checking for more of them
				end
			else
				previoustext.curpos = previoustext.curpos + (previoustext.fontSize + RecSCT.animation_vertical_spacing)
			end

			-- Check the next one against the current one
			curtext = previoustext
		end
	end
end

-- Animate our texts on update
local function Move(self, elapsed)
	local t
	-- Loop through all active fontstrings
	for k,v in pairs(RecSCT.anim_strings) do

		for l,u in pairs(RecSCT.anim_strings[k]) do
			t = RecSCT.anim_strings[k][l]

			if t and t.inuse then
				--increment it's timer until the animation delay is fulfilled
				t.timer = t.timer + elapsed
				if t.timer >= RecSCT.animation_delay then

					--[[we store it's elapsed time separately so we can continue to delay
						its animation (so we're not updating every onupdate, but can still
						tell what its full animation duration is)--]]
					t.totaltime = t.totaltime + t.timer

					--[[If the animation is not complete, then we need to animate it by moving
						its Y coord (in our sample scrollarea) the proper amount.  If it is complete,
						then we hide it and flag it for recycling --]]
					local percentDone = t.totaltime / RecSCT.animation_duration
					if (percentDone <= 1) then
						t.text:ClearAllPoints()
						if not t.crit then
							t.curpos = RecSCT.scrollframe_height * percentDone -- move up
							t.text:SetPoint(RecSCT.scroll_area_frames[t.scrollarea].textalign, RecSCT.scroll_area_frames[t.scrollarea], "BOTTOMLEFT", 0, t.curpos)
						else
							if t.curpos > RecSCT.scrollframe_height/2 then t.totaltime = 99 end
							t.text:SetPoint(RecSCT.scroll_area_frames[t.scrollarea].textalign, RecSCT.scroll_area_frames[t.scrollarea], RecSCT.scroll_area_frames[t.scrollarea].textalign, 0, t.curpos)
						end

						-- Fade in
						if (percentDone <= 0.05) then t.text:SetAlpha(1 * (percentDone / 0.05))
						-- Fade out
						elseif (percentDone >= 0.80) then t.text:SetAlpha(1 * (1 - percentDone) / (1 - 0.80))
						-- Full vis for times inbetween
						else t.text:SetAlpha(1) end
					else
						t.text:Hide()
						t.inuse = false
					end

					t.timer = 0		--reset our animation delay timer
				end
			end

			--[[Now, we loop backwards through the fontstrings to determine which ones
				can be recycled --]]
			for j = #RecSCT.anim_strings[k], 1, -1 do
				t = RecSCT.anim_strings[k][j]
				if not t.inuse then
					table.remove(RecSCT.anim_strings[k], j)
					-- Place the used frame into our recycled cache
					RecSCT.empty_strings[(#RecSCT.empty_strings or 0) + 1] = t.text
					RecSCT:EraseTable(t)
					RecSCT.empty_tables[(#RecSCT.empty_tables or 0)+1] = t
				end
			end
		end
	end
end

local function PlayerEnteringWorld()
	CreateScrollArea("outgoing", RecSCT.scrollframe_height, 280, 365, "LEFT")
	CreateScrollArea("incoming", RecSCT.scrollframe_height, -280, 365, "RIGHT")
	CreateScrollArea("notification", RecSCT.scrollframe_height, 0, 155, "CENTER")
	RecSCT.scroll_area_frames["outgoing"]:SetScript("OnUpdate", Move)

	RecSCT.player = UnitGUID("player")
end

-- Text processing
-- Scroll text creation, global so you can pipe other text into here
function RecSCT:AddText(text, crit, scrollarea)
	local destination_area
	if not crit then
		destination_area = RecSCT.anim_strings[scrollarea]
	else
		destination_area = RecSCT.anim_strings[scrollarea.."crit"]
	end
	local t
	-- If there are too many frames in the animation area, steal one of them first
	if (#destination_area >= RecSCT.animations_per_scrollframe) then
		t = table.remove(destination_area, 1)

	-- If there are frames in the recycle bin, then snatch one of them!
	elseif #RecSCT.empty_tables > 0 then
		t = table.remove(RecSCT.empty_tables, 1)

	-- If we still don't have a frame, then we'll just have to create a brand new one
	else
		t = {}
	end
	if not t.text then
		t.text = table.remove(RecSCT.empty_strings, 1) or RecSCT.event_frame:CreateFontString(nil, "BORDER")
	end

	-- Settings which need to be set/reset on each fontstring after it is created/obtained
	t.fontSize = t.crit and RecSCT.font_size_crit or RecSCT.font_size_normal
	t.crit = crit
	t.text:SetFont(RecSCT.font, t.fontSize, RecSCT.font_flags)
	t.text:SetText(text)
	t.inuse = true
	t.timer = 0
	t.totaltime = 0
	t.curpos = 0
	t.text:ClearAllPoints()
	if t.crit then
		t.text:SetPoint(RecSCT.scroll_area_frames[scrollarea.."crit"].textalign, RecSCT.scroll_area_frames[scrollarea.."crit"], RecSCT.scroll_area_frames[scrollarea.."crit"].textalign, 0, 0)
		t.text:SetDrawLayer("OVERLAY") -- on top of normal texts.
	else
		t.text:SetPoint(RecSCT.scroll_area_frames[scrollarea].textalign, RecSCT.scroll_area_frames[scrollarea], "BOTTOMLEFT", 0, 0)
		t.text:SetDrawLayer("ARTWORK")
	end
	t.text:SetAlpha(0)
	t.text:Show()
	t.animationSpeed = RecSCT.animation_speed
	t.scrollarea = t.crit and scrollarea.."crit" or scrollarea

	-- Make sure that adding this fontstring will not collide with anything!
	CollisionCheck(t)

	-- Add the fontstring into our table which gets looped through during the OnUpdate
	destination_area[#destination_area+1] = t
	last_use = 0
end

function RecSCT:GenerateText(e)
	-- Loop through each of our events to determine if the event we have should
	-- be inserted into that particular scroll area (allows text to show in multiple
	-- scrollareas

	for module, event_table in pairs(RecSCT.event_handlers) do
		if event_table[e.event] and e.plugin == module then
			RecSCT[module].Handler(e)
		end
	end
	--recycle cur?
	--RecSCT:EraseTable(e)
	--RecSCT.empty_tables[(#RecSCT.empty_tables or 0)+1] = e
end

local function OnEvent(s,e,...)

	-- If the module is looking for an actual event, rather than a combat event, then let's call those handlers
	for module, event_table in pairs(RecSCT.event_handlers) do
		if event_table[e] then
			RecSCT[module].Handler(e, ...)
		end
	end

	-- Combat log event, pass to handler
	if e == "COMBAT_LOG_EVENT_UNFILTERED" then
		RecSCT:HandleCombatEvent(...)
		return

	-- Update our pet's GUID
	elseif e == "UNIT_PET" then
		if select(1, ...) ~= "player" then return end	-- If it's not our pet, then bail
		RecSCT.pet = UnitGUID("pet")	-- Update our pet's GUID.

	-- Setup the scrollframes
	elseif e == "PLAYER_ENTERING_WORLD" then
		PlayerEnteringWorld()
		event:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
end

-- Spam Processing
local spamProcessTimer = 0
local function GroupSpam(num)
	if not num or num == 0 then return end
	local test_event
	local make_group = false
	-- Don't attempt to merge any more events than were available when the function was called since more events may get added while the merge is taking place.
	for i=1,num do
		test_event = RecSCT.spam_ready[i]
		for _, spam_event in ipairs(RecSCT.spam_grouped) do
			if test_event.plugin == spam_event.plugin then
				if test_event.type == spam_event.type then
					if not test_event.skill_name and not spam_event.skill_name then
						if test_event.dest_name == spam_event.dest_name then make_group = true end
					elseif test_event.skill_name == spam_event.skill_name then
						if test_event.dest_guid ~= spam_event.dest_guid then spam_event.dest_name = "Multiple" end
						make_group = true
					end
				end
			end
			if make_group then
				test_event.event_merged = true
				if test_event.amount then spam_event.amount = (spam_event.amount or 0) + test_event.amount end
				if test_event.overheal_amount then spam_event.overheal_amount = (spam_event.overheal_amount or 0) + test_event.overheal_amount end
				spam_event.num_merged = spam_event.num_merged + 1
				if test_event.crit then spam_event.num_crits = spam_event.num_crits + 1 else spam_event.crit = false end
				break
			end
		end
		if not make_group then
			test_event.num_merged = 0
			if test_event.crit then test_event.num_crits = 1 else test_event.num_crits = 0 end

			RecSCT.spam_grouped[(#RecSCT.spam_grouped or 0)+1] = test_event
		end
		make_group = false
	end
	for _, spam in ipairs(RecSCT.spam_grouped) do
		if (spam.num_merged > 0) then
			local crit_trailer = ""
			if (spam.num_crits > 0) then
				crit_trailer = string.format("%d %s", spam.num_crits, spam.num_crits == 1 and "Crit" or "Crits")
				spam.num_merged = spam.num_merged - spam.num_crits
			end
			if (spam.num_crits <= 0) then
				spam.merge_trailer = string.format("(%d %s)", spam.num_merged + 1, "Hits")
			elseif (spam.num_crits > 0) and ((spam.num_merged + 1) > 0) then
				spam.merge_trailer = string.format("(%d %s, %s)", spam.num_merged + 1, "Hits", crit_trailer)
			else
				spam.merge_trailer = string.format("(%s)", crit_trailer)
			end
		end
	end
	for i=1,num do
		if (RecSCT.spam_ready[1].event_merged) then
			RecSCT:EraseTable(RecSCT.spam_ready[1])
			RecSCT.empty_tables[(#RecSCT.empty_tables or 0)+1] = RecSCT.spam_ready[1]
		end
		table.remove(RecSCT.spam_ready, 1)
	end
end

local function OnEventUpdate(s,e)
	spamProcessTimer = spamProcessTimer + e
	if spamProcessTimer >= RecSCT.spam_processing_time then
		GroupSpam(#RecSCT.spam_ready)
		for i, spam in ipairs(RecSCT.spam_grouped) do
			RecSCT:GenerateText(spam)
			RecSCT.spam_grouped[i] = nil
			RecSCT:EraseTable(spam)
			RecSCT.empty_tables[(#RecSCT.empty_tables or 0)+1] = spam
		end
	spamProcessTimer = 0
	end

	-- Keep footprint down by releasing stored tables and strings after we've been idle for a bit.
	last_use = last_use + e
	if last_use > 30 then
		if #RecSCT.empty_tables and #RecSCT.empty_tables > 0 then
			RecSCT.empty_tables = {}
		end
		if #RecSCT.empty_strings and #RecSCT.empty_strings > 0 then
			RecSCT.empty_strings = {}
		end
		last_use = 0
		collectgarbage("collect")
	end
end
local spamTimer = CreateFrame("Frame")
spamTimer:Show()
spamTimer.elapsed = 0
spamTimer.energizeTimer = 0
local function CheckSpam(s,e)
	spamTimer.elapsed = spamTimer.elapsed + e
	if spamTimer.elapsed > RecSCT.spam_queue_time then
		spamTimer.elapsed = 0
		if #RecSCT.spam_queue > 0 then
			for i,spam in ipairs(RecSCT.spam_queue) do
				RecSCT.spam_queue[i] = nil
				RecSCT.spam_ready[(#RecSCT.spam_ready or 0)+1] = spam
			end
		end
	end
	spamTimer.energizeTimer = spamTimer.energizeTimer + e
	if spamTimer.energizeTimer > RecSCT.energize_queue_time then
		spamTimer.energizeTimer = 0
		if #RecSCT.energize_queue > 0 then
			for i,energize in ipairs(RecSCT.energize_queue) do
				RecSCT.energize_queue[i] = nil
				RecSCT.spam_ready[(#RecSCT.spam_ready or 0)+1] = energize
			end
		end
	end
end
spamTimer:SetScript("OnUpdate", CheckSpam)

-- Event frame stuffs!
RecSCT.event_frame = CreateFrame("Frame")
RecSCT.event_frame:SetScript("OnEvent", OnEvent)

event:SetScript("OnEvent", OnEvent)					-- Handles events which may cause text to be shown.
event:SetScript("OnUpdate", OnEventUpdate)			-- Handles the spam queue
event:Show()										-- TODO: We need to hide it, and enable it only when events need processing.
--event:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
event:RegisterEvent("UNIT_PET")
event:RegisterEvent("PLAYER_ENTERING_WORLD")

if not RecSCT.enable_loot_items  then return end

local lootItem					= '^'..LOOT_ITEM_SELF:gsub("%%s", "(.*)")..'$'
local lootCreatedItem			= '^'..LOOT_ITEM_CREATED_SELF:gsub("%%s", ".*")..'$'
local lootMultipleItems			= '^'..LOOT_ITEM_SELF_MULTIPLE:gsub("%%sx%%d", "(.+)x(%%d+)")..'$'
local lootMultipleCreatedItems	= '^'..LOOT_ITEM_CREATED_SELF_MULTIPLE:gsub("%%sx%%d", "(.+)x(%%d+)")..'$'
local OUTPUT_PATTERN = "%s %s %s%s"
local MULTIPLE = "x"
local string_format = string.format
local c = RecSCT.constants

RecSCT.loot_items = {
	-- Spam control settings.
	Queue = function(event) return nil end,
	
	-- Our module's handler
	Handler = function(event, e)
		local item, player, num
		
		-- First we need to check if there are more than one item being looted or created.
		item, num = select(3, e:find(lootMultipleItems))
		if not item then
			item, num = select(3, e:find(lootMultipleCreatedItems))
		end
		
		-- If we didn't find multiple items, then we can safely set num to 1, and just find a single item.
		if not item then
			num = 1
			item = select(3, e:find(lootItem))
		end
		if not item then
			item = select(3, e:find(lootCreatedItem))
		end
		
		if num then num = tonumber(num) end
		
		-- Send the event.
		if item and num then
			RecSCT:AddText(string_format(OUTPUT_PATTERN, c.PLUS, item, num > 1 and MULTIPLE or c.BLANK, num > 1 and num or c.BLANK), nil, c.NOTIFICATION)
		end
	end
}

-- Register handled events
RecSCT.event_handlers["loot_items"] = {
	["CHAT_MSG_LOOT"] = true,
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent("CHAT_MSG_LOOT")

if not RecSCT.enable_loot_money  then return end

local gold_pattern = GOLD_AMOUNT:gsub("%%d", "(%%d+)")
local silver_pattern = SILVER_AMOUNT:gsub("%%d", "(%%d+)")
local copper_pattern = COPPER_AMOUNT:gsub("%%d", "(%%d+)")
local GSC_RETURN_PATTERN = "%d|cffffd700%s|r%d|cffc7c7cf%s|r%d|cffeda55f%s|r"
local SC_RETURN_PATTERN = "%d|cffc7c7cf%s|r%d|cffeda55f%s|r"
local C_RETURN_PATTERN = "%d|cffeda55f%s|r"
local OUTPUT_FORMAT = "+ %s"
local string_format = string.format
local tonum = tonumber
local c = RecSCT.constants

local MoneyToCopper = function(s)
	return (tonum(s:match(gold_pattern)) or 0)*10000 + (tonum(s:match(silver_pattern)) or 0)*100 + (tonum(s:match(copper_pattern)) or 0)
end
local PrettyCopper = function(c, long)
	if c > 10000 then
		return string_format(GSC_RETURN_PATTERN, c/10000, long and GOLD or 'g', (c/100)%100, long and SILVER or 's', c%100, long and COPPER or 'c')
	elseif c > 100 then
		return string_format(SC_RETURN_PATTERN, (c/100)%100, long and SILVER or 's', c%100, long and COPPER or 'c')
	else
		return string_format(C_RETURN_PATTERN, c%100, long and COPPER or 'c')
	end
end

RecSCT.loot_money = {
	-- Spam control settings.
	Queue = function(event) return nil end,
	
	-- Our module's handler
	Handler = function(event, e)
		RecSCT:AddText(string_format(OUTPUT_FORMAT, PrettyCopper(MoneyToCopper(e))), nil, c.NOTIFICATION)
	end
}

-- Register handled events
RecSCT.event_handlers["loot_money"] = {
	["CHAT_MSG_MONEY"] = true,
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent("CHAT_MSG_MONEY")

if not RecSCT.enable_combat_notice  then return end

local string_format = string.format
local ENTERED_COMBAT = "PLAYER_REGEN_DISABLED"
local LEFT_COMBAT = "PLAYER_REGEN_ENABLED"
local OUTPUT_PATTERN = "%s Combat"
local c = RecSCT.constants

RecSCT.combat_notice = {
	-- Spam control settings.
	Queue = function(event) return nil end,
	
	-- Our module's handler
	Handler = function(event)
		if event == ENTERED_COMBAT then
			RecSCT:AddText(string_format(OUTPUT_PATTERN, c.PLUS), nil, c.NOTIFICATION)
		else
			RecSCT:AddText(string_format(OUTPUT_PATTERN, c.MINUS), nil, c.NOTIFICATION)
		end
	end
}

-- Register handled events
RecSCT.event_handlers["combat_notice"] = {
	[LEFT_COMBAT] = true,
	[ENTERED_COMBAT] = true
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent(LEFT_COMBAT)
RecSCT.event_frame:RegisterEvent(ENTERED_COMBAT)

if not RecSCT.enable_experience  then return end

local string_find = string.find
local string_format = string.format
local EXPERIENCE_PATTERN = ".+ gain (%d+) experience"
local OUTPUT_FORMAT ="|cFF7F7FFF+%s XP|r"
local c = RecSCT.constants

RecSCT.experience = {
	-- Spam control settings.
	Queue = function(event, e) return nil end,
	
	-- Our module's handler
	Handler = function(event, e)
		RecSCT:AddText(string_format(OUTPUT_FORMAT, select(3, string_find(e, EXPERIENCE_PATTERN))), false, c.NOTIFICATION)
	end
}

-- Register handled events
RecSCT.event_handlers["experience"] = {
	["CHAT_MSG_COMBAT_XP_GAIN"] = true,
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")

if not RecSCT.enable_reputation  then return end

local string_find = string.find
local string_format = string.format
local INCREASE = "increased"
local REPUTATION_INCREASE = "Reputation with (.+) increased by (%d+)\."
local REPUTATION_DECREASE = "Reputation with (.+) decreased by (%d+)\."
local OUTPUT_FORMAT = "|cFF7F7FFF%s%s %s|r"
local c = RecSCT.constants

RecSCT.reputation = {
	-- Spam control settings.
	Queue = function(e) return nil end,
	
	-- Our module's handler
	Handler = function(event, e)
		local faction, amount
		if string_find(e, INCREASE) then
			faction, amount = select(3, string_find(e, REPUTATION_INCREASE))
			RecSCT:AddText(string_format(OUTPUT_FORMAT, c.PLUS, amount, faction), nil, c.NOTIFICATION)
		else
			faction, amount = select(3, string_find(e, REPUTATION_DECREASE))
			RecSCT:AddText(string_format(OUTPUT_FORMAT, c.MINUS, amount, faction), nil, c.NOTIFICATION)
		end
	end
}

-- Register handled events
RecSCT.event_handlers["reputation"] = {
	["CHAT_MSG_COMBAT_FACTION_CHANGE"] = true,
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")

if not RecSCT.enable_honor  then return end

local string_format = string.format
local string_lower = string.lower
local string_find = string.find
local OUTPUT_FORMAT = "|cFFFFFF00+%s honor|r"
local HONOR_PATTERN = "(%d+) honor points"
local c = RecSCT.constants

RecSCT.honor = {
	-- Spam control settings.
	Queue = function(event, e) return nil end,
	
	-- Our module's handler
	Handler = function(event, e)
		RecSCT:AddText(string_format(OUTPUT_FORMAT, select(3, string_find(string_lower(e), HONOR_PATTERN))), nil, c.NOTIFICATION)
	end
}

-- Register handled events
RecSCT.event_handlers["honor"] = {
	["CHAT_MSG_COMBAT_HONOR_GAIN"] = true,
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN")

if not RecSCT.enable_buffs then return end

local string_format = string.format
local OUTPUT_FORMAT = "|cFF%s%s %s %s %s|r"
local c = RecSCT.constants

RecSCT.buffs = {
	-- Spam control settings.
	Queue = function(e) return "spam" end,
	
	-- Our module's handler
	Handler = function(e)
		-- Bail if not an event we care about.
		if e.dest_guid ~= RecSCT.player then return end
		if e.aura_type ~= c.BUFF then return end
		
		-- Output the text.
		RecSCT:AddText(string_format(OUTPUT_FORMAT,
			RecSCT.school_colors[e.skill_school],
			e.fade and c.MINUS or c.PLUS,
			e.amount > 1 and string_format(c.STACK_FORMAT, e.amount) or c.BLANK,
			e.skill_name and RecSCT:ShortenAbilityName(e.skill_name) or c.BLANK,
			e.source_guid ~= RecSCT.player and e.source_guid ~= UnitGUID("target") and e.source_guid ~= RecSCT.pet and RecSCT:ShortenUnitName(e.source_name, e.source_guid) or c.BLANK),
			false, c.NOTIFICATION)
	end
}

-- Register handled events
RecSCT.event_handlers["buffs"] = {
	["SPELL_AURA_APPLIED"] = true,
	["SPELL_AURA_REMOVED"] = true,
	["SPELL_AURA_APPLIED_DOSE"] = true,
	["SPELL_AURA_REMOVED_DOSE"] = true,
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

if not RecSCT.enable_damage then return end

local string_format = string.format
local OUTPUT_FORMAT = "|cFF%s- %s %s %s %s%s%s%s%s%s%s%s%s|r"
local c = RecSCT.constants

RecSCT.damage = {
	-- Spam control settings.
	Queue = function(e) return "spam" end,
	
	-- Our module's handler
	Handler = function(e)
		-- Bail if not an event we care about.
		if e.dest_guid ~= RecSCT.player and e.dest_guid ~= RecSCT.pet and e.source_guid ~= RecSCT.player and e.source_guid ~= RecSCT.pet then return end
		
		-- Flag for which frame to output to.
		if e.dest_guid ~= RecSCT.player and e.dest_guid ~= RecSCT.pet then e.outgoing = true end
		
		if e.overkill_amount and e.overkill_amount > 0 then
			e.amount = e.amount - e.overkill_amount
			e.overkill_amount = string_format(c.EXTRA_AMOUNT, e.overkill_amount, c.OVERKILL)
		else
			e.overkill_amount = c.BLANK
		end
		if e.resist_amount then e.resist_amount = string_format(c.EXTRA_AMOUNT, e.resist_amount, c.RESISTED) end
		if e.absorb_amount then e.absorb_amount = string_format(c.EXTRA_AMOUNT, e.absorb_amount, c.ABSORBED) end
		if e.block_amount then e.block_amount = string_format(c.EXTRA_AMOUNT, e.block_amount, c.BLOCKED) end
		
		-- Output the text.
		RecSCT:AddText(string_format(OUTPUT_FORMAT,
			(e.event == "SWING_DAMAGE" or e.event == "RANGE_DAMAGE") and RecSCT.school_colors[e.damage_type <= 1 and 0] or e.skill_school and RecSCT.school_colors[e.skill_school] or c.WHITE,
			e.amount or c.BLANK,
			e.skill_name and RecSCT:ShortenAbilityName(e.skill_name) or c.BLANK,
			e.outgoing and e.dest_guid ~= UnitGUID("target") and RecSCT:ShortenUnitName(e.dest_name, e.dest_guid) or not(e.outgoing) and e.source_guid ~= RecSCT.player and e.source_guid ~= UnitGUID("target") and RecSCT:ShortenUnitName(e.source_name, e.source_guid) or c.BLANK,
			e.outgoing and e.source_guid == RecSCT.pet and c.PET or not(e.outgoing) and e.dest_guid == RecSCT.pet and c.PET or c.BLANK,
			e.dot and c.DOT or c.BLANK,
			e.crit and c.CRIT or c.BLANK,
			e.crushing and c.CRUSHING or c.BLANK,
			e.glancing and c.GLANCING or c.BLANK,
			e.absorb_amount or c.BLANK,
			e.overkill_amount or c.BLANK,
			e.resist_amount or c.BLANK,
			e.block_amount or c.BLANK,
			e.merge_trailer or c.BLANK),
			e.crit and true or false, e.outgoing and c.OUTGOING or c.INCOMING)
	end
}

-- Register handled events
RecSCT.event_handlers["damage"] = {
	["SWING_DAMAGE"] = true,
	["RANGE_DAMAGE"] = true,
	["SPELL_DAMAGE"] = true,
	["SPELL_PERIODIC_DAMAGE"] = true,
	["DAMAGE_SHIELD"] = true,
	["DAMAGE_SPLIT"] = true,
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

if not RecSCT.enable_healing then return end

local string_format = string.format
local OVERHEAL_FORMAT = "(%s overheal)"
local OUTPUT_FORMAT = "|cFF00FF00+%s %s %s %s%s%s%s"
local c = RecSCT.constants

RecSCT.healing = {
	-- Spam control settings.
	Queue = function(e) return "spam" end,
	
	-- Our module's handler
	Handler = function(e)
		-- Bail if not an event we care about.
		if e.dest_guid ~= RecSCT.player and e.source_guid ~= RecSCT.player then return end
		
		-- Flag for which frame to output to.
		if e.dest_guid ~= RecSCT.player then e.outgoing = true end
		
		if not(e.outgoing) and e.amount and e.overheal_amount and (e.amount - e.overheal_amount == 0) and e.hot then return end
		
		-- Output the text.
		RecSCT:AddText(string_format(OUTPUT_FORMAT,
			e.amount and e.amount - (e.overheal_amount or 0) or c.BLANK,
			e.skill_name and RecSCT:ShortenAbilityName(e.skill_name) or c.BLANK,
			e.outgoing and e.dest_guid ~= UnitGUID("target") and RecSCT:ShortenUnitName(e.dest_name, e.dest_guid) or not e.outgoing and e.source_guid ~= RecSCT.player and RecSCT:ShortenUnitName(e.source_name, e.source_guid) or c.BLANK,
			e.hot and c.HOT or c.BLANK,
			e.crit and c.CRIT or c.BLANK,
			e.overheal_amount and e.overheal_amount > 0 and string_format(OVERHEAL_FORMAT, e.overheal_amount) or c.BLANK,
			e.merge_trailer or c.BLANK),
			e.crit and true or false, e.outgoing and c.OUTGOING or c.INCOMING)
	end
}

-- Register handled events
RecSCT.event_handlers["healing"] = {
	["SPELL_HEAL"] = true,
	["SPELL_PERIODIC_HEAL"] = true,
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

if not RecSCT.enable_power then return end

local OUTPUT_FORMAT = "|cFF%s+%s %s %s %s|r"
local string_format = string.format
local c = RecSCT.constants

RecSCT.power = {
	-- Spam control settings.
	Queue = function(e) return "energize" end,
	
	-- Our module's handler
	Handler = function(e)
		-- Bail if not an event we care about.
		if e.dest_guid ~= RecSCT.player then return end
		
		-- Output the text.
		RecSCT:AddText(string_format(OUTPUT_FORMAT,
			e.power_type and RecSCT.power_colors[e.power_type] or c.WHITE,
			e.amount and e.amount > 0 and e.amount or c.BLANK,
			e.skill_name and RecSCT:ShortenAbilityName(e.skill_name) or c.BLANK,
			e.source_guid ~= RecSCT.player and RecSCT:ShortenUnitName(e.source_name, e.source_guid) or c.BLANK,
			e.merge_trailer or c.BLANK),
			false, c.NOTIFICATION)
	end
}

-- Register handled events
RecSCT.event_handlers["power"] = {
	["SPELL_ENERGIZE"] = true,
	["SPELL_PERIODIC_ENERGIZE"] = true,
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

if not RecSCT.enable_debuffs then return end

local string_format = string.format
local OUTPUT_FORMAT = "|cFF%s%s%s%s %s|r"
local c = RecSCT.constants

RecSCT.debuffs = {
	-- Spam control settings.
	Queue = function(e) return "spam" end,
	
	-- Our module's handler
	Handler = function(e)
		-- Bail if not an event we care about.
		if e.dest_guid == RecSCT.pet then return end	-- If the debuff is going to our pet
		if e.source_guid == RecSCT.pet then return end	-- If the debuff came from our pet
		if e.aura_type ~= c.DEBUFF then return end		-- If it is not a DEbuff
		
		-- Flag for which frame to output to.
		if e.dest_guid ~= RecSCT.player then e.outgoing = true end
		
		-- Output the text.
		RecSCT:AddText(string_format(OUTPUT_FORMAT,
			e.skill_school and RecSCT.school_colors[e.skill_school] or c.WHITE,
			e.fade and c.MINUS or c.PLUS,
			e.amount > 1 and string_format(c.STACK_FORMAT, e.amount) or c.BLANK,
			e.skill_name and RecSCT:ShortenAbilityName(e.skill_name) or c.BLANK,
			e.outgoing and e.dest_guid ~= UnitGUID("target") and RecSCT:ShortenUnitName(e.dest_name, e.dest_guid) or not e.outgoing and e.source_guid ~= RecSCT.player and RecSCT:ShortenUnitName(e.source_name, e.source_guid) or c.BLANK),
			false, e.outgoing and c.OUTGOING or c.INCOMING)
	end
}

-- Register handled events
RecSCT.event_handlers["debuffs"] = {
	["SPELL_AURA_APPLIED"] = true,
	["SPELL_AURA_REMOVED"] = true,
	["SPELL_AURA_APPLIED_DOSE"] = true,
	["SPELL_AURA_REMOVED_DOSE"] = true,
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

if not RecSCT.enable_killing_blow then return end

local tonum = tonumber
local string_format = string.format
local OUTPUT_FORMAT = "|cFFFF0000 Killing Blow %s %s"
local c = RecSCT.constants

RecSCT.killing_blow = {
	-- Spam control settings.
	Queue = function(e) return "spam" end,
	
	-- Our module's handler
	Handler = function(e)
		-- Bail if not an event we care about.
		if e.source_guid ~= RecSCT.player then return end
		if e.dest_guid == RecSCT.pet then return end
		if tonum(e.dest_guid:sub(5,5), 16)%8 > 3 then return end	-- If we did not kill a player or npc
		
		RecSCT:AddText(string_format(OUTPUT_FORMAT, 
			e.dest_name and RecSCT.MINUS or c.BLANK,
			e.dest_name and RecSCT:ShortenUnitName(e.dest_name, e.dest_guid) or c.BLANK),
			true, c.NOTIFICATION)
	end
}

-- Register handled events
RecSCT.event_handlers["killing_blow"] = {
	["PARTY_KILL"] = true,
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

if not RecSCT.enable_misses then return end

local string_format = string.format
local OUTPUT_FORMAT = "|cFF%s%s%s%s%s%s|r"
local MINUS = "- 0"
local c = RecSCT.constants

RecSCT.misses = {
	-- Spam control settings.
	Queue = function(e) return "spam" end,
	
	-- Our module's handler
	Handler = function(e)
		-- Bail if not an event we care about.
		if e.dest_guid ~= RecSCT.player and e.dest_guid ~= RecSCT.pet and e.source_guid ~= RecSCT.player and e.source_guid ~= RecSCT.pet then return end
		
		-- Flag for which frame to output to.
		if e.dest_guid ~= RecSCT.player and e.dest_guid ~= RecSCT.pet then e.outgoing = true end

		-- Output the text.
		RecSCT:AddText(string_format(OUTPUT_FORMAT,
			e.skill_school and RecSCT.school_colors[(e.skill_school > 1 and e.skill_school) or 0] or c.WHITE,
			e.amount and MINUS or c.BLANK,
			e.skill_name and string_format(c.TARGET_FORMAT, RecSCT:ShortenAbilityName(e.skill_name)) or c.BLANK,
			e.outgoing and e.dest_guid ~= UnitGUID("target") and string_format(c.TARGET_FORMAT, RecSCT:ShortenUnitName(e.dest_name, e.dest_guid)) or not(e.outgoing) and e.source_guid ~= RecSCT.player and e.source_guid ~= UnitGUID("target") and string_format(c.TARGET_FORMAT, RecSCT:ShortenUnitName(e.source_name, e.source_guid)) or c.BLANK,
			e.outgoing and e.source_guid == RecSCT.pet and string_format(c.TARGET_FORMAT, c.PET) or not(e.outgoing) and e.dest_guid == RecSCT.pet and string_format(c.TARGET_FORMAT, c.PET) or c.BLANK,
			e.amount and string_format(c.EXTRA_AMOUNT, e.amount, e.miss_type and RecSCT.miss_printable[e.miss_type] or c.MISS) or string_format(c.MISS_FORMAT, e.miss_type and RecSCT.miss_printable[e.miss_type] or c.MISS),
			e.merge_trailer or c.BLANK),
			false, e.outgoing and c.OUTGOING or c.INCOMING)
	end
}

-- Register handled events
RecSCT.event_handlers["misses"] = {
	["SWING_MISSED"] = true,
	["SPELL_MISSED"] = true,
	["SPELL_PERIODIC_MISSED"] = true,
	["RANGE_MISSED"] = true,
	["DAMAGE_SHIELD_MISSED"] = true,
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

if not RecSCT.enable_environmental then return end

local string_format = string.format
local OUTPUT_FORMAT = "|cFFFF0000- %s %s %s%s%s%s%s%s%s%s"
local c = RecSCT.constants

RecSCT.environmental = {
	-- Spam control settings.
	Queue = function(e) return "spam" end,
	
	-- Our module's handler
	Handler = function(e)
		-- Bail if not an event we care about.
		if e.dest_guid ~= RecSCT.player then return end
		
		if e.overkill_amount and e.overkill_amount > 0 then
			e.amount = e.amount - e.overkill_amount
			e.overkill_amount = string_format(c.EXTRA_AMOUNT, e.overkill_amount, c.OVERKILL)
		else
			e.overkill_amount = c.BLANK
		end
		if e.resist_amount then e.resist_amount = string_format(c.EXTRA_AMOUNT, e.resist_amount, c.RESISTED) end
		if e.absorb_amount then e.absorb_amount = string_format(c.EXTRA_AMOUNT, e.absorb_amount, c.ABSORBED) end
		if e.block_amount then e.block_amount = string_format(c.EXTRA_AMOUNT, e.block_amount, c.BLOCKED) end
		
		-- Output the text.
		RecSCT:AddText(string_format(OUTPUT_FORMAT,
			e.amount,
			e.hazard_type and RecSCT.environment_printable[e.hazard_type] or c.BLANK,
			e.crit and c.CRIT or c.BLANK,
			e.crushing and c.CRUSHING or c.BLANK,
			e.glancing and c.GLANCING or c.BLANK,
			e.absorb_amount or c.BLANK,
			e.overkill_amount,
			e.resist_amount or c.BLANK,
			e.block_amount or c.BLANK,
			e.merge_trailer or c.BLANK),
			e.crit and true or false, c.INCOMING)
	end
}

-- Register handled events
RecSCT.event_handlers["environmental"] = {
	["ENVIRONMENTAL_DAMAGE"] = true,
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")