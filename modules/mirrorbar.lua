local _, recUI = ...
-- Test: /script MirrorTimer1:Show(); MirrorTimer2:Show(); MirrorTimer3:Show()

for i=1,3 do
	-- Make some short references
	local mirror_frame				= _G[string.format("MirrorTimer%d", i)]
	local mirror_bar_text			= _G[string.format("MirrorTimer%dText", i)]
	local mirror_bar				= _G[string.format("MirrorTimer%dStatusBar", i)]
	local mirror_default_border		= _G[string.format("MirrorTimer%dBorder", i)]
	local mirror_border				= CreateFrame("Frame", nil, mirror_frame)
	local mirror_default_backdrop	= mirror_frame:GetRegions()	-- The first region returned is the unnamed backdrop
	local mirror_backdrop			= mirror_bar:CreateTexture(nil, "BORDER")

	-- Frame position
	mirror_frame:ClearAllPoints()
	mirror_frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", (i == 1 and -394) or (i == 2 and -317.5) or (i == 3 and -239), 313.5)
	mirror_frame:SetPoint("TOPRIGHT", UIParent, "BOTTOM", (i == 1 and -319) or (i == 2 and -240.5) or (i == 3 and -164), 315.5)

	recUI.Kill(mirror_default_backdrop)	-- Remove the default backdrop
	recUI.Kill(mirror_default_border)	-- Remove the default border
	recUI.Kill(mirror_bar_text)			-- Remove the bar text

	-- Reskin the status bar
	mirror_bar:SetStatusBarTexture(recUI.media.statusBar)
	mirror_bar:ClearAllPoints()
	mirror_bar:SetAllPoints(mirror_frame)

	-- Our custom border reskin
	mirror_border:SetPoint("TOPLEFT", mirror_frame, "TOPLEFT", -4, 5)
	mirror_border:SetPoint("BOTTOMRIGHT", mirror_frame, "BOTTOMRIGHT", 5, -5)
	mirror_border:SetFrameStrata("BACKGROUND")
	mirror_border:SetBackdrop {
		edgeFile = recUI.media.edgeFile, edgeSize = 4,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	}
	mirror_border:SetBackdropColor(0, 0, 0, 0)
	mirror_border:SetBackdropBorderColor(0, 0, 0)

	-- Our custom backdrop reskin
	mirror_backdrop:SetPoint("TOPLEFT", mirror_bar, "TOPLEFT", -1.5, 1.5)
	mirror_backdrop:SetPoint("BOTTOMRIGHT", mirror_bar, "BOTTOMRIGHT", 1.5, -1.5)
	mirror_backdrop:SetTexture(0,0,0,1)
end