local recAutoShot = CreateFrame("StatusBar")
recAutoShot:SetStatusBarTexture(recMedia.texture.STATUSBAR)
recAutoShot:SetStatusBarColor(1, .3, .3, .8)
recAutoShot:SetPoint("CENTER")
recAutoShot:SetSize(200, 10)
recAutoShot:Hide()

recAutoShot.backdrop = recAutoShot:CreateTexture(nil, "BACKGROUND")
recAutoShot.backdrop:SetPoint("TOPLEFT", -2, 2)
recAutoShot.backdrop:SetPoint("BOTTOMRIGHT", 2, -2)
recAutoShot.backdrop:SetTexture(recMedia.texture.BACKDROP)
recAutoShot.backdrop:SetVertexColor(0, 0, 0, .5)

recAutoShot.label = recAutoShot:CreateFontString(nil, "OVERLAY")
recAutoShot.label:SetPoint("LEFT", 5)
recAutoShot.label:SetFont(recMedia.fontFace.NORMAL, 8, "THINOUTLINE")
recAutoShot.label:SetText("Auto Shot")

recAutoShot.time = recAutoShot:CreateFontString(nil, "OVERLAY")
recAutoShot.time:SetPoint("RIGHT", -5)
recAutoShot.time:SetFont(recMedia.fontFace.NORMAL, 8, "THINOUTLINE")

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