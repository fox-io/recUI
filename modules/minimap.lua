local event_frame = CreateFrame("Frame")

-- Objects which we want to get rid of.
local unwanted_objects = {
	MinimapBorder,
	MinimapZoneTextButton,
	MinimapToggleButton,
	MiniMapMailFrame,
	MiniMapBattlefieldFrame,
	MiniMapVoiceChatFrame,
	GameTimeFrame,
	MiniMapWorldMapButton,
	MinimapZoomIn,
	MinimapZoomOut,
	MinimapBorderTop,
	MiniMapInstanceDifficulty,
	TimeManagerClockButton,
	MinimapNorthTag
}

event_frame:SetScript("OnEvent", function(self, event)
	-- Only have to run this once.
	self:UnregisterEvent(event)
	self:SetScript("OnEvent", nil)
	
	-- Make Minimap square
	Minimap:SetMaskTexture([[Interface\AddOns\recMinimap\media\square]])
	
	-- Position Minimap
	Minimap:SetParent(TestTextureFrame)
	Minimap:ClearAllPoints()
	Minimap:SetPoint("CENTER", MiniMapPanel)
	Minimap:SetSize(142, 142)

	-- Disable cluster mouse trapping (We don't move the cluster, it is still in the upper right corner of the screen.
	MinimapCluster:EnableMouse(false)
	
	-- Remove unwanted objects
	for _, object in pairs(unwanted_objects) do
		recLib.Kill(object)
	end
	unwanted_objects = nil
	
	Minimap:SetScript("OnMouseWheel", function(self, direction)
		if direction > 0 then
			Minimap_ZoomIn()
		else
			Minimap_ZoomOut()
		end
	end)
	Minimap:EnableMouseWheel(true)
	
	event_frame = nil
end)

event_frame:RegisterEvent("PLAYER_ENTERING_WORLD")

local coordinate_text = Minimap:CreateFontString(nil, "OVERLAY")
coordinate_text:SetFont(recMedia.fontFace.NORMAL, 9, "OUTLINE")
coordinate_text:SetPoint("BOTTOM", 0, 4)
local coordinate_formatting = "%0.1f, %0.1f"

local string_format = string.format

local x, y
local function update_coordinate_text()
	x, y = GetPlayerMapPosition("player")
	if x > 0 and y > 0 then
		coordinate_text:SetText(string_format(coordinate_formatting, x*100, y*100))
	end
end

local t = 0
local function on_update(self, elapsed)
	t = t - elapsed
	if t < 0 then
		t = 1
		update_coordinate_text()
	end
end

Minimap:RegisterEvent("ZONE_CHANGED_NEW_AREA")
Minimap:HookScript("OnEvent", function(self, event, ...)
	if event == "ZONE_CHANGED_NEW_AREA" then
		SetMapToCurrentZone()
	end
end)
Minimap:HookScript("OnUpdate", on_update)

-- Shortcut references.
local container = _G.MiniMapTracking
local button    = _G.MiniMapTrackingButton

-- Rather than use an icon, we crete a fontstring which will tell us what we are tracking.
local text = Minimap:CreateFontString(nil, "OVERLAY")
text:SetFont(recMedia.fontFace.NORMAL, 9, "OUTLINE")
text:SetPoint("CENTER", button)

-- Rawr! GTFO POI tracking!  Default _Init, with filter for only find/track/quest entries.
function MiniMapTrackingDropDown_Initialize()
	local name, texture, active, category
	local anyActive, checked
	local count = GetNumTrackingTypes()
	local info
	for id=1, count do
		name, texture, active, category  = GetTrackingInfo(id)
		
		if name:find("Find") or name:find("Track") or name:find("Quests") then
			info = UIDropDownMenu_CreateInfo()
			info.text = name
			info.checked = active
			info.func = MiniMapTracking_SetTracking
			info.icon = texture
			info.arg1 = id
			if ( category == "spell" ) then
				info.tCoordLeft = 0.0625
				info.tCoordRight = 0.9
				info.tCoordTop = 0.0625
				info.tCoordBottom = 0.9
			else
				info.tCoordLeft = 0
				info.tCoordRight = 1
				info.tCoordTop = 0
				info.tCoordBottom = 1
			end
			UIDropDownMenu_AddButton(info)
			if ( active ) then
				anyActive = active
			end
		end
	end
	
	if ( anyActive ) then
		checked = nil
	else
		checked = 1
	end

	info = UIDropDownMenu_CreateInfo()
	info.text = NONE
	info.checked = checked
	info.func = MiniMapTracking_SetTracking
	info.arg1 = nil
	UIDropDownMenu_AddButton(info)
end
UIDropDownMenu_Initialize(MiniMapTrackingDropDown, MiniMapTrackingDropDown_Initialize, "MENU")

-- Update the text to reflect the current tracking type.
-- This is called from PLAYER_LOGIN -and- MINIMAP_UPDATE_TRACKING.
-- PLAYER_LOGIN uses it so if you are tracking something when you log in, the text will display properly.
-- MINIMAP_UPDATE_TRACKING fires when you change your tracking.
text.update = function()
	text:SetText("Not Tracking")
	local name, active
	local num = GetNumTrackingTypes()
	for id = 1, num do
		name, _, active = GetTrackingInfo(id)
		if active then
			return text:SetText(name)
		end
	end
	
end

local function setup_tracking()
	-- GTFO ICON FRAME!  Sadly, all attempts to simply hide this failed.  So... move it off the damn screen!
	container:ClearAllPoints()
	container:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", 9001, 9001)
	
	-- Position tracking BUTTON. Text is anchored to this.
	button:ClearAllPoints()
	button:SetPoint("TOPLEFT", Minimap)
	button:SetPoint("BOTTOMRIGHT", Minimap, "TOPRIGHT", 0, -15)
	
	-- Damnit Bliz! Re-anchor the dropdown to the BUTTON and not the icon texture frame.
	button:SetScript("OnClick", function(self)
		ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, "cursor")
	end)
	
	-- Remove highlight texture
	button:SetHighlightTexture(nil)

	-- Remove border and animation from tracking button
	MiniMapTrackingButtonBorder:SetTexture(nil)
	MiniMapTrackingButtonShine:SetTexture(nil)
	
	-- Remove tooltip.  We're using text now, so no need to use a tip to explain anything.
	button:SetScript("OnEnter", nil)
	button:SetScript("OnLeave", nil)
	
	-- Remove the shine animation on tracking change
	MiniMapTrackingShineFadeIn = recLib.NullFunction
	MiniMapTrackingShineFadeOut = recLib.NullFunction
end

Minimap:RegisterEvent("PLAYER_LOGIN")
Minimap:RegisterEvent("MINIMAP_UPDATE_TRACKING")
Minimap:HookScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		setup_tracking()
		setup_tracking = nil
	end
	
	text.update()
end)