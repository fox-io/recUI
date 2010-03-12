local _, recUI = ...
-- Options.  Set to true or false.
local load_report	= true	-- Show a report when logging in?
local hide_bliz		= true	-- Hide Blizzard default skill gain messages?
local summary		= true	-- Prepend node list with skill text? ie: 'Herbalism: 235/300'
local hide_max		= true	-- Stop reporting when skill is maxed? (450+)
local train_max		= true	-- Warn when training is required?
local train_avail	= true	-- Warn when training can be learned?
-- End Options

local db = {
	['colors'] = {
		'808080',	-- 1 Grey
		'40C040',	-- 2 Green
		'FFFF00',	-- 3 Yellow
		'FF8019',	-- 4 Orange
		'FF1919'	-- 5 Red
	},
	-- Values may differentiate from in-game values.
	['Skinning'] = true,
	['Fishing']  = true,
	['Cooking']  = true,
	['First Aid'] = {
		{'Linen Bandage',               1,  30,  45,  60},
		{'Heavy Linen Bandage',        40,  50,  75, 100},
		{'Wool Bandage',               80,  80, 115, 150},
		{'Heavy Wool Bandage',        115, 115, 150, 185},
		{'Silk Bandage',              150, 150, 180, 210},
		{'Heavy Silk Bandage',        180, 180, 210, 240},
		{'Mageweave Bandage',         210, 210, 240, 270},
		{'Heavy Mageweave Bandage',   240, 240, 270, 300},
		{'Runecloth Bandage',         260, 260, 290, 320},
		{'Heavy Runecloth Bandage',   290, 290, 320, 350},
		{'Netherweave Bandage',       330, 330, 347, 365},
		{'Heavy Netherweave Bandage', 360, 360, 367, 375},
		{'Frostweave Bandage',        350, 375, 392, 410},
		{'Heavy Frostweave Bandage',  400, 400, 430, 470},
	},
	['Mining'] = {
		{'Copper Vein',				  1,  25,  47, 100},
		{'Tin Vein',				 65,  90, 115, 165},
		{'Silver Vein',				 75, 100, 125, 175},
		{'Iron Vein',				125, 150, 175, 225},
		{'Gold Vein',				155, 175, 205, 255},
		{'Mithril Deposit',			175, 200, 225, 275},
		{'Truesilver Deposit',		230, 255, 280, 330},
		{'Small Thorium Vein',		245, 270, 295, 345},
		{'Rich Thorium Vein',		275, 300, 325, 350},
		{'Fel Iron Vein',			275, 325, 350, 375}, -- Changed to 275 at some point.
		{'Adamantite Vein',			325, 350, 375, 400},
		{'Rich Adamantite Vein',	350, 375, 400, 450},
		{'Cobalt Deposit',			350, 375, 400, 425},
		{'Khorium Vein',			375, 400, 425, 450}, -- 450
		{'Rich Cobalt Deposit',		375, 400, 425, 450},
		{'Saronite Deposit',		400, 425, 450, 475}, -- 475
		{'Rich Saronite Deposit',	425, 450, 475, 500}, -- 475 500
		{'Pure Saronite Deposit',	450, 475, 500, 525}, -- 475 500 525
		{'Titanium Deposit',		450, 475, 500, 525}, -- 475 500 525
	},
	['Herbalism'] = {
		{'Peacebloom', 				  1,  25,  50, 100},
		{'Silverleaf', 				  1,  25,  50, 100},
		{'Bloodthistle', 			  1,  25,  50, 100},
		{'Earthroot', 				 15,  40,  65, 115},
		{'Mageroyal', 				 50,  75, 100, 150},
		{'Briarthorn', 				 70,  95, 120, 170},
		{'Stranglekelp', 			 85, 110, 135, 185},
		{'Bruiseweed', 				100, 125, 150, 200},
		{'Wild Steelbloom', 		115, 140, 165, 215},
		{'Grave Moss', 				120, 150, 170, 220},
		{'Kingsblood', 				125, 155, 175, 225},
		{'Liferoot', 				150, 175, 200, 250},
		{'Fadeleaf', 				160, 185, 210, 260},
		{'Goldthorn', 				170, 195, 220, 270},
		{'Khadgar\'s Whisker',		185, 210, 235, 285},
		{'Wintersbite', 			195, 225, 245, 295},
		{'Firebloom', 				205, 230, 255, 305},
		{'Purple Lotus', 			210, 235, 260, 310},
		{'Arthas\' Tears', 			220, 250, 270, 320},
		{'Sungrass', 				230, 255, 280, 330},
		{'Blindweed', 				235, 260, 285, 335},
		{'Ghost Mushroom', 			245, 270, 295, 345},
		{'Gromsblood', 				250, 275, 300, 350},
		{'Golden Sansam', 			260, 280, 310, 360},
		{'Dreamfoil', 				270, 295, 320, 370},
		{'Mountain Silversage',		280, 310, 330, 380},
		{'Plaguebloom',				285, 314, 335, 385},
		{'Icecap', 					290, 315, 340, 390},
		{'Black Lotus', 			300, 325, 350, 400}, -- 325 350
		{'Felweed', 				300, 325, 350, 400},
		{'Dreaming Glory', 			315, 340, 365, 415},
		{'Ragveil', 				325, 350, 400, 425}, -- 400
		{'Flame Cap', 				335, 360, 390, 435}, -- 390
		{'Terocone', 				325, 350, 375, 400}, -- 375 400
		{'Ancient Lichen', 			340, 375, 400, 440}, -- 375 400
		{'Netherbloom', 			350, 375, 400, 450}, -- 400
		{'Netherdust Bush', 		350, 394, 401, 450},
		{'Nightmare Vine', 			365, 390, 419, 465},
		{'Mana Thistle', 			375, 415, 425, 475},
		{'Goldclover', 				350, 380, 420, 450}, -- 450
		{'Firethorn', 				360, 385, 415, 460}, -- 415 460
		{'Tiger Lily', 				375, 415, 450, 475}, -- 415 450 475
		{'Talandra\'s Rose', 		385, 425, 460, 485}, -- 425 460 485
		{'Frozen Herb', 			405, 425, 460, 500}, -- 460
		{'Adder\'s Tongue', 		400, 430, 460, 500}, -- 430 460 500
		{'Lichbloom', 				425, 450, 480, 525}, -- 450 480
		{'Icethorn', 				435, 475, 500, 535}, -- 475 500
		{'Frost Lotus', 			450, 480, 515, 550}  -- 480 515 550
	},
	
}

local function Report(skill_to_update)
	-- We do this, rather than parse the event text, because we need to obtain the max as well.
	for skill_index = 1, GetNumSkillLines() do
  		local name, _, _, rank, _, _, max_rank = GetSkillLineInfo(skill_index)
		if name == skill_to_update then

			-- Show report if we are capped?
			if rank >= 450 and rank == max_rank and hide_max then return end

			-- Show warning that training is required?
			if rank <= 449 and rank == max_rank and train_max then
				print(string.format('|cFF6060FF%s: Training Required!|r', skill_to_update))
			end

			-- Show warning that training is available?
			if rank <= 424 and rank >= (max_rank - 25) and rank < max_rank and train_avail then
				print(string.format('|cFF6060FF%s: Training Available!|r', skill_to_update))
			end

			-- Show 'Skill: 123/456' summary?
  			local report = summary and string.format('|cFF6060FF%s: %s/%s|r ', skill_to_update, rank, max_rank) or ''

  			-- Create node difficulty list.
			if skill_to_update == 'Skinning' then
				local max_mob_level
				if rank <= 100 then
					max_mob_level = floor((rank/10)+10)
				else
					max_mob_level = floor(rank/5)
				end
				report = string.format('%s |cFF%sUp to level %s|r', report, db['colors'][4], max_mob_level)
			elseif skill_to_update == 'Fishing' or skill_to_update == 'Cooking' then
				-- ??
			else
				local red_out, green_out
				for i=1, #db[skill_to_update] do
					local output
					for j=1,4 do
						if not output and rank < db[skill_to_update][i][j+1] then
							if not red_out then
								report = string.format('%s%s|cFF%s%s|r%s', report, green_out and ', ' or '', db['colors'][6-j], db[skill_to_update][i][1], j == 1 and string.format('|cFF6060FF(%s)|r', db[skill_to_update][i][2]) or '')
								output = true; green_out = true
								if j == 1 then red_out = true end
							end
						end
					end
				end
  			end

  			-- Show the report.
  			print(report)
  		end
	end
end

local function RequestReport(self, event, message)
	if event == 'PLAYER_ALIVE' then
		recUI.lib.unregisterEvent('PLAYER_ALIVE', "recUIProfessions")
	end
	for skill, _ in pairs(db) do
		if skill ~= 'color' and (((event == 'PLAYER_ALIVE' and load_report) or (not message) or (message and string.find(message, skill)))) then
			Report(skill)
		end
	end
	return hide_bliz
end

recUI.lib.registerEvent("PLAYER_ALIVE", "recUIProfessions", RequestReport)

ChatFrame_AddMessageEventFilter('CHAT_MSG_SKILL', RequestReport)

SLASH_RECSKILLUPS1 = '/skillups'
SLASH_RECSKILLUPS2 = '/su'
SlashCmdList.RECSKILLUPS = RequestReport