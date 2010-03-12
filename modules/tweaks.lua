local _, recUI = ...
recUI.tweaks = {}
local t = recUI.tweaks

recUI.tweaks.eventFrame = CreateFrame("Frame")

local GetInventoryItemQuality = GetInventoryItemQuality
local CharacterFrame = CharacterFrame
local GetContainerItemLink = GetContainerItemLink
local GetTradeSkillNumReagents = GetTradeSkillNumReagents
local GetTradeSkillReagentItemLink = GetTradeSkillReagentItemLink
local MerchantFrame = MerchantFrame
local GetMerchantNumItems = GetMerchantNumItems
local GetMerchantItemLink = GetMerchantItemLink
local ATTACHMENTS_MAX_SEND = ATTACHMENTS_MAX_SEND
local GetSendMailItem = GetSendMailItem
local q
local select = select
local pairs = pairs
local type = type
local numPage = MERCHANT_ITEMS_PER_PAGE
local GetItemInfo = GetItemInfo
local GetTradePlayerItemLink = GetTradePlayerItemLink

-- Move achievement/dungeon completions to center of screen.
local function reanchor()
	local one, two, lfg = AchievementAlertFrame1, AchievementAlertFrame2, DungeonCompletionAlertFrame1
	if one then
		one:ClearAllPoints()
		one:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	end
	if two then
		two:ClearAllPoints()
		two:SetPoint("TOP", one, "BOTTOM", 0, -10)	
	end
	if lfg:IsShown() then
		lfg:ClearAllPoints()
		if one then
			if two then
				lfg:SetPoint("TOP", two, "BOTTOM", 0, -10)
			else
				lfg:SetPoint("TOP", one, "BOTTOM", 0, -10)
			end
		else
			lfg:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		end
	end
end

recUI.tweaks.eventFrame:RegisterEvent("VARIABLES_LOADED")
recUI.tweaks.eventFrame:HookScript("OnEvent", function(self, event, ...)
	if event == "VARIABLES_LOADED" then
		AlertFrame_FixAnchors = reanchor
	end
end)






-- Toggle name on head when afk
recUI.tweaks.eventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
recUI.tweaks.eventFrame:RegisterEvent("PLAYER_LOGOUT")
recUI.tweaks.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
recUI.tweaks.eventFrame:HookScript("OnEvent", function(self, event, ...)
	if event == "CHAT_MSG_SYSTEM" or event == "PLAYER_LOGOUT" or event == "PLAYER_ENTERING_WORLD" then
		if event == "PLAYER_LOGOUT" then
			SetCVar("UnitNameOwn", 0)
		else
			SetCVar("UnitNameOwn", UnitIsAFK("player") and 1 or 0)
			
			if event == "CHAT_MSG_SYSTEM" then
				if string.find(..., CLEARED_AFK) then
					SetCVar("UnitNameOwn", 0)
				elseif string.find(..., string.gsub(MARKED_AFK_MESSAGE, "%%s", ".*")) or string.find(..., MARKED_AFK) then
					SetCVar("UnitNameOwn", 1)
				end
			end
		end
	end
end)





-- Auto release in battlegrounds
recUI.tweaks.eventFrame:RegisterEvent("PLAYER_DEAD")
recUI.tweaks.eventFrame:HookScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_DEAD" then
		if MiniMapBattlefieldFrame.status == "active" then
			RepopMe()
		end
	end
end)





-- Setup many cvars
recUI.tweaks.eventFrame:RegisterEvent("PLAYER_LOGIN")
recUI.tweaks.eventFrame:HookScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		SetCVar("alwaysCompareItems", 0)						-- 0,1 show comparison tooltips 0 == with shift, 1 == full time
		SetCVar("autoDismount", 1)								-- 0,1 dismount when using an ability
		SetCVar("autoDismountFlying", 1)						-- 0,1 dismount when using an ability while flying
		SetCVar("autointeract", 0)								-- 0,1 aka: Click to move
		SetCVar("autoStand", 1)									-- 0,1 stand up when using an ability
		SetCVar("autoUnshift", 1)								-- 0,1 unshapeshift when necessary for abilities
		SetCVar("baseMip", 1)									-- 0-1, lower == better quality aka Texture Resolution
		SetCVar("cameraDistanceMax", 50)						-- 1-50 max distance camera can zoom
		SetCVar("cameraDistanceMaxFactor", 3.4)					-- 1-3.4 max camera distance factor (max*factor)
		SetCVar("cameraDistanceMoveSpeed", 50)					--
		SetCVar("cameraViewBlendStyle", 2)						-- 1,2 camera movement from saved position: 1 smooth, 2 instant
		SetCVar("componentTextureLevel", 8)						-- 8-9 aka Player Textures
		SetCVar("environmentDetail", 0)							-- 0-2 draw distance for doodads
		SetCVar("equipmentManager", 1)							--
		SetCVar("extShadowQuality", 0)							-- 0-5
		SetCVar("farclip", 1277)								-- 177-1277 aka View Distance
		SetCVar("farclipoverride", 0)							-- 0,1 Override 777 farclip limit, only needed in some clients
		SetCVar("ffx", "0")										--
		SetCVar("ffxDeath", "0")								-- 0,1 aka Death Effect
		SetCVar("ffxGlow", "0")									-- 0,1 aka Full Screen Glow
		SetCVar("groundEffectDensity", 0)						-- 16-64 aka Ground Clutter Density (0-250?)
		SetCVar("groundEffectDist", 0)							-- 70-140 aka Ground Clutter Radius
		SetCVar("gxapi", "d3d9")								-- "d3d9", "d3d9ex", "opengl"
		SetCVar("gxCursor", "1")								-- 0,1 aka Use Hardware Cursor
		SetCVar("gxFixLag", "0")								--
		SetCVar("gxMultisample","1")							--
		SetCVar("gxMultisampleQuality","0.000000")				--
		SetCVar("gxRefresh", "50")								--
		SetCVar("gxtextureCacheSize", 0)						-- 0-512 in MB cache textures in memory (see also texturecachesize)
		SetCVar("gxTripleBuffer", "0")							--
		SetCVar("gxVSync", "0")									--
		SetCVar("M2Faster", 1)									-- 0,1 reduce the number of times we re-program the vertex shader hardware when vertex shaders are enabled
		SetCVar("mapShadows", "0")								-- 0,1 terrain shadows
		SetCVar("Maxfps", "45")									-- limit game fps. 0 = no limit
		SetCVar("maxfpsbk", "10")								-- limit game fps when game is in background/minimized. 0 = no limit
		SetCVar("nameplateShowEnemies", 1)						--
		SetCVar("objectFade", 1)								-- 0,1 fading of small objects
		SetCVar("ObjectSelectionCircle", 1)						-- 0,1 show selection circle
		SetCVar("particleDensity", 1)							-- 0.1-1
		SetCVar("previewTalents", 1)							--
		SetCVar("projectedTextures", 1)							-- 0,1
		SetCVar("screenshotFormat", "jpeg")						-- 'jpeg' or 'tga'
		SetCVar("ScreenshotQuality", 10)						-- 1-10
		SetCVar("secureAbilityToggle", 1)						--
		SetCVar("shadowLevel", "0")								--
		SetCVar("shadowLOD", "0")								-- 0,1 blob shadows
		SetCVar("showfootprints", "0")							--
		SetCVar("showNewbieTips", 0)							--
		SetCVar("showGameTips", 0)								-- 0,1 Loading screen tips
		SetCVar("showTutorials", 0)								-- 0,1 Level 1 tutorial nonsense
		SetCVar("skycloudlod", 0)								-- 0-3 level of sky detail
		SetCVar("Sound_AmbienceVolume", "1")					--
		SetCVar("Sound_EnableErrorSpeech", "0")					--
		SetCVar("Sound_EnableMusic", "0")						--
		SetCVar("Sound_EnableSoundWhenGameIsInBG", "1")			--
		SetCVar("Sound_ListenerAtCharacter", 1)					-- 0,1 1 = character 0 = camera
		SetCVar("Sound_MasterVolume", "1")						--
		SetCVar("Sound_MusicVolume", "0")						--
		SetCVar("Sound_OutputQuality", "0")						--
		SetCVar("Sound_SFXVolume", "1")							--
		SetCVar("specular", "0")								-- 0,1 aka Specular Lighting
		SetCVar("spellEffectLevel", "9")						-- 9-2000 2000 will make video card catch fire and die a quick death.
		SetCVar("synchronizeSettings", 1)						-- 0,1 sync ui settings to server
		SetCVar("synchronizeConfig", 1)							-- 0,1 sync game options to server
		SetCVar("synchronizeBindings", 1)						-- 0,1 sync key binds to server
		SetCVar("synchronizeMacros", 1)							-- 0,1 sync macros to server
		SetCVar("textureCacheSize", 32)							-- 0-512 in MB cache textures in memory (see also gxtexturecachesize)
		SetCVar("textureFilteringMode", 0)						-- 0-5 aka Texture Filtering
		SetCVar("UberTooltips", 1)								-- 0,1 Shows spell descriptions in tooltips
		SetCVar("violencelevel", 5)								-- 0-5 Level of violence, 0 == none, 1 == green blood 2-5 == red blood
		SetCVar("useWeatherShaders", "0")						--
		SetCVar("weatherDensity", 0)							-- 0-3 aka Weather Intensity
		SetCVar("processAffinityMask", "3")						-- how many processor cores to use. 1 = 1 core, 3 = 2 cores, 15 = 4 cores, 255 = 8 cores
		SetCVar("useUiScale", 1)								--
		SetCVar("uiScale", 0.84)								--
		ConsoleExec( "pitchlimit 449" )							-- 89, 449. 449 allows doing flips, 89 will not
		ConsoleExec( "characterAmbient -0.1")					-- -0.1-1 use ambient lighting for character. <0 == off
		--ConsoleExec( "gxRestart" )							-- Needed for some settings to take effect
	end
end)







-- Cancel incoming duels.
recUI.tweaks.eventFrame:RegisterEvent("DUEL_REQUESTED")
recUI.tweaks.eventFrame:HookScript("OnEvent", function(self, event, ...)
	if event == "DUEL_REQUESTED" then
		CancelDuel()
	end
end)







-- Block errors
UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")






-- Ensure Keybinds
local bindings = {
                 ["W"] = "MOVEFORWARD",
                 ["S"] = "MOVEBACKWARD",
                 ["A"] = "TURNLEFT",
                 ["D"] = "TURNRIGHT",
                 ["Q"] = "STRAFELEFT",
                 ["E"] = "STRAFERIGHT",
                 ["1"] = "ACTIONBUTTON1",
                 ["2"] = "ACTIONBUTTON2",
                 ["3"] = "ACTIONBUTTON3",
                 ["4"] = "ACTIONBUTTON4",
                 ["5"] = "ACTIONBUTTON5",
                 ["6"] = "ACTIONBUTTON6",
                 ["7"] = "ACTIONBUTTON7",
                 ["8"] = "ACTIONBUTTON8",
                 ["9"] = "ACTIONBUTTON9",
                 ["0"] = "ACTIONBUTTON10",
                 ["-"] = "ACTIONBUTTON11",
                 ["="] = "ACTIONBUTTON12",
           ["BUTTON3"] = "MOVEANDSTEER",
             ["SPACE"] = "JUMP",
                 ["X"] = "SITORSTAND",
                 ["Z"] = "TOGGLESHEATH",
           ["NUMLOCK"] = "TOGGLEAUTORUN",
      ["NUMPADDIVIDE"] = "TOGGLERUN",
             ["ENTER"] = "OPENCHAT",
                 ["/"] = "OPENCHATSLASH",
            ["PAGEUP"] = "CHATPAGEUP",
          ["PAGEDOWN"] = "CHATPAGEDOWN",
    ["SHIFT-PAGEDOWN"] = "CHATBOTTOM",
                 ["R"] = "REPLY",
           ["SHIFT-R"] = "REPLY2",
               ["TAB"] = "TARGETNEARESTENEMY",
         ["SHIFT-TAB"] = "TARGETLASTENEMY",
          ["CTRL-TAB"] = "TARGETNEARESTFRIEND",
                ["F1"] = "TARGETSELF",
                ["F2"] = "TARGETPARTYMEMBER1",
                ["F3"] = "TARGETPARTYMEMBER2",
                ["F4"] = "TARGETPARTYMEMBER3",
                ["F5"] = "TARGETPARTYMEMBER4",
                 ["V"] = "NAMEPLATES",
           ["SHIFT-V"] = "FRIENDNAMEPLATES",
            ["CTRL-V"] = "ALLNAMEPLATES",
			     ["F"] = "ASSISTTARGET",
                 ["C"] = "TOGGLECHARACTER0",
                 ["B"] = "OPENALLBAGS",
                 ["P"] = "TOGGLESPELLBOOK",
                 ["N"] = "TOGGLETALENTS",
                 ["H"] = "TOGGLECHARACTER4",
                 ["K"] = "TOGGLECHARACTER1",
                 ["L"] = "TOGGLEQUESTLOG",
            ["ESCAPE"] = "TOGGLEGAMEMENU",
                 ["M"] = "TOGGLEWORLDMAP",
                 ["O"] = "TOGGLESOCIAL",
                 ["I"] = "TOGGLELFGPARENT",
           ["SHIFT-M"] = "TOGGLEBATTLEFIELDMINIMAP",
                 ["Y"] = "TOGGLEACHIEVEMENT",
       ["PRINTSCREEN"] = "SCREENSHOT",
      ["MOUSEWHEELUP"] = "CAMERAZOOMIN",
    ["MOUSEWHEELDOWN"] = "CAMERAZOOMOUT",
}

local event_frame = CreateFrame("Frame")
event_frame:RegisterEvent("PLAYER_ENTERING_WORLD")
event_frame:SetScript("OnEvent", function(self)
	-- Remove all keybinds
	for i = 1, GetNumBindings() do
		local command = GetBinding(i)
		while GetBindingKey(command) do
			local key = GetBindingKey(command)
			SetBinding(key) -- Clear Keybind
		end
	end
	
	-- Apply personal keybinds
	for key, bind in pairs(bindings) do
		SetBinding(key, bind)
	end
	
	-- Save keybinds
	SaveBindings(1)

	-- All done, clean up a bit.
	event_frame:UnregisterEvent(event)
	event_frame:SetScript("OnEvent", nil)
	bindings = nil	-- Remove table
	event_frame = nil -- Remove frame
end)










-- Auto DE/Greed
recUI.tweaks.eventFrame:RegisterEvent("START_LOOT_ROLL")
recUI.tweaks.eventFrame:HookScript("OnEvent", function(self, event, id)
	if event == "START_LOOT_ROLL" then
		if UnitLevel("player") < 60 then return end
		if(id and select(4, GetLootRollItemInfo(id))==2 and not (select(5, GetLootRollItemInfo(id)))) then
			if RollOnLoot(id, 3) then
				RollOnLoot(id, 3)
			else
				RollOnLoot(id, 2)
			end
		end
	end
end)











-- Move/scale loot frame
local function on_show(self, ...)
	self:ClearAllPoints()
	if self:GetName() == "GroupLootFrame1" then
		self:SetPoint("CENTER", UIParent, "CENTER", -762.5, -330.5)
	else
		local _, _, num = self:GetName():find("GroupLootFrame(%d)")
		self:SetPoint("BOTTOM", _G[string.format("GroupLootFrame%d", num-1)], "TOP", 0, 5)
		self:SetFrameLevel(0)
	end
	self:SetScale(.75)
	
	if self.on_show then
		self:on_show(...)
	end
end

GroupLootFrame1.on_show = GroupLootFrame1:GetScript("OnShow")
GroupLootFrame2.on_show = GroupLootFrame2:GetScript("OnShow")
GroupLootFrame3.on_show = GroupLootFrame3:GetScript("OnShow")
GroupLootFrame4.on_show = GroupLootFrame4:GetScript("OnShow")

GroupLootFrame1:SetScript("OnShow", on_show)
GroupLootFrame2:SetScript("OnShow", on_show)
GroupLootFrame3:SetScript("OnShow", on_show)
GroupLootFrame4:SetScript("OnShow", on_show)










-- Auto reagent purchasing

--[[
	This is where you will add your characters, their realm, and the stock levels
	of each item they will want auto-stocked.
--]]
local my_reagents
local reagents = {
	["Moon Guard"] = {
		["Lanuit"]	= { [17028] = 40,	[8766]  = 60,	[4599]  = 20 },
		["Suzi"]	= { [17032] = 20,	[17031] = 20,	[17020] = 100 },
		["Foliage"]	= { [1708]	= 20,	[17036] = 5 },
		["Zima"]	= { [41586] = 18000 },
		["Lewts"]	= { [3770]	= 20,	[6947]	= 20,	[3775] = 20 },
		["Neural"]	= { [33449] = 20 },
		["Kudzu"]	= { [17030] = 10 },
	},
	["Sisters of Elune"] = {
		["Suzie"]   = { [1708] = 40, [4607] = 20 },
	},
	["Sentinels"] = {
		["Suzy"]    = { [11284] = 5000, [1645] = 20, [4599] = 20 },
	},
}

local not_enough_money		= "Not enough money to purchase reagents."
local itemid_pattern		= "item:(%d+)"
local GetContainerNumSlots	= GetContainerNumSlots
local GetContainerItemLink	= GetContainerItemLink
local GetContainerItemInfo	= GetContainerItemInfo
local GetMerchantNumItems	= GetMerchantNumItems
local GetMerchantItemInfo	= GetMerchantItemInfo
local GetMerchantItemLink	= GetMerchantItemLink
local BuyMerchantItem		= BuyMerchantItem
local UnitName				= UnitName
local GetRealmName			= GetRealmName
local GetItemInfo			= GetItemInfo
local GetMoney				= GetMoney
local select				= select
local print					= print
local math_max				= math.max
local math_min				= math.min
local math_floor			= math.floor
local tonumber				= tonumber
local string_find			= string.find
local player_realm, player_name

--[[
	Returns the amount of checkid which would be needed to stock the item to the preset level.
	This does NOT return the amount of the item which will be purchased (due to possible
	overstock), rather the total amount which would be ideal.
--]]
local get_num_reagents_needed = function(checkid)
	if not my_reagents[checkid] then return 0 end
	local total = 0
	for bag = 0, NUM_BAG_FRAMES do
		for slot = 1, GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
			if link then
				local id = tonumber(select(3, string_find(link, itemid_pattern)))
				local stack = select(2, GetContainerItemInfo(bag, slot))
				if id == checkid then total = total + stack end
			end
		end
	end
	return math_max(0, (my_reagents[checkid] - total))
end

--[[
	Purchases the required amount of reagents to come as close as possible to the requested
	stock level.  Does NOT overstock, so you may end up with less than the stock level you
	asked for.
--]]
local buy_reagents = function()
	for i=1, GetMerchantNumItems() do
		local link, id = GetMerchantItemLink(i)
		if link then id = tonumber(select(3, string_find(link, itemid_pattern))) end
		if id and my_reagents[id] then
			local price, stack, stock = select(3, GetMerchantItemInfo(i))
			local quantity = get_num_reagents_needed(id)
			if quantity > 0 then
				if stock ~= -1 then quantity = math_min(quantity, stock) end
				subtotal = price * (quantity/stack)
				if subtotal > GetMoney() then print(not_enough_money); return end
				local fullstack = select(8, GetItemInfo(id))
				while quantity > fullstack do
					BuyMerchantItem(i, math_floor(fullstack/stack))
					quantity = quantity - fullstack
				end
				if quantity >= stack then
					BuyMerchantItem(i, math_floor(quantity/stack))
				end
			end
		end
	end
end

--[[
	Ensures that we have the player's name, their realm, and that a table actually exists for
	that particular character before scanning the vendor for purchases.
--]]
recUI.tweaks.eventFrame:RegisterEvent("MERCHANT_SHOW")
recUI.tweaks.eventFrame:HookScript("OnEvent", function(self, event, ...)
	if event == "MERCHANT_SHOW" then
		if not my_reagents then
			if not player_name then player_name = UnitName("player") end
			if not player_realm then player_realm = GetRealmName() end
			if reagents[player_realm] and reagents[player_realm][player_name] then
				my_reagents = reagents[player_realm][player_name]
				reagents = nil
			end
		end
		if my_reagents then
			buy_reagents()
		end
	end
end)

recUI.tweaks.eventFrame:RegisterEvent("MERCHANT_SHOW")
recUI.tweaks.eventFrame:HookScript("OnEvent", function(self, event, ...)
	if event == "MERCHANT_SHOW" then
		if CanMerchantRepair() then
			local repair_cost, repair_needed = GetRepairAllCost()
			if repair_needed and repair_cost > 0 and repair_cost < GetMoney() then
				RepairAllItems()	-- Use RepairAllItems(1) for guild bank.
				print(string.format("Repaired all items for: %.1fg", repair_cost * 0.0001))
			end
		end
	end
end)








-- Handy slash commands

SLASH_RECUI_RELOAD1 = "/rl"
SlashCmdList["RECUI_RELOAD"] = function() ReloadUI() end

SLASH_RECUI_DISABLE_ADDON1 = "/disable"
SlashCmdList["RECUI_DISABLE_ADDON"] = function(addon) DisableAddOn(addon) end

SLASH_RECUI_ENABLE_ADDON1 = "/enable"
SlashCmdList["RECUI_ENABLE_ADDON"] = function(addon) EnableAddOn(addon) end

SLASH_RECUI_GM_TICKET1 = "/gm"
SlashCmdList["RECUI_GM_TICKET"] = function() ToggleHelpFrame() end

SLASH_RECUI_CLEAR_CHAT1 = "/clear"
SLASH_RECUI_CLEAR_CHAT2 = "/cls"
SlashCmdList["RECUI_CLEAR_CHAT"] = function()
	for i=1,7 do
		if i ~= 2 then
			_G[string.format("ChatFrame%d", i)]:Clear()
		end
	end
end

-- /tt
-- Sends whisper to your target.
ChatFrameEditBox:HookScript("OnTextChanged", function(self, from_user, ...)
	if from_user then
		local message = string.match(self:GetText(), "^/tt (.*)")
		if message and UnitExists("target") and UnitIsPlayer("target") and UnitIsFriend("player", "target") then
			local name, realm = UnitName("target")
			if name and not UnitIsSameServer("player", "target") then
				name = string.format("%s-%s", name, realm)
			end
			ChatFrame_SendTell(name)
			ChatFrameEditBox:SetText(message)
		end
	end
end)






-- Auto sell grey items
recUI.tweaks.eventFrame:RegisterEvent("MERCHANT_SHOW")
recUI.tweaks.eventFrame:HookScript("OnEvent", function(self, event, ...)
	if event == "MERCHANT_SHOW" then
		for bag_id = 0, 4 do
			for slot_id = 0, GetContainerNumSlots(bag_id) do
				local item_link = GetContainerItemLink(bag_id, slot_id)
				-- Vendor all grey items.
				if item_link and select(3, GetItemInfo(item_link)) == 0 then
					UseContainerItem(bag_id, slot_id)
				end
			end
		end
	end
end)









--oGlow
local colorTable = setmetatable({
	[100] = {r = .9, g = 0, b = 0},
	[99] = {r = 1, g = 1, b = 0},
}, {__call = function(self, val)
	local c = self[val]
	if(c) then return c.r, c.g, c.b
	elseif(type(val) == "number") then return GetItemQualityColor(val) end
end})

local createBorder = function(self, point)
	local bc = self:CreateTexture(nil, "OVERLAY")
	bc:SetTexture"Interface\\Buttons\\UI-ActionButton-Border"
	bc:SetBlendMode"ADD"
	bc:SetAlpha(.8)

	bc:SetWidth(70)
	bc:SetHeight(70)

	bc:SetPoint("CENTER", point or self)
	self.bc = bc
end

local border, r, g, b
oGlow = setmetatable({
	RegisterColor = function(self, key, r, g, b)
		colorTable[key] = {r = r, g = g, b = b}
	end,
}, {
	__call = function(self, frame, quality, point)
		if(type(quality) == "number" and quality > 1 or type(quality) == "string") then
			if(not frame.bc) then createBorder(frame, point) end

			border = frame.bc
			if(border) then
				r, g, b = colorTable(quality)
				border:SetVertexColor(r, g, b)
				border:Show()
			end
		elseif(frame.bc) then
			frame.bc:Hide()
		end
	end,
})

if(select(4, GetAddOnInfo("Fizzle"))) then return end

local hook = CreateFrame"Frame"
local items = {
	"Head",
	"Neck",
	"Shoulder",
	"Shirt",
	"Chest",
	"Waist",
	"Legs",
	"Feet",
	"Wrist",
	"Hands",
	"Finger0",
	"Finger1",
	"Trinket0",
	"Trinket1",
	"Back",
	"MainHand",
	"SecondaryHand",
	"Ranged",
	"Tabard",
}

local update = function()
	if(not InspectFrame:IsShown()) then return end
	local unit = InspectFrame.unit
	for i, key in pairs(items) do
		local link = GetInventoryItemLink(unit, i)
		local self = _G["Inspect"..key.."Slot"]

		if(link and not oGlow.preventInspect) then
			q = select(3, GetItemInfo(link))
			oGlow(self, q)
		elseif(self.bc) then
			self.bc:Hide()
		end
	end
end

hook["PLAYER_TARGET_CHANGED"] = update
hook["ADDON_LOADED"] = function(addon)
	if(addon == "Blizzard_InspectUI") then
		hook:SetScript("OnShow", update)
		hook:SetParent"InspectFrame"

		hook:RegisterEvent"PLAYER_TARGET_CHANGED"
		hook:UnregisterEvent"ADDON_LOADED"
	end
end

hook:SetScript("OnEvent", function(self, event, ...)
	self[event](...)
end)

-- Check if it's already loaded by some add-on
if(IsAddOnLoaded("Blizzard_InspectUI")) then
	hook:SetScript("OnShow", update)
	hook:SetParent"InspectFrame"
else
	hook:RegisterEvent"ADDON_LOADED"
end

oGlow.updateInspect = update

local send = function(self, event)
	if(not SendMailFrame:IsShown()) then return end

	for i=1, ATTACHMENTS_MAX_SEND do
		local link = GetSendMailItemLink(i)
		local slot = _G["SendMailAttachment"..i]
		if(link and not oGlow.preventMail) then
			local q = select(3, GetItemInfo(link))
			oGlow(slot, q)
		elseif(slot.bc) then
			slot.bc:Hide()
		end
	end
end

local inbox = function(self, event)
	local numItems = GetInboxNumItems()
	local index = ((InboxFrame.pageNum - 1) * INBOXITEMS_TO_DISPLAY) + 1

	for i=1, INBOXITEMS_TO_DISPLAY do
		local slot = _G["MailItem"..i.."Button"]
		if (index <= numItems) then
			local hq = 0
			for j=1, ATTACHMENTS_MAX_RECEIVE do
				local name = GetInboxItemLink(index, j)
				if(name) then
					-- I've always thought of (func()) to be completly useless, guess I was wrong
					hq = math.max(hq, (select(3, GetItemInfo(name))))
				end
			end

			if(hq ~= 0 and not oGlow.preventMail) then
				oGlow(slot, hq)
			elseif(slot.bc) then
				slot.bc:Hide()
			end

		elseif(slot.bc) then
			slot.bc:Hide()
		end
		index = index + 1
	end
end

local addon = CreateFrame"Frame"
addon:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

hooksecurefunc("OpenMail_Update", function(self)
	if(not InboxFrame.openMailID) then return end

	for i=1, ATTACHMENTS_MAX_RECEIVE do
		local name = GetInboxItemLink(InboxFrame.openMailID, i)
		if(name) then
			local slot = _G["OpenMailAttachmentButton"..i]
			if(not oGlow.preventMail) then
				oGlow(slot, select(3, GetItemInfo(name)))
			elseif(slot.bc) then
				slot.bc:Hide()
			end
		end
	end
end)

hooksecurefunc("InboxFrame_Update", inbox)

addon.MAIL_SHOW = send
addon.MAIL_SEND_INFO_UPDATE = send
addon.MAIL_SEND_SUCCESS = send

addon:RegisterEvent"MAIL_SHOW"
addon:RegisterEvent"MAIL_SEND_INFO_UPDATE"
addon:RegisterEvent"MAIL_SEND_SUCCESS"

oGlow.updateMail = update

-- Addon
local update = function()
	if(MerchantFrame.selectedTab == 1) then
		local numItems = GetMerchantNumItems()
		for i=1, numPage do
			local index = (((MerchantFrame.page - 1) * numPage) + i)
			local link = GetMerchantItemLink(index)
			local button = _G["MerchantItem"..i.."ItemButton"]

			if(link and not oGlow.preventMerchant) then
				local q = select(3, GetItemInfo(link))
				oGlow(button, q)
			elseif(button.bc) then
				button.bc:Hide()
			end
		end
	else
		local numItems = GetNumBuybackItems()
		for i=1, numPage do
			local index = (((MerchantFrame.page - 1) * numPage) + i)
			local link = GetBuybackItemLink(index)
			local button = _G["MerchantItem"..i.."ItemButton"]

			if(link and not oGlow.preventBuyback) then
				local q = select(3, GetItemInfo(link))
				oGlow(button, q)
			elseif(button.bc) then
				button.bc:Hide()
			end
		end
	end
end

hooksecurefunc("MerchantFrame_Update", update)
oGlow.updateMerchant = update

-- Addon
local hook = CreateFrame"Frame"

local setQuality = function(self, link)
	if(link and not oGlow.preventTrade) then
		q = select(3, GetItemInfo(link))
		oGlow(self, q)
	elseif(self.bc) then
		self.bc:Hide()
	end
end

local update = function()
	for i=1,7 do
		hook["TRADE_PLAYER_ITEM_CHANGED"](i)
		hook["TRADE_TARGET_ITEM_CHANGED"](i)
	end
end

hook["TRADE_SHOW"] = update
hook["TRADE_UPDATE"] = update

local self, link
hook["TRADE_PLAYER_ITEM_CHANGED"] = function(index)
	self = _G["TradePlayerItem"..index.."ItemButton"]
	link = GetTradePlayerItemLink(index)

	setQuality(self, link)
end

hook["TRADE_TARGET_ITEM_CHANGED"] = function(index)
	self = _G["TradeRecipientItem"..index.."ItemButton"]
	link = GetTradeTargetItemLink(index)

	setQuality(self, link)
end

hook:SetScript("OnEvent", function(self, event, id)
	self[event](id)
end)

hook:RegisterEvent"TRADE_SHOW" -- isn't used?
hook:RegisterEvent"TRADE_UPDATE" -- isn't used?
hook:RegisterEvent"TRADE_PLAYER_ITEM_CHANGED"
hook:RegisterEvent"TRADE_TARGET_ITEM_CHANGED"

oGlow.updateTrade = update

-- Tradeskill
local icon, link, frame, point
local update = function(id)
	icon = _G["TradeSkillSkillIcon"]
	link = GetTradeSkillItemLink(id)

	if(link and not oGlow.preventTradeskill) then
		q = select(3, GetItemInfo(link))
		oGlow(icon, q)
	elseif(icon.bc) then
		icon.bc:Hide()
	end

	for i=1, GetTradeSkillNumReagents(id) do
		frame = _G["TradeSkillReagent"..i]
		link = GetTradeSkillReagentItemLink(id, i)

		if(link) then
			q = select(3, GetItemInfo(link))
			point = _G["TradeSkillReagent"..i.."IconTexture"]

			oGlow(frame, q, point)
		elseif(frame.bc) then
			frame.bc:Hide()
		end
	end
end

if(IsAddOnLoaded("Blizzard_TradeSkillUI")) then
	hooksecurefunc("TradeSkillFrame_SetSelection", update)
else
	local hook = CreateFrame"Frame"

	hook:SetScript("OnEvent", function(self, event, addon)
		if(addon == "Blizzard_TradeSkillUI") then
			hooksecurefunc("TradeSkillFrame_SetSelection", update)
			hook:UnregisterEvent"ADDON_LOADED"
			hook:SetScript("OnEvent", nil)
		end
	end)
	hook:RegisterEvent"ADDON_LOADED"
end

oGlow.updateTradeskill = update

-- Addon
local hook = CreateFrame"Frame"
hook:SetParent"BankFrame"

local self, link
local update = function()
	for i=1, 28 do
		self = _G["BankFrameItem"..i]
		link = GetContainerItemLink(-1, i)
	
		if(link and not oGlow.preventBank) then
			q = select(3, GetItemInfo(link))
			oGlow(self, q)
		elseif(self.bc) then
			self.bc:Hide()
		end
	end
end

hook:SetScript("OnShow", update)
hook:SetScript("OnEvent", update)
hook:RegisterEvent"PLAYERBANKSLOTS_CHANGED" -- NERF IT!

oGlow.updateBank = update

if(select(4, GetAddOnInfo("Fizzle"))) then return end

-- Addon
local items = {
	[0] = "Ammo",
	"Head 1",
	"Neck",
	"Shoulder 2",
	"Shirt",
	"Chest 3",
	"Waist 4",
	"Legs 5",
	"Feet 6",
	"Wrist 7",
	"Hands 8",
	"Finger0",
	"Finger1",
	"Trinket0",
	"Trinket1",
	"Back",
	"MainHand 9",
	"SecondaryHand 10",
	"Ranged 11",
	"Tabard",
}

local key, self
local update = function()
	if(not CharacterFrame:IsShown()) then return end
	for i, value in pairs(items) do
		key, index = string.split(" ", value)
		q = GetInventoryItemQuality("player", i)
		self = _G["Character"..key.."Slot"]

		if(oGlow.preventCharacter) then
			q = 0
		elseif(GetInventoryItemBroken("player", i)) then
			q = 100
		elseif(index and GetInventoryAlertStatus(index) == 3) then
			q = 99
		end

		oGlow(self, q)
	end
end

local hook = CreateFrame"Frame"
hook:SetParent"CharacterFrame"
hook:SetScript("OnShow", update)
hook:SetScript("OnEvent", function(self, event, unit) if(unit == "player") then update() end end)
hook:RegisterEvent"UNIT_INVENTORY_CHANGED"

oGlow.updateCharacter = update

-- Craft

local frame, link, icon
local update = function(id)
	icon = _G["CraftIcon"]
	link = GetCraftItemLink(id)

	if(link and not oGlow.preventCraft) then
		q = select(3, GetItemInfo(link))
		oGlow(icon, q)
	elseif(icon.bc) then
		icon.bc:Hide()
	end

	for i=1, GetCraftNumReagents(id) do
		frame = _G["CraftReagent"..i]
		link = GetCraftReagentItemLink(id, i)

		if(link) then
			q = select(3, GetItemInfo(link))
			point = _G["CraftReagent"..i.."IconTexture"]

			oGlow(frame, q, point)
		elseif(frame.bc) then
			frame.bc:Hide()
		end
	end
end

if(IsAddOnLoaded("Blizzard_CraftUI")) then
	hooksecurefunc("CraftFrame_SetSelection", update)
else
	local hook = CreateFrame"Frame"

	hook:SetScript("OnEvent", function(self, event, addon)
		if(addon == "Blizzard_CraftUI") then
			hooksecurefunc("CraftFrame_SetSelection", update)
			hook:UnregisterEvent"ADDON_LOADED"
			hook:SetScript("OnEvent", nil)
		end
	end)
	hook:RegisterEvent"ADDON_LOADED"
end

oGlow.updateCraft = update

local update = function()
	local tab = GetCurrentGuildBankTab()
	local index, column, q
	for i=1, MAX_GUILDBANK_SLOTS_PER_TAB do
		index = math.fmod(i, NUM_SLOTS_PER_GUILDBANK_GROUP)
		if(index == 0) then
			index = NUM_SLOTS_PER_GUILDBANK_GROUP
		end
		column = ceil((i-0.5)/NUM_SLOTS_PER_GUILDBANK_GROUP)

		local link = GetGuildBankItemLink(tab, i)
		local slot = _G["GuildBankColumn"..column.."Button"..index]
		if(link and not oGlow.preventGBank) then
			q = select(3, GetItemInfo(link))
			oGlow(slot, q)
		elseif(slot.bc) then
			slot.bc:Hide()
		end
	end
end

local event = CreateFrame"Frame"
event:SetScript("OnEvent", function(self, event, ...)
	if(event == "GUILDBANKFRAME_OPENED") then
		self:RegisterEvent"GUILDBANKBAGSLOTS_CHANGED"
		self:Show()
	elseif(event == "GUILDBANKBAGSLOTS_CHANGED") then
		self:Show()
	elseif(event == "GUILDBANKFRAME_CLOSED") then
		self:UnregisterEvent"GUILDBANKBAGSLOTS_CHANGED"
		self:Hide()
	end
end)

local delay = 0
event:SetScript("OnUpdate", function(self, elapsed)
	delay = delay + elapsed
	if(delay > .05) then
		update()
	
		delay = 0
		self:Hide()
	end
end)

event:RegisterEvent"GUILDBANKFRAME_OPENED"
event:RegisterEvent"GUILDBANKFRAME_CLOSED"
event:Hide()

oGlow.updateGBank = update

-- no oGlow bags, already supported internally