-------------------
-- EVENT HANDLER --
-------------------
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