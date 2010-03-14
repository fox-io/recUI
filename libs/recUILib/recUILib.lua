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

--[[lib.decToHex = function(value)
    local B, K, OUT, I, D = 16, "0123456789ABCDEF", "", 0
    while value > 0 do
        I = I + 1
        value, D = math.floor(value/B), math.floor(value%B) + 1
        OUT = string.sub(K, D, D)..OUT
    end
    return OUT
end--]]

lib.playerClass = select(2, UnitClass("player"))

SLASH_RECUILIB1 = "/recuilib"
SlashCmdList.RECUILIB = function()
	for _, statusFunc in pairs(lib.status) do
		statusFunc()
	end
end