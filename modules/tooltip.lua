local _, recUI = ...
local anchor_from_point		= "BOTTOM"
local anchor_to_point		= "BOTTOM"
local anchor_to_frame		= "UIParent"
local anchor_x_offset		= 0.5
local anchor_y_offset		= 167.5

local _G					= getfenv(0)
local select				= select
local tonumber				= tonumber
local string_find			= string.find
local string_gsub			= string.gsub
local string_format			= string.format
local UnitName				= _G.UnitName
local UnitLevel				= _G.UnitLevel
local UnitClass				= _G.UnitClass
local UnitExists			= _G.UnitExists
local UnitIsUnit			= _G.UnitIsUnit
local GetItemInfo			= _G.GetItemInfo
local GetMouseFocus			= _G.GetMouseFocus
local GetQuestGreenRange	= _G.GetQuestGreenRange
local gttip					= _G.GameTooltip
local irttip				= _G.ItemRefTooltip
local bar					= _G.GameTooltipStatusBar
local player_level			= UnitLevel("player") or nil

local _, link, itemlevel, stack, tt, targetUnit, target, targetText, unit, line

local TooltipList = {
	["GameTooltip"] = true,
	["ShoppingTooltip1"] = true,
	["ShoppingTooltip2"] = true,
	["ShoppingTooltip3"] = true,
	["ItemRefTooltip"] = true,
	["WorldMapTooltip"] = true
}

local targetingText = "Targeting:"

-- When we get a target change, we need to update the unit that our
-- mouseover is targetting, forcing a tooltip refresh.
local function OnEvent(self, event, ...)
	-- Update player level if player just leveled up.
	if event == "PLAYER_LEVEL_UP" then
		player_level = select(1, ...)
	elseif select(1, ...) ~= "none" then
		gttip:SetUnit("mouseover")
	end
end
recUI.lib.registerEvent("UNIT_TARGET", "recUITooltip", OnEvent)
recUI.lib.registerEvent("PLAYER_LEVEL_UP", "recUITooltip", OnEvent)

-- Returns the itemID from an itemlink
local function GetID(link)
	return tonumber(select(3, string_find(link, "item:(%d+)")))
end

-- Adds "Targeting: _______" to the tooltips
local function InsertTarget(self, unit)
	targetUnit = string_format("%starget", unit)
	target = UnitName(targetUnit)
	if target and target ~= UNKNOWN and target ~= "" or UnitExists(targetUnit) then
		if UnitIsUnit("player", targetUnit) then
			-- Targeting you
			self:AddDoubleLine(targetingText, ">> YOU << ", 1, 1, 1, 1, 0, 0)
		else
			-- Targeting something else
			self:AddDoubleLine(targetingText, target, 1, 1, 1, 0, 1, 0)
		end
	end
end

-- Adds class color to player name and border of unit tooltip.
local function ColorName(self, unit)
	local _, unitClass = UnitClass(unit)
	if unitClass then
		local line = _G["GameTooltipTextLeft1"]
		if line then
			local name = line:GetText()
			--local name = string_find(name, NAME_PATTERN)
			if name then
				name = string_format("|cFF%02X%02X%02X%s|r", RAID_CLASS_COLORS[unitClass].r*255, RAID_CLASS_COLORS[unitClass].g*255, RAID_CLASS_COLORS[unitClass].b*255, name)
				self.bg:SetBackdropBorderColor(RAID_CLASS_COLORS[unitClass].r*.6, RAID_CLASS_COLORS[unitClass].g*.6, RAID_CLASS_COLORS[unitClass].b*.6)
				line:SetText(name)
			end
		end
	end
end

local function ColorTapping(self, unit)
	if UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
		self.bg:SetBackdropColor(.3, .3, .3, .5)
		self.bg:SetBackdropBorderColor(.5, .5, .5)
	end
end

local function GetDifficultyColor(level)
	if (level > 4) then
		return "|cFFFF2020"
	elseif (level > 2) then
		return "|cFFFF8040"
	elseif (level >= -2) then
		return "|cFFFFFF00"
	elseif (level >= -GetQuestGreenRange()) then
		return "|cFF40C040"
	else
		return "|cFF808080"
	end
end
local function ColorLevel(self, unit)
	if not player_level then player_level = UnitLevel("player") end
	if not player_level then return end
	local unitLevel = UnitLevel(unit)
	if unitLevel then
		for i = 2, self:NumLines() do
			local line = _G[string_format("GameTooltipTextLeft%d", i)]
			if line then
				local text = line:GetText()
				local _, _, level = string_find(text, "Level (%d+).*")
				if level then
					local color = GetDifficultyColor(tonumber(level) - player_level)
					if color then
						text = string_gsub(text, "Level %d+", "%%sLevel %%d|r")
						text = string_format(text, color, level)
						line:SetText(text)
						break
					end
				end
			end
		end
	end
end

local function ModifyGuild(self, unit)
	local guild, guildRank = GetGuildInfo(unit)
	if (guild) then
		GameTooltipTextLeft2:SetFormattedText(guildRank and "<%s> %s" or "<%s>", guild, guildRank);
	end
end

-- Removes "PvP" from the tooltip
local function RemovePvP(self)
	for i = 2, self:NumLines() do
		local line = _G[string_format("GameTooltipTextLeft%d", i)]
		if (line:GetText() == PVP_ENABLED) then
			line:SetText(nil)
			break
		end
	end
end

-- Tooltip hook functions
local function GTTOnUpdate(self, elapsed)
	-- Prevent gathering nodes from turning tooltip blue
	--self.bg:SetBackdropColor(0, 0, 0, .5)
	-- Keep the health bar hidden
	--bar:Hide()
end
bar:SetAlpha(0)
local function GTTOnShow(self, ...)
	-- Prevent gathering nodes from turning tooltip blue
	self.bg:SetBackdropColor(0, 0, 0, .5)
end
local function GTTOnHide(self, ...)
	self.bg:SetBackdropColor(0, 0, 0, .5)
	self.bg:SetBackdropBorderColor(0, 0, 0)
end

local function GTTOnTooltipSetItem(self, ...)
	link = select(2, self:GetItem()) or nil
	if link then
		itemlevel, _, _, _, stack = select(4, GetItemInfo(link))
		if not itemlevel then itemlevel = "??" end
		if not stack then stack = "??" end
		-- Add in additional item information
		self:AddLine(" ")
		self:AddDoubleLine(string_format("iLvl: %s", itemlevel), string_format("Stacks to: %s", stack), 1, 1, 1, 1, 1, 1)
		self:AddDoubleLine(string_format("ID: %s", GetID(link)), " ", 1, 1, 1, 1, 1, 1)
	end
end

local function GTTOnTooltipSetUnit(self, ...)
	local _, unit = self:GetUnit()
	if not unit then
		mouseunit = GetMouseFocus()
		unit = mouseunit and mouseunit:GetAttribute("unit")
	end
	if not unit and UnitExists("mouseover") then
		unit = "mouseover"
	end
	if not unit then
		return
	end
	if UnitIsUnit(unit, "mouseover") then
		unit = "mouseover"
	end
	
	if not UnitIsFriend(unit, "player") then
		if UnitIsPlayer(unit) then
			-- Enemy Player
			ColorName(self, unit)
			ColorLevel(self, unit)
			RemovePvP(self)
			ModifyGuild(self, unit)
			InsertTarget(self, unit)
			ColorTapping(self, unit)
		else
			-- Enemy NPC
			local quest_line, objective_line
			for i = 2, self:NumLines() do
				local line = _G[string.format("GameTooltipTextLeft%d", i)]:GetText()
				if string.find(line, "^ - .*") then
					quest_line = _G[string.format("GameTooltipTextLeft%d", i-1)]:GetText()
					objective_line = line
				end
			end
			self:ClearLines()
			self:AddLine(UnitName(unit))
			local guild = _G["GameTooltipTextLeft2"]:GetText()
			if guild then
				if not string.find(guild, "Level %d") then
					-- Is guild
					guild = string.format("<%s>", guild)
					_G["GameTooltipTextLeft2"]:SetText(guild)
				end
			end
			self:AddLine(string.format("Level %d %s%s", UnitLevel(unit), UnitCreatureType(unit) and UnitCreatureType(unit) or "", UnitCreatureFamily(unit) and string.format(" (%s)", UnitCreatureFamily(unit)) or ""))
			ColorLevel(self, unit)
			if quest_line then
				self:AddLine(" ")
				self:AddLine(quest_line)
			end
			if objective_line then
				self:AddLine(objective_line)
			end
			InsertTarget(self, unit)
			ColorTapping(self, unit)
		end
	else
		if UnitIsPlayer(unit) then
			-- Friendly Player
			ColorName(self, unit)
			ColorLevel(self, unit)
			RemovePvP(self)
			ModifyGuild(self, unit)
			InsertTarget(self, unit)
		else
			-- Friendly NPC
			local name = _G["GameTooltipTextLeft1"]:GetText()
			if name then
				name = string.format("|cFF%02X%02X%02X%s|r", .9*255, .75*255, 0*255, name)
				_G["GameTooltipTextLeft1"]:SetText(name)
			end
			local guild = _G["GameTooltipTextLeft2"]:GetText()
			if guild then
				if not string.find(guild, "Level %d") then
					-- Is guild
					guild = string.format("<%s>", guild)
					_G["GameTooltipTextLeft2"]:SetText(guild)
				end
			end
			ColorLevel(self, unit)
			RemovePvP(self)
		end
	end
end

-- Apply our changes to the tooltips
for v,_ in pairs(TooltipList) do
	tt = _G[v]

	-- Change our tooltips to match the UI theme.
	tt:SetBackdrop(nil)
	tt.SetBackdrop = recUI.lib.NullFunction
	--tt:SetBackdropColor(0, 0, 0, 0)
	--tt:SetBackdropBorderColor(0, 0, 0, 0)
	tt.SetBackdropBorderColor = recUI.lib.NullFunction
	tt.bg = CreateFrame("Frame", nil, tt)
	tt.bg:SetPoint("TOPLEFT")
	tt.bg:SetPoint("BOTTOMRIGHT")
	tt.bg:SetBackdrop(recUI.media.backdropTable)
	tt.bg:SetFrameStrata("FULLSCREEN_DIALOG")
	tt.bg:SetBackdropBorderColor(0, 0, 0)
	tt.bg:SetBackdropColor(0, 0, 0, .5)

	-- Remove background blue color and the health bar on unit tips
	tt:HookScript("OnShow", GTTOnShow)
	tt:HookScript("OnHide", GTTOnHide)
	tt:HookScript("OnUpdate", GTTOnUpdate)

	-- Add item info to mouseover and chat-clicked item links
	tt:HookScript("OnTooltipSetItem", GTTOnTooltipSetItem)

	-- Add who the tooltip unit is targeting and remove the "PvP" text, if present.
	tt:HookScript("OnTooltipSetUnit", GTTOnTooltipSetUnit)
end

local GTTFont = CreateFont("GTTFont")
GTTFont:SetFont(recUI.media.font, 9, "OUTLINE")

-- Resize tooltip fonts
_G.GameTooltipHeaderText:SetFontObject(GTTFont)
_G.GameTooltipText:SetFontObject(GTTFont)
_G.GameTooltipTextSmall:SetFontObject(GTTFont)

-- Override the real anchoring function with our own so we can anchor where we want
function GameTooltip_SetDefaultAnchor(tt, parent)
	if tt and parent then
		tt:SetOwner(parent, "ANCHOR_NONE")
		tt:SetPoint("BOTTOM", MiniMapPanel, "TOP")
		tt.default = 1
	end
end
