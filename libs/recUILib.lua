local _, recUI = ...

recUI.lib = {}


recUI.lib.NullFunction = function() end

recUI.lib.Kill = function(object)
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
	object_reference.Show = recUI.lib.NullFunction
	object_reference:Hide()
end

recUI.lib.playerClass = select(2, UnitClass("player"))

-------------------
-- EVENT HANDLER --
-------------------
recUI.lib.events = {}
recUI.lib.eventFrame = CreateFrame("Frame")
recUI.lib.eventFrame:SetScript("OnEvent", function(self, event, ...)
	-- If no handlers are assigned, bail.
	if not recUI.lib.events[event] then
		print(format("recUI: Unhandled event - %s", event))
		return
	end
	
	-- Call each event handler.
	for _, eventHander in pairs(recUI.lib.events[event]) do
		eventHandler(self, event, ...)
	end
end)
recUI.lib.registerEvent = function(event, handlerName, eventHandler)
	-- Create this event in our handler table if it doesn't exist yet.
	if not recUI.lib.events[event] then
		recUI.lib.events[event] = {}
	end
	
	-- Inform if handler already exists.
	if recUI.lib.events[event][handlerName] then
		print(format("recUI: Attempt to register duplicate event handler - %s", handlerName))
		return
		
	-- Insert handler
	else
		recUI.lib.events[event][handlerName] = eventHandler
		return
	end
end
recUI.lib.unregisterEvent = function(event, handlerName)
	-- Inform on bad event.
	if not recUI.lib.events[event] then
		print(format("recUI: Attempt to unregister non-existant event - %s", event))
		return
		
	-- Inform on bad handler name.
	elseif not recUI.lib.events[event][handlerName] then
		print(format("recUI: Attempt to unregister non-existant event handler - %s", handerName))
		return
	else
		-- Remove handler
		recUI.lib.events[event][handlerName] = nil
		
		-- Remove event entry if final handler was removed.
		local remainingHandlers = #recUI.lib.events[event]
		if not(remainingHandlers) or (remainingHandlers == 0) then
			recUI.lib.events[event] = nil
		end
	end
end