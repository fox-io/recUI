local function style(self, unit)
	
	self:RegisterForClicks("AnyUp")
	self:SetAttribute("type2", "menu")
	
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	self:HookScript("OnShow", function(frame)
		for _, v in ipairs(frame.__elements) do
			v(frame, "UpdateElement", frame.unit)
		end
	end)
	
	if unit == "player" or unit == "target" then
		self:SetAttribute("initial-height", 53)
		self:SetAttribute("initial-width", 230)
	elseif self:GetAttribute("unitsuffix") == "pet" then
		self:SetAttribute("initial-height", 10)
		self:SetAttribute("initial-width", 113)
	elseif self:GetParent():GetName():match("oUF_Raid") then
		self:SetAttribute("initial-height", 28)
		self:SetAttribute("initial-width", 60)
	else
		self:SetAttribute("initial-height", 22)
		self:SetAttribute("initial-width", 113)
	end
	
	self.FrameBackdrop = CreateFrame("Frame", nil, self)
	self.FrameBackdrop:SetPoint("TOPLEFT", self, "TOPLEFT", -4, 4)
	self.FrameBackdrop:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 4, -4)
	self.FrameBackdrop:SetFrameStrata("BACKGROUND")
	self.FrameBackdrop:SetBackdrop {
		bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
		edgeFile = [[]], edgeSize = 3,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	}
	self.FrameBackdrop:SetBackdropColor(0.25, 0.25, 0.25)
	self.FrameBackdrop:SetBackdropBorderColor(0, 0, 0)
	
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