local _, recUI = ...
--This is a heavily modified version of gotChat.
--
--Support is provided by the compilation's author and not by the author(s) of the individual addons.

local format = string.format
local _G = _G
local cftbb = CreateFrame("Frame", "RecChatButtonBar", UIParent)

local font = recUI.media.font

local function GetChatFrameID(...)
	-- Gets the current chat frame's id.
	return RecChatButtonBar.id
end

local function GetCurrentChatFrame(...)
	-- Gets the chat frame which should be currently shown.
	return _G[format("ChatFrame%s", RecChatButtonBar.id)]
end

color_border = function(object)
	-- Blizzard's code for reverting sticky targets that do not exist.
	if ( ChatFrameEditBox:GetAttribute("chatType") == ChatFrameEditBox:GetAttribute("stickyType") ) then
		if (ChatFrameEditBox:GetAttribute("stickyType") == "GUILD" and not GetGuildInfo("player")) or ( (ChatFrameEditBox:GetAttribute("stickyType") == "PARTY") and (GetNumPartyMembers() == 0) ) or ( (ChatFrameEditBox:GetAttribute("stickyType") == "RAID") and (GetNumRaidMembers() == 0) ) or ( (ChatFrameEditBox:GetAttribute("stickyType") == "BATTLEGROUND") and (GetNumRaidMembers() == 0) ) then
			ChatFrameEditBox:SetAttribute("chatType", "SAY")
			ChatEdit_UpdateHeader(ChatFrameEditBox)
		end
	end
	
	local chat_type = ChatFrameEditBox:GetAttribute("chatType")
	object:SetBackdropBorderColor((ChatTypeInfo[chat_type].r or 1) * .4, (ChatTypeInfo[chat_type].g or 1) * .4, (ChatTypeInfo[chat_type].b or 1) * .4)
end

local function ShowChatFrame(self)
	-- Set required id variables.
	RecChatButtonBar.id = self.id
	SELECTED_CHAT_FRAME = _G[format("ChatFrame%s", self.id)]

	-- Hide all chat frames
	for i=1,3 do
		_G[format("ChatTab%sPanel", i)]:SetBackdropBorderColor(0, 0, 0)
		_G[format("ChatFrame%s", i)]:Hide()
	end

	-- Change our tab to a colored version so the user can see which tab is selected.
	color_border(_G[format("ChatTab%sPanel", self.id)])

	-- If this is not the combat log, then show the chat frame.
	_G[format("ChatFrame%s", self.id)]:Show()
end

function remove_chat(i)
	if i ~= 2 then
		local cf = _G[format("ChatFrame%d", i)]
		ChatFrame_RemoveAllChannels(cf)
		ChatFrame_RemoveAllMessageGroups(cf)
	end
end

local function join_zone_channels()
	local cf = ChatFrame1
	ChatFrame_AddChannel(cf, "General")
	ChatFrame_AddChannel(cf, "Trade")
	ChatFrame_AddChannel(cf, "LocalDefense")
	local guild = GetGuildInfo("player")
	if not guild then
		ChatFrame_AddChannel(cf, "GuildRecruitment")
	end
	ChatFrame_AddChannel(cf, "LookingForGroup")
end

local function enable_chat_types(i)
	local cf = _G[format("ChatFrame%d", i)]
	if i == 1 then
		ChatFrame_AddMessageGroup(cf, "SAY")
		ChatFrame_AddMessageGroup(cf, "EMOTE")
		ChatFrame_AddMessageGroup(cf, "YELL")
		ChatFrame_AddMessageGroup(cf, "GUILD")
		ChatFrame_AddMessageGroup(cf, "GUILD_OFFICER")
		ChatFrame_AddMessageGroup(cf, "GUILD_ACHIEVEMENT")
		ChatFrame_AddMessageGroup(cf, "PARTY")
		ChatFrame_AddMessageGroup(cf, "PARTY_LEADER")
		ChatFrame_AddMessageGroup(cf, "RAID")
		ChatFrame_AddMessageGroup(cf, "RAID_LEADER")
		ChatFrame_AddMessageGroup(cf, "RAID_WARNING")
		ChatFrame_AddMessageGroup(cf, "BATTLEGROUND")
		ChatFrame_AddMessageGroup(cf, "BATTLEGROUND_LEADER")
		ChatFrame_AddMessageGroup(cf, "ACHIEVEMENT")
		ChatFrame_AddMessageGroup(cf, "MONSTER_SAY")
		ChatFrame_AddMessageGroup(cf, "MONSTER_EMOTE")
		ChatFrame_AddMessageGroup(cf, "MONSTER_YELL")
		ChatFrame_AddMessageGroup(cf, "MONSTER_WHISPER")
		ChatFrame_AddMessageGroup(cf, "MONSTER_BOSS_EMOTE")
		ChatFrame_AddMessageGroup(cf, "MONSTER_BOSS_WHISPER")
		ChatFrame_AddMessageGroup(cf, "BG_HORDE")
		ChatFrame_AddMessageGroup(cf, "BG_ALLIANCE")
		ChatFrame_AddMessageGroup(cf, "BG_NEUTRAL")
		ChatFrame_AddMessageGroup(cf, "CHANNEL")
		ChatFrame_AddMessageGroup(cf, "SYSTEM")
		ChatFrame_AddMessageGroup(cf, "SKILL")
	elseif i == 3 then
		ChatFrame_AddMessageGroup(cf, "LOOT")
		ChatFrame_AddMessageGroup(cf, "MONEY")
		ChatFrame_AddMessageGroup(cf, "COMBAT_HONOR_GAIN")
		ChatFrame_AddMessageGroup(cf, "COMBAT_XP_GAIN")
		ChatFrame_AddMessageGroup(cf, "COMBAT_FACTION_CHANGE")
		ChatFrame_AddMessageGroup(cf, "ERRORS")
	end
end
local _, playerClass = UnitClass("player")
local c = RAID_CLASS_COLORS[playerClass]

local previous_zone
recUI.lib.registerEvent("VARIABLES_LOADED", "recUIModuleChatOnLoad", function(self, event, addon, ...)
	-- Fake a PEW to this handler to prevent an error on game clients which have a fresh WTF folder.
	-- This forces an init on the checkboxes in the chatframe config pages.  For some reason, blocking
	-- the default chat tabs prevents this from being called correctly.
	ChatConfigFrame_OnEvent(nil, "PLAYER_ENTERING_WORLD", ...)
	
	-- Random error from within this function.  It is not needed, so dispose of it.
	FCF_UpdateButtonSide = function() end
	
	local cf1 = _G["ChatFrame1"]
	local cfmb = _G["ChatFrameMenuButton"]
	
	-- Rename Dungeon Guide to 'P' just like normal party people. Has lighter color, tho.
	CHAT_PARTY_GUIDE_GET = "|Hchannel:party|hP|h %s:\32";

	-- Remove chat frame mouseover highlight. Thanks Caellian
	DEFAULT_CHATFRAME_ALPHA = 0

	for i = 1, 7 do
		local cf = _G[format("ChatFrame%s", i)]
		
		cf:SetParent(TestTextureFrame)
		
		cf:SetFont(recUI.media.font, 9, nil)
		
		-- Disable/Hide chat tabs
		local cft = _G[format("ChatFrame%sTab", i)]
		local cftf = _G[format("ChatFrame%sTabFlash", i)]
		cf:SetScript("OnEnter", nil)
		cft:EnableMouse(false)
		cft:SetScript("OnEnter", nil)
		cft:SetScript("OnLeave", nil)
		cft:GetHighlightTexture():SetTexture(nil)
		cft.SetAlpha = function() end
		cftf:SetScript("OnShow", nil)
		cftf:SetScript("OnHide", nil)
		cftf:GetRegions():SetTexture(nil)
		recUI.lib.Kill(_G[format("ChatFrame%sTabLeft", i)])
		recUI.lib.Kill(_G[format("ChatFrame%sTabMiddle", i)])
		recUI.lib.Kill(_G[format("ChatFrame%sTabRight", i)])
		recUI.lib.Kill(_G[format("ChatFrame%sTabText", i)])
		recUI.lib.Kill(_G["ChatFrame"..i.."TabDockRegionHighlight"])

		-- Enable Mousewheel scrolling
		cf:SetScript("OnMouseWheel", function(self, v)
			if v > 0 then
				if IsShiftKeyDown() then
					self:ScrollToTop()
				else
					self:ScrollUp()
				end
			elseif v < 0 then
				if IsShiftKeyDown() then
					self:ScrollToBottom()
				else
					self:ScrollDown()
				end
			end
		end)
		cf:EnableMouseWheel(true)

		-- Disable side scroll buttons
		recUI.lib.Kill(_G[format("ChatFrame%sUpButton", i)])
		recUI.lib.Kill(_G[format("ChatFrame%sDownButton", i)])
		recUI.lib.Kill(_G[format("ChatFrame%sBottomButton", i)])

		-- Disable fading
		cf:SetFading(nil)

		-- Larger scrollback buffer (x10)
		cf:SetMaxLines(2500)
		
		remove_chat(i)
		enable_chat_types(i)

		cf:Hide()
	end
	
	join_zone_channels()

	-- Move and dim language/emote button
	cfmb:SetAlpha(0.125)
	cfmb:ClearAllPoints()
	cfmb:SetPoint("TOPRIGHT", RBoxPanel, "TOPRIGHT", 0, 0)

	-- Custom chat tabs
	cftbb:SetWidth(180); cftbb:SetHeight(20)
	cftbb:SetPoint("BOTTOMLEFT", cf1, "TOPLEFT", 0, 0)
	cftbb:EnableMouse(true)
	cftbb:SetAlpha(1)
	cftbb.id = 1
	
	local function MakeButton(id, txt, tip)
		local btn = CreateFrame("Button", format("RecChatButton%s", id), cftbb)
		btn.id = id
		btn:SetWidth(30); btn:SetHeight(20)
		--btn:SetScript("OnEnter", function(...) RecChatButtonBar:SetAlpha(1) end)
		--btn:SetScript("OnLeave", function(...) RecChatButtonBar:SetAlpha(0) end)
		btn:RegisterForClicks("LeftButtonDown", "RightButtonDown")
		btn:SetScript("OnClick", function(self, button, ...)
			if button == "RightButton" then
				if self.id == RecChatButtonBar.id then
					ShowUIPanel(ChatConfigFrame)
				end
			else
				ShowChatFrame(self)
			end
		end)
		if tip then
			btn:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_NONE")
				GameTooltip:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT")
				GameTooltip:AddLine(tip)
				GameTooltip:Show()
			end)
		end
		btn:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
		btn.t = btn:CreateFontString(nil, "OVERLAY")
		btn.t:SetFont(recUI.media.font, 9, nil)
		btn.t:SetPoint("CENTER")
		btn.t:SetTextColor(1, 1, 1)
		btn.t:SetText(txt)
		
		return btn
	end
	
	local cft1 = MakeButton(1, "G", "General")
	local cft2 = MakeButton(2, "C", "Combat")
	local cft3 = MakeButton(3, "I", "Info")
	
	cft3:SetPoint("BOTTOMRIGHT", RBoxPanel, "TOPRIGHT", 0, 0)
	cft2:SetPoint("RIGHT", cft3, "LEFT")
	cft1:SetPoint("RIGHT", cft2, "LEFT")

	-- Override old tab bar functions so that we can use our custom buttons to open chat options
	FCF_GetCurrentChatFrameID = GetChatFrameID
	FCF_GetCurrentChatFrame = GetCurrentChatFrame

	-- Edit box positioning
	local cfeb = _G["ChatFrameEditBox"]
	cfeb:SetFrameStrata("TOOLTIP")
	cfeb:ClearAllPoints()
	cfeb:SetPoint("BOTTOMLEFT", RBoxPanel, "TOPLEFT", 0, 0)
	cfeb:SetPoint("BOTTOMRIGHT", cft1, "BOTTOMLEFT", 0, 0)

	-- Edit box theme
	local l, m, r = select(6, cfeb:GetRegions())
	l:Hide()
	m:Hide()
	r:Hide()
	cfeb:SetFont(recUI.media.font, 9, nil)
	cfeb:SetHeight(20)
	cfeb:HookScript("OnShow", function(self)
		color_border(EditBoxPanel)
	end)
	cfeb:HookScript("OnHide", function(self)
		EditBoxPanel:SetBackdropBorderColor(0, 0, 0)
		-- Change the color of the selected chat button to match sticky chat type
		for i=1,3 do
			if _G[format("RecChatButton%s", i)].id == RecChatButtonBar.id then
				color_border(_G[format("ChatTab%sPanel", i)])
			end
		end
	end)

	-- Allow arrow key editing
	cfeb:SetAltArrowKeyMode(0)

	-- Enable edit box history
	local history = {}
	local function AddHistory(obj, line)
		table.insert(history, line)
		for i=1, #history - obj:GetHistoryLines() do
			table.remove(history, 1)
		end
	end
	cfeb:HookScript("OnEnter", AddHistory)

	-- Chat timestamps
	--local PostTimestamp = cf1.AddMessage
	--local function AddTimestamp(frame, text, ...)
		--if text then text = format("[%s] %s", date("%H:%M"), text) end
		--return PostTimestamp(frame, text, ...)
	--end
	--cf1.AddMessage = AddTimestamp
	
	-- Shorten channel names/messages
	CHAT_PARTY_GET               = "|Hchannel:Party|hP|h %s:\32"
	CHAT_MONSTER_PARTY_GET       = "|Hchannel:Party|hP|h %s: "
	CHAT_PARTY_LEADER_GET        = "|Hchannel:Party|hP|h %s: "
	CHAT_CHANNEL_LEAVE_GET       = "%s left."
	CHAT_MONSTER_SAY_GET         = "%s: "
	CHAT_CHANNEL_JOIN_GET        = "%s joined."
	CHAT_BATTLEGROUND_LEADER_GET = "|Hchannel:Battleground|hBL|h %s: "
	CHAT_RAID_GET                = "|Hchannel:raid|hR|h %s: "
	CHAT_YELL_GET                = "%s: "
	CHAT_BATTLEGROUND_GET        = "|Hchannel:Battleground|hBG|h %s: "
	CHAT_GUILD_GET               = "|Hchannel:Guild|hG|h %s: "
	CHAT_SAY_GET                 = "%s: "
	CHAT_RAID_WARNING_GET        = "RW %s: "
	CHAT_RAID_LEADER_GET         = "|Hchannel:raid|hRL|h %s: "
	CHAT_OFFICER_GET             = "|Hchannel:o|hO|h %s: "
	CHAT_MONSTER_YELL_GET        = "%s: "
	CHAT_MONSTER_WHISPER_GET     = "From %s: "
	CHAT_CHANNEL_LIST_GET        = "|Hchannel:%d|h%s|h:\32"
	CHAT_YOU_CHANGED_NOTICE      = ""--"Changed: |Hchannel:%d|h%s|h"
	CHAT_YOU_JOINED_NOTICE       = ""--"Joined: |Hchannel:%d|h%s|h"
	CHAT_YOU_LEFT_NOTICE         = ""--"Left: |Hchannel:%d|h%s|h"
	CHAT_SUSPENDED_NOTICE        = ""--"Left: |Hchannel:%d|h%s|h "
	ERR_FRIEND_OFFLINE_S         = "%s logged out."
	ERR_FRIEND_ONLINE_SS         = "|Hplayer:%s|h%s|h logged in."
	ERR_FRIEND_REMOVED_S         = "%s is no longer your friend."
	ERR_FRIEND_ADDED_S           = "%s is now your friend."
	
	-- Shorten edit box targets
	CHAT_BATTLEGROUND_SEND = "BG:\32"
	CHAT_CHANNEL_SEND      = "%d. %s:\32"
	CHAT_GUILD_SEND        =  "G:\32"
	CHAT_OFFICER_SEND      =  "O:\32"
	CHAT_PARTY_SEND        =  "P:\32"
	CHAT_RAID_SEND         =  "R:\32"
	CHAT_RAID_WARNING_SEND = "RW:\32"
	CHAT_SAY_SEND          =  "S:\32"
	CHAT_WHISPER_SEND      = "%s:\32"
	CHAT_YELL_SEND         =  "Y:\32"

	-- Move chat into proper position
	for cfnum = 1, 2 do
		if cfnum == 2 then cfnum = 3 end
		local cf = _G[format("ChatFrame%d", cfnum)]
		cf:ClearAllPoints()
		cf:SetPoint("BOTTOMLEFT", RBoxPanel, "BOTTOMLEFT", 5, 7)
		cf:SetPoint("TOPRIGHT", RBoxPanel, "TOPRIGHT", -5, -7)
		cf.SetPoint = function() end
		cf:Hide()
	end

	for i = 1, 7 do
		-- Make chat frames transparent
		_G[format("ChatFrame%sBackground", i)]:SetVertexColor(0, 0, 0, 0)
		_G[format("ChatFrame%sBackground", i)].SetVertexColor = function() end
	end
	
	-- Enable class coloring
	ToggleChatColorNamesByClassGroup(true, "SAY")
	ToggleChatColorNamesByClassGroup(true, "EMOTE")
	ToggleChatColorNamesByClassGroup(true, "YELL")
	ToggleChatColorNamesByClassGroup(true, "GUILD")
	ToggleChatColorNamesByClassGroup(true, "GUILD_OFFICER")
	ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "WHISPER")
	ToggleChatColorNamesByClassGroup(true, "PARTY")
	ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID")
	ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND_LEADER")
	ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
	
	-- Start with chat frame 1 shown.
	ShowChatFrame(cft1)

	-- Prevent Blizzard from changing to chat tab 1 (on instance enter, flight path end etc).
	cf1:HookScript("OnShow", function()
		if RecChatButtonBar.id ~= 1 then
			ShowChatFrame(_G[format("RecChatButton%d", RecChatButtonBar.id)])
		end
	end)
	
	recUI.lib.unregisterEvent("VARIABLES_LOADED", "recUIModuleChatOnLoad")
end)

ChatTypeInfo.SAY.sticky = 1
ChatTypeInfo.EMOTE.sticky = 1
ChatTypeInfo.YELL.sticky = 1
ChatTypeInfo.PARTY.sticky = 1
ChatTypeInfo.GUILD.sticky = 1
ChatTypeInfo.OFFICER.sticky = 1
ChatTypeInfo.RAID.sticky = 1
ChatTypeInfo.RAID_WARNING.sticky = 0
ChatTypeInfo.BATTLEGROUND.sticky = 1
ChatTypeInfo.WHISPER.sticky = 1
ChatTypeInfo.CHANNEL.sticky = 1

recUI.lib.scheduleUpdate("recUIModuleChatColors", 10, function()
	join_zone_channels()
	ChangeChatColor("CHANNEL1", 1, .75, .75)	-- General
	ChangeChatColor("CHANNEL2", 1, .75, .75)	-- Trade
	ChangeChatColor("CHANNEL3", 1, .75, .75)	-- LocalDefense
	ChangeChatColor("CHANNEL4", 1, .75, .75)	-- GuildRecruitment
	ChangeChatColor("CHANNEL5", 1, .75, .75)	-- LookingForGroup
	ChangeChatColor("WHISPER",  1,  .7,   1)	-- Incoming Whispers
	ChangeChatColor("WHISPER_INFORM", 1, .7, 1)	-- Outgoing Whispers
	recUI.lib.unscheduleUpdate("recUIModuleChatColors")
end)