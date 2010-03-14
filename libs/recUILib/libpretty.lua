local _, recUI = ...
local lib = recUI.lib

-- Source: Caellian
lib.prettyTime = function(seconds)
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

lib.prettyNumber = function(value)
	if value >= 1e6 then
		return ("%.1fm"):format(value / 1e6):gsub("%.?0+([km])$", "%1")
	elseif value >= 1e3 or value <= -1e3 then
		return ("%.1fk"):format(value / 1e3):gsub("%.?0+([km])$", "%1")
	else
		return value
	end
end

--[[lib.gradient = function(val, low, hi, reverse)
	local perc = (val - low)/(hi - low)
	if perc >= 1 then if reverse then return 1, 0, 0 else return 0, 1, 0 end elseif perc <= 0 then if reverse then return 0, 1, 0 else return 1, 0, 0 end end
	if reverse then return perc, 1+ (-1*perc), 0 else return 1+ (-1*perc), perc, 0 end
end--]]