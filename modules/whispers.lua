local incoming = ">"
local outgoing = "<"
local message_pattern = "%s[%s] %s %s"
local afk = "[AFK]"
local dnd = "[DND]"
local ignored = "[IGNORED]"
local chat_windows = {}

local menu = CreateFrame("Frame", "recWhispersMenu")
menu.displayMode = "MENU"
menu.info = {}
local function add_menu_entry(self, text, func, title)
	local info = self.info
	wipe(info)
	info.text = text
	info.notCheckable = 1
	info.func = func
	if title then
		info.isTitle = true
	end
	UIDropDownMenu_AddButton(info, level)
end
menu.initialize = function(self, level)
	if string.find(self.target_name, "-") then
		add_menu_entry(self, "Cross-Server Communication", nil, true)
		return
	end
	add_menu_entry(self, self.target_name, nil, true)
	add_menu_entry(self, "Who", function() SendWho(self.target_name) end)
	add_menu_entry(self, "Friend", function() AddFriend(self.target_name) end)
	add_menu_entry(self, "Invite", function() InviteUnit(self.target_name) end)
	add_menu_entry(self, "Ignore", function() AddIgnore(self.target_name) end)
end

local function get_chat_window(target_name)
	-- Get an existing window for this target, if it exists.
	local old_id
	for id, window in pairs(chat_windows) do
		if ((GetTime() - window.last_timestamp) > 300) and (not window.in_use) then old_id = id end
		if window.target_name == target_name then
			chat_windows[id]:Show()
			return id
		end
	end
	-- If we had no name matched window, use a window which has not been used for five minutes.
	if old_id then
		chat_windows[old_id]:Clear()
		chat_windows[old_id].target_name = target_name
		chat_windows[old_id].title_button:SetText(target_name)
		return old_id
	end
	
	-- No chat window found, create new window.
	local new_id = (#chat_windows or 0) + 1
	local f = CreateFrame("ScrollingMessageFrame", string.format("recWhispers%d", new_id), UIParent)
	f.target_name = target_name
	f.id = new_id
	
	f.bg = CreateFrame("Frame", nil, f)
	f.bg:SetPoint("TOPLEFT", -14, 13.5)
	f.bg:SetPoint("BOTTOMRIGHT", 14, -14)
	f.bg:SetBackdrop({
		bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
		edgeFile = [=[Interface\Addons\recMedia\caellian\glowtex]=], edgeSize = 4,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	})
	f.bg:SetFrameStrata("BACKGROUND")
	f.bg:SetBackdropColor(0, 0, 0, .5)
	f.bg:SetBackdropBorderColor(0, 0, 0)

	f.title_button = CreateFrame("Button", string.format("recWhispers%dTitleButton", new_id), f)
	f.title_button:RegisterForClicks("AnyUp")
	f.title_button:SetScript("OnClick", function(self, button)
			if button == "LeftButton" then
				ChatFrame_SendTell(self:GetParent().target_name)
			elseif button == "RightButton" then
				recWhispersMenu.target_name = self:GetParent().target_name
				ToggleDropDownMenu(1, nil, recWhispersMenu, "cursor")
			end
		end)
	f.title_button:SetPoint("BOTTOMLEFT", f.bg, "TOPLEFT")
	f.title_button:SetPoint("BOTTOMRIGHT", f.bg, "TOPRIGHT", -23, 0)
	f.title_button:SetHeight(20)
	f.title_button:SetNormalFontObject(recMedia.fontObject("NORMAL", 10, ""))
	f.title_button:SetText(target_name)
	
	f.title_button.bg = CreateFrame("Frame", nil, f.title_button)
	f.title_button.bg:SetPoint("TOPLEFT")
	f.title_button.bg:SetPoint("BOTTOMRIGHT")
	f.title_button.bg:SetBackdrop({
		bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
		edgeFile = [=[Interface\Addons\recMedia\caellian\glowtex]=], edgeSize = 4,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	})
	f.title_button.bg:SetFrameStrata("BACKGROUND")
	f.title_button.bg:SetBackdropColor(0, 0, 0, .5)
	f.title_button.bg:SetBackdropBorderColor(0, 0, 0)
	
	f.close_button = CreateFrame("Button", string.format("recWhispers%dCloseButton", new_id), f)
	--f.close_button:SetWidth(28)
	--f.close_button:SetHeight(28)
	f.close_button:SetNormalFontObject(recMedia.fontObject("NORMAL", 10, ""))
	f.close_button:SetText("X")
	
	f.close_button.bg = CreateFrame("Frame", nil, f.close_button)
	f.close_button.bg:SetPoint("TOPLEFT")
	f.close_button.bg:SetPoint("BOTTOMRIGHT")
	f.close_button.bg:SetBackdrop({
		bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
		edgeFile = [=[Interface\Addons\recMedia\caellian\glowtex]=], edgeSize = 4,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	})
	f.close_button.bg:SetFrameStrata("BACKGROUND")
	f.close_button.bg:SetBackdropColor(0, 0, 0, .5)
	f.close_button.bg:SetBackdropBorderColor(0, 0, 0)
	
	f.close_button:SetPoint("TOPLEFT", f.title_button, "TOPRIGHT")
	f.close_button:SetPoint("BOTTOMRIGHT", f.bg, "TOPRIGHT")
	--f.close_button:SetPoint("TOPRIGHT", f.bg, 2.5, 24)
	--f.close_button:SetNormalTexture([[Interface\Buttons\UI-Panel-MinimizeButton-Up]])
	--f.close_button:SetPushedTexture([[Interface\Buttons\UI-Panel-MinimizeButton-Down]])
	--f.close_button:SetHighlightTexture([[Interface\Buttons\UI-Panel-MinimizeButton-Highlight]], "ADD")
	f.close_button:SetScript("OnClick", function(self)
			self:GetParent().in_use = false
			self:GetParent():Hide()
		end)
	
	f:SetHeight(150)
	f:SetWidth(300)
	f:SetFont(recMedia.fontFace.NORMAL, 9, nil)
	f:SetTextColor(1, .7, 1)
	f:SetJustifyH("LEFT")
	f:SetPoint("RIGHT", UIParent, "RIGHT", -20, 0)
	f:EnableMouse(true)
	f:EnableMouseWheel(true)
	f:SetMovable(true)
	f:RegisterForDrag("LeftButton")
	f:SetMaxLines(1000)
	f:SetFading(false)
	f:SetClampedToScreen(true)
	f:SetScript("OnDragStart", function(self) self:StartMoving() end)
	f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	f:SetScript("OnHyperlinkClick", ChatFrame_OnHyperlinkShow)
	f:SetScript("OnMouseWheel", function(self, direction)
			if direction > 0 then
				if IsShiftKeyDown() then self:ScrollToTop() else self:ScrollUp() end
			else
				if IsShiftKeyDown() then self:ScrollToBottom() else self:ScrollDown() end
			end
		end)
	chat_windows[new_id] = f
	return new_id
end

local function show_message(window_id, message)
	chat_windows[window_id]:Show()
	chat_windows[window_id].last_timestamp = GetTime()
	chat_windows[window_id].in_use = true
	chat_windows[window_id]:AddMessage(message)
end

local function on_event(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		ChatFrame_RemoveMessageGroup(ChatFrame1, "WHISPER")
		ChatFrame_RemoveMessageGroup(ChatFrame1, "AFK")
		ChatFrame_RemoveMessageGroup(ChatFrame1, "DND")
		ChatFrame_RemoveMessageGroup(ChatFrame1, "IGNORED")
		return
	end
	
	local message, player, language, gm = ...
	if gm and gm == "GM" then gm = "[GM]" else gm = "" end
	
	if event == "CHAT_MSG_WHISPER" then
		PlaySound("TellMessage")
		ChatEdit_SetLastTellTarget(player)
	end

	show_message(get_chat_window(player),
		string.format(
			message_pattern,
			gm,
			date("%H:%M"),
			((event == "CHAT_MSG_WHISPER_INFORM") and outgoing) or incoming, 
			((event == "CHAT_MSG_AFK") and afk) or 
			((event == "CHAT_MSG_DND") and dnd) or 
			((event == "CHAT_MSG_IGNORED") and ignored) or message
		)
	)

end

local event_frame = CreateFrame("Frame")
event_frame:SetScript("OnEvent", on_event)
event_frame:RegisterEvent("CHAT_MSG_WHISPER")
event_frame:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
event_frame:RegisterEvent("CHAT_MSG_AFK")
event_frame:RegisterEvent("CHAT_MSG_DND")
event_frame:RegisterEvent("CHAT_MSG_IGNORED")
event_frame:RegisterEvent("PLAYER_ENTERING_WORLD")