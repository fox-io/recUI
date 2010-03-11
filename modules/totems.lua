local _, recUI = ...
-- Lean and clean version of aTotemBar by Arimis

if UnitLevel("player") < 30 or select(2, UnitClass("player")) ~= "SHAMAN" then
	return
end

local totem_bar, page, summon
local module = CreateFrame("Frame")

subFrames = {
	MultiCastSummonSpellButton,
	MultiCastActionPage1,
	MultiCastActionPage2,
	MultiCastActionPage3,
	MultiCastSlotButton1,
	MultiCastSlotButton2,
	MultiCastSlotButton3,
	MultiCastSlotButton4,
	MultiCastFlyoutFrame,
	MultiCastFlyoutButton,
	MultiCastRecallSpellButton,
}

module:RegisterEvent("PLAYER_ENTERING_WORLD")
module:SetScript("OnEvent", function()
	totem_bar = CreateFrame("Frame", "totem_bar", UIParent)
	totem_bar:SetWidth(230)
	totem_bar:SetHeight(40)
	totem_bar:Show()
	totem_bar:SetPoint("BOTTOM", TLActionBarPanel, "TOP")

	for _, subFrame in ipairs(subFrames) do
		subFrame:SetParent(totem_bar)
		subFrame.SetParent = recLib.NullFunction
	end
	
	-- This is the Call of ____ switcher
	MultiCastSummonSpellButton:ClearAllPoints()
	MultiCastSummonSpellButton:SetPoint("BOTTOMLEFT", totem_bar, "BOTTOMLEFT", 3, 3)
	
	-- These are the pages linked to each Call of ______
	for i = 1, NUM_MULTI_CAST_PAGES do
		page = _G[format("MultiCastActionPage%d", i)]
		page:SetPoint("BOTTOMLEFT", totem_bar, "BOTTOMLEFT", 41, 3)
	end
	
	-- Move slots to buttons
	for i = 1, 4 do
		local slot = _G[format("MultiCastSlotButton%d", i)]
		slot:ClearAllPoints()
		slot:SetAllPoints(_G[format("MultiCastActionButton%d", i)])
	end
	
	MultiCastRecallSpellButton:SetParent(totem_bar)
	MultiCastRecallSpellButton:ClearAllPoints()
	MultiCastRecallSpellButton:SetPoint("BOTTOMLEFT", MultiCastSlotButton4, "BOTTOMRIGHT", 8, 0)
	
	totem_bar:SetScript("OnMouseDown", function(self) self:StartMoving() end)
	totem_bar:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)

	totem_bar:SetScale(.7)
	
	subFrames = nil
	module:UnregisterAllEvents()
	module:SetScript("OnEvent", nil)
	module = nil
end)