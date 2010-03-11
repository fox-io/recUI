local n, t = ...
t.events = CreateFrame("Frame")

local n, t = ...
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

t.events:RegisterEvent("VARIABLES_LOADED")
t.events:HookScript("OnEvent", function(self, event, ...)
	if event == "VARIABLES_LOADED" then
		AlertFrame_FixAnchors = reanchor
	end
end)

local n, t = ...
t.events:RegisterEvent("CHAT_MSG_SYSTEM")
t.events:RegisterEvent("PLAYER_LOGOUT")
t.events:RegisterEvent("PLAYER_ENTERING_WORLD")
t.events:HookScript("OnEvent", function(self, event, ...)
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

local n, t = ...
t.events:RegisterEvent("PLAYER_DEAD")
t.events:HookScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_DEAD" then
		if MiniMapBattlefieldFrame.status == "active" then
			RepopMe()
		end
	end
end)

local n, t = ...
-- BuffRemover is essentially a rip of the AntiHawk addon by p3lim, modified
-- to remove any and all buffs that you do not want on your character.  To use
-- BuffRemover, simply obtain the spell ID for the buff you want to remove and
-- enter it in the list below.
local unwanted_buffs = {
	[58493] = true,	-- Mr. T mohawk
}

t.events:RegisterEvent("UNIT_AURA")
t.events:HookScript("OnEvent", function(self, event, ...)
	if event == "UNIT_AURA" then
		if unit == "player" then
			for k,_ in pairs(unwanted_buffs) do
				if UnitAura(unit, GetSpellInfo(k)) then
					CancelUnitBuff(unit, GetSpellInfo(k))
				end
			end
		end
	end
end)

local n, t = ...
t.events:RegisterEvent("PLAYER_LOGIN")
t.events:HookScript("OnEvent", function(self, event, ...)
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

local n, t = ...
t.events:RegisterEvent("DUEL_REQUESTED")
t.events:HookScript("OnEvent", function(self, event, ...)
	if event == "DUEL_REQUESTED" then
		CancelDuel()
	end
end)

UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")

local useless_messages = {
	"fish are hooked",
	"Mail sent",
	"Discovered: "
}
-- Filter out messages we don't care about.
local oUIErrorsFrame_OnEvent = UIErrorsFrame:GetScript("OnEvent")
UIErrorsFrame:SetScript("OnEvent", function(self, event, msg, ...)
	if event == "UI_INFO_MESSAGE" then
		for _, keyword in pairs(useless_messages) do
			if msg:find(keyword) then return end
		end
	end

	return oUIErrorsFrame_OnEvent(self, event, msg, ...)
end)

local n, t = ...
t.events:RegisterEvent("ADDON_LOADED")
t.events:RegisterEvent("UPDATE_INSTANCE_INFO")

t.events:HookScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
		if ... == "recConfig" then
			RequestRaidInfo()
		end
	end
	
	if event == "UPDATE_INSTANCE_INFO" then
		for i = 1, GetNumSavedInstances() do
			local name, _, _, _, is_locked, is_extended = GetSavedInstanceInfo(i)
			if (name == "The Oculus" or name == "The Culling of Stratholme") and is_locked and (not is_extended) then
				SetSavedInstanceExtend(i, true)
			end
		end
	end
end)

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

local n, t = ...

-- Auto DE/Greed
t.events:RegisterEvent("START_LOOT_ROLL")
t.events:HookScript("OnEvent", function(self, event, id)
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

-- Move/scale frame
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

LoadAddOn("Blizzard_MacroUI")

-- Sample.  Need to create table and loop, class checks etc.
local btn = CreateFrame("Button", "ViperHawkButton", UIParent, "SecureUnitButtonTemplate")
btn:SetAttribute("type", "macro")
btn:SetAttribute("macrotext", [[/castsequence !Aspect of the Hawk, !Aspect of the Viper]])
ClearOverrideBindings(btn)
SetOverrideBindingClick(btn, false, [[`]], btn:GetName())

-- Snatched via Cael's copy of Gotai's macro code.
-- Modified to be a bit less featureful, but still do what needs to be done.
-- Unless you edit this, you do not want this to run on your system, I think.
-- IF YOU RUN THIS CODE, ALL MACROS NOT IN THIS LIST WILL BE DELETED!
--local i_understand = true
-- Uncomment the line above to enable this module.  You have been warned.
local macros = {
	["AutoHP"] = {
		body = [[]],
	},
	["AutoMP"] = {
		body = [[]],
	},
	["AutoPet"] = {
		class = "HUNTER",
		body = [[]],
	},
	["Icy Touch"] = {
		class = "DEATHKNIGHT",
		body = [[
#showtooltip
/cast Icy Touch
/cast !Rune Strike
/startattack
]],
	},
	["Plague Strike"] = {
		class = "DEATHKNIGHT",
		body = [[
#showtooltip
/cast Plague Strike
/cast !Rune Strike
/startattack
]],
	},
	["Heart Strike"] = {
		class = "DEATHKNIGHT",
		body = [[
#showtooltip
/cast Heart Strike
/cast !Rune Strike
/startattack
]],
	},
	["Death Coil"] = {
		class = "DEATHKNIGHT",
		body = [[
#showtooltip
/cast Death Coil
/cast !Rune Strike
/startattack
]],
	},
	["Death Strike"] = {
		class = "DEATHKNIGHT",
		body = [[
#showtooltip
/cast Death Strike
/cast !Rune Strike
/startattack
]],
	},
	["EoEDrakes"] = {
		body = [[/raid ==DPS Drakes==
/raid Target Malygos
/raid 11112 11112
/raid 1115 if targeted
/raid ==Heal Drakes==
/raid Target Self
/raid 333334 333334
/raid 3335 if targeted]],
	},
	["FishAttack"] = {
		body = [[#showtooltip
/cast [equipped:Fishing Pole] Fishing; [equipped:Wand] Shoot; [noequipped:Fishing Pole, noequipped:Wand, nomodifier:ctrl] Auto Attack; [modifier:ctrl] Pick Lock;
               ]],
	},
	["Focus"] = {
		body = [[/stopmacro [target=focus,dead] [noexists]
/target focus
/focus [target=lasttarget]
               ]],
	},
	["Thaddius"] = {
		body = [[/raid NEG  <--  boss  -->   POS]],
	},
	["QuestTurnIn"] = {
		body = [[/run SelectGossipActiveQuest(1); CompleteQuest(); GetQuestReward()]],
	},
}

local function CreateBlizzardMacro(name, perChar, icon)
	if icon then
		if type(icon) == "string" then
			local path = icon:match("Interface.Icons.(.+)") or icon
			path = "Interface\\Icons\\"..path       -- Allow discrepancies in given path.
			
			for i=1, GetNumMacroIcons() do
				if GetMacroIconInfo(i) == path then
					icon = i
					break
				end
			end
		end
		
		if type(icon) ~= "number" then
			icon = nil
		end
	end
	
	local macroname = name:sub(1,13)
	local show = macros[name].show
	local macrobody = macros[name].body
	
	if show then
		show = string.format("#showtooltip %s\n", show)
		if show:len()+macrobody:len() <= 255 then
			macrobody = show..macrobody
		end
	end
	
	local index = GetMacroIndexByName(macroname)
	if index > 0 then
		EditMacro(index, nil, icon or 1, macrobody, 1)
	else
		local Macros, PerCharMacros = GetNumMacros()
		if perChar and PerCharMacros >= 18 then -- MAX_CHARACTER_MACROS
			perChar = nil
		end
		
		if not perChar and Macros >= 36 then -- MAX_ACCOUNT_MACROS
			return -- full
		end
		
		CreateMacro(macroname, icon or 1, macrobody, perChar)
	end
end

local event_frame = CreateFrame("Frame")
event_frame:RegisterEvent("PLAYER_ENTERING_WORLD")
event_frame:SetScript("OnEvent", function(self, event, ...)
	if i_understand then
		local _, playerClass = UnitClass("player")
		local playerName = UnitName("player")
		
		if InCombatLockdown() then
			return self:RegisterEvent("PLAYER_REGEN_ENABLED")
		end
		
		-- Remove all macros
		local NumMacros, NumMacrosPerChar = GetNumMacros()

		local name
		
		for i=NumMacros, 1, -1 do
			name = GetMacroInfo(i)
			if not macros[name] then
				DeleteMacro(i)
			end
		end
		
		for i=37+(NumMacrosPerChar-1 or 0), 37, -1 do
			name = GetMacroInfo(i)
			if not macros[name] then
				DeleteMacro(i)
			end
		end

		-- Insert recUI macros
		for k,v in pairs(macros) do
			if v.class and v.class:find(playerClass) then
				CreateBlizzardMacro(k, true, v.icon)
			else
				if v.char and v.char:find(playerName) then
					CreateBlizzardMacro(k, true, v.icon)
				else
					CreateBlizzardMacro(k, false, v.icon)
				end
			end
		end
	end
	
	self:UnregisterEvent(event)
	self:SetScript("OnEvent", nil)
	event_frame = nil
	macros = nil
end)

local n, t = ...
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
		["Suzy"]    = { [3030] = 5000, [1645] = 20, [4599] = 20 },
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
t.events:RegisterEvent("MERCHANT_SHOW")
t.events:HookScript("OnEvent", function(self, event, ...)
	if event == "MERCHANT_SHOW" then
		if not my_reagents then
			if not player_name then player_name = UnitName("player") end
			if not player_realm then player_realm = GetRealmName() end
			if reagents[player_realm] and reagents[player_realm][player_name] then
				my_reagents = reagents[player_realm][player_name]
				reagents = nil
			end
		end
		buy_reagents()
	end
end)

local n, t = ...
t.events:RegisterEvent("MERCHANT_SHOW")
t.events:HookScript("OnEvent", function(self, event, ...)
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

local n, t = ...
t.events:RegisterEvent("MERCHANT_SHOW")
t.events:HookScript("OnEvent", function(self, event, ...)
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

local n, t = ...

-- Override Blizzard fade durations

FadingFrame_SetFadeInTime(  ZoneTextFrame,    2)
FadingFrame_SetHoldTime(    ZoneTextFrame,    0)
FadingFrame_SetFadeOutTime( ZoneTextFrame,    5)
FadingFrame_SetFadeInTime(  SubZoneTextFrame, 2)
FadingFrame_SetHoldTime(    SubZoneTextFrame, 0)
FadingFrame_SetFadeOutTime( SubZoneTextFrame, 5)

-- Override Blizzard function to set custom colors/fonts/anchors.
function SetZoneText(showZone)
	local pvpType, isSubZonePvP, factionName = GetZonePVPInfo()
	PVPArenaTextString:SetText("")
	PVPInfoTextString:SetText("")
	local pvpTextString = PVPInfoTextString
	if ( isSubZonePvP ) then
		pvpTextString = PVPArenaTextString
	end

	--[[if ( pvpType == "sanctuary" ) then
		pvpTextString:SetText(SANCTUARY_TERRITORY)
		pvpTextString:SetTextColor(0.41, 0.8, 0.94)
		ZoneTextString:SetTextColor(0.41, 0.8, 0.94)
		SubZoneTextString:SetTextColor(0.41, 0.8, 0.94)
	elseif ( pvpType == "arena" ) then
		pvpTextString:SetText(FREE_FOR_ALL_TERRITORY)
		pvpTextString:SetTextColor(1.0, 0.1, 0.1)
		ZoneTextString:SetTextColor(1.0, 0.1, 0.1)
		SubZoneTextString:SetTextColor(1.0, 0.1, 0.1)
	elseif ( pvpType == "friendly" ) then
		pvpTextString:SetFormattedText(FACTION_CONTROLLED_TERRITORY, factionName)
		pvpTextString:SetTextColor(0.1, 1.0, 0.1)
		ZoneTextString:SetTextColor(0.1, 1.0, 0.1)
		SubZoneTextString:SetTextColor(0.1, 1.0, 0.1)
	elseif ( pvpType == "hostile" ) then
		pvpTextString:SetFormattedText(FACTION_CONTROLLED_TERRITORY, factionName)
		pvpTextString:SetTextColor(1.0, 0.1, 0.1)
		ZoneTextString:SetTextColor(1.0, 0.1, 0.1)
		SubZoneTextString:SetTextColor(1.0, 0.1, 0.1)
	elseif ( pvpType == "contested" ) then
		pvpTextString:SetText(CONTESTED_TERRITORY)
		pvpTextString:SetTextColor(1.0, 0.7, 0)
		ZoneTextString:SetTextColor(1.0, 0.7, 0)
		SubZoneTextString:SetTextColor(1.0, 0.7, 0)
	elseif ( pvpType == "combat" ) then
		pvpTextString:SetText(COMBAT_ZONE)
		pvpTextString:SetTextColor(1.0, 0.1, 0.1)
		ZoneTextString:SetTextColor(1.0, 0.1, 0.1)
		SubZoneTextString:SetTextColor(1.0, 0.1, 0.1)
	else--]]
	
	ZoneTextString:SetTextColor(1, 1, 1)
	SubZoneTextString:SetTextColor(1, 1, 1)
	--end
	
	ZoneTextString:SetFont(    ns.media.font, 18, "OUTLINE" )
	SubZoneTextString:SetFont( ns.media.font, 18, "OUTLINE" )
	pvpTextString:SetFont(     ns.media.font, 18, "OUTLINE" )
	
	ZoneTextString:SetJustifyH("CENTER")
	ZoneTextString:ClearAllPoints()
	ZoneTextString:SetPoint("CENTER", UIParent, "CENTER", 0, -10)
	SubZoneTextString:SetJustifyH("CENTER")
	SubZoneTextString:ClearAllPoints()
	SubZoneTextString:SetPoint("TOPLEFT", ZoneTextString, "BOTTOMLEFT", 0, -3)
	pvpTextString:SetJustifyH("CENTER")
	pvpTextString:ClearAllPoints()
	pvpTextString:SetPoint("TOPLEFT", SubZoneTextString, "BOTTOMLEFT", 0, -3)

	--if ( ZonePVPType ~= pvpType ) then
		--ZonePVPType = pvpType
--		FadingFrame_Show(ZoneTextFrame)
	--elseif ( not showZone ) then
		--PVPInfoTextString:SetText("")
		--SubZoneTextString:SetPoint("TOP", "ZoneTextString", "BOTTOM", 0, 0)
	--end

	--if ( PVPInfoTextString:GetText() == "" ) then
		--SubZoneTextString:SetPoint("TOP", "ZoneTextString", "BOTTOM", 0, 0)
	--else
		--SubZoneTextString:SetPoint("TOP", "PVPInfoTextString", "BOTTOM", 0, 0)
	--end
end

-- TODO: Override event handler
function ZoneText_OnEvent(self, event, ...)
	local showZoneText = false
	local zoneText = GetZoneText()
	if ( (zoneText ~= self.zoneText) or (event == "ZONE_CHANGED_NEW_AREA") ) then
		self.zoneText = zoneText
		ZoneTextString:SetText( zoneText )
		showZoneText = true
		SetZoneText( showZoneText )
		FadingFrame_Show( self )
	end
	
	local subzoneText = GetSubZoneText()
	if ( subzoneText == "" and not showZoneText) then
		subzoneText = zoneText
	end
	SubZoneTextString:SetText( "" )

	if ( subzoneText == zoneText ) then
		showZoneText = false
		if ( not self:IsShown() ) then
			SubZoneTextString:SetText( subzoneText )
			SetZoneText( showZoneText )
			FadingFrame_Show( SubZoneTextFrame )
		end
	else
		if (self:IsShown()) then
			showZoneText = true
		end
		SubZoneTextString:SetText( subzoneText )
		SetZoneText( showZoneText )
		FadingFrame_Show( SubZoneTextFrame )
	end
end