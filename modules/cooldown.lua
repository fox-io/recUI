local _, recUI = ...
local day, hour, minute = 86400, 3600, 60
local format = string.format
local floor = math.floor
local min = math.min
local time = time

local function GetFormattedTime(s)
	if s >= day then
		return format("%dd", floor(s/day + 0.5)), s % day
	elseif s >= hour then
		return format("%dh", floor(s/hour + 0.5)), s % hour
	elseif s >= minute then
		if s <= minute * 5 then
			return format("%d:%02d", floor(s/60), s % minute), s - floor(s)
		end
		return format("%dm", floor(s/minute + 0.5)), s % minute
	else
		return floor(s + 0.5), (s * 100 - floor(s * 100))/100
	end
end

local function Timer_OnUpdate(self, elapsed)
	if self.text:IsShown() then
		if self.nextUpdate > 0 then
			self.nextUpdate = self.nextUpdate - elapsed
		else
			if (self:GetEffectiveScale()/UIParent:GetEffectiveScale()) < .5 then
				self.text:SetText("")
				self.nextUpdate = 1
			else
				local remain = self.duration - (GetTime() - self.start)
				if floor(remain) >= 0 then
					local time, nextUpdate = GetFormattedTime(remain)
					self.text:SetText(time)
					self.nextUpdate = nextUpdate
				else
					self.text:Hide()
				end
			end
		end
	end
end

local function Timer_Create(self)
	local scale = min(self:GetParent():GetWidth() / 32, 1)
	if scale < .5 then
		self.noOCC = true
	else
		local text = self:CreateFontString(nil, "OVERLAY")
		text:SetPoint("CENTER", 0, 1)
		text:SetFont(recUI.media.font, 15, "OUTLINE")
		text:SetTextColor(1, 1, 0)
		self.text = text
		self:HookScript("OnHide", function(self) self.text:Hide() end)
		self:SetScript("OnUpdate", Timer_OnUpdate)
		return text
	end
end

local function Timer_Start(self, start, duration)
	self.start = start
	self.duration = duration
	self.nextUpdate = 0
	local text = self.text or (not self.noOCC and Timer_Create(self))
	if text then
		text:Show()
	end
end

local methods = getmetatable(ActionButton1Cooldown).__index
hooksecurefunc(methods, "SetCooldown", function(self, start, duration)
	if self.ocd then return end
	if start > 0 and duration > 1.5 then
		Timer_Start(self, start, duration)
	else
		local text = self.text
		if text then
			text:Hide()
		end
	end
end)