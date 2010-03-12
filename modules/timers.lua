local _, recUI = ...

if recUI.lib.playerClass == "HUNTER" then
	local recAutoShot = CreateFrame("StatusBar")
	recAutoShot:SetStatusBarTexture(recUI.media.statusBar)
	recAutoShot:SetStatusBarColor(1, .3, .3, .8)
	recAutoShot:SetPoint("CENTER")
	recAutoShot:SetSize(200, 10)
	recAutoShot:Hide()

	recAutoShot.backdrop = recAutoShot:CreateTexture(nil, "BACKGROUND")
	recAutoShot.backdrop:SetPoint("TOPLEFT", -2, 2)
	recAutoShot.backdrop:SetPoint("BOTTOMRIGHT", 2, -2)
	recAutoShot.backdrop:SetTexture(recUI.media.bgFile)
	recAutoShot.backdrop:SetVertexColor(0, 0, 0, .5)

	recAutoShot.label = recAutoShot:CreateFontString(nil, "OVERLAY")
	recAutoShot.label:SetPoint("LEFT", 5)
	recAutoShot.label:SetFont(recUI.media.font, 8, "THINOUTLINE")
	recAutoShot.label:SetText("Auto Shot")

	recAutoShot.time = recAutoShot:CreateFontString(nil, "OVERLAY")
	recAutoShot.time:SetPoint("RIGHT", -5)
	recAutoShot.time:SetFont(recUI.media.font, 8, "THINOUTLINE")

	local currentTime, startTime, endTime
	recAutoShot:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	recAutoShot:SetScript("OnEvent", function(self, event, unit, name)
		if unit ~= "player" then return end
		if name ~= "Auto Shot" then return end

		startTime = GetTime()
		endTime = startTime + UnitRangedDamage("player")
		
		self:SetMinMaxValues(startTime, endTime)
		self.time:SetText(" ")
		self:Show()
	end)

	recAutoShot:SetScript("OnUpdate", function(self, elapsed)
		currentTime = GetTime()
		if currentTime > endTime then
			self:Hide()
		else
			local elapsed = (currentTime - startTime)
			self:SetValue(startTime + elapsed)
			self.time:SetFormattedText("%.1f", endTime - currentTime)
		end
	end)
end

recUI.timers = {}
local event_frame = CreateFrame("Frame")
local floor = math.floor
local mod = mod
local format = string.format
local pairs = pairs
local UnitBuff, UnitDebuff = UnitBuff, UnitDebuff
local font_face    = recUI.media.font
local font_size    = 9
local font_outline = ""
local texture      = recUI.media.statusBar
local edge_file    = recUI.media.edgeFile
local bg_file      = recUI.media.bgFile
local aura_colors  = {
	["Magic"]   = {r = 0.00, g = 0.25, b = 0.45}, 
	["Disease"] = {r = 0.40, g = 0.30, b = 0.10}, 
	["Poison"]  = {r = 0.00, g = 0.40, b = 0.10}, 
	["Curse"]   = {r = 0.40, g = 0.00, b = 0.40},
	["None"]    = {r = 0.40, g = 0.40, b = 0.40}
}

local bars = {}

local function pretty_time(s)
	-- Caellian's version
	local day, hour, minute = 86400, 3600, 60
	if s >= day then
		return format("%dd", floor(s/day + 0.5)), s % day
	elseif s >= hour then
		return format("%dh", floor(s/hour + 0.5)), s % hour
	elseif s >= minute then
		if s <= minute * 5 then
			return format("%d:%02d", floor(s/60), s % minute), s - floor(s)
		end
		return format("%dm", floor(s/minute + 0.5)), s % minute
	elseif s >= minute / 12 then
		return floor(s + 0.5), (s * 100 - floor(s * 100))/100
	end
	return format("%.1f", s), (s * 100 - floor(s * 100))/100
end

local function on_update(self, elapsed)
	self.timer = self.timer - elapsed
	
	if self.timer > 0 then return end
	self.timer = 0.1
	
	if self.active then
		if self.expires >= GetTime() then
			self:SetValue(self.expires - GetTime())
			self:SetMinMaxValues(0, self.duration)
			if not self.hide_name then
				self.lbl:SetText(format("%s%s - %s", self.spell_name, self.count > 1 and format(" x%d", self.count) or "", pretty_time(self.expires - GetTime())))
			else
				self.lbl:SetText(format("%s", pretty_time(self.expires - GetTime())))
			end
		else
			self.active = false
		end
	end
	
	if not self.active then
		self:Hide()
	end
end

-- Function to position bar based on talent spec.
local function position_bar(bar)
	local spec = GetActiveTalentGroup()
	bar:ClearAllPoints()
	bar:SetPoint(bar.position[spec].attach_point, bar.position[spec].parent_frame, bar.position[spec].relative_point, bar.position[spec].x_offset, bar.position[spec].y_offset)
end

recUI.timers.make_bar = function(self, spell_name, unit, buff_type, only_self, r, g, b, width, height, attach_point1, parent_frame1, relative_point1, x_offset1, y_offset1, attach_point2, parent_frame2, relative_point2, x_offset2, y_offset2, hide_name)
	local new_id = (#bars or 0) + 1
	bars[new_id] = CreateFrame("StatusBar", format("recTimers_Bar_%d", new_id), parent_frame)
	bars[new_id]:SetHeight(height)
	bars[new_id]:SetWidth(width)
	bars[new_id].spell_name = spell_name
	bars[new_id].unit = unit
	bars[new_id].buff_type = buff_type
	bars[new_id].only_self = only_self
	bars[new_id].hide_name = hide_name
	bars[new_id].count     = 0
	bars[new_id].active    = false
	bars[new_id].expires   = 0
	bars[new_id].duration  = 0
	bars[new_id].timer     = 0
	
	-- Store values for each talent spec position.
	bars[new_id].position = {
		-- Talent spec 1 references
		[1] = {
			attach_point   = attach_point1,
			parent_frame   = parent_frame1,
			relative_point = relative_point1,
			x_offset       = x_offset1,
			y_offset       = y_offset1
		},
		-- Talent spec 2 references - default to spec 1 values if user did not provide them.
		[2] = {
			attach_point   = attach_point2   or attach_point1,
			parent_frame   = parent_frame2   or parent_frame1,
			relative_point = relative_point2 or relative_point1,
			x_offset       = x_offset2       or x_offset1,
			y_offset       = y_offset2       or y_offset1
		}
	}
	
	bars[new_id].tx = bars[new_id]:CreateTexture(nil, "ARTWORK")
	bars[new_id].tx:SetAllPoints()
	bars[new_id].tx:SetTexture(texture)
	-- Color bar with user values unless they enter nil values.  If so, then we color bar based on aura type
	if r and g and b then
		bars[new_id].tx:SetVertexColor(r, g, b, 1)
	else
		bars[new_id].auto_color = true
	end
	bars[new_id]:SetStatusBarTexture(bars[new_id].tx)

	bars[new_id].soft_edge = CreateFrame("Frame", nil, bars[new_id])
	bars[new_id].soft_edge:SetPoint("TOPLEFT", -4, 3.5)
	bars[new_id].soft_edge:SetPoint("BOTTOMRIGHT", 4, -4)
	bars[new_id].soft_edge:SetBackdrop({
		bgFile = bg_file,
		edgeFile = edge_file, edgeSize = 4,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	})
	bars[new_id].soft_edge:SetFrameStrata("BACKGROUND")
	bars[new_id].soft_edge:SetBackdropColor(0.15, 0.15, 0.15, 1)
	bars[new_id].soft_edge:SetBackdropBorderColor(0, 0, 0)

	bars[new_id].bg = bars[new_id]:CreateTexture(nil, "BORDER")
	bars[new_id].bg:SetPoint("TOPLEFT")
	bars[new_id].bg:SetPoint("BOTTOMRIGHT")
	bars[new_id].bg:SetTexture(texture)
	bars[new_id].bg:SetVertexColor(0.25, 0.25, 0.25, 1)

	bars[new_id].icon = bars[new_id]:CreateTexture(nil, "BORDER")
	bars[new_id].icon:SetHeight(height)
	bars[new_id].icon:SetWidth(height)
	bars[new_id].icon:SetPoint("TOPRIGHT", bars[new_id], "TOPLEFT", 0, 0)
	bars[new_id].icon:SetTexture(nil)
	
	bars[new_id].lbl = bars[new_id]:CreateFontString(format("recTimers_BarLabel_%d", new_id), "OVERLAY")
	bars[new_id].lbl:SetFont(recUI.media.font, 8, "THINOUTLINE")
	bars[new_id].lbl:SetPoint("CENTER", bars[new_id], "CENTER", 0, 1)
	
	position_bar(bars[new_id])
	
	bars[new_id]:Hide()
end

local function check_buffs()
	for _, bar in pairs(bars) do
		local icon, count, duration, expiration, caster
		
		if bar.buff_type == "buff" then
			_, _, icon, count, aura_type, duration, expiration, caster = UnitBuff(bar.unit, bar.spell_name)
		else
			_, _, icon, count, aura_type, duration, expiration, caster = UnitDebuff(bar.unit, bar.spell_name)
		end
		
		if icon and (not(bar.only_self) or (bar.only_self and (caster == "player"))) then
			--bar.icon:SetTexture(icon)
			bar.count = count
			bar.active = true
			bar.expires = expiration
			bar.duration = duration
			
			if duration and duration > 0 then
				bar:SetScript("OnUpdate", on_update)
			else
				bar:SetScript("OnUpdate", nil)
				bar.lbl:SetText(format("%s%s", bar.spell_name, bar.count > 1 and format("(%d)", bar.count) or ""))
			end
			
			-- If we need to color the bar automatically, do so.
			if bar.auto_color then
				bar.tx:SetVertexColor(aura_colors[aura_type or "None"].r, aura_colors[aura_type or "None"].g, aura_colors[aura_type or "None"].b, 1)
			end
			
			bar:Show()
		end
	end
end

local function on_cleu(...)
	local _, event, source_guid, _, _, dest_guid, _, _, spell_id, spell_name, _, _ = ...
	if spell_name then
	
			if event == "SPELL_AURA_REMOVED" then
				for _, bar in pairs(bars) do
					if dest_guid == UnitGUID(bar.unit) and spell_name == bar.spell_name then
						if not(bar.only_self) or (bar.only_self and (source_guid == UnitGUID("player"))) then
							bar.count = 0
							bar.active = false
							bar.expires = 0
							bar:Hide()
						end
					end
				end
			end
		
		return check_buffs()
	end
end

event_frame:RegisterEvent("PLAYER_TARGET_CHANGED")
event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
event_frame:RegisterEvent("PLAYER_ENTERING_WORLD")
event_frame:RegisterEvent("PLAYER_TALENT_UPDATE")
event_frame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_TARGET_CHANGED" then
		for _, bar in pairs(bars) do
			if bar.unit == "target" then
				bar:Hide()
			end
		end
		check_buffs()
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		on_cleu(...)
	elseif event == "PLAYER_ENTERING_WORLD" then
		check_buffs()
	elseif event == "PLAYER_TALENT_UPDATE" then
		for index, _ in pairs(bars) do
			position_bar(bars[index])
		end
	end
end)

local class = recUI.lib.playerClass
local level = UnitLevel("player")

-- Bar creation reference.
--
-- t.make_bar = function(self, spell_name, unit, buff_type, only_self, r, g, b, width, height, attach_point1, parent_frame1, relative_point1, x_offset1, y_offset1, attach_point2, parent_frame2, relative_point2, x_offset2, y_offset2, hide_name)
--
-- spell_name:    Name of the buff/debuff.
-- unit:          Unit to monitor (player, target, focus, party1, etc)
-- buff_type:     Buff or debuff.
-- only_self:     If set to false, timer will always show if buff/debuff is present.  If set to true, timer will only show if you were the player who cast the buff/debuff.
-- r, g, b:       Color of the timer bar.  If nil, they will automatically color to aura type. (poison, curse, etc)
-- width, height: Width and height of the timer bar.
--
-- The first set of points positions the bar for your primary talent spec.
-- attach_point1:        Which point on the timer to use when positioning the bar.
-- parent_frame1:        Which frame to use when positioning the bar.  Normally UIParent.
-- relative_point1:      Which point of the parent_frame to use when positioning the bar.
-- x_offset1, y_offset1: X/Y offset values from the attach point.
-- attach_point2, parent_frame2, relative_point2, x_offset2, y_offset2: Secondary talent spec values.  You may enter 'nil' to use the same values as primary spec.
-- 
-- hide_name:   This will hide the name of the buff/debuff if set to true.  You may need to set this if your bar is too short to contain the name.

-- EVERYONE
	--t:make_bar("Well Fed",		"player", "buff",	false, .4, .4, .4,	200, 10, "CENTER", UIParent, "CENTER", 0, 0)
	--t:make_bar("Toasty Fire",	"player", "buff",	false, .4, .4, .4,	200, 10, "CENTER", UIParent, "CENTER", 0, 0)
	
-- LEVELBASED
if level == 80 then
	--t:make_bar("Well Fed",		"player", "buff",	false, .4, .4, .4,	200, 10, "CENTER", UIParent, "CENTER", 0, 0)
end

-- DEATHKNIGHT
if class == "DEATHKNIGHT" then
	recUI.timers:make_bar("Blood Plague",		"target", "debuff", true,	0, .5, 0,	200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	recUI.timers:make_bar("Frost Fever",		"target", "debuff", true,	0, .5, .5,	200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 328)
	recUI.timers:make_bar("Horn of Winter",	"player", "buff",	false, nil, nil, nil,	200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 344, nil, nil, nil, 0, 355)
end

-- DRUID
if class == "DRUID" then
	recUI.timers:make_bar("Entangling Roots",    "target", "debuff", false, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	recUI.timers:make_bar("Moonfire",            "target", "debuff", false, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	recUI.timers:make_bar("Faerie Fire",         "target", "debuff", false, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	recUI.timers:make_bar("Faerie Fire (Feral)", "target", "debuff", false, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	recUI.timers:make_bar("Rake",                "target", "debuff", false, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	recUI.timers:make_bar("Rip",                 "target", "debuff", false, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	recUI.timers:make_bar("Mangle (Cat)",        "target", "debuff", false, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	recUI.timers:make_bar("Lacerate",            "target", "debuff", false, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	recUI.timers:make_bar("Demoralizing Roar",   "target", "debuff", false, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	recUI.timers:make_bar("Mangle (Bear)",       "target", "debuff", false, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	recUI.timers:make_bar("Gift of the Wild",    "player", "buff",   false, .5, 0, .5, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	recUI.timers:make_bar("Mark of the Wild",    "player", "buff",   false, .5, 0, .5, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	recUI.timers:make_bar("Thorns",              "player", "buff",   false, .3, .2, .1, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 329)
end

-- HUNTER
if class == "HUNTER" then
	recUI.timers:make_bar("Serpent Sting", "target", "debuff", true, 0.0, 0.35, 0.0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 328)
	recUI.timers:make_bar("Hunter's Mark", "target", "debuff", false, 0.4, 0.0, 0.0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
end

-- MAGE
if class == "MAGE" then
	recUI.timers:make_bar("Scorch",				"target", "debuff",	false, 1.0, 0.0, 0.0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	recUI.timers:make_bar("Ice Barrier",			"player", "buff",	false, 0.0, 0.5, 0.5, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 329)
	recUI.timers:make_bar("Missile Barrage",		"player", "buff",	false, 1.0, 0.0, 0.0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 346)
	recUI.timers:make_bar("Dalaran Intellect",		"player", "buff",	false, 0.0, 0.0, 0.5, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 363)
	recUI.timers:make_bar("Dalaran Brilliance",	"player", "buff",	false, 0.0, 0.0, 0.5, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 363)
	recUI.timers:make_bar("Arcane Intellect",		"player", "buff",	false, 0.0, 0.0, 0.5, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 363)
	recUI.timers:make_bar("Arcane Brilliance",		"player", "buff",	false, 0.0, 0.0, 0.5, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 363)
	recUI.timers:make_bar("Molten Armor",			"player", "buff",	false, 0.5, 0.2, 0.0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 380)
end

-- PALADIN
if class == "PALADIN" then
	recUI.timers:make_bar("Judgement of Wisdom",	"target", "debuff",	false,	0.0, 0.42, 0.53, 230,  10, "BOTTOM", UIParent, "BOTTOM", 278, 370)
	recUI.timers:make_bar("Judgement of Light",	"target", "debuff",	false,	0.6, 0.60, 0.00, 230,  10, "BOTTOM", UIParent, "BOTTOM", 278, 387)
	recUI.timers:make_bar("Judgement of Justice",	"target", "debuff",	false,	0.5, 0.30, 0.09, 230,  10, "BOTTOM", UIParent, "BOTTOM", 278, 404)
	recUI.timers:make_bar("Blessing of Sanctuary",	"player", "buff",	false,	0.0, 0.00, 0.50, 57.5, 10, "BOTTOM", UIParent, "BOTTOM", -192, 404, true)
	recUI.timers:make_bar("Blessing of Wisdom",	"player", "buff",	false,	0.0, 0.50, 0.50, 57.5, 10, "BOTTOM", UIParent, "BOTTOM", -192 - 57.5, 404, true)
	recUI.timers:make_bar("Blessing of Might",		"player", "buff",	false,	0.4, 0.00, 0.00, 57.5, 10, "BOTTOM", UIParent, "BOTTOM", -192 - 115, 404, true)
	recUI.timers:make_bar("Blessing of Kings",		"player", "buff",	false,	0.6, 0.60, 0.00, 57.5, 10, "BOTTOM", UIParent, "BOTTOM", -192 - 172, 404, true)
	recUI.timers:make_bar("Seal of Righteousness",	"player", "buff",	true,	0.6, 0.60, 0.00, 230,  10, "BOTTOM", UIParent, "BOTTOM", -278, 387)
	recUI.timers:make_bar("Seal of Wisdom",		"player", "buff",	true,	1.0, 0.00, 0.00, 230,  10, "BOTTOM", UIParent, "BOTTOM", -278, 387)
	recUI.timers:make_bar("Seal of Justice",		"player", "buff",	true,	0.5, 0.30, 0.09, 230,  10, "BOTTOM", UIParent, "BOTTOM", -278, 387)
	recUI.timers:make_bar("Seal of Light",			"player", "buff",	true,	0.6, 0.60, 0.00, 230,  10, "BOTTOM", UIParent, "BOTTOM", -278, 387)
	recUI.timers:make_bar("Righteous Fury",		"player", "buff",	true,	0.5, 0.30, 0.09, 230,  10, "BOTTOM", UIParent, "BOTTOM", -278, 370)
end

-- PRIEST
if class == "PRIEST" then
	recUI.timers:make_bar("Shadow Word: Pain",		"target", "debuff", true, 0.4, 0.0, 0.6, 200, 10, "BOTTOM", UIParent, "BOTTOM", 263, 416)
	recUI.timers:make_bar("Shadow Word: Death",	"target", "debuff", true, 0.4, 0.0, 0.6, 200, 10, "BOTTOM", UIParent, "BOTTOM", 263, 399)
	recUI.timers:make_bar("Weakened Soul",			"target", "debuff", true, 0.5, 0.1, 0.0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 263, 382)
	recUI.timers:make_bar("Renew",					"target", "buff",	true, 0.0, 0.6, 0.0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 263, 365)
	recUI.timers:make_bar("Weakened Soul",			"player", "debuff", true, 0.5, 0.1, 0.0, 200, 10, "BOTTOM", UIParent, "BOTTOM", -263, 433)
	recUI.timers:make_bar("Inner Fire",			"player", "buff",	true, 0.6, 0.6, 0.0, 200, 10, "BOTTOM", UIParent, "BOTTOM", -263, 416)
	recUI.timers:make_bar("Power Word: Fortitude",	"player", "buff",	true, 0.5, 0.6, 0.6, 200, 10, "BOTTOM", UIParent, "BOTTOM", -263, 399)
	recUI.timers:make_bar("Prayer of Fortitude",	"player", "buff",	true, 0.5, 0.6, 0.6, 200, 10, "BOTTOM", UIParent, "BOTTOM", -263, 399)
	recUI.timers:make_bar("Divine Spirit",			"player", "buff",	true, 0.6, 0.6, 0.0, 200, 10, "BOTTOM", UIParent, "BOTTOM", -263, 382)
	recUI.timers:make_bar("Prayer of Spirit",		"player", "buff",	true, 0.6, 0.6, 0.0, 200, 10, "BOTTOM", UIParent, "BOTTOM", -263, 382)
	recUI.timers:make_bar("Fade",					"player", "buff",	true, 0.0, 0.5, 0.6, 200, 10, "BOTTOM", UIParent, "BOTTOM", -263, 365)
	recUI.timers:make_bar("Power Word: Fortitude",	"party1", "buff",	true, 0.5, 0.6, 0.6,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 399, true)
	recUI.timers:make_bar("Prayer of Fortitude",	"party1", "buff",	true, 0.5, 0.6, 0.6,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 399, true)
	recUI.timers:make_bar("Divine Spirit",			"party1", "buff",	true, 0.6, 0.6, 0.0,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 382, true)
	recUI.timers:make_bar("Prayer of Spirit",		"party1", "buff",	true, 0.6, 0.6, 0.0,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 382, true)
	recUI.timers:make_bar("Power Word: Fortitude",	"party2", "buff",	true, 0.5, 0.6, 0.6,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 399, true)
	recUI.timers:make_bar("Prayer of Fortitude",	"party2", "buff",	true, 0.5, 0.6, 0.6,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 399, true)
	recUI.timers:make_bar("Divine Spirit",			"party2", "buff",	true, 0.6, 0.6, 0.0,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 382, true)
	recUI.timers:make_bar("Prayer of Spirit",		"party2", "buff",	true, 0.6, 0.6, 0.0,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 382, true)
	recUI.timers:make_bar("Power Word: Fortitude",	"party3", "buff",	true, 0.5, 0.6, 0.6,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 399, true)
	recUI.timers:make_bar("Prayer of Fortitude",	"party3", "buff",	true, 0.5, 0.6, 0.6,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 399, true)
	recUI.timers:make_bar("Divine Spirit",			"party3", "buff",	true, 0.6, 0.6, 0.0,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 382, true)
	recUI.timers:make_bar("Prayer of Spirit",		"party3", "buff",	true, 0.6, 0.6, 0.0,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 382, true)
	recUI.timers:make_bar("Power Word: Fortitude",	"party4", "buff",	true, 0.5, 0.6, 0.6,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 399, true)
	recUI.timers:make_bar("Prayer of Fortitude",	"party4", "buff",	true, 0.5, 0.6, 0.6,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 399, true)
	recUI.timers:make_bar("Divine Spirit",			"party4", "buff",	true, 0.6, 0.6, 0.0,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 382, true)
	recUI.timers:make_bar("Prayer of Spirit",		"party4", "buff",	true, 0.6, 0.6, 0.0,  40, 10, "BOTTOM", UIParent, "BOTTOM", 0, 382, true)
end

-- ROGUE
if class == "ROGUE" then
	recUI.timers:make_bar("Deadly Poison",  "target", "debuff", true, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	recUI.timers:make_bar("Slice and Dice", "player", "buff",   true, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	recUI.timers:make_bar("Rupture",        "target", "debuff", true, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	recUI.timers:make_bar("Sap",            "target", "debuff", true, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	recUI.timers:make_bar("Sap",            "focus",  "debuff", true, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	recUI.timers:make_bar("Garrote",        "target", "debuff", true, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	recUI.timers:make_bar("Cheap Shot",     "target", "debuff", true, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	recUI.timers:make_bar("Kidney Shot",    "target", "debuff", true, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	recUI.timers:make_bar("Blind",          "target", "debuff", true, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	recUI.timers:make_bar("Gouge",          "target", "debuff", true, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	recUI.timers:make_bar("Evasion",        "player", "buff",   true, 1, 0, 0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
end

-- SHAMAN
if class == "SHAMAN" then
	recUI.timers:make_bar("Tidal Waves",	"player",	"buff",		true, 0.0, 0.0, 1.0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 277)
	recUI.timers:make_bar("Water Shield",	"player",	"buff",		true, 0.3, 0.3, 0.6, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 293)
	recUI.timers:make_bar("Earth Shield",	"focus",	"buff",		true, 0.6, 0.6, 0.3, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 305)
	recUI.timers:make_bar("Flame Shock",	"target",	"debuff",	true, 1.0, 0.0, 0.0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 261)
end

-- WARLOCK
if class == "WARLOCK" then
	recUI.timers:make_bar("Immolate",               "target", "debuff", true, .65, .20,   0, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 312)
	recUI.timers:make_bar("Seed of Corruption",     "target", "debuff", true,   0, .38, .03, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 329)
	recUI.timers:make_bar("Curse of Agony",         "target", "debuff", true, .43,   0, .40, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 346)
	recUI.timers:make_bar("Demonic Circle: Summon", "player", "buff",   true,   0, .38, .03, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 363)
	recUI.timers:make_bar("Fel Armor",              "player", "buff",   true,   0, .38, .03, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 380)
	recUI.timers:make_bar("Life Tap",               "player", "buff",   true, .43,   0, .40, 200, 10, "BOTTOM", UIParent, "BOTTOM", 0, 397)
end

-- WARRIOR
if class == "WARRIOR" then
	recUI.timers:make_bar("Battle Shout",       "player", "buff",   false,	0.59, 0.00, 0.00, 230, 10, "BOTTOM", UIParent, "BOTTOM", -225, 377)
	recUI.timers:make_bar("Bloodrage",          "player", "buff",   true,	0.59, 0.00, 0.00, 230, 10, "BOTTOM", UIParent, "BOTTOM", -225, 394)
	recUI.timers:make_bar("Shield Block",       "player", "buff",   true,	0.60, 0.60, 0.00, 230, 10, "BOTTOM", UIParent, "BOTTOM", -225, 411)
	recUI.timers:make_bar("Shield Wall",        "player", "buff",   true,	0.60, 0.60, 0.00, 230, 10, "BOTTOM", UIParent, "BOTTOM", -225, 428)
	recUI.timers:make_bar("Last Stand",         "player", "buff",   true,	0.60, 0.60, 0.00, 230, 10, "BOTTOM", UIParent, "BOTTOM", -225, 445)
	recUI.timers:make_bar("Berserker Rage",     "player", "buff",   true,	0.50, 0.20, 0.00, 230, 10, "BOTTOM", UIParent, "BOTTOM", -225, 462)
	recUI.timers:make_bar("Retaliation",        "player", "buff",   true,	0.50, 0.20, 0.00, 230, 10, "BOTTOM", UIParent, "BOTTOM", -225, 479)
	recUI.timers:make_bar("Sunder Armor",       "target", "debuff", true,	0.50, 0.20, 0.00, 230, 10, "BOTTOM", UIParent, "BOTTOM", 225, 377)
	recUI.timers:make_bar("Rend",               "target", "debuff", true,	0.59, 0.00, 0.00, 230, 10, "BOTTOM", UIParent, "BOTTOM", 225, 394)
	recUI.timers:make_bar("Thunder Clap",       "target", "debuff", false,	0.60, 0.60, 0.00, 230, 10, "BOTTOM", UIParent, "BOTTOM", 225, 411)
	recUI.timers:make_bar("Demoralizing Shout", "target", "debuff", false,	0.00, 0.50, 0.00, 230, 10, "BOTTOM", UIParent, "BOTTOM", 225, 428)
	recUI.timers:make_bar("Hamstring",          "target", "debuff", false,	0.50, 0.20, 0.00, 230, 10, "BOTTOM", UIParent, "BOTTOM", 225, 445)
end