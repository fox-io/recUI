local _, recUI = ...

recUI.lib = {

	NullFunction = function() end,

	Kill = function(object)
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
		object_reference.Show = ns.NullFunction
		object_reference:Hide()
	end
}

recUI.lib.playerClass = select(2, UnitClass("player")