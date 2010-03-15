local _, recUI = ...
local oUF   = recUI.oUF
local lib   = recUI.lib
local media = recUI.media

do
	--[[****************************************************************************
	  * oUF_SpellRange by Saiket                                                   *
	  * oUF_SpellRange.lua - Improved range element for oUF.                       *
	  *                                                                            *
	  * Elements handled: .SpellRange                                              *
	  * Settings: (Either override method or both alpha properties are required)   *
	  *   - :SpellRangeOverride( InRange ) - Callback fired when a unit either     *
	  *       enters or leaves range. Overrides default alpha changing.            *
	  *   OR                                                                       *
	  *   - .inRangeAlpha - Frame alpha value for units in range.                  *
	  *   - .outsideRangeAlpha - Frame alpha for units out of range.               *
	  * Note that SpellRange will automatically disable Range elements of frames.  *
	  ****************************************************************************]]


	local UpdateRate = 0.1;

	local UpdateFrame;
	local Objects = {};
	local ObjectRanges = {};

	-- Class-specific spell info
	local HelpID, HelpName, CanHelp; -- ID of spell, and whether it is known by the player
	local HarmID, HarmName, CanHarm;




	--[[****************************************************************************
	  * Function: local IsInRange                                                  *
	  ****************************************************************************]]
	local IsInRange;
	do
		local UnitIsConnected = UnitIsConnected;
		local UnitCanAssist = UnitCanAssist;
		local UnitCanAttack = UnitCanAttack;
		local UnitIsUnit = UnitIsUnit;
		local UnitPlayerOrPetInRaid = UnitPlayerOrPetInRaid;
		local UnitIsDead = UnitIsDead;
		local UnitOnTaxi = UnitOnTaxi;
		local UnitInRange = UnitInRange;
		local IsSpellInRange = IsSpellInRange;
		local CheckInteractDistance = CheckInteractDistance;
		function IsInRange ( UnitID )
			if ( UnitIsConnected( UnitID ) ) then
				if ( UnitCanAssist( "player", UnitID ) ) then
					if ( CanHelp and not UnitIsDead( UnitID ) ) then
						return IsSpellInRange( HelpName, UnitID ) == 1;
					elseif ( not UnitOnTaxi( "player" ) -- UnitInRange always returns nil while on flightpaths
						and ( UnitIsUnit( UnitID, "player" ) or UnitIsUnit( UnitID, "pet" )
							or UnitPlayerOrPetInParty( UnitID ) or UnitPlayerOrPetInRaid( UnitID ) )
					) then
						return UnitInRange( UnitID ); -- Fast checking for self and party members (38 yd range)
					end
				elseif ( CanHarm and not UnitIsDead( UnitID ) and UnitCanAttack( "player", UnitID ) ) then
					return IsSpellInRange( HarmName, UnitID ) == 1;
				end

				-- Fallback when spell not found or class uses none
				return CheckInteractDistance( UnitID, 4 ); -- Follow distance (28 yd range)
			end
		end
	end
	--[[****************************************************************************
	  * Function: local UpdateRange                                                *
	  ****************************************************************************]]
	local UpdateRange;
	do
		local InRange;
		function UpdateRange ( self )
			InRange = not not IsInRange( self.unit ); -- Cast to boolean
			if ( ObjectRanges[ self ] ~= InRange ) then -- Range state changed
				ObjectRanges[ self ] = InRange;

				if ( self.SpellRangeOverride ) then
					self:SpellRangeOverride( InRange );
				else
					self:SetAlpha( self[ InRange and "inRangeAlpha" or "outsideRangeAlpha" ] );
				end
			end
		end
	end
	--[[****************************************************************************
	  * Function: local UpdateSpells                                               *
	  ****************************************************************************]]
	local UpdateSpells;
	do
		local IsSpellKnown = IsSpellKnown;
		function UpdateSpells ()
			-- Set to true if spell is in spellbook, and cache its name
			if ( HelpID ) then
				CanHelp = IsSpellKnown( HelpID );
				if ( CanHelp and not HelpName ) then
					HelpName = GetSpellInfo( HelpID );
				end
			end
			if ( HarmID ) then
				CanHarm = IsSpellKnown( HarmID );
				if ( CanHarm and not HarmName ) then
					HarmName = GetSpellInfo( HarmID );
				end
			end
		end
	end


	--[[****************************************************************************
	  * Function: local OnUpdate                                                   *
	  ****************************************************************************]]
	local OnUpdate;
	do
		local NextUpdate = 0;
		function OnUpdate ( self, Elapsed )
			NextUpdate = NextUpdate - Elapsed;
			if ( NextUpdate <= 0 ) then
				NextUpdate = UpdateRate;

				UpdateSpells();
				for Object in pairs( Objects ) do
					if ( Object:IsVisible() ) then
						UpdateRange( Object );
					end
				end
			end
		end
	end


	--[[****************************************************************************
	  * Function: local Enable                                                     *
	  ****************************************************************************]]
	local function Enable ( self, UnitID )
		if ( self.SpellRange ) then
			assert( type( self.SpellRangeOverride ) == "function"
				or ( type( self.inRangeAlpha ) == "number" and type( self.outsideRangeAlpha ) == "number" ),
				"oUF layout addon omitted required SpellRange properties." );
			if ( self.Range ) then -- Disable default range checking
				self:DisableElement( "Range" );
				self.Range = nil;
			end

			if ( not UpdateFrame ) then
				UpdateFrame = CreateFrame( "Frame" );
				UpdateFrame:SetScript( "OnUpdate", OnUpdate );
			else
				UpdateFrame:Show();
			end
			Objects[ self ] = true;
			return true;
		end
	end
	--[[****************************************************************************
	  * Function: local Disable                                                    *
	  ****************************************************************************]]
	local function Disable ( self )
		Objects[ self ] = nil;
		ObjectRanges[ self ] = nil;
		if ( not next( Objects ) ) then
			UpdateFrame:Hide();
		end
	end
	--[[****************************************************************************
	  * Function: local Update                                                     *
	  ****************************************************************************]]
	local function Update ( self, Event, UnitID )
		if ( Event ~= "OnTargetUpdate" ) then -- Caused by a real event
			UpdateSpells();
			ObjectRanges[ self ] = nil; -- Force update to fire
			UpdateRange( self ); -- Update range immediately
		end
	end




	--------------------------------------------------------------------------------
	-- Function Hooks / Execution
	-----------------------------

	do
		local _, Class = UnitClass( "player" );
		-- Optional low level baseline skills with greater than 28 yard range
		HelpID = ( {
			DRUID = 5185; -- Healing Touch
			MAGE = 1459; -- Arcane Intellect
			PALADIN = 635; -- Holy Light
			PRIEST = 2050; -- Lesser Heal
			SHAMAN = 331; -- Healing Wave
			WARLOCK = 5697; -- Unending Breath
		} )[ Class ];
		HarmID = ( {
			DEATHKNIGHT = 52375; -- Death Coil
			DRUID = 5176; -- Wrath
			HUNTER = 75; -- Auto Shot
			MAGE = 133; -- Fireball
			PALADIN = 62124; -- Hand of Reckoning
			PRIEST = 585; -- Smite
			SHAMAN = 403; -- Lightning Bolt
			WARLOCK = 686; -- Shadow Bolt
			WARRIOR = 355; -- Taunt
		} )[ Class ];

		oUF:AddElement( "SpellRange", Update, Enable, Disable );
	end
	---------------------------------------------------------------------------
	-- end spellrange
	---------------------------------------------------------------------------
end

do
	--[[
		Weapon Enchant
		Elements handled: .Enchant
		
		Options:
		 - spacing: Padding between enchant icons. (Default: 0)
		 - size: Size of the enchant icons. (Default: 16)
		 - initialAnchor: Initial anchor in the enchant frame. (Default: "BOTTOMLEFT")
		 - growth-x: Growth direction, affected by initialAnchor. (Default: "UP")
		 - growth-y: Growth direction, affected by initialAnchor. (Default: "RIGHT")
		 - showCharges: Shows a count of the remaining charges. (Default: false)
				I'm actually not sure if any weapon enchants still have charges, but it's there just in case.
		 - showCD: Shows the duration using a cooldown animation. (Default: false)
		 - showBlizzard: Setting this prevents Blizzard's temp enchant frame from being hidden. (Default: false)
		 
		Variables set on each icon:
		 - expTime: Expiration time of this weapon enchant. Substract GetTime() to get remaining duration.
		 
		Functions that can be overridden from within a layout:
		 :PostCreateEnchantIcon(button, icons)
		 :PostUpdateEnchantIcons(icons)
	]]

	-- Allow embedding and what not.
	local parent = debugstack():match[[\AddOns\(.-)\]]
	local global = GetAddOnMetadata(parent, 'X-oUF')
	local oUF = _G[global] or oUF
	assert(oUF, 'oUF not loaded')

	-- Set playerGUID after PEW.
	local playerGUID
	local pending
	local frame = CreateFrame("Frame")
	frame.elapsed = 0
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:SetScript("OnEvent", function(self, event) playerGUID = UnitGUID("player") self:UnregisterEvent(event) end)

	local OnEnter = function(self)
		if(not self:IsVisible()) then return end

		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
		GameTooltip:SetInventoryItem("player", self.slot)
		GameTooltip:Show()
	end

	local OnLeave = function()
		GameTooltip:Hide()
	end

	local OnClick = function(self, button)
		if button == "RightButton" then
			CancelItemTempEnchantment(self.slot == 16 and 1 or 2)
		end
	end

	local function CreateIcon(self, icons)
		local button = CreateFrame("Frame", nil, icons)
		button:EnableMouse()
		
		button:SetWidth(icons.size or 16)
		button:SetHeight(icons.size or 16)
		
		local cd = CreateFrame("Cooldown", nil, button)
		cd:SetAllPoints(button)

		local icon = button:CreateTexture(nil, "BACKGROUND")
		icon:SetAllPoints(button)

		local count = button:CreateFontString(nil, "OVERLAY")
		count:SetFont(recUI.media.font, 8, "OUTLINE")
		count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 0)
		
		local overlay = button:CreateTexture(nil, "OVERLAY")
		overlay:SetTexture"Interface\\Buttons\\UI-Debuff-Overlays"
		overlay:SetAllPoints(button)
		overlay:SetTexCoord(.296875, .5703125, 0, .515625)
			
		table.insert(icons, button)
		
		button.overlay = overlay
		button.frame = self
		button.icon = icon
		button.count = count
		button.cd = cd
		
		button:SetScript("OnEnter", OnEnter)
		button:SetScript("OnLeave", OnLeave)
		button:SetScript("OnMouseUp", OnClick)

		if(self.PostCreateEnchantIcon) then self:PostCreateEnchantIcon(button, icons) end

		return button
	end

	local function SetIconPosition(self, icons)
		local col = 0
		local row = 0
		local spacing = icons.spacing or 0
		local size = (icons.size or 16) + spacing
		local anchor = icons.initialAnchor or "TOPLEFT"
		local growthx = (icons["growth-x"] == "LEFT" and -1) or 1
		local growthy = (icons["growth-y"] == "DOWN" and -1) or 1
		local cols = math.floor(icons:GetWidth() / size + .5)
		local rows = math.floor(icons:GetHeight() / size + .5)
		
		local icon = icons[1]
		icons[1]:SetPoint(anchor, icons, anchor, 0,0)
		if icon:IsShown() then
			col = col + 1
			if(col >= cols) then
				col = 0
				row = row + 1
			end
			icons[2]:SetPoint(anchor, icons, anchor, col * growthx * size, row * growthy * size)
		else
			icons[2]:SetPoint(icon:GetPoint())
		end
	end

	local function UpdateIcons(self)
		local icons = self.Enchant
		
		local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo();
		local now = GetTime()
		
		local icon = icons[1] or CreateIcon(self, icons)
		if hasMainHandEnchant then
			icon.icon:SetTexture(GetInventoryItemTexture("player", 16))
			
			icon.expTime = mainHandExpiration
			if mainHandExpiration then
				icon.expTime = now+mainHandExpiration/1000
				
				if icons.showCD then
					icon.cd:SetCooldown(now, mainHandExpiration)
				end
			end
			
			if icons.showCharges and mainHandCharges then
				icon.count:SetText(mainHandCharges)
			end
			
			icon.slot = 16
			icon:Show()
		else
			icon:Hide()
		end
		
		icon = icons[2] or CreateIcon(self, icons)
		if hasOffHandEnchant then
			icon.icon:SetTexture(GetInventoryItemTexture("player", 17))
			
			icon.expTime = offHandExpiration
			if offHandExpiration then
				icon.expTime = now+offHandExpiration/1000
				
				if icons.showCD then
					icon.cd:SetCooldown(now, offHandExpiration)
				end
			end
			
			if icons.showCharges and offHandCharges then
				icon.count:SetText(offHandCharges)
			end
			
			icon.slot = 17
			icon:Show()
		else
			icon:Hide()
		end
		
		SetIconPosition(self, icons)
		
		if self.PostUpdateEnchantIcons then self:PostUpdateEnchantIcons(icons) end
	end

	-- Work around the annoying delay between casting and GetWeaponEnchantInfo's information being updated.
	frame:SetScript("OnUpdate", function(self, elapsed)
		if pending then
			self.elapsed = self.elapsed + elapsed
			if self.elapsed > 1 then
				UpdateIcons(pending)
				self.elapsed = 0
				pending = nil
			end
		end
	end)

	local function CLEU(self, event, timestamp, subevent, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
		if subevent:sub(1,7) ~= "ENCHANT" or destGUID ~= playerGUID then
			return
		end
		if subevent:sub(9) == "REMOVED" then
			return UpdateIcons(self)
		end

		pending = self
	end

	local Enable = function(self)
		if(self.Enchant and self.unit == "player") then
			if not self.showBlizzard then
				TemporaryEnchantFrame:Hide()
			end

			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", CLEU)
			self:RegisterEvent("UNIT_INVENTORY_CHANGED", UpdateIcons)
			UpdateIcons(self)
			return true
		end
	end

	local Disable = function(self)
		if(self.Enchant) then
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", CLEU)
			self:UnregisterEvent("UNIT_INVENTORY_CHANGED", UpdateIcons)
		end
	end

	oUF:AddElement('WeaponEnchant', UpdateIcons, Enable, Disable)
	-- End Weapon Enchant
end

local menu = function(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub("(.)", string.upper, 1)
	if(unit == "party" or unit == "partypet") then
		ToggleDropDownMenu(1, nil, _G[format("PartyMemberFrame%dDropDown", self.id)], "cursor", 0, 0)
	elseif(_G[format("%sFrameDropDown", cunit)]) then
		ToggleDropDownMenu(1, nil, _G[format("%sFrameDropDown", cunit)], "cursor", 0, 0)
	end
end

local updateName = function(self, event, unit)
	if (self.unit == unit) then
		local r, g, b, t
		if (UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) or not UnitIsConnected(unit)) then
			r, g, b = .6, .6, .6
		elseif (unit == 'pet') then
			t = self.colors.happiness[GetPetHappiness()]
		elseif (UnitIsPlayer(unit)) then
			local _, class = UnitClass(unit)
			t = self.colors.class[class]
		else
			t = self.colors.reaction[UnitReaction(unit, "player")]
		end

		if (t) then
			r, g, b = t[1], t[2], t[3]
		end

		if (r) then
			self.Name:SetTextColor(r, g, b)
		end
		if self:GetParent():GetName():match("oUF_Raid") then
			self.Name:SetText(string.sub(UnitName(unit), 0, 3))
		elseif unit == "focus" or unit == "targettarget" or unit == "pet" or unit == "focustarget" then
			self.Name:SetText(string.sub(UnitName(unit), 0, 6))
		else
			self.Name:SetText(UnitName(unit))
		end
	end
end

local PostUpdateHealth = function(self, event, unit, bar, min, max)
	if (UnitIsDead(unit)) then
		bar.value:SetText("d")
	elseif (UnitIsGhost(unit)) then
		bar.value:SetText("g")
	elseif (not UnitIsConnected(unit)) then
		bar.value:SetText("o")
	else
		if unit == "player" or unit == "target" then
			if (min ~= 0 and min ~= max) then
				bar.value:SetFormattedText("%s | %s", lib.prettyNumber(min), lib.prettyNumber(max))
			else
				bar.value:SetText(max)
			end
		else
			bar.value:SetText(lib.prettyNumber(min))
		end
	end

	bar:SetStatusBarColor(.25, .25, .35)
	return updateName(self, event, unit)
end

local PostUpdatePower = function(self, event, unit, bar, min, max)
	if (min == 0 or max == 0 or not UnitIsConnected(unit)) then
		bar.value:SetText()
		bar:SetValue(0)
	elseif (UnitIsDead(unit) or UnitIsGhost(unit)) then
		bar.value:SetText()
		bar:SetValue(0)
	else
		if unit == "player" or unit == "target" then
			if (min ~= 0 and min ~= max) then
				bar.value:SetFormattedText("%s | %s", lib.prettyNumber(min), lib.prettyNumber(max))
			else
				bar.value:SetText(max)
			end
		else
			bar.value:SetText()
		end
	end
end

local PostCastStart = function(self, event, unit, spell, spellrank, castid)
	self.Castbar.spellName:SetText(spell)
end

local PostCastStop = function(self, event, unit)
	if (unit ~= self.unit) then return end
	self.Castbar.spellName:SetText()
end

local function UpdateAura(self, elapsed)
	self.elapsed = self.elapsed + elapsed
	if self.elapsed >= .1 then
		self.elapsed = 0
		local _, _, _, _, _, duration = UnitAura(self.unit, self.index, self.filter)
		if duration and duration > 0 then
			self.time:SetText(lib.prettyTime(duration))
		else
			self.time:SetText()
		end
	end
end

local PostCreateAuraIcon = function(self, button)
	button.count:SetFont(media.font, 9, "THINOUTLINE")
	button.count:ClearAllPoints()
	button.count:SetPoint("BOTTOMRIGHT", -1, 3)

	-- Icons are easier to recognize without this set.
	--button.icon:SetTexCoord(.07, .93, .07, .93)

	-- Push icon in 1px because it likes to poke out from the border on some scales.
	button.icon:ClearAllPoints()
	button.icon:SetPoint("TOPLEFT", 1, -1)
	button.icon:SetPoint("BOTTOMRIGHT", -1, 1)

	-- Thin 'outline' border texture.
	button.outline = button:CreateTexture(nil, "OVERLAY")
	button.outline:SetTexture(media.buttonNormal)
	button.outline:SetAllPoints()

	-- Make icon look pretty with an overlay.
	button.gloss = button:CreateTexture(nil, "OVERLAY")
	button.gloss:SetTexture(media.buttonGloss)
	button.gloss:SetAllPoints()

	-- Put spiral inside outline frame.
	button.cd:ClearAllPoints()
	button.cd:SetPoint("TOPLEFT", 3, -3)
	button.cd:SetPoint("BOTTOMRIGHT", -3, 3)
	-- Remove cooldown spiral.
	--button.cd = nil

	-- Use time display rather than spiral.
	--button.time = button:CreateFontString(nil, "OVERLAY")
	--button.time:SetPoint("TOPLEFT", 1, -1)
	--button.time:SetFont(media.font, 9, "THINOUTLINE")
	--button.time:SetText("0")
end

--local auraColor  = {
--	["Magic"]   = {r = 0.00, g = 0.25, b = 0.45},
--	["Disease"] = {r = 0.40, g = 0.30, b = 0.10},
--	["Poison"]  = {r = 0.00, g = 0.40, b = 0.10},
--	["Curse"]   = {r = 0.40, g = 0.00, b = 0.40},
--	["None"]    = {r = 0.40, g = 0.40, b = 0.40}
--}

local PostUpdateAuraIcon
do
	local playerUnits = {
		player = true,
		pet = true,
		vehicle = true,
	}

	PostUpdateAuraIcon = function(self, icons, unit, icon, index, offset, filter, isDebuff)
		--local auraType = select(5, UnitAura(unit, index, icon.filter))
		--f (auraType) then -- Be absolutely sure.
		--	print(auraType, auraColor[auraType].r, auraColor[auraType].g, auraColor[auraType].b)
		--	icon.outline:SetVertexColor(auraColor[auraType].r, auraColor[auraType].g, auraColor[auraType].b, 1)
		--end
		if unit == "target" and not(playerUnits[icon.owner]) and isDebuff then
			icon.icon:SetDesaturated(true)
		else
			icon.icon:SetDesaturated(false)
		end
	end
end

local function style(self, unit)

	local is_party = not unit and self:GetParent():GetName():match("oUF_Party")
	local is_raid = not unit and self:GetParent():GetName():match("oUF_Raid")
	
	self.menu = menu
	self:RegisterForClicks("AnyUp")
	self:SetAttribute("type2", "menu")
	
	-- Friendly click casting
	if unit == "player" or unit == "pet" or is_raid or is_party then
		if lib.playerClass == "SHAMAN" then
			self:SetAttribute("type1", "spell")
			self:SetAttribute("spell1", (UnitLevel("player") > 1) and "Healing Wave" or "Lesser Healing Wave")
			--[[self:SetAttribute("type2", "spell")
			self:SetAttribute("spell2", "Chain Heal")
			self:SetAttribute("type3", "spell")
			self:SetAttribute("spell3", "Riptide")
			self:SetAttribute("shift-type1", "spell")
			self:SetAttribute("shift-spell1", "Healing Wave")
			self:SetAttribute("shift-type2", "spell")
			self:SetAttribute("shift-spell2", "Cleanse Spirit")--]]
			self:SetAttribute("alt-type1", "target")
			self:SetAttribute("alt-type2", "menu")
		end
	end

	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	self:HookScript("OnShow", function(frame)
		for _, v in ipairs(frame.__elements) do
			v(frame, "UpdateElement", frame.unit)
		end
	end)

-- Backdrop
	self.background = CreateFrame("Frame", nil, self)
	self.background:SetPoint("TOPLEFT", self, "TOPLEFT", -4, 4)
	self.background:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 4, -4)
	self.background:SetFrameStrata("BACKGROUND")
	self.background:SetBackdrop {
		bgFile = media.bgFile,
		edgeFile = media.edgeFile, edgeSize = 3,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	}
	self.background:SetBackdropColor(0, 0, 0, 1)
	self.background:SetBackdropBorderColor(0, 0, 0)

-- Health
	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetStatusBarTexture(media.statusBar)
	self.Health:SetPoint("TOPLEFT", 0,0)
	self.Health:SetPoint("TOPRIGHT", 0,0)
	self.Health.frequentUpdates = true

	self.Health.background = self.Health:CreateTexture(nil, "BACKGROUND")
	self.Health.background:SetTexture(.25, .25, .25, 1)
	self.Health.background:SetAllPoints()

	self.Health.value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.value:SetFont(media.font, 9, "THINOUTLINE")
	self.Health.value:SetPoint("RIGHT", -5, 2)
	self.Health.value:SetTextColor(1, 1, 1)

-- Power
	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetStatusBarTexture(media.statusBar)
	self.Power:SetPoint("BOTTOMLEFT", 0,0)
	self.Power:SetPoint("BOTTOMRIGHT", 0,0)
	self.Power.frequentUpdates = true
	self.Power.colorTapping = true
	self.Power.colorHappiness = true
	self.Power.colorClass = true
	self.Power.colorReaction = true

	self.Power.background = self.Power:CreateTexture(nil, "BACKGROUND")
	self.Power.background:SetTexture(.25, .25, .25, 1)
	self.Power.background:SetAllPoints()

	self.Power.value = self.Power:CreateFontString(nil, "OVERLAY")
	self.Power.value:SetFont(media.font, 9, "THINOUTLINE")
	self.Power.value:SetPoint("RIGHT", -5, 2)
	self.Power.value:SetTextColor(1, 1, 1)

-- Name
	self.Name = self.Health:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("LEFT", 5, 2)
	self.Name:SetJustifyH("LEFT")
	self.Name:SetFont(media.font, 9, "THINOUTLINE")
	self.Name:SetTextColor(1, 1, 1)

-- Castbar
	if unit == "player" or unit == "target" then
		self.Castbar = CreateFrame("StatusBar", nil, self)
		self.Castbar:SetStatusBarTexture(media.statusBar)
		self.Castbar:SetStatusBarColor(.3, .3, .6, 1)
		self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -2)
		self.Castbar:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", 0, 2)
		self.Castbar:SetToplevel(true)

		self.Castbar.spellName = self.Castbar:CreateFontString(nil, "OVERLAY")
		self.Castbar.spellName:SetFont(media.font, 9, "THINOUTLINE")
		self.Castbar.spellName:SetPoint("LEFT", 5, 2)
		self.Castbar.spellName:SetTextColor(1, 1, 1)

-- Portrait
		self.Portrait = CreateFrame("PlayerModel", nil, self)
		self.Portrait:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -3)
		self.Portrait:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", 0, 2)

		self.Portrait.backdrop = self.Portrait:CreateTexture(nil, "BACKGROUND")
		self.Portrait.backdrop:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -2)
		self.Portrait.backdrop:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", 0, 2)
		self.Portrait.backdrop:SetTexture(.15, .15, .15, 1)
	end

-- Buffs
	if unit == "player" or unit == "target" then
		self.Buffs = CreateFrame("Frame", nil, self)
		self.Buffs:SetHeight(2 * 22 + 2 * 2)
		self.Buffs:SetWidth(8 * 22 + 8 * 2)
		self.Buffs.num = 16
		self.Buffs.size = 22
		self.Buffs.spacing = 1

		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs:SetHeight(2 * 22 + 2 * 2)
		self.Debuffs:SetWidth(8 * 22 + 8 * 2)
		self.Debuffs.num = 16
		self.Debuffs.size = 22
		self.Debuffs.spacing = 1

		if unit == "player" then
			self.Buffs.initialAnchor = "TOPRIGHT"
			self.Buffs["growth-x"] = "LEFT"
			self.Buffs["growth-y"] = "DOWN"
			self.Buffs:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 2)

			BuffFrame:Hide()
			TemporaryEnchantFrame:Hide()
			
			self.Enchant = CreateFrame("Frame", nil, self)
			self.Enchant.spacing = 1
			self.Enchant.size = 22
			self.Enchant.initialAnchor = "TOPLEFT"
			self.Enchant["growth-x"] = "RIGHT"
			self.Enchant["growth-y"] = "DOWN"
			self.Enchant.showCharges = false
			self.Enchant.showCD = true
			self.Enchant.showBlizzard = false
			self.Enchant:SetHeight(1 * 22 + 1 * 2)
			self.Enchant:SetWidth(2 * 22 + 2 * 2)
			self.Enchant:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 2)
		else
			self.Buffs.initialAnchor = "TOPLEFT"
			self.Buffs["growth-x"] = "RIGHT"
			self.Buffs["growth-y"] = "DOWN"
			self.Buffs:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 2)
		end

		self.Debuffs.initialAnchor = "TOPLEFT"
		self.Debuffs["growth-x"] = "RIGHT"
		self.Debuffs["growth-y"] = "DOWN"
		self.Debuffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -3, -4)

		self.PostUpdateAuraIcon = PostUpdateAuraIcon
		self.PostCreateAuraIcon = PostCreateAuraIcon
		self.PostCreateEnchantIcon = PostCreateAuraIcon
	end

-- Size
	if unit == "player" or unit == "target" then
		self:SetAttribute("initial-height", 40)
		self:SetAttribute("initial-width", 230)
		self.Power:SetHeight(10)
		self.Health:SetHeight(15)
	elseif self:GetAttribute("unitsuffix") == "pet" then
		self:SetAttribute("initial-height", 10)
		self:SetAttribute("initial-width", 113)
		self.Power:SetHeight(2)
		self.Health:SetHeight(8)
	elseif self:GetParent():GetName():match("oUF_Raid") then
		self:SetAttribute("initial-height", 28)
		self:SetAttribute("initial-width", 60)
		self.Power:SetHeight(6)
		self.Health:SetHeight(20)
	else
		self:SetAttribute("initial-height", 22)
		self:SetAttribute("initial-width", 113)
		self.Power:SetHeight(5)
		self.Health:SetHeight(15)
	end
	
-- Range
	self.inRangeAlpha = 1
	self.outsideRangeAlpha = .4
	self.SpellRange = true

-- Overrides/Hooks
	self.PostUpdateHealth = PostUpdateHealth
	self.PostUpdatePower = PostUpdatePower
	self.PostChannelStart = PostCastStart
	self.PostCastStart = PostCastStart
	self.PostCastStop = PostCastStop
	self.PostChannelStop = PostCastStop
	if unit == "pet" then
		self:RegisterEvent("UNIT_HAPPINESS", updateName)
	end
	self:RegisterEvent('UNIT_NAME_UPDATE', updateName)

	return self
end

oUF:RegisterStyle("recUI", style)
oUF:SetActiveStyle("recUI")

oUF:Spawn("player", "recUI_player"):SetPoint("BOTTOM", UIParent, -278.5, 269.5)
oUF:Spawn("target", "recUI_target"):SetPoint("BOTTOM", UIParent, 278.5, 269.5)

oUF:Spawn("pet", "recUI_pet"):SetPoint("BOTTOMLEFT", recUI_player, "TOPLEFT", 0, 10)
oUF:Spawn("focus", "recUI_focus"):SetPoint("BOTTOMRIGHT", recUI_player, "TOPRIGHT", 0, 10)
oUF:Spawn("focustarget", "recUI_focustarget"):SetPoint("BOTTOMLEFT", recUI_target, "TOPLEFT", 0, 10)
oUF:Spawn("targettarget", "recUI_targettarget"):SetPoint("BOTTOMRIGHT", recUI_target, "TOPRIGHT", 0, 10)
local party = oUF:Spawn("header", "oUF_Party")
party:SetAttribute("showParty", true)
party:SetAttribute("yOffset", -27.5)
party:SetAttribute("template", "recUI_Party")
party:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 15, -15)

local raid = {}
for i = 1, NUM_RAID_GROUPS do
	local raidgroup = oUF:Spawn("header", "oUF_Raid"..i)
	raidgroup:SetAttribute("groupFilter", tostring(i))
	raidgroup:SetAttribute("showRaid", true)
	raidgroup:SetAttribute("yOffSet", -7.5)
	table.insert(raid, raidgroup)
	if i == 1 then
		raidgroup:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 15, -15)
	else
		raidgroup:SetPoint("TOPLEFT", raid[i-1], "TOPRIGHT", (60 * 1 - 60) + 7.5, 0) --1 == scale
	end
end

local partyToggle = CreateFrame("Frame")
partyToggle:RegisterEvent("PLAYER_LOGIN")
partyToggle:RegisterEvent("RAID_ROSTER_UPDATE")
partyToggle:RegisterEvent("PARTY_LEADER_CHANGED")
partyToggle:RegisterEvent("PARTY_MEMBERS_CHANGED")
partyToggle:SetScript("OnEvent", function(self)
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		local numraid = GetNumRaidMembers()
		if numraid > 0 and (numraid > 5 or numraid ~= GetNumPartyMembers() + 1) then
			party:Hide()
			for i, v in ipairs(raid) do v:Show() end
		else
			party:Show()
			for i, v in ipairs(raid) do v:Hide() end
		end
	end
end)