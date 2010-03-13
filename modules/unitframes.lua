local _, recUI = ...
local oUF = recUI.oUF

local menu = function(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub("(.)", string.upper, 1)
	if(unit == "party" or unit == "partypet") then
		ToggleDropDownMenu(1, nil, _G[format("PartyMemberFrame%dDropDown", self.id)], "cursor", 0, 0)
	elseif(_G[format("%sFrameDropDown", cunit)]) then
		ToggleDropDownMenu(1, nil, _G[format("%sFrameDropDown", cunit)], "cursor", 0, 0)
	end
end

local updateName = function(self, event, unit)
	if(self.unit == unit) then
		local r, g, b, t
		if(UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) or not UnitIsConnected(unit)) then
			r, g, b = .6, .6, .6
		elseif(unit == 'pet') then
			t = self.colors.happiness[GetPetHappiness()]
		elseif(UnitIsPlayer(unit)) then
			local _, class = UnitClass(unit)
			t = self.colors.class[class]
		else
			t = self.colors.reaction[UnitReaction(unit, "player")]
		end

		if(t) then
			r, g, b = t[1], t[2], t[3]
		end

		if(r) then
			self.Name:SetTextColor(r, g, b)
		end
		if self:GetParent():GetName():match("oUF_Raid") then
			self.Name:SetText(string.sub(UnitName(unit), 0, 3))
		elseif unit == "focus" or unit == "targettarget" or unit == "pet" or unit == "focustarget" then
			self.Name:SetText(string.sub(UnitName(unit), 0, 6))
		else
			self.Name:SetText(UnitName(unit))
		end
	end
end

local PostUpdateHealth = function(self, event, unit, bar, min, max)
	if(UnitIsDead(unit)) then
		bar.value:SetText("d")
	elseif(UnitIsGhost(unit)) then
		bar.value:SetText("g")
	elseif(not UnitIsConnected(unit)) then
		bar.value:SetText("o")
	else
		if unit == "player" or unit == "target" then
			if(min ~= 0 and min ~= max) then
				bar.value:SetFormattedText("%s | %s", recUI.lib.prettyNumber(min), recUI.lib.prettyNumber(max))
			else
				bar.value:SetText(max)
			end
		else
			bar.value:SetText(recUI.lib.prettyNumber(min))
		end
	end

	bar:SetStatusBarColor(.25, .25, .35)
	return updateName(self, event, unit)
end

local PostUpdatePower = function(self, event, unit, bar, min, max)
	if(min == 0 or max == 0 or not UnitIsConnected(unit)) then
		bar.value:SetText()
		bar:SetValue(0)
	elseif(UnitIsDead(unit) or UnitIsGhost(unit)) then
		bar.value:SetText()
		bar:SetValue(0)
	else
		if unit == "player" or unit == "target" then
			if (min ~= 0 and min ~= max) then
				bar.value:SetFormattedText("%s | %s", recUI.lib.prettyNumber(min), recUI.lib.prettyNumber(max))
			else
				bar.value:SetText(max)
			end
		else
			bar.value:SetText()
		end
	end
end

local PostCastStart = function(self, event, unit, spell, spellrank, castid)
	self.Castbar.spellName:SetText(spell)
end

local PostCastStop = function(self, event, unit)
	if(unit ~= self.unit) then return end
	self.Castbar.spellName:SetText()
end

local function UpdateAura(self, elapsed)
	self.elapsed = self.elapsed + elapsed
	if self.elapsed >= .1 then
		self.elapsed = 0
		local _, _, _, _, _, duration = UnitAura(self.unit, self.index, self.filter)
		if duration and duration > 0 then
			self.time:SetText(recUI.lib.prettyTime(duration))
		else
			self.time:SetText()
		end
	end
end

local PostCreateAuraIcon = function(self, button)
	button.count:SetFont(recUI.media.font, 9, "THINOUTLINE")
	button.count:ClearAllPoints()
	button.count:SetPoint("BOTTOMRIGHT", -1, 3)

	-- Icons are easier to recognize without this set.
	--button.icon:SetTexCoord(.07, .93, .07, .93)

	-- Push icon in 1px because it likes to poke out from the border on some scales.
	button.icon:ClearAllPoints()
	button.icon:SetPoint("TOPLEFT", 1, -1)
	button.icon:SetPoint("BOTTOMRIGHT", -1, 1)

	-- Thin 'outline' border texture.
	button.outline = button:CreateTexture(nil, "OVERLAY")
	button.outline:SetTexture(recUI.media.buttonNormal)
	button.outline:SetAllPoints()

	-- Make icon look pretty with an overlay.
	button.gloss = button:CreateTexture(nil, "OVERLAY")
	button.gloss:SetTexture(recUI.media.buttonGloss)
	button.gloss:SetAllPoints()

	-- Put spiral inside outline frame.
	button.cd:ClearAllPoints()
	button.cd:SetPoint("TOPLEFT", 3, -3)
	button.cd:SetPoint("BOTTOMRIGHT", -3, 3)
	-- Remove cooldown spiral.
	--button.cd = nil

	-- Use time display rather than spiral.
	--button.time = button:CreateFontString(nil, "OVERLAY")
	--button.time:SetPoint("TOPLEFT", 1, -1)
	--button.time:SetFont(recUI.media.font, 9, "THINOUTLINE")
	--button.time:SetText("0")
end

--local auraColor  = {
--	["Magic"]   = {r = 0.00, g = 0.25, b = 0.45},
--	["Disease"] = {r = 0.40, g = 0.30, b = 0.10},
--	["Poison"]  = {r = 0.00, g = 0.40, b = 0.10},
--	["Curse"]   = {r = 0.40, g = 0.00, b = 0.40},
--	["None"]    = {r = 0.40, g = 0.40, b = 0.40}
--}

local PostUpdateAuraIcon
do
	local playerUnits = {
		player = true,
		pet = true,
		vehicle = true,
	}

	PostUpdateAuraIcon = function(self, icons, unit, icon, index, offset, filter, isDebuff)
		--local auraType = select(5, UnitAura(unit, index, icon.filter))
		--f (auraType) then -- Be absolutely sure.
		--	print(auraType, auraColor[auraType].r, auraColor[auraType].g, auraColor[auraType].b)
		--	icon.outline:SetVertexColor(auraColor[auraType].r, auraColor[auraType].g, auraColor[auraType].b, 1)
		--end
		if unit == "target" and not(playerUnits[icon.owner]) and isDebuff then
			icon.icon:SetDesaturated(true)
		else
			icon.icon:SetDesaturated(false)
		end
	end
end

local function style(self, unit)
	self.menu = menu
	self:RegisterForClicks("AnyUp")
	self:SetAttribute("type2", "menu")

	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	self:HookScript("OnShow", function(frame)
		for _, v in ipairs(frame.__elements) do
			v(frame, "UpdateElement", frame.unit)
		end
	end)

-- Backdrop
	self.background = CreateFrame("Frame", nil, self)
	self.background:SetPoint("TOPLEFT", self, "TOPLEFT", -4, 4)
	self.background:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 4, -4)
	self.background:SetFrameStrata("BACKGROUND")
	self.background:SetBackdrop {
		bgFile = recUI.media.bgFile,
		edgeFile = recUI.media.edgeFile, edgeSize = 3,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	}
	self.background:SetBackdropColor(0, 0, 0, 1)
	self.background:SetBackdropBorderColor(0, 0, 0)

-- Health
	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetStatusBarTexture(recUI.media.statusBar)
	self.Health:SetPoint("TOPLEFT", 0,0)
	self.Health:SetPoint("TOPRIGHT", 0,0)
	self.Health.frequentUpdates = true

	self.Health.background = self.Health:CreateTexture(nil, "BACKGROUND")
	self.Health.background:SetTexture(.25, .25, .25, 1)
	self.Health.background:SetAllPoints()

	self.Health.value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.value:SetFont(recUI.media.font, 9, "THINOUTLINE")
	self.Health.value:SetPoint("RIGHT", -5, 2)
	self.Health.value:SetTextColor(1, 1, 1)

-- Power
	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetStatusBarTexture(recUI.media.statusBar)
	self.Power:SetPoint("BOTTOMLEFT", 0,0)
	self.Power:SetPoint("BOTTOMRIGHT", 0,0)
	self.Power.frequentUpdates = true
	self.Power.colorTapping = true
	self.Power.colorHappiness = true
	self.Power.colorClass = true
	self.Power.colorReaction = true

	self.Power.background = self.Power:CreateTexture(nil, "BACKGROUND")
	self.Power.background:SetTexture(.25, .25, .25, 1)
	self.Power.background:SetAllPoints()

	self.Power.value = self.Power:CreateFontString(nil, "OVERLAY")
	self.Power.value:SetFont(recUI.media.font, 9, "THINOUTLINE")
	self.Power.value:SetPoint("RIGHT", -5, 2)
	self.Power.value:SetTextColor(1, 1, 1)

-- Name
	self.Name = self.Health:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("LEFT", 5, 2)
	self.Name:SetJustifyH("LEFT")
	self.Name:SetFont(recUI.media.font, 9, "THINOUTLINE")
	self.Name:SetTextColor(1, 1, 1)

-- Castbar
	if unit == "player" or unit == "target" then
		self.Castbar = CreateFrame("StatusBar", nil, self)
		self.Castbar:SetStatusBarTexture(recUI.media.statusBar)
		self.Castbar:SetStatusBarColor(.3, .3, .6, 1)
		self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -2)
		self.Castbar:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", 0, 2)
		self.Castbar:SetToplevel(true)

		self.Castbar.spellName = self.Castbar:CreateFontString(nil, "OVERLAY")
		self.Castbar.spellName:SetFont(recUI.media.font, 9, "THINOUTLINE")
		self.Castbar.spellName:SetPoint("LEFT", 5, 2)
		self.Castbar.spellName:SetTextColor(1, 1, 1)

-- Portrait
		self.Portrait = CreateFrame("PlayerModel", nil, self)
		self.Portrait:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -3)
		self.Portrait:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", 0, 2)

		self.Portrait.backdrop = self.Portrait:CreateTexture(nil, "BACKGROUND")
		self.Portrait.backdrop:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -2)
		self.Portrait.backdrop:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", 0, 2)
		self.Portrait.backdrop:SetTexture(.15, .15, .15, 1)
	end

-- Buffs
	if unit == "player" or unit == "target" then
		self.Buffs = CreateFrame("Frame", nil, self)
		self.Buffs:SetHeight(2 * 22 + 2 * 2)
		self.Buffs:SetWidth(8 * 22 + 8 * 2)
		self.Buffs.num = 16
		self.Buffs.size = 22
		self.Buffs.spacing = 1

		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs:SetHeight(2 * 22 + 2 * 2)
		self.Debuffs:SetWidth(8 * 22 + 8 * 2)
		self.Debuffs.num = 16
		self.Debuffs.size = 22
		self.Debuffs.spacing = 1

		if unit == "player" then
			self.Buffs.initialAnchor = "TOPRIGHT"
			self.Buffs["growth-x"] = "LEFT"
			self.Buffs["growth-y"] = "DOWN"
			self.Buffs:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 2)

			BuffFrame:Hide()
			TemporaryEnchantFrame:Hide()
		else
			self.Buffs.initialAnchor = "TOPLEFT"
			self.Buffs["growth-x"] = "RIGHT"
			self.Buffs["growth-y"] = "DOWN"
			self.Buffs:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 2)
		end

		self.Debuffs.initialAnchor = "TOPLEFT"
		self.Debuffs["growth-x"] = "RIGHT"
		self.Debuffs["growth-y"] = "DOWN"
		self.Debuffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -3, -4)

		self.PostUpdateAuraIcon = PostUpdateAuraIcon
		self.PostCreateAuraIcon = PostCreateAuraIcon
	end

-- Size
	if unit == "player" or unit == "target" then
		self:SetAttribute("initial-height", 40)
		self:SetAttribute("initial-width", 230)
		self.Power:SetHeight(10)
		self.Health:SetHeight(15)
	elseif self:GetAttribute("unitsuffix") == "pet" then
		self:SetAttribute("initial-height", 10)
		self:SetAttribute("initial-width", 113)
		self.Power:SetHeight(2)
		self.Health:SetHeight(8)
	elseif self:GetParent():GetName():match("oUF_Raid") then
		self:SetAttribute("initial-height", 28)
		self:SetAttribute("initial-width", 60)
		self.Power:SetHeight(6)
		self.Health:SetHeight(20)
	else
		self:SetAttribute("initial-height", 22)
		self:SetAttribute("initial-width", 113)
		self.Power:SetHeight(5)
		self.Health:SetHeight(15)
	end

-- Overrides/Hooks
	self.PostUpdateHealth = PostUpdateHealth
	self.PostUpdatePower = PostUpdatePower
	self.PostChannelStart = PostCastStart
	self.PostCastStart = PostCastStart
	self.PostCastStop = PostCastStop
	self.PostChannelStop = PostCastStop
	if unit == "pet" then
		self:RegisterEvent("UNIT_HAPPINESS", updateName)
	end
	self:RegisterEvent('UNIT_NAME_UPDATE', updateName)

	return self
end

oUF:RegisterStyle("recUI", style)
oUF:SetActiveStyle("recUI")

oUF:Spawn("player", "recUI_player"):SetPoint("BOTTOM", UIParent, -278.5, 269.5)
oUF:Spawn("target", "recUI_target"):SetPoint("BOTTOM", UIParent, 278.5, 269.5)

oUF:Spawn("pet", "recUI_pet"):SetPoint("BOTTOMLEFT", recUI_player, "TOPLEFT", 0, 10)
oUF:Spawn("focus", "recUI_focus"):SetPoint("BOTTOMRIGHT", recUI_player, "TOPRIGHT", 0, 10)
oUF:Spawn("focustarget", "recUI_focustarget"):SetPoint("BOTTOMLEFT", recUI_target, "TOPLEFT", 0, 10)
oUF:Spawn("targettarget", "recUI_targettarget"):SetPoint("BOTTOMRIGHT", recUI_target, "TOPRIGHT", 0, 10)
local party = oUF:Spawn("header", "oUF_Party")
party:SetAttribute("showParty", true)
party:SetAttribute("yOffset", -27.5)
party:SetAttribute("template", "recUI_Party")
party:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 15, -15)

local raid = {}
for i = 1, NUM_RAID_GROUPS do
	local raidgroup = oUF:Spawn("header", "oUF_Raid"..i)
	raidgroup:SetAttribute("groupFilter", tostring(i))
	raidgroup:SetAttribute("showRaid", true)
	raidgroup:SetAttribute("yOffSet", -7.5)
	table.insert(raid, raidgroup)
	if i == 1 then
		raidgroup:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 15, -15)
	else
		raidgroup:SetPoint("TOPLEFT", raid[i-1], "TOPRIGHT", (60 * 1 - 60) + 7.5, 0) --1 == scale
	end
end

local partyToggle = CreateFrame("Frame")
partyToggle:RegisterEvent("PLAYER_LOGIN")
partyToggle:RegisterEvent("RAID_ROSTER_UPDATE")
partyToggle:RegisterEvent("PARTY_LEADER_CHANGED")
partyToggle:RegisterEvent("PARTY_MEMBERS_CHANGED")
partyToggle:SetScript("OnEvent", function(self)
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		local numraid = GetNumRaidMembers()
		if numraid > 0 and (numraid > 5 or numraid ~= GetNumPartyMembers() + 1) then
			party:Hide()
			for i, v in ipairs(raid) do v:Show() end
		else
			party:Show()
			for i, v in ipairs(raid) do v:Hide() end
		end
	end
end)