local _, recRunes = ...

recRunes.opt = {

	-- Color of the background (a = 0 for none).
	background_color = { r = 0, g = 0, b = 0, a = 1 },
	
	-- Show the runes and timers when you are out of combat?
	show_ooc = true,
	
	-- Show the runes and timers when you are in a vehicle?
	show_vehicle = false,
	
	runes = {
		-- Hide the Blizzard default runes?
		hide_blizzard_runes = true,
	},
	
	global_cooldown = {
		-- Show global cooldown bar?
		show = true,
	},
	
	runic_power = {
		-- Show Runic Power bar?
		show = true,
	},
	
	diseases = {
		-- Show disease timers?
		show = false,
	},
}

recRunes.gcd_reference_spell = [[Death Coil]]

if not recMedia then
	recRunes.font_face         = [[Interface\AddOns\recRunes\media\pf_tempesta_five_condensed.ttf]]
	recRunes.font_size         = 10
	recRunes.font_flags        = "OUTLINE"
	recRunes.bg_file           = [[Interface\ChatFrame\ChatFrameBackground]]
	recRunes.edge_file         = [[Interface\AddOns\recRunes\media\glowtex]]
	recRunes.statusbar_texture = [[Interface\AddOns\recRunes\media\normtexa]]
else
	recRunes.font_face         = recMedia.fontFace.TINY_PIXEL
	recRunes.font_size         = 10
	recRunes.font_flags        = recMedia.fontFlag.OUTLINE
	recRunes.bg_file           = recMedia.texture.BACKDROP
	recRunes.edge_file         = recMedia.texture.BORDER
	recRunes.statusbar_texture = recMedia.texture.STATUSBAR
end

local _, recRunes = ...

local runes		= {}
local bg		= CreateFrame("Frame", "rr_rune_bg", UIParent, nil)
local colors	= {
	[1] = { 1.00, 0.00, 0.00 },	-- Blood
	[2] = { 0.00, 0.75, 0.00 },	-- Unholy
	[3] = { 0.00, 1.00, 1.00 },	-- Frost
	[4] = { 0.90, 0.10, 1.00 },	-- Death
}

local font = CreateFont("recRunesFont")
font:SetFont(recRunes.font_face, recRunes.font_size, recRunes.font_flags)

local function make_backdrop(frame)
	frame.bg = CreateFrame("Frame", nil, frame)
	frame.bg:SetPoint("TOPLEFT")
	frame.bg:SetPoint("BOTTOMRIGHT")
	frame.bg:SetBackdrop({
		bgFile = recRunes.bg_file,
		edgeFile = recRunes.edge_file, edgeSize = 4,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	})
	frame.bg:SetFrameStrata("BACKGROUND")
	frame.bg:SetBackdropColor(0, 0, 0, .5)
	frame.bg:SetBackdropBorderColor(0, 0, 0)
end

bg:SetHeight(25)
bg:SetWidth(135)

bg:SetPoint("CENTER")
bg:SetMovable(true)
bg:RegisterForDrag("LeftButton")
bg:SetUserPlaced(true)

bg.in_vehicle = false

for i = 1,6 do
	runes[i] = CreateFrame("Frame", format("rr_rune_%d", i), bg, nil)
	make_backdrop(runes[i])
	runes[i]:SetHeight(23)
	runes[i]:SetWidth(23)
	-- First rune is anchored to the backdrop, the rest are anchored to the previous rune.
	-- runes[i]:SetPoint(i == 1 and "TOPLEFT" or "LEFT" , i == 1 and bg or runes[i - 1], i == 1 and "TOPLEFT" or "RIGHT", i == 1 and 2.5 or 2, i == 1 and (showgcd and -10 or -2.5) or 0)
	runes[i]:SetPoint("LEFT" , i == 1 and bg or runes[i - 1], i == 1 and "LEFT" or "RIGHT", 0, 0)
	runes[i].timer = runes[i]:CreateFontString(format("rr_rune_timer_%d", i), "ARTWORK")
	runes[i].timer:SetFontObject(recRunesFont)
	runes[i].timer:SetPoint("CENTER")
end

local timer = 0
bg:SetScript("OnUpdate", function(self, elapsed)
	-- Throttle Updates.
	timer = timer - elapsed
	if timer > 0 then return end
	timer = 0.25
	
	for i = 1,6 do
		local s, d, r = GetRuneCooldown(i)
		local c = colors[GetRuneType(i)]
		runes[i].bg:SetBackdropColor( (r and c[1] or (c[1] * .3)), (r and c[2] or (c[2] * .3)), (r and c[3] or (c[3] * .3)), 1)
		if not r then
			local t = math.ceil(10 - (GetTime() - s))
			runes[i].timer:SetText(((t < 1) or UnitIsDeadOrGhost("player")) and "" or t)
		else
			runes[i].timer:SetText("")
		end
	end
end)

bg:SetScript("OnDragStart", function() bg:StartMoving() end)
bg:SetScript("OnDragStop", function() bg:StopMovingOrSizing() end)
bg:RegisterEvent("PLAYER_ENTERING_WORLD")

if not recRunes.opt.show_ooc then
	bg:RegisterEvent("PLAYER_REGEN_ENABLED")
	bg:RegisterEvent("PLAYER_REGEN_DISABLED")
	bg:Hide()
end

if not recRunes.opt.show_vehicle then
	bg:RegisterEvent("UNIT_ENTERED_VEHICLE")
	bg:RegisterEvent("UNIT_EXITED_VEHICLE")
end

bg:SetScript("OnEvent", function(self, event, ...)
	if event == "UNIT_ENTERED_VEHICLE" then
		if select(1, ...) == "player" then
			bg.in_vehicle = true
			bg:Hide()
		end
	elseif event == "UNIT_EXITED_VEHICLE" then
		if select(1, ...) == "player" then
			bg.in_vehicle = false
			if recRunes.opt.show_ooc and not InCombatLockdown() then
				bg:Show()
			end
		end
	elseif event == "PLAYER_REGEN_DISABLED" then
		if recRunes.opt.show_vehicle or (not recRunes.opt.show_vehicle and not bg.in_vehicle) then
			bg:Show()
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		bg:Hide()
	elseif event == "PLAYER_ENTERING_WORLD" then
		-- If character is not a DK, inform player and hibernate.
		local _, class = UnitClass("player")
		if class ~= "DEATHKNIGHT" then
			bg:UnregisterAllEvents()
			bg:SetScript("OnUpdate", nil)
			bg:Hide()
			print("recRunes: You are not playing as a Death Knight.  The addon will be automatically disabled at next login.")
			DisableAddOn("recRunes")
			return
		end
		-- Disable and hide the Blizzard rune frame if option is set.
		if recRunes.opt.runes.hide_blizzard_runes then
			RuneFrame.Show = function() end
			RuneFrame:UnregisterAllEvents()
			RuneFrame:Hide()
		end
	end
end)

SLASH_RECRUNES1 = "/recrunes"
SlashCmdList.RECRUNES = function()
	-- Slash command toggles dragging of frame.
	if bg:IsMouseEnabled() then
		bg:EnableMouse(false)
		-- We need to hide the frame if the user has set the option to hide out of combat.
		if ((not recRunes.opt.show_ooc) and (not InCombatLockdown())) then
			bg:Hide()
		end
		print("recRunes is now locked.")
	else
		bg:EnableMouse(true)
		-- We need to show the frame if the user has turned off the frame out of combat.
		if ((not recRunes.opt.show_ooc) and (not InCombatLockdown())) then
			bg:Show()
		end
		print("recRunes is now movable. /recrunes to lock")
	end
end

local _, recRunes = ...
if not recRunes.opt.runic_power.show then return end

local delay = 0

rp = CreateFrame("StatusBar", "rr_rp", rr_rune_bg)
rp:SetHeight(10)
rp:SetPoint("TOPLEFT", rr_rune_1, "BOTTOMLEFT", 4, -1)
rp:SetPoint("TOPRIGHT", rr_rune_6, "BOTTOMRIGHT", -4, -1)
rp:SetStatusBarColor(0, 0, 1, 0.5)

rp.tx = rp:CreateTexture(nil, "ARTWORK")
rp.tx:SetAllPoints()
rp.tx:SetTexture([[Interface\AddOns\recRunes\media\normtexa.tga]])
rp.tx:SetVertexColor(.5, .75, 1, 1)
rp:SetStatusBarTexture(rp.tx)

rp.lbl = rp:CreateFontString("CDKR_rpl", "ARTWORK")
rp.lbl:SetFontObject(recRunesFont)
rp.lbl:SetPoint("CENTER", 0, 1)

rp.soft_edge = CreateFrame("Frame", nil, rp)
rp.soft_edge:SetPoint("TOPLEFT", -4, 3.5)
rp.soft_edge:SetPoint("BOTTOMRIGHT", 4, -4)
rp.soft_edge:SetBackdrop({
	bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
	edgeFile = [[Interface\Addons\recRunes\media\glowtex]], edgeSize = 4,
	insets = {left = 3, right = 3, top = 3, bottom = 3}
})
rp.soft_edge:SetFrameStrata("BACKGROUND")
rp.soft_edge:SetBackdropColor(0.15, 0.15, 0.15, 1)
rp.soft_edge:SetBackdropBorderColor(0, 0, 0)

rp.bg = rp:CreateTexture(nil, "BORDER")
rp.bg:SetAllPoints()
rp.bg:SetTexture([[Interface\AddOns\recRunes\media\normtexa.tga]])
rp.bg:SetVertexColor(0.25, 0.25, 0.25, 1)

local timer = 0
rp:SetScript("OnUpdate", function(self, elapsed)
	-- Throttle Updates.
	timer = timer - elapsed
	if timer > 0 then return end
	timer = 0.25
	
	rp.lbl:SetText(UnitPower("player"))
	rp:SetMinMaxValues(0,UnitPowerMax("player"))
	rp:SetValue(UnitPower("player"))
end)

local _, recRunes = ...
if not recRunes.opt.global_cooldown.show then return end

gcd = CreateFrame("StatusBar", "rr_gcd", rr_rune_bg)
gcd:SetHeight(5)
gcd:SetPoint("BOTTOMLEFT", rr_rune_1, "TOPLEFT", 3.5, 1)
gcd:SetPoint("BOTTOMRIGHT", rr_rune_6, "TOPRIGHT", -4.5, 1)

gcd.tx = gcd:CreateTexture(nil, "ARTWORK")
gcd.tx:SetAllPoints()
gcd.tx:SetTexture(recRunes.statusbar_texture)
gcd.tx:SetVertexColor(.6, .6, 0, 1)
gcd:SetStatusBarTexture(gcd.tx)

gcd.soft_edge = CreateFrame("Frame", nil, gcd)
gcd.soft_edge:SetPoint("TOPLEFT", -4, 3.5)
gcd.soft_edge:SetPoint("BOTTOMRIGHT", 4, -4)
gcd.soft_edge:SetBackdrop({
	bgFile = recRunes.bg_file,
	edgeFile = recRunes.edge_file, edgeSize = 4,
	insets = {left = 3, right = 3, top = 3, bottom = 3}
})
gcd.soft_edge:SetFrameStrata("BACKGROUND")
gcd.soft_edge:SetBackdropColor(0.15, 0.15, 0.15, 1)
gcd.soft_edge:SetBackdropBorderColor(0, 0, 0)

--gcd.bg = gcd:CreateTexture(nil, "BORDER")
--gcd.bg:SetPoint("TOPLEFT")
--gcd.bg:SetPoint("BOTTOMRIGHT")
--gcd.bg:SetTexture(recRunes.statusbar_texture)
--gcd.bg:SetVertexColor(0.25, 0.25, 0.25, 1)

gcd:Hide()
--gcd:SetMinMaxValues(0, 1)
--gcd:SetValue(.6)
--gcd:Show()
gcd.s = 0
gcd.d = 0

local timer = 0
gcd:SetScript("OnUpdate", function(self, elapsed)

	-- Throttle Updates.
	--timer = timer - elapsed
	--if timer > 0 then return end
	--timer = 0.025
	
	gcd:SetMinMaxValues(0, 1)
	
	local p = (GetTime() - gcd.s) / gcd.d
	if p > 1 then
		gcd:Hide()
	else
		gcd:SetValue(p)
	end
end)

gcd:RegisterEvent("SPELL_UPDATE_COOLDOWN")

local function GCD()
	local s, d = GetSpellCooldown(recRunes.gcd_reference_spell)
	
	if not s or s == 0 or not d or d == 0 or d > 1.5 then
		gcd:Hide()
		return
	end
	
	-- We only store the values here.  The display is updated in the OnUpdate.
	gcd.s = s
	gcd.d = d
	gcd:SetValue(0)
	gcd:Show()
end

gcd:SetScript("OnEvent", GCD)--]]

local _, recRunes = ...
if not recRunes.opt.diseases.show then return end

local event_frame = CreateFrame("Frame")
local frost_fever = 55095
local blood_plague = 55078

local function on_update(self, elapsed)
	self.timer = self.timer - elapsed
	
	if self.timer > 0 then return end
	self.timer = 0.01
	
	if self.active then
		if self.expires >= GetTime() then
			self:SetValue(self.expires - GetTime())
			self:SetMinMaxValues(0, self.duration)
			self.lbl:SetText(math.floor(self.expires - GetTime()))
		else
			self.active = false
		end
	end
	
	if not self.active then
		self:Hide()
	end
end

local function make_bar(name)
	local bar = CreateFrame("StatusBar", name, rr_rune_bg)
	bar:SetHeight(10)
	bar:SetWidth(100)
	bar.active = false
	bar.expires = 0
	bar.duration = 0
	bar.timer = 0
	
	bar.tx = bar:CreateTexture(nil, "ARTWORK")
	bar.tx:SetAllPoints()
	bar.tx:SetTexture(recRunes.statusbar_texture)	
	bar:SetStatusBarTexture(bar.tx)
	
	bar.soft_edge = CreateFrame("Frame", nil, bar)
	bar.soft_edge:SetPoint("TOPLEFT", -4, 3.5)
	bar.soft_edge:SetPoint("BOTTOMRIGHT", 4, -4)
	bar.soft_edge:SetBackdrop({
		bgFile = recRunes.bg_file,
		edgeFile = recRunes.edge_file, edgeSize = 4,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	})
	bar.soft_edge:SetFrameStrata("BACKGROUND")
	bar.soft_edge:SetBackdropColor(0.15, 0.15, 0.15, 1)
	bar.soft_edge:SetBackdropBorderColor(0, 0, 0)
	
	bar.bg = bar:CreateTexture(nil, "BACKGROUND")
	bar.bg:SetAllPoints()
	bar.bg:SetTexture(recRunes.statusbar_texture)
	bar.bg:SetVertexColor(recRunes.opt.background_color.r, recRunes.opt.background_color.g, recRunes.opt.background_color.b, recRunes.opt.background_color.a)
	
	bar.lbl = bar:CreateFontString(string.format("%s_label", name), "ARTWORK")
	bar.lbl:SetFontObject(recRunesFont)
	bar.lbl:SetPoint("CENTER", 0, 1)
	
	if name == "cdkd_frost_fever" then
		bar:SetPoint("BOTTOMLEFT", rr_rune_1, "TOPLEFT", 3.5, recRunes.opt.global_cooldown.show and 26 or 16)
		bar:SetPoint("BOTTOMRIGHT", rr_rune_6, "TOPRIGHT", -4.5, recRunes.opt.global_cooldown.show and 26 or 16)
		bar.tx:SetVertexColor(0, 1, 1, 1)
	else
		bar:SetPoint("BOTTOMLEFT", rr_rune_1, "TOPLEFT", 3.5, recRunes.opt.global_cooldown.show and 11 or 1)
		bar:SetPoint("BOTTOMRIGHT", rr_rune_6, "TOPRIGHT", -4.5, recRunes.opt.global_cooldown.show and 11 or 1)
		bar.tx:SetVertexColor(0, .75, 0, 1)
	end
	
	bar:Hide()
	--bar:Show()
	bar:SetScript("OnUpdate", on_update)
	return bar
end

local frost_fever_bar = make_bar("cdkd_frost_fever")
local blood_plague_bar = make_bar("cdkd_blood_plague")

local function on_target()
	for i = 1, 40 do
		_, _, _, _, _, duration, expires, caster, _, _, spell_id = UnitDebuff("target", i)
		if spell_id == frost_fever and caster == "player" then
			frost_fever_bar.active = true
			frost_fever_bar.expires = expires
			frost_fever_bar.duration = duration
			frost_fever_bar:Show()
		end
		if spell_id == blood_plague and caster == "player" then
			blood_plague_bar.active = true
			blood_plague_bar.expires = expires
			blood_plague_bar.duration = duration
			blood_plague_bar:Show()
		end
	end
end

local function on_cleu(...)
	local _, event, source_guid, _, _, dest_guid, _, _, spell_id, spell_name, _, _ = ...
	if source_guid ~= UnitGUID("player") then return end
	if dest_guid ~= UnitGUID("target") then return end
	if spell_id ~= frost_fever and spell_id ~= blood_plague then return end
	
	if event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH" then
		on_target()
		
	elseif event == "SPELL_AURA_REMOVED" then
		if spell_id == frost_fever then
			frost_fever_bar.active = false
			frost_fever_bar.expires = 0
		elseif spell_id == blood_plague then
			blood_plague_bar.active = false
			blood_plague_bar.expires = 0
		end
	end
end

event_frame:RegisterEvent("PLAYER_TARGET_CHANGED")
event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
event_frame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_TARGET_CHANGED" then
		frost_fever_bar:Hide()
		blood_plague_bar:Hide()
		on_target()
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		on_cleu(...)
	end
end)