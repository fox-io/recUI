local _, recUI = ...
recUI.DIRECTORY = [[Interface\Addons\recUI\media]]

recUI.media = {
	bgFile        = [[Interface\ChatFrame\ChatFrameBackground]],
	edgeFile      = [[Interface\Addons\recUI\media\texture\glowtex]],
	statusBar     = [[Interface\Addons\recUI\media\texture\minimalist]],
	font          = [[Interface\Addons\recUI\media\font\Russel Square LT.ttf]],
	iconBorder    = [[Interface\Addons\recUI\media\texture\border]],
	iconHighlight = [[Interface\Addons\recUI\media\texture\highlight]],
	
	buttonNormal    = [[Interface\AddOns\recUI\media\texture\button_normal]],
	buttonGloss     = [[Interface\AddOns\recUI\media\texture\button_gloss]],
	buttonFlash     = [[Interface\AddOns\recUI\media\texture\button_flash]],
	buttonHover     = [[Interface\AddOns\recUI\media\texture\button_hover]],
	buttonPushed    = [[Interface\AddOns\recUI\media\texture\button_pushed]],
	buttonChecked   = [[Interface\AddOns\recUI\media\texture\button_checked]],
	buttonEquipped  = [[Interface\AddOns\recUI\media\texture\button_gloss]],
	buttonBackdrop  = [[Interface\AddOns\recUI\media\texture\button_backdrop]],
	buttonHighlight = [[Interface\AddOns\recUI\media\texture\button_highlight]]
}

recUI.media.fontObject = CreateFont("recUIFontObject")
recUI.media.fontObject:SetFont(recUI.media.font, 10, nil)

recUI.media.backdropTable = {
	bgFile   = recUI.media.bgFile,
	edgeFile = recUI.media.edgeFile,
	edgeSize = 4,
	insets   = {
		left   = 3,
		right  = 3,
		top    = 3,
		bottom = 3
	}
}

recUI.media.borderTable = {
	bgFile   = nil,
	edgeFile = recUI.media.edgeFile,
	edgeSize = 4,
	insets   = {
		left   = 3,
		right  = 3,
		top    = 3,
		bottom = 3
	}
}

recUI.media.backdrop = function(object, remove_backdrop)
	if not object then return end
	if type(object) == "frame" then
		object:SetBackdrop((not remove_backdrop) and recUI.media.backdropTable or recUI.media.borderTable)
		object:SetBackdropBorderColor(0, 0, 0)
		object:SetBackdropColor(.25,.25,.25, .5)
	else
		object.bg = CreateFrame("Frame", nil, object)
		object.bg:SetPoint("TOPLEFT")
		object.bg:SetPoint("BOTTOMRIGHT")
		object.bg:SetBackdrop((not remove_backdrop) and recUI.media.backdropTable or recUI.media.borderTable)
		object.bg:SetFrameStrata("BACKGROUND")
		object.bg:SetBackdropBorderColor(0, 0, 0)
		object.bg:SetBackdropColor(.25,.25,.25, .5)
	end
	return object
end

-- System font overrides
local SetFont = function(obj, font, size, style, r, g, b, sr, sg, sb, sox, soy)
	obj:SetFont(font, size, style)
	if sr and sg and sb then obj:SetShadowColor(sr, sg, sb) end
	if sox and soy then obj:SetShadowOffset(sox, soy) end
	if r and g and b then obj:SetTextColor(r, g, b)
	elseif r then obj:SetAlpha(r) end
end

local FixTitleFont = function()
	for _, button in pairs(PlayerTitlePickerScrollFrame.buttons) do
		button.text:SetFontObject(GameFontHighlightSmallLeft)
	end
end

UNIT_NAME_FONT     = recUI.media.font
NAMEPLATE_FONT     = recUI.media.font
DAMAGE_TEXT_FONT   = recUI.media.font
STANDARD_TEXT_FONT = recUI.media.font

recUI.lib.registerEvent("ADDON_LOADED", "recUIMediaLoadFonts", function(self, event, addon)
	if IsAddOnLoaded("Blizzard_CombatLog") or addon == "Blizzard_CombatLog" then
		UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 9
		CHAT_FONT_HEIGHTS = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24}

		-- Base fonts
		SetFont(AchievementFont_Small,              recUI.media.font, 9)
		SetFont(GameFontNormalHuge,					recUI.media.font, 20, "OUTLINE") -- Used for RaidWarningFrame
		SetFont(GameTooltipHeader,                  recUI.media.font, 10, "OUTLINE")
		SetFont(InvoiceFont_Med,                    recUI.media.font, 9, nil, 0.15, 0.09, 0.04)
		SetFont(InvoiceFont_Small,                  recUI.media.font, 8,  nil, 0.15, 0.09, 0.04)
		SetFont(MailFont_Large,                     recUI.media.font, 9, nil, 0.15, 0.09, 0.04, 0.54, 0.4, 0.1, 1, -1)
		SetFont(NumberFont_OutlineThick_Mono_Small, recUI.media.font, 11, "THICKOUTLINE")
		SetFont(NumberFont_Outline_Huge,            recUI.media.font, 13, "OUTLINE", 28)
		SetFont(NumberFont_Outline_Large,           recUI.media.font, 13, "OUTLINE")
		SetFont(NumberFont_Outline_Med,             recUI.media.font, 13, "OUTLINE")
		SetFont(NumberFont_Shadow_Med,              recUI.media.font, 12)
		SetFont(NumberFont_Shadow_Small,            recUI.media.font, 10)
		SetFont(QuestFont_Large,                    recUI.media.font, 13)
		SetFont(QuestFont_Shadow_Huge,              recUI.media.font, 13, nil, nil, nil, nil, 0.54, 0.4, 0.1)
		SetFont(ReputationDetailFont,               recUI.media.font, 10, nil, nil, nil, nil, 0, 0, 0, 1, -1)
		SetFont(SpellFont_Small,                    recUI.media.font, 9)
		SetFont(SystemFont_InverseShadow_Small,     recUI.media.font, 9)
		SetFont(SystemFont_Large,                   recUI.media.font, 13)
		SetFont(SystemFont_Med1,                    recUI.media.font, 11)
		SetFont(SystemFont_Med2,                    recUI.media.font, 12, nil, 0.15, 0.09, 0.04)
		SetFont(SystemFont_Med3,                    recUI.media.font, 13)
		SetFont(SystemFont_OutlineThick_Huge2,      recUI.media.font, 13, "OUTLINE")
		SetFont(SystemFont_OutlineThick_Huge4,      recUI.media.font, 13, "OUTLINE")
		SetFont(SystemFont_OutlineThick_WTF,        recUI.media.font, 13, "OUTLINE", nil, nil, nil, 0, 0, 0, 1, -1)
		SetFont(SystemFont_Outline_Small,           recUI.media.font, 11, "OUTLINE")
		SetFont(SystemFont_Shadow_Huge1,            recUI.media.font, 13)
		SetFont(SystemFont_Shadow_Huge3,            recUI.media.font, 13)
		SetFont(SystemFont_Shadow_Large,            recUI.media.font, 13)
		SetFont(SystemFont_Shadow_Med1,             recUI.media.font, 11)
		SetFont(SystemFont_Shadow_Med3,             recUI.media.font, 13)
		SetFont(SystemFont_Shadow_Outline_Huge2,    recUI.media.font, 13, "OUTLINE")
		SetFont(SystemFont_Shadow_Small,            recUI.media.font, 9)
		SetFont(SystemFont_Small,                   recUI.media.font, 8)
		SetFont(SystemFont_Tiny,                    recUI.media.font, 7)
		SetFont(Tooltip_Med,                        recUI.media.font, 11)
		SetFont(Tooltip_Small,                      recUI.media.font, 10)

		-- Derived fonts
		SetFont(BossEmoteNormalHuge,                recUI.media.font, 13, "OUTLINE")
		SetFont(CombatTextFont,                     recUI.media.font, 13)
		SetFont(ErrorFont,                          recUI.media.font, 13, "OUTLINE")
		SetFont(QuestFontNormalSmall,               recUI.media.font, 11, nil, nil, nil, nil, 0.54, 0.4, 0.1)
		SetFont(WorldMapTextFont,                   recUI.media.font, 13, "THICKOUTLINE",  38, nil, nil, 0, 0, 0, 1, -1)
		
		hooksecurefunc("PlayerTitleFrame_UpdateTitles", FixTitleFont)
		FixTitleFont()
		
		recUI.lib.unregisterEvent("ADDON_LOADED", "recUIMediaLoadFonts")
	end
end)