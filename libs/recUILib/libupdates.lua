--------------------
-- UPDATE HANDLER --
--------------------
local _, recUI = ...
local lib = recUI.lib
local updateFrame = lib.frame

local scheduledUpdates = {}
local onUpdate = function(self, elapsed)
	-- For every scheduled update...
	for _, scheduledUpdate in pairs(scheduledUpdates) do
		-- Increment updater
		scheduledUpdate.elapsed = scheduledUpdate.elapsed + elapsed

		-- See if we need to fire this onUpdate.
		if scheduledUpdate.elapsed >= scheduledUpdate.frequency then
			-- Reset elapsed timer.
			scheduledUpdate.elapsed = 0

			-- Run onUpdate func
			scheduledUpdate.onUpdate(scheduledUpdate.frame)
		end
	end
end


lib.scheduleUpdate = function(updateName, updateFrequency, updateHandler, selfFrame)
	-- Inform on duplicate updater
	if scheduledUpdates[updateName] then
		print(format("recUI: Attempt to schedule duplicate update - %s", updateName))
		return

	else
		-- Add updater to list
		scheduledUpdates[updateName] = {}
		scheduledUpdates[updateName].onUpdate = updateHandler
		scheduledUpdates[updateName].elapsed = 0
		scheduledUpdates[updateName].frequency = updateFrequency
		scheduledUpdates[updateName].frame = selfFrame

		-- Ensure updates are firing.
		updateFrame:SetScript("OnUpdate", onUpdate)
	end
end


lib.unscheduleUpdate = function(updateName)
	-- Inform on bad removal
	if not scheduledUpdates[updateName] then
		print(format("recUI: Attempt to unschedule update - %s", updateName))
		return
	else
		-- Remove update
		scheduledUpdates[updateName] = nil

		-- Stop updating if there are no scheduled updates.
		local numUpdates = 0
		for k,v in pairs(scheduledUpdates) do
			numUpdates = numUpdates + 1
		end
		if numUpdates == 0 then
			updateFrame:SetScript("OnUpdate", nil)
		end
	end
end

lib.status.libupdates = function()
	local numOnUpdates = 0
	for k,v in pairs(scheduledUpdates) do
		numOnUpdates = numOnUpdates + 1
	end
	print(format("recUILib is processing %d OnUpdate scripts.", numOnUpdates))
end
