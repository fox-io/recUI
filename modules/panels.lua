local _, recPanels = ...

recPanels.event_frame = CreateFrame("Frame")
recPanels.panels = {}

--[[reference
recMedia.backdrop_table = {
	bgFile   = [=[Interface\ChatFrame\ChatFrameBackground]=],
	edgeFile = [=[Interface\Addons\recMedia\caellian\glowtex]=],
	edgeSize = 4,
	insets   = {
		left   = 3,
		right  = 3,
		top    = 3,
		bottom = 3
	}
}
--]]

recPanels.create_panel = function(self, name, offsetx, offsety, width, height, point, rpoint, anchor, parent)
	local id = (#self.panels or 0) + 1
	self.panels[id] = CreateFrame("Frame", name, parent)
	self.panels[id]:SetWidth(width)
	self.panels[id]:SetHeight(height)
	self.panels[id]:SetPoint(point, anchor, rpoint, offsetx, offsety)
	
	self.panels[id]:SetBackdrop({
		bgFile = nil,
		edgeFile = [[Interface\Addons\recMedia\caellian\glowtex]],
		edgeSize = 4,
	})
	self.panels[id]:SetBackdropBorderColor(0,0,0)
	self.panels[id]:SetFrameLevel(1)
	
	self.panels[id].backdrop = self.panels[id]:CreateTexture(nil, "BACKGROUND")
	self.panels[id].backdrop:SetPoint("TOPLEFT", 4, -4)
	self.panels[id].backdrop:SetPoint("BOTTOMRIGHT", -4, 4)
	self.panels[id].backdrop:SetTexture([[Interface\ChatFrame\ChatFrameBackground]])
	self.panels[id].backdrop:SetVertexColor(0,0,0,1)
	self.panels[id].backdrop:SetDrawLayer("BACKGROUND")
	
	self.panels[id]:Show()
end

-- UI Panels
recPanels:create_panel("SouthPanel",		 0, 10, 1322,     20.0, "BOTTOM",	   "BOTTOM",		UIParent,		  UIParent)
recPanels:create_panel("MiniMapPanel",		 0,  0,  150,    150.0, "BOTTOM",	   "TOP",			SouthPanel,		  UIParent)
recPanels:create_panel("LRActionBarPanel",	 0,  0,  180,     70.0, "BOTTOMLEFT",  "BOTTOMRIGHT",	MiniMapPanel,	  UIParent)
recPanels:create_panel("LLActionBarPanel",	 0,  0,  180,     70.0, "BOTTOMRIGHT", "BOTTOMLEFT",	MiniMapPanel,	  UIParent)
recPanels:create_panel("TRActionBarPanel",	 0,  0,  180,     70.0, "TOPLEFT",	   "TOPRIGHT",		MiniMapPanel,	  UIParent)
recPanels:create_panel("TLActionBarPanel",	 0,  0,  180,     70.0, "TOPRIGHT",	   "TOPLEFT",		MiniMapPanel,	  UIParent)
recPanels:create_panel("RBoxPanel",			 0,  0,  411,    130.0, "BOTTOMLEFT",  "BOTTOMRIGHT",	LRActionBarPanel, UIParent)
recPanels:create_panel("LRBoxPanel",		 0,  0,  203.25, 150.0, "BOTTOMRIGHT", "BOTTOMLEFT",	LLActionBarPanel, UIParent)
recPanels:create_panel("LLBoxPanel",		 0,  0,  202,    150.0, "BOTTOMRIGHT", "BOTTOMLEFT",	LRBoxPanel,       UIParent)
recPanels:create_panel("RaidPanel",			 0,  0,  271,    130.0, "BOTTOMLEFT",  "TOPLEFT",		LBoxPanelTopper,  UIParent)
recPanels:create_panel("ChatTab3Panel",      0,  0,    1,        1, "BOTTOMRIGHT", "TOPRIGHT",      RBoxPanel,        UIParent)
recPanels:create_panel("ChatTab2Panel",      0,  0,    1,        1, "BOTTOMRIGHT", "BOTTOMLEFT",    ChatTab3Panel,    UIParent)
recPanels:create_panel("ChatTab1Panel",      0,  0,    1,        1, "BOTTOMRIGHT", "BOTTOMLEFT",    ChatTab2Panel,    UIParent)
recPanels:create_panel("EditBoxPanel",       0,  0,    1,        1, "BOTTOMLEFT",  "TOPLEFT",       RBoxPanel,        UIParent)

-- Additional anchors
RBoxPanel:SetPoint("BOTTOMRIGHT", SouthPanel,       "TOPRIGHT")
LRBoxPanel:SetPoint("TOPRIGHT",   TLActionBarPanel, "TOPLEFT")
LLBoxPanel:SetPoint("TOPRIGHT",   LRBoxPanel,       "TOPLEFT")
LLBoxPanel:SetPoint("BOTTOMLEFT", SouthPanel,       "TOPLEFT")
ChatTab3Panel:SetPoint("TOPLEFT", RBoxPanel,        "TOPRIGHT",   -30, 20)
ChatTab2Panel:SetPoint("TOPLEFT", ChatTab3Panel,    "BOTTOMLEFT", -30, 20)
ChatTab1Panel:SetPoint("TOPLEFT", ChatTab2Panel,    "BOTTOMLEFT", -30, 20)
EditBoxPanel:SetPoint("TOPRIGHT", ChatTab1Panel,    "TOPLEFT",      0,  0)

local _, playerClass = UnitClass("player")
local c = RAID_CLASS_COLORS[playerClass]

local textures = {
	["leaf"] = {
		file = [[Interface\Addons\recMedia\panels\leaf]],
		vertex = { r = 0, g = 0, b = 0, a = 1 },
		panel = { r = .25, g = .25, b = .25, a = .5 }
	},
	["cyborg"] = {
		file = [[Interface\Addons\recMedia\panels\cyborg]],
		vertex = { r = c.r, g = c.g, b = c.b, a = 1 },
		panel = { r = 0, g = 0, b = 0, a = 0 }
	},
}

-- Apply texture
local texture = textures["cyborg"]

local textureFrame = CreateFrame("Frame", "TestTextureFrame", UIParent)
textureFrame:SetPoint("TOPLEFT", LLBoxPanel, 4, -4)
textureFrame:SetPoint("BOTTOMRIGHT", SouthPanel, -4, 4)
textureFrame:SetFrameLevel(1)

textureFrame.texture = textureFrame:CreateTexture(nil, "BACKGROUND")
textureFrame.texture:SetTexture(texture.file)
textureFrame.texture:SetAllPoints()
textureFrame.texture:SetVertexColor(texture.vertex.r, texture.vertex.g, texture.vertex.b, texture.vertex.a)
textureFrame.texture:SetDrawLayer("BORDER")

for _, panel in pairs(recPanels.panels) do
	panel.backdrop:SetVertexColor(texture.panel.r, texture.panel.g, texture.panel.b, texture.panel.a)
end






--[[recPanels.on_raid = function(self, num_members)
	RaidPanel:SetWidth(282)
	RaidPanel:SetHeight(132.5)
end
recPanels.on_party = function(self, num_members)
	RaidPanel:SetWidth(137.5)
	if not num_members or num_members == 1 then
		RaidPanel:Hide()
	else
		RaidPanel:Show()
		RaidPanel:SetHeight( (20 * num_members) + (3 * (num_members - 1) ) + 20)
	end
end

recPanels.event_frame:RegisterEvent("PLAYER_LOGIN") 
recPanels.event_frame:RegisterEvent("RAID_ROSTER_UPDATE") 
recPanels.event_frame:RegisterEvent("PARTY_LEADER_CHANGED") 
recPanels.event_frame:RegisterEvent("PARTY_MEMBERS_CHANGED") 
recPanels.event_frame:SetScript("OnEvent", function(self) 
	if InCombatLockdown() then
		-- Try again after combat.
		recPanels.event_frame:RegisterEvent("PLAYER_REGEN_ENABLED") 
		return
	else
		-- Stop watching combat.
		recPanels.event_frame:UnregisterEvent("PLAYER_REGEN_ENABLED") 
	end
	
	local num_raid_members = GetNumRaidMembers() 
	if (num_raid_members > 0) and ( (num_raid_members > 5) or (num_raid_members ~= (GetNumPartyMembers() + 1) ) ) then
		-- Is in a raid
		recPanels:on_raid(num_raid_members)
	else
		-- Is in a party
		recPanels:on_party(GetNumPartyMembers()+1)
	end
end) --]]