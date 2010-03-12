local _, recUI = ...
local GetCursorPosition = GetCursorPosition
local function null_function() return end

local function OnUpdate(self)
	local currentx, currenty = GetCursorPosition()
	if self.isrotating then
		self:SetFacing(self:GetFacing() + ((currentx - self.prevx) / 50))
	elseif self.isposing then
		local cz, cx, cy = self:GetPosition()
		self:SetPosition(cz, cx + ((currentx - self.prevx) / 50), cy + ((currenty - self.prevy) / 50))
	end
	self.prevx, self.prevy = currentx, currenty
end
local function OnMouseDown(self, button)
	self.pMouseDown(button)
	recUI.lib.scheduleUpdate("recUIDressingRoom", 0, function()
		OnUpdate(self)
	end)
	if button == "LeftButton" then
		self.isrotating = 1
	elseif button == "RightButton" then
		self.isposing = 1
	end
	self.prevx, self.prevy = GetCursorPosition()
end
local function OnMouseUp(self, button)
	self.pMouseUp(button)
	recUI.lib.unscheduleUpdate("recUIDressingRoom")
	if button == "LeftButton" then
		self.isrotating = nil
	end
	if button == "RightButton" then
		self.isposing = nil
	end
end
local function OnMouseWheel(self, direction)
	local cz, cx, cy = self:GetPosition()
	self:SetPosition(cz + ((direction > 0 and 0.6) or -0.6), cx, cy)
end

-- base functions
-- - model - model frame name (string)
-- - w/h - new width/height of the model frame
-- - x/y - new x/y positions for default setpoint
-- - sigh - if rotation buttons have different base names than parent
-- - norotate - if the model doesn't have default rotate buttons
local function Apply(model, w, h, x, y, sigh, norotate)
	local gmodel = _G[model]
	if not norotate then
		model = sigh or model
		_G[model.."RotateRightButton"]:Hide()
		_G[model.."RotateLeftButton"]:Hide()
	end
	if w then gmodel:SetWidth(w) end
	if h then gmodel:SetHeight(h) end
	if x or y then 
		local p,rt,rp,px,py = gmodel:GetPoint()
		gmodel:SetPoint(p, rt, rp, x or px, y or py) 
	end
	gmodel:SetModelScale(2)
	gmodel:EnableMouse(true)
	gmodel:EnableMouseWheel(true)
	gmodel.pMouseDown = gmodel:GetScript("OnMouseDown") or null_function
	gmodel.pMouseUp = gmodel:GetScript("OnMouseUp") or null_function
	gmodel:SetScript("OnMouseDown", OnMouseDown)
	gmodel:SetScript("OnMouseUp", OnMouseUp)
	gmodel:SetScript("OnMouseWheel", OnMouseWheel)
end
-- in case someone wants to apply it to his/her model
recDressUpApply = Apply

local gtt = GameTooltip
local function gttshow(self)
	gtt:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	gtt:SetText(self.tt)
	if recDressUpNPC and recDressUpNPC:IsVisible() and self.tt == "Undress" then
		gtt:AddLine("Cannot dress NPC models")
	end
	gtt:Show()
end
local function gtthide()
	gtt:Hide()
end
local function newbutton(name, parent, text, w, h, button, tt, func)
	local b = button or CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
	b:SetText(text or b:GetText())
	b:SetWidth(w or b:GetWidth())
	b:SetHeight(h or b:GetHeight())
	b:SetScript("OnClick", func)
	if tt then
		b.tt = tt
		b:SetScript("OnEnter", gttshow)
		b:SetScript("OnLeave", gtthide)
	end
	return b
end

-- modifies the auction house dressing room
local function hook_auction_house()
	Apply("AuctionDressUpModel", nil, 370, 0, 10)
	local reset_button, model = AuctionDressUpFrameResetButton, AuctionDressUpModel
	local w, h = 20, reset_button:GetHeight()
	newbutton(nil, nil, "T", w, h, reset_button, "Target", function()
		if UnitExists("target") and UnitIsVisible("target") then
			model:SetUnit("target")
		end
	end)
	local a,b,c,d,e = reset_button:GetPoint()
	reset_button:SetPoint(a,b,c,d,e-30)
	newbutton("recDressUpAHReset", model, "R", 20, 22, nil, "Reset", function() model:Dress() end):SetPoint("RIGHT", reset_button, "LEFT", 0, 0)
	newbutton("recDressUpAHUndress", model, "U", 20, 22, nil, "Undress", function() model:Undress() end):SetPoint("LEFT", reset_button, "RIGHT", 0, 0)
end
local function hook_inspect()
	Apply("InspectModelFrame", nil, nil, nil, nil, "InspectModel")
end

-- now apply the changes
-- need an event frame since 2 of the models are from LoD addons
recUI.lib.registerEvent("ADDON_LOADED", "recUIDressingRoom", function(self, event, addon)
	if addon == "Blizzard_AuctionUI" then
		hook_auction_house()
	elseif addon == "Blizzard_InspectUI" then
		hook_inspect()
	end
end)

-- in case Blizzard_AuctionUI or Blizzard_InspectUI were loaded early
if AuctionDressUpModel then hook_auction_house() end
if InspectModelFrame then hook_inspect() end

-- main dressing room model with undress buttons
Apply("DressUpModel", nil, 332, nil, 104)
local cancel_button = DressUpFrameCancelButton
local w, h = 40, cancel_button:GetHeight()
local model = DressUpModel

-- since 2.1 dressup models doesn't apply properly to NPCs, make a substitute
local target_model = CreateFrame("PlayerModel", "recDressUpNPC", DressUpFrame)
target_model:SetAllPoints(DressUpModel)
target_model:Hide()
Apply("recDressUpNPC", nil, nil, nil, nil, nil, true)
	
DressUpFrame:HookScript("OnShow", function()
	target_model:Hide()
	model:Show()
end)
	
-- convert default close button into set target button
newbutton(nil, nil, "Tar", w, h, cancel_button, "Target", function()
	if UnitExists("target") and UnitIsVisible("target") then 
		if UnitIsPlayer("target") then
			target_model:Hide()
			model:Show()
			model:SetUnit("target")
		else
			target_model:Show()
			model:Hide()
			target_model:SetUnit("target")
		end
		SetPortraitTexture(DressUpFramePortrait, "target")
	end
end)
local a,b,c,d,e = cancel_button:GetPoint()
cancel_button:SetPoint(a, b, c, d - (w/2), e)
newbutton("recDressUpUndress", DressUpFrame, "Und", w, h, nil, "Undress", function() model:Undress() end):SetPoint("LEFT", cancel_button, "RIGHT", -2, 0)

Apply("CharacterModelFrame")
Apply("TabardModel", nil, nil, nil, nil, "TabardCharacterModel")
Apply("PetModelFrame")
Apply("PetStableModel")
PetPaperDollPetInfo:SetFrameStrata("HIGH")

if CompanionModelFrame then
	Apply("CompanionModelFrame")
end