-------------------
-- EVENT HANDLER --
-------------------
local _, recUI = ...
local lib = recUI.lib
local eventFrame = lib.frame

local events = {}
eventFrame:SetScript("OnEvent", function(self, event, ...)
	-- If no handlers are assigned, bail.
	if not events[event] then
		print(format("recUI: Unhandled event - %s", event))
		return
	end
	
	-- Call each event handler.
	for _, eventHandler in pairs(events[event]) do
		eventHandler(self, event, ...)
	end
end)
lib.registerEvent = function(event, handlerName, eventHandler)
	-- Create this event in our handler table if it doesn't exist yet.
	if not events[event] then
		events[event] = {}
	end
	
	-- Inform if handler already exists.
	if events[event][handlerName] then
		print(format("recUI: Attempt to register duplicate event handler - %s", handlerName))
		return
		
	-- Insert handler
	else
		eventFrame:RegisterEvent(event)
		events[event][handlerName] = eventHandler
		return
	end
end
lib.unregisterEvent = function(event, handlerName)
	-- Unregister all events if requested
	-- TODO: test...
	if event == "all" then
		for event, handlers in pairs(events) do
			for handler, _ in pairs(handlers) do
				if handler == handlerName then
					lib.unregisterEvent(event, handler)
				end
			end
		end
		return
	end
	
	-- Inform on bad event.
	if not events[event] then
		print(format("recUI: Attempt to unregister non-existant event - %s", event))
		return
		
	-- Inform on bad handler name.
	elseif not events[event][handlerName] then
		print(format("recUI: Attempt to unregister non-existant event handler - %s", handerName))
		return
	else
		-- Remove handler
		events[event][handlerName] = nil
		
		-- Remove event entry if final handler was removed.
		local numHandlers = 0
		for k,v in pairs(events[event]) do
			numHandlers = numHandlers + 1
		end
		if numHandlers == 0 then
			eventFrame:UnregisterEvent(event)
			events[event] = nil
		end
	end
end

lib.status.libevents = function()
	local numEvents = 0
	local numHandlers = 0
	for k,v in pairs(events) do
		numEvents = numEvents + 1
		for f,b in pairs(v) do
			numHandlers = numHandlers + 1
		end
	end
	print(format("recUILib is handling %d events with %d handlers.", numEvents, numHandlers))
end
