local _, ns = ...
ns.DIRECTORY = [[Interface\Addons\recUI\media]]

ns.media = {
	bgFile        = [[Interface\ChatFrame\ChatFrameBackground]],
	edgeFile      = [[Interface\Addons\recUI\media\texture\glowtex]],
	statusBar     = [[Interface\Addons\recUI\media\texture\minimalist]],
	font          = [[Interface\Addons\recUI\media\font\Russel Square LT.ttf]],
	iconBorder    = [[Interface\Addons\recUI\media\texture\border]],
	iconHighlight = [[Interface\Addons\recUI\media\texture\highlight]],
	
	buttonNormal = [[Interface\AddOns\recUI\media\texture\Normal]],
	buttonGloss = [[Interface\AddOns\recUI\media\texture\gloss]],
	buttonFlash = [[Interface\AddOns\recUI\media\texture\flash]],
	buttonHover = [[Interface\AddOns\recUI\media\texture\hover]],
	buttonPushed = [[Interface\AddOns\recUI\media\texture\pushed]],
	buttonChecked = [[Interface\AddOns\recUI\media\texture\checked]],
	buttonEquipped = [[Interface\AddOns\recUI\media\texture\gloss_grey]],
	buttonBackdrop = [[Interface\AddOns\recUI\media\texture\Backdrop]],
	buttonHighlight = [[Interface\AddOns\recUI\media\texture\Highlight]]
}

ns.backdrop_table = {
	bgFile   = ns.media.bgFile,
	edgeFile = ns.media.edgeFile,
	edgeSize = 4,
	insets   = {
		left   = 3,
		right  = 3,
		top    = 3,
		bottom = 3
	}
}

ns.border_table = {
	bgFile   = nil,
	edgeFile = ns.media.edgeFile,
	edgeSize = 4,
	insets   = {
		left   = 3,
		right  = 3,
		top    = 3,
		bottom = 3
	}
}

ns.backdrop = function(object, remove_backdrop)
	if not object then return end
	if type(object) == "frame" then
		object:SetBackdrop((not remove_backdrop) and ns.backdrop_table or ns.border_table)
		object:SetBackdropBorderColor(0, 0, 0)
		object:SetBackdropColor(.25,.25,.25, .5)
	else
		object.bg = CreateFrame("Frame", nil, object)
		object.bg:SetPoint("TOPLEFT")
		object.bg:SetPoint("BOTTOMRIGHT")
		object.bg:SetBackdrop((not remove_backdrop) and ns.backdrop_table or ns.border_table)
		object.bg:SetFrameStrata("BACKGROUND")
		object.bg:SetBackdropBorderColor(0, 0, 0)
		object.bg:SetBackdropColor(.25,.25,.25, .5)
	end
	return object
end

--[[
	Buttons:
	button:SetNormalFontObject(ns.fontObject("NORMAL", 10, "OUTLINE"))

	FontStrings:
	fontstring:SetFont(ns.font("bold10outline"))
--]]

ns.fontFace = {
	--PIXEL      = ns.DIRECTORY..[[fonts\pf_tempesta_five_condensed.ttf]],
	--TINY_PIXEL = ns.DIRECTORY..[[fonts\pf_tempesta_five_condensed.ttf]],
	PIXEL =      ns.DIRECTORY..[[fonts\25321Russel Square LT.ttf]],
	TINY_PIXEL = ns.DIRECTORY..[[fonts\25321Russel Square LT.ttf]],
	--SMALL      = ns.DIRECTORY..[[fonts\Oceania-Medium.ttf]],
	--SMALL_BOLD = ns.DIRECTORY..[[fonts\Oceania-Medium.ttf]],
	--NORMAL     = ns.DIRECTORY..[[fonts\Oceania-Medium.ttf]],
	--BOLD       = ns.DIRECTORY..[[fonts\Oceania-Medium.ttf]],
	--LARGE      = ns.DIRECTORY..[[fonts\Oceania-Medium.ttf]]
	SMALL =      ns.DIRECTORY..[[fonts\25321Russel Square LT.ttf]],
	SMALL_BOLD = ns.DIRECTORY..[[fonts\25321Russel Square LT.ttf]],
	NORMAL =     ns.DIRECTORY..[[fonts\25321Russel Square LT.ttf]],
	BOLD =       ns.DIRECTORY..[[fonts\25321Russel Square LT.ttf]],
	LARGE =      ns.DIRECTORY..[[fonts\25321Russel Square LT.ttf]]
}

ns.fontFlag = {
	OUTLINE = "OUTLINE",
	THICK =   "THICKOUTLINE",
	THIN =    "THINOUTLINE"
}

ns.fontSize = {
	NORMAL = 9
}
	
ns.fontObject = function(font, size, flags)
	
	-- Use default in case of error.
	if (not font) or (not ns.fontFace[font]) then
		font = "NORMAL"
	end
	
	-- If we have already created this font, return the reference to it.
	local fontName = string.format("recUIFontObject%s%s%s", font, size, flags)
	if _G[fontName] then return _G[fontName] end
	
	-- We need to create the font and return it.
	local fontObject = CreateFont( fontName )
	fontObject:SetFont( ns.fontFace[font], (size or 10), (flags or "") )
	return fontObject
end











--[[]]
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

UNIT_NAME_FONT     = ns.media.font
NAMEPLATE_FONT     = ns.media.font
DAMAGE_TEXT_FONT   = ns.media.font
STANDARD_TEXT_FONT = ns.media.font

ns.font_events = CreateFrame("Frame")
ns.font_events:RegisterEvent("ADDON_LOADED")

ns.font_events:SetScript("OnEvent", function(self, event, addon)
	
	--if IsAddOnLoaded("Blizzard_CombatLog") or addon == "Blizzard_CombatLog" then
	
	UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 9
	CHAT_FONT_HEIGHTS = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24}

	-- Base fonts
	SetFont(AchievementFont_Small,                ns.media.font, 9)
	SetFont(GameFontNormalHuge,					ns.media.font, 20, "OUTLINE") -- Used for RaidWarningFrame
	SetFont(GameTooltipHeader,                    ns.media.font, 10, "OUTLINE")
	SetFont(InvoiceFont_Med,                    ns.media.font, 9, nil, 0.15, 0.09, 0.04)
	SetFont(InvoiceFont_Small,                  ns.media.font, 8,  nil, 0.15, 0.09, 0.04)
	SetFont(MailFont_Large,                     ns.media.font, 9, nil, 0.15, 0.09, 0.04, 0.54, 0.4, 0.1, 1, -1)
	SetFont(NumberFont_OutlineThick_Mono_Small, ns.media.font, 11, "THICKOUTLINE")
	SetFont(NumberFont_Outline_Huge,            ns.media.font, 13, "OUTLINE", 28)
	SetFont(NumberFont_Outline_Large,           ns.media.font, 13, "OUTLINE")
	SetFont(NumberFont_Outline_Med,             ns.media.font, 13, "OUTLINE")
	SetFont(NumberFont_Shadow_Med,              ns.media.font, 12)
	SetFont(NumberFont_Shadow_Small,            ns.media.font, 10)
	SetFont(QuestFont_Large,                    ns.media.font, 13)
	SetFont(QuestFont_Shadow_Huge,                ns.media.font, 13, nil, nil, nil, nil, 0.54, 0.4, 0.1)
	SetFont(ReputationDetailFont,                 ns.media.font, 10, nil, nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(SpellFont_Small,                      ns.media.font, 9)
	SetFont(SystemFont_InverseShadow_Small,       ns.media.font, 9)
	SetFont(SystemFont_Large,                   ns.media.font, 13)
	SetFont(SystemFont_Med1,                    ns.media.font, 11)
	SetFont(SystemFont_Med2,                    ns.media.font, 12, nil, 0.15, 0.09, 0.04)
	SetFont(SystemFont_Med3,                    ns.media.font, 13)
	SetFont(SystemFont_OutlineThick_Huge2,      ns.media.font, 13, "OUTLINE")
	SetFont(SystemFont_OutlineThick_Huge4,        ns.media.font, 13, "OUTLINE")
	SetFont(SystemFont_OutlineThick_WTF,          ns.media.font, 13, "OUTLINE", nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(SystemFont_Outline_Small,           ns.media.font, 11, "OUTLINE")
	SetFont(SystemFont_Shadow_Huge1,              ns.media.font, 13)
	SetFont(SystemFont_Shadow_Huge3,              ns.media.font, 13)
	SetFont(SystemFont_Shadow_Large,            ns.media.font, 13)
	SetFont(SystemFont_Shadow_Med1,             ns.media.font, 11)
	SetFont(SystemFont_Shadow_Med3,             ns.media.font, 13)
	SetFont(SystemFont_Shadow_Outline_Huge2,    ns.media.font, 13, "OUTLINE")
	SetFont(SystemFont_Shadow_Small,              ns.media.font, 9)
	SetFont(SystemFont_Small,                   ns.media.font, 8)
	SetFont(SystemFont_Tiny,                    ns.media.font, 7)
	SetFont(Tooltip_Med,                        ns.media.font, 11)
	SetFont(Tooltip_Small,                        ns.media.font, 10)

	-- Derived fonts
	SetFont(BossEmoteNormalHuge,                  ns.media.font, 13, "OUTLINE")
	SetFont(CombatTextFont,                     ns.media.font, 13)
	SetFont(ErrorFont,                          ns.media.font, 13, "OUTLINE")
	SetFont(QuestFontNormalSmall,                 ns.media.font, 11, nil, nil, nil, nil, 0.54, 0.4, 0.1)
	SetFont(WorldMapTextFont,                   ns.media.font, 13, "THICKOUTLINE",  38, nil, nil, 0, 0, 0, 1, -1)
	
	hooksecurefunc("PlayerTitleFrame_UpdateTitles", FixTitleFont)
	FixTitleFont()
	
	SetFont = nil
	self:SetScript("OnEvent", nil)
	self:UnregisterAllEvents()
	self = nil
	
	--end
end)--]]