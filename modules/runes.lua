local _, recUI = ...

if recUI.lib.playerClass ~= "DEATHKNIGHT" then
	return
end

recUI.runes = {}

recUI.runes.opt = {

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

recUI.runes.gcd_reference_spell = [[Death Coil]]

local runes		= {}
local bg		= CreateFrame("Frame", "rr_rune_bg", UIParent, nil)
local colors	= {
	[1] = { 1.00, 0.00, 0.00 },	-- Blood
	[2] = { 0.00, 0.75, 0.00 },	-- Unholy
	[3] = { 0.00, 1.00, 1.00 },	-- Frost
	[4] = { 0.90, 0.10, 1.00 },	-- Death
}

local font = CreateFont("recRunesFont")
font:SetFont(recUI.media.font, 10, "OUTLINE")

local function make_backdrop(frame)
	frame.bg = CreateFrame("Frame", nil, frame)
	frame.bg:SetPoint("TOPLEFT")
	frame.bg:SetPoint("BOTTOMRIGHT")
	frame.bg:SetBackdrop({
		bgFile = recUI.media.bgFile,
		edgeFile = recUI.media.edgeFile, edgeSize = 4,
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

if not recUI.runes.opt.show_ooc then
	bg:RegisterEvent("PLAYER_REGEN_ENABLED")
	bg:RegisterEvent("PLAYER_REGEN_DISABLED")
	bg:Hide()
end

if not recUI.runes.opt.show_vehicle then
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
			if recUI.runes.opt.show_ooc and not InCombatLockdown() then
				bg:Show()
			end
		end
	elseif event == "PLAYER_REGEN_DISABLED" then
		if recUI.runes.opt.show_vehicle or (not recUI.runes.opt.show_vehicle and not bg.in_vehicle) then
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
			return
		end
		-- Disable and hide the Blizzard rune frame if option is set.
		if recUI.runes.opt.runes.hide_blizzard_runes then
			RuneFrame.Show = function() end
			RuneFrame:UnregisterAllEvents()
			RuneFrame:Hide()
		end
	end
end)

SLASH_RECUIRUNES1 = "/recuirunes"
SlashCmdList.RECUIRUNES = function()
	-- Slash command toggles dragging of frame.
	if bg:IsMouseEnabled() then
		bg:EnableMouse(false)
		-- We need to hide the frame if the user has set the option to hide out of combat.
		if ((not recUI.runes.opt.show_ooc) and (not InCombatLockdown())) then
			bg:Hide()
		end
		print("recUI Runes is now locked.")
	else
		bg:EnableMouse(true)
		-- We need to show the frame if the user has turned off the frame out of combat.
		if ((not recUI.runes.opt.show_ooc) and (not InCombatLockdown())) then
			bg:Show()
		end
		print("recUI Runes is now movable. /recuirunes to lock")
	end
end

gcd = CreateFrame("StatusBar", "rr_gcd", rr_rune_bg)
gcd:SetHeight(5)
gcd:SetPoint("BOTTOMLEFT", rr_rune_1, "TOPLEFT", 3.5, 1)
gcd:SetPoint("BOTTOMRIGHT", rr_rune_6, "TOPRIGHT", -4.5, 1)

gcd.tx = gcd:CreateTexture(nil, "ARTWORK")
gcd.tx:SetAllPoints()
gcd.tx:SetTexture(recUI.media.statusBar)
gcd.tx:SetVertexColor(.6, .6, 0, 1)
gcd:SetStatusBarTexture(gcd.tx)

gcd.soft_edge = CreateFrame("Frame", nil, gcd)
gcd.soft_edge:SetPoint("TOPLEFT", -4, 3.5)
gcd.soft_edge:SetPoint("BOTTOMRIGHT", 4, -4)
gcd.soft_edge:SetBackdrop({
	bgFile = recUI.media.bgFile,
	edgeFile = recUI.media.edgeFile, edgeSize = 4,
	insets = {left = 3, right = 3, top = 3, bottom = 3}
})
gcd.soft_edge:SetFrameStrata("BACKGROUND")
gcd.soft_edge:SetBackdropColor(0.15, 0.15, 0.15, 1)
gcd.soft_edge:SetBackdropBorderColor(0, 0, 0)
gcd:Hide()
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
	local s, d = GetSpellCooldown(recUI.runes.gcd_reference_spell)
	
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

gcd:SetScript("OnEvent", GCD)