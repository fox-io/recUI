local _, recUI = ...

-- Initialize recUILib namespace
recUI.lib = {}

local lib = recUI.lib

-- Used for stat output
lib.status = {}

-- Used for lib modules.
lib.frame = CreateFrame("Frame")

lib.NullFunction = function() end

lib.Kill = function(object)
	local object_reference = object
	if type(object) == "string" then
		object_reference = _G[object]
	else
		object_reference = object
	end
	if not object_reference then return end
	if type(object_reference) == "frame" then
		object_reference:UnregisterAllEvents()
	end
	object_reference.Show = lib.NullFunction
	object_reference:Hide()
end

lib.playerClass = select(2, UnitClass("player"))

-- Source: Caellian
lib.formatTime = function(seconds)
	local day, hour, minute = 86400, 3600, 60
	if seconds >= day then
		return format("%dd", floor(seconds/day + 0.5)), seconds % day
	elseif seconds >= hour then
		return format("%dh", floor(seconds/hour + 0.5)), seconds % hour
	elseif seconds >= minute then
		if seconds <= minute * 5 then
			return format("%d:%02d", floor(seconds/60), seconds % minute), seconds - floor(seconds)
		end
		return format("%dm", floor(seconds/minute + 0.5)), seconds % minute
	elseif seconds >= minute / 12 then
		return floor(seconds + 0.5), (seconds * 100 - floor(seconds * 100))/100
	end
	return format("%.1f", seconds), (seconds * 100 - floor(seconds * 100))/100
end

SLASH_RECUILIB1 = "/recuilib"
SlashCmdList.RECUILIB = function()
	for _, statusFunc in pairs(lib.status) do
		statusFunc()
	end
end