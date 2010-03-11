local _, recUI = ...
local recycle_bin = {}

local function Recycler(trash_table)
	if trash_table then
		-- Recycle trash_table
		for k,v in pairs(trash_table) do
			if type(v) == "table" then
				Recycler(v)
			end
			trash_table[k] = nil
		end
		recycle_bin[(#recycle_bin or 0) + 1] = trash_table
	else
		-- Return recycled table, or new table if there are no used ones to give.
		if #recycle_bin and #recycle_bin > 0 then
			return table.remove(recycle_bin, 1)
		else
			return {}
		end
	end
end

old_data = Recycler()
new_data = Recycler()

local update_in_progress = false
local update_pause = CreateFrame("Frame")

local function deepcopy(table_to_copy)
    local lookup_table = Recycler()
    local function _copy(table_to_copy)
        if type(table_to_copy) ~= "table" then
            return table_to_copy
        elseif lookup_table[table_to_copy] then
            return lookup_table[table_to_copy]
        end
        local new_table = Recycler()
        lookup_table[table_to_copy] = new_table
        for index, value in pairs(table_to_copy) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(table_to_copy))
    end
    return _copy(table_to_copy)
end

local QuestCompleted = ERR_QUEST_OBJECTIVE_COMPLETE_S
local ObjCompPattern = QuestCompleted:gsub("[()]", "%%%1"):gsub("%%s", "(%.%-)")
local UIErrorsFrame_OldOnEvent = UIErrorsFrame:GetScript("OnEvent")
UIErrorsFrame:SetScript("OnEvent", function(self, event, msg, ...)
	if event == "UI_INFO_MESSAGE" then
		if msg:find("(.-): (.-)/(.+)") or msg:find(ObjCompPattern) or msg:find("Objective Complete.") then
			return
		end
	end

	return UIErrorsFrame_OldOnEvent(self, event, msg, ...)
end)

-- Storage for a quest after it has been reported complete.
local quest_reported = nil

local function CheckForProgress()
	-- Loop through our new_data table, gathering data until we get to an objective.
	local current_zone, current_quest, current_quest_name, current_quest_done, current_objective_name, current_objective_num, current_objective_total, current_objective_done, current_quest_reported
	for line_index, line_data in ipairs(new_data) do

		if line_data.line_type == "zone" then
			-- Save data we will need.  This is very important.
			current_zone = line_data.name

		elseif line_data.line_type == "quest" then
			-- Save data we will need.  This is very important.
			current_quest = line_data.id
			current_quest_name = line_data.name
			current_quest_done = line_data.complete
			-- Flag to prevent duplicate reports of compelted quests.
			if current_quest == quest_reported then
				current_quest_reported = true
			else
				current_quest_reported = false
			end

			-- Check if the next entry is an objective.  If not, then we need to directly check the quest
			-- for completion.
			if new_data[line_index + 1] and new_data[line_index + 1].line_type ~= "objective" then
				-- This quest has no objectives, so we need to just go ahead and check if the quest is done and was not before here.

				local old_zone_matched, old_quest_matched, old_quest_done
				for old_line_index, old_line_data in ipairs(old_data) do
					if old_line_data.line_type == "zone" then
						if old_line_data.name == current_zone then
							old_zone_matched = true
							-- New zone found, cancel matching quest/objective if they were set.
							old_quest_matched = false
							old_objective_matched = false
						else
							old_zone_matched = false
						end

					elseif old_line_data.line_type == "quest" then
						if old_line_data.complete then
							old_quest_done = true
						else
							old_quest_done = false
						end
						if old_line_data.id == current_quest then
							old_quest_matched = true
							-- New quest found, cancel matching objective if it was set.
							old_objective_matched = false
						else
							old_quest_matched = false
						end
					end

					-- If we have a zone, quest, and objective match, then we can compare the two to see what may have changed.
					if old_quest_matched and old_zone_matched then
						-- We use elseifs here so that we don't get 3 messages for finishing the last objective for a quest completion.
						-- If quest complete, then only show that
						-- If quest was not complete but the objective was, then show only that.
						-- If quest and objective were not complete, then show cur/tot for objective.
						if not (quest_reported == current_quest) and current_quest_done and not old_quest_done then
							-- Save flag for this quest to ensure we do not report it again.
							quest_reported = current_quest
							-- print(string.format("Completed quest. %s - %s", current_zone, current_quest_name))
							RaidNotice_AddMessage(RaidWarningFrame, string.format("%s Complete", current_quest_name), ChatTypeInfo["SYSTEM"])
							PlaySoundFile([[Sound\Creature\Peon\PeonBuildingComplete1.wav]])
						end
					end
				end
			end

		elseif line_data.line_type == "objective" then
			-- Save some data we might need (these are not 'necessary', but to emphasize that these values will be used
			current_objective_name  = line_data.name
			current_objective_num   = line_data.num
			current_objective_total = line_data.total
			current_objective_done  = line_data.done

			-- We have an objective, so we need to find out if that objective matches anything in our old_data table.
			local old_zone_matched, old_quest_matched, old_objective_matched, old_quest_done
			for old_line_index, old_line_data in ipairs(old_data) do
				if old_line_data.line_type == "zone" then
					if old_line_data.name == current_zone then
						old_zone_matched = true
						-- New zone found, cancel matching quest/objective if they were set.
						old_quest_matched     = false
						old_objective_matched = false
					else
						old_zone_matched = false
					end

				elseif old_line_data.line_type == "quest" then
					if old_line_data.complete then
						old_quest_done = true
					else
						old_quest_done = false
					end
					if old_line_data.id == current_quest then
						old_quest_matched = true
						-- New quest found, cancel matching objective if it was set.
						old_objective_matched = false
					else
						old_quest_matched = false
					end

				elseif old_line_data.line_type == "objective" then
					if old_line_data.name == current_objective_name then
						old_objective_matched = true
					else
						old_objective_matched = false
					end
				end

				-- If we have a zone, quest, and objective match, then we can compare the two to see what may have changed.
				if old_objective_matched and old_quest_matched and old_zone_matched then
					-- We use elseifs here so that we don't get 3 messages for finishing the last objective for a quest completion.
					-- If quest complete, then only show that
					-- If quest was not complete but the objective was, then show only that.
					-- If quest and objective were not complete, then show cur/tot for objective.
					if not (quest_reported == current_quest) and current_quest_done and not old_quest_done then
						-- Save flag for this quest to ensure we do not report it again.
						quest_reported = current_quest
						-- print(string.format("Completed quest. %s - %s", current_zone, current_quest_name))
						RaidNotice_AddMessage(RaidWarningFrame, string.format("%s Complete", current_quest_name), ChatTypeInfo["SYSTEM"])
						PlaySoundFile([[Sound\Creature\Peon\PeonBuildingComplete1.wav]])
					elseif not (quest_reported == current_quest) and current_objective_done and not old_line_data.done then
						-- print(string.format("Completed objective. %s - %s - %s", current_zone, current_quest_name, current_objective_name))
						RaidNotice_AddMessage(RaidWarningFrame, string.format("%s Complete", current_objective_name), ChatTypeInfo["SYSTEM"])
						PlaySoundFile([[Sound\Creature\Peon\PeonReady1.wav]])
						-- > 0 is a cheap hack for blocking output at quest turnin/abandon
					elseif not (quest_reported == current_quest) and current_objective_num and old_line_data.num and tonumber(current_objective_num) > 0 and tonumber(current_objective_num) ~= tonumber(old_line_data.num) then
						-- print(string.format("Objective progress. %s - %s - %s - %s/%s", current_zone, current_quest_name, current_objective_name, current_objective_num, current_objective_total))
						RaidNotice_AddMessage(RaidWarningFrame, string.format("%s: %s/%s", current_objective_name, current_objective_num, current_objective_total), ChatTypeInfo["SYSTEM"])
					end
				end
			end
		end
	end
end

local function UpdateQuestLog()	
	-- If we need to wait, then turn on our update pause timer
	if update_in_progress then return update_pause:Show() end

	-- prevent more updates from running until we are done with this update
	update_in_progress = true

	Recycler(new_data)
	new_data = Recycler()

	-- Parse the entire quest log for current data.
	-- Save all the data to the new_data table
    local selection_id = GetQuestLogSelection()
    local num_entries, num_quests = GetNumQuestLogEntries()
    local current_header

    local line_index = 0
    if num_entries > 0 then
        for quest_index = 1, num_entries do
            local name, level, tag, group, header, collapsed, complete, daily = GetQuestLogTitle(quest_index)

            if header then
                line_index = line_index + 1
                if not new_data[line_index] then
                    new_data[line_index] = Recycler()
                end
                -- Short reference
                local h = new_data[line_index]
                h.name      = name
                h.line_type = "zone"
            else
                line_index = line_index + 1
                local quest_id = tonumber(string.match(GetQuestLink(quest_index), "quest:(%d+)"))
                if not new_data[line_index] then
                    new_data[line_index] = Recycler()
                end
                -- Short reference
                local q = new_data[line_index]
                q.index     = quest_index
                q.id        = quest_id
                q.name      = name
                q.level     = level
                q.complete  = complete
                q.line_type = "quest"

                local num_objectives = GetNumQuestLeaderBoards(quest_index)
                if num_objectives and num_objectives > 0 then
                    for o = 1, num_objectives do
                        line_index = line_index + 1
                        local name, _, done = GetQuestLogLeaderBoard(o, quest_index)
                        local _, _, o_name, o_num, o_total = string.find(name, "(.*):%s*([%d]+)%s*/%s*([%d]+)")
                        if not new_data[line_index] then
                            new_data[line_index] = Recycler()
                        end
                        -- Short reference
                        local o = new_data[line_index]
                        o.name      = o_name or name
                        o.num       = o_num
                        o.total     = o_total
                        o.line_type = "objective"
                        o.done      = done and true or false
                    end
                end
            end
        end
    end

    if old_data then
    	-- If we have an old_data table, then check it against the new data to determine quest progress
    	CheckForProgress()
    end

	Recycler(old_data)
    old_data = deepcopy(new_data)

	-- Turn off flag to allow more updates to run
	update_in_progress = false

end

-- Check if updating is done every .5 seconds
local time_to_update = 0.5

local function CheckUpdate(self, elapsed)

	time_to_update = time_to_update - elapsed

	if time_to_update <= 0 then

		-- Reset timer duration
		time_to_update = 0.5

		if update_in_progress then

			-- Wait another .5 seconds and check again
			return

		else

			-- Hide frame to stop updating
			self:Hide()

			-- Attempt to update
			UpdateQuestLog()

		end
	end
end

-- Hide frame so it does not run it's onupdate
-- This gets shown if a QLU event fires before the previous QLU has finished processing its data.
update_pause:Hide()
update_pause:SetScript("OnUpdate", CheckUpdate)
-- Our event to check for quest progress on.
update_pause:SetScript("OnEvent", UpdateQuestLog)
update_pause:RegisterEvent("QUEST_LOG_UPDATE")