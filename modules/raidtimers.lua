local _, recUI = ...
recUI.recBossTimers = {}
local recBossTimers = recUI.recBossTimers
local t = recUI.recBossTimers

recBossTimers.warning_frame = CreateFrame("Frame")
recBossTimers.warning_frame.warning_timer = 5
recBossTimers.warning_frame:SetWidth(500)
recBossTimers.warning_frame:SetHeight(50)
recBossTimers.warning_frame:SetPoint("CENTER", UIParent, "CENTER", 0, 50)

recBossTimers.warning_frame.warning_message = recBossTimers.warning_frame:CreateFontString(nil, "OVERLAY")
recBossTimers.warning_frame.warning_message:SetFont(recUI.media.font, 18, "OUTLINE")
recBossTimers.warning_frame.warning_message:SetPoint("CENTER")

recBossTimers.warning = function(self, message)
	if not message then return end
	
	self.warning_frame.warning_message:SetText(message)
	self.warning_frame.warning_timer = 5
	self.warning_frame:Show()
	self.warning_frame:SetScript("OnUpdate", function(self, elapsed)
		self.warning_timer = self.warning_timer - elapsed
		if self.warning_timer <= 0 then
			self:SetScript("OnUpdate", nil)
			self:Hide()
		end
	end)
end

recBossTimers.timers = {}

local function pretty_time(seconds)
	local hours		= floor(seconds / 3600)
	hours = (hours > 0) and format("%d:", hours) or ""
	local minutes	= floor(mod(seconds / 60, 60))
	minutes = ((minutes > 0) and (hours ~= "")) and format("%02d:", minutes) or format("%d:", minutes) or ""
	seconds	= floor(mod(seconds / 1, 60))
	seconds = ((seconds > 0) and (minutes ~= "")) and format("%02d", seconds) or format("%d", seconds)
	return format("%s%s%s", hours, minutes, seconds)
end

recBossTimers.cancel_timer = function(timer_name)
	if recBossTimers.timers[timer_name] then
		recBossTimers.timers[timer_name]:Hide()
	end
end

local function on_update(self, elapsed)
	self.update = self.update - elapsed
	
	if self.update > 0 then return end
	self.update = 0.01
	
	if self.expires >= GetTime() then
		self:SetValue(self.expires - GetTime())
		self:SetMinMaxValues(0, self.duration)
		self.lbl:SetText(format("%s - %s", self.timer_name, pretty_time(self.expires - GetTime())))
	else
		self:Hide()
	end
end

recBossTimers.create_timer = function(self, duration, timer_name, x_offset, y_offset, r, g, b, width, height, attach_point, relative_point, x_offset, y_offset)
	local timer
	if not recBossTimers.timers[timer_name] then
		timer = CreateFrame("StatusBar", format("RBT_%s", timer_name), UIParent)
		timer:SetHeight(10)
		timer:SetWidth(200)
		timer.timer_name = timer_name
		timer.active = true
		timer.duration = duration
		timer.expires = GetTime() + duration
		timer.update = 0
		
		timer.tx = timer:CreateTexture(nil, "ARTWORK")
		timer.tx:SetAllPoints()
		timer.tx:SetTexture(recUI.media.statusBar)
		timer.tx:SetVertexColor(1, 0, 0, 1)
		timer:SetStatusBarTexture(timer.tx)

		timer.soft_edge = CreateFrame("Frame", nil, timer)
		timer.soft_edge:SetPoint("TOPLEFT", -4, 3.5)
		timer.soft_edge:SetPoint("BOTTOMRIGHT", 4, -4)
		timer.soft_edge:SetBackdrop({
			bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
			edgeFile = [=[Interface\Addons\recUI\media\texture\glowtex]=], edgeSize = 4,
			insets = {left = 3, right = 3, top = 3, bottom = 3}
		})
		timer.soft_edge:SetFrameStrata("BACKGROUND")
		timer.soft_edge:SetBackdropColor(0.15, 0.15, 0.15, 1)
		timer.soft_edge:SetBackdropBorderColor(0, 0, 0)
	
		timer.bg = timer:CreateTexture(nil, "BORDER")
		timer.bg:SetPoint("TOPLEFT")
		timer.bg:SetPoint("BOTTOMRIGHT")
		timer.bg:SetTexture(recUI.media.statusBar)
		timer.bg:SetVertexColor(0.25, 0.25, 0.25, 1)
	
		timer.icon = timer:CreateTexture(nil, "BORDER")
		timer.icon:SetHeight(10)
		timer.icon:SetWidth(10)
		timer.icon:SetPoint("TOPRIGHT", timer, "TOPLEFT", 0, 0)
		timer.icon:SetTexture(nil)
		
		timer.lbl = timer:CreateFontString(nil, "OVERLAY")
		timer.lbl:SetFont(recUI.media.font, 8, "OUTLINE")
		timer.lbl:SetPoint("CENTER", timer, "CENTER", 0, 1)
		
		timer:SetPoint("CENTER", UIParent, "CENTER", x_offset, y_offset)
		
		timer:SetScript("OnUpdate", on_update)
		
		recBossTimers.timers[timer_name] = timer
	else
		timer = recBossTimers.timers[timer_name]
		timer.active = true
		timer.duration = duration
		timer.expires = GetTime() + duration
		timer.update = 0
	end
	
	timer:Show()
end


local event_frame = CreateFrame("Frame")
event_frame:RegisterEvent("LFG_PROPOSAL_SHOW")
event_frame:RegisterEvent("LFG_PROPOSAL_FAILED")
event_frame:RegisterEvent("LFG_UPDATE")
event_frame:SetScript("OnEvent", function(self, event, ...)
	if event == "LFG_PROPOSAL_SHOW" then
		recBossTimers:create_timer(40, "LFG Invitation", 0, 0)
	elseif event == "LFG_PROPOSAL_FAILED" then
		recBossTimers:cancel_timer("LFG Invitation")
	elseif event == "LFG_UPDATE" then
		local _, joined = GetLFGInfoServer()
		if not joined then
			recBossTimers:cancel_timer("LFG Invitation")
		end
	end
end)

-- malygos = 28859
-- This frame will not be here in final version.
local event_frame = CreateFrame("Frame")
event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
event_frame:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
event_frame:RegisterEvent("CHAT_MSG_MONSTER_YELL")

event_frame:SetScript("OnEvent", function(self, event, ...)
	if event == "CHAT_MSG_MONSTER_YELL" or "CHAT_MSG_RAID_BOSS_EMOTE" then
		local msg = select(1, ...)
		if not msg or type(msg) ~= "string" then return end -- grr
		if msg:find("My patience has reached its limit. I will be rid of you!") then
			recBossTimers:create_timer(615, "Enrage", 0, 17)
		end
		if msg:find("A Power Spark forms from a nearby rift!") then
			recBossTimers:warning("Spark")
			recBossTimers:create_timer(30, "Next Spark", 0, 30)
		end
		if msg:find("I had hoped to end your lives quickly") then
			recBossTimers:warning("PHASE 2")
		end
		if msg:find("Now your benefactors make their") then
			recBossTimers:warning("PHASE 3")
		end
		if msg:find("You will not succeed while I draw breath!") then
			recBossTimers:warning("Breath")
			recBossTimers:create_timer(59, "Next Breath", 0, 13)
		end
	end
	
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local timestamp, event, source_guid, source_name, source_flags, dest_guid, dest_name, dest_flags, spell_id, spell_name, spell_type = ...
		
		if event == "SPELL_CAST_SUCCESS" then
			if spell_id == 56105 then
				recBossTimers:create_timer(60, "Vortex CD", 0, 0)
				recBossTimers:create_timer(11, "Vortex", 0, 13)
			end
		end
		if event == "SPELL_AURA_APPLIED" then
		end
	end
end)

local lord_marrowgar = 36612
local coldflame_elapsed = 0
-- This frame will not be here in final version.
local event_frame = CreateFrame("Frame")
event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
-- enrage @ 600
event_frame:SetScript("OnEvent", function(self, event, ...)

--	if event == "CHAT_MSG_MONSTER_YELL" then
--		if select(1, ...) == "This meaningless exertion bores me. I'll incinerate you all from above!" then
--			recBossTimers:warning("PHASE 2")
--		end
--	end
	
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local timestamp, event, source_guid, source_name, source_flags, dest_guid, dest_name, dest_flags, spell_id, spell_name, spell_type = ...
		if event == "SPELL_CAST_START" then
			if spell_id == 69057 or spell_id == 70826 then
				recBossTimers:warning("Bone Spike")
				recBossTimers:create_timer(18, "Bone Spike CD", 0, 0)
			end
		elseif event == "SPELL_PERIODIC_DAMAGE" then
			if spell_id == 69146 or spell_id == 70823 or spell_id == 70824 or spell_id == 70825 then
				if dest_guid == UnitGUID("player") and GetTime() - coldflame_elapsed > 2 then
					recBossTimers:warning("COLDFLAME MOVE!")
					coldflame_elapsed = GetTime()
				end
			end
		elseif event == "SPELL_SUMMON" then
			if spell_id == 69062 or spell_id == 72669 or spell_id == 72670 then
				recBossTimers:warning("Impaled!")
			end
		elseif event == "SPELL_AURA_APPLIED" then
			if spell_id == 69076 then
				recBossTimers:warning("WHIRLWIND")
				recBossTimers:create_timer(90, "Whirlwind CD", 0, 0)
				recBossTimers:create_timer(20, "Whirlwind", 0, 0) -- 40s on heroic mode
				-- 10 normal, stop bonespike timer
			end
		elseif event == "SPELL_AURA_REMOVED" then
			if spell_id == 69065 then
				-- end ww
			end
			if spell_id == 69076 then
				-- 10 mornal, start bonespike again, every 15s
			end
		end
	end
end)

--function mod:OnCombatStart(delay)
--	timerWhirlwindCD:Start(45-delay)
--	timerBoneSpike:Start(15-delay)
--	berserkTimer:Start(-delay)
--end

---------------------------
--  Trash - Lower Spire  --
---------------------------
--
--L:SetWarningLocalization{
--	specWarnTrap		= "Trap Activated! - Deathbound Ward released"--creatureid 37007
--}
--L:SetOptionLocalization{
--	specWarnTrap		= "Show special warning for trap activation",
--	SetIconOnDarkReckoning	= DBM_CORE_AUTO_ICONS_OPTION_TEXrecBossTimers:format(69483),
--	SetIconOnDeathPlague	= DBM_CORE_AUTO_ICONS_OPTION_TEXrecBossTimers:format(72865)
--}
--L:SetMiscLocalization{
--	WarderTrap1		= "Who... goes there...?",
--	WarderTrap2		= "I... awaken!",
--	WarderTrap3		= "The master's sanctum has been disturbed!"
--}

-- ANUB'REKHAN
local anubrekhan = 15956
local combar_start
local f = CreateFrame("Frame")
f:RegisterEvent("UNIT_DIED")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
-- @90s on 10/91 on 25, first swarm

f:SetScript("OnEvent", function(self, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local timestamp, event, source_guid, source_name, source_flags, dest_guid, dest_name, dest_flags, spell_id, spell_name, spell_type = ...
		if event == "SPELL_CAST_START" then
			if spell_id == 28785 or spell_id == 54021 then
				recBossTimers:warning("Locust Swarm")
				recBossTimers:create_timer(26, "Locust Swarm", 0, 17)
				-- 25 man recBossTimers:create_timer(19, "Locust Swarm", 0, 17)
			end
		end
		if event == "SPELL_AURA_REMOVED" then
			if spell_id == 28785 or spell_id == 54021 then
				recBossTimers:cancel_timer("Locust Swarm")
				recBossTimers:create_timer(80, "Next Locust Swarm", 0, 34)
			end
		end
	end
end)

-- FAERLINA
local faerlina = 15953

local g = CreateFrame("Frame")
g:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
g:SetScript("OnEvent", function(self, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local timestamp, event, source_guid, source_name, source_flags, dest_guid, dest_name, dest_flags, spell_id, spell_name, spell_type = ...
		if event == "SPELL_CAST_SUCCESS" then
			if spell_id == 28732 or spell_id == 54097 then
				-- Widow's Embrace
				recBossTimers:create_timer(30, "Widow's Embrace", 0, 34)
				recBossTimers:warning("Embrace Active")
			end
		end
		if event == "SPELL_AURA_APPLIED" then
			if spell_id == 28798 or spell_id == 54100 then
				recBossTimers:warning("ENRAGED")
			end
		end
	end
end)

-- MAEXXNA
local maexxna = 15952
local h = CreateFrame("Frame")
h:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
h:SetScript("OnEvent", function(self, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local timestamp, event, source_guid, source_name, source_flags, dest_guid, dest_name, dest_flags, spell_id, spell_name, spell_type = ...
		if event == "SPELL_CAST_SUCCESS" then
			if spell_id == 29484 or spell_id == 54125 then
				-- Web Spray
				recBossTimers:warning("Web Spray")
				recBossTimers:cancel_timer("BABIES")
				recBossTimers:create_timer(30, "BABIES", 0, 34)
				recBossTimers:cancel_timer("Next Web Spray")
				recBossTimers:create_timer(40.5, "Next Web Spray", 0, 17)
				recBossTimers:warning("Embrace Active")
			end
		end
		if event == "SPELL_AURA_APPLIED" then
			if spell_id == 28622 then
				recBossTimers:warning("Web Wrap")
			end
		end
	end
end)


-- ONYXIA
local onyxia = 10184

-- This frame will not be here in final version.
local event_frame = CreateFrame("Frame")
event_frame:RegisterEvent("CHAT_MSG_MONSTER_YELL")
event_frame:RegisterEvent("UNIT_DIED")
event_frame:RegisterEvent("UNIT_HEALTH")
event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

event_frame:SetScript("OnEvent", function(self, event, ...)

	if event == "CHAT_MSG_MONSTER_YELL" then
		if select(1, ...) == "This meaningless exertion bores me. I'll incinerate you all from above!" then
			-- Start P2
			recBossTimers:warning("PHASE 2")
		elseif select(1, ...) == "It seems you'll need another lesson, mortals!" then
			-- Start P3
			recBossTimers:warning("PHASE 3")
		end
	end
	
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local timestamp, event, source_guid, source_name, source_flags, dest_guid, dest_name, dest_flags, spell_id, spell_name, spell_type = ...
		
		if event == "SPELL_CAST_START" then
			if spell_id == 68958 then
				recBossTimers:warning("Blast Nova")
			elseif spell_id == 17086 or spell_id == 18351 or spell_id == 18564 or spell_id == 18576 or spell_id == 18584 or spell_id == 18596 or spell_id == 18609 or spell_id == 18617 then -- Aparently there is a different id for each direction she faces.
				recBossTimers:warning("DEEP BREATH!")
				recBossTimers:create_timer(8, "Deep Breath", 0, 17)
				recBossTimers:create_timer(35, "Next Deep Breath", 0, 34)
			elseif spell_id == 18435 or spell_id == 68970 then
				recBossTimers:create_timer(20, "Next Flame Breath", 0, 51)
			end
		end
		
		-- Seriously, does this even need to be in here =/
		-- I mean if you're gettin tail swiped, you fail pretty bad.
		if event == "SPELL_DAMAGE" then
			if dest_guid == UnitGUID("player") and (spell_id == 68867 or spell_id == 69286) then
				recBossTimers:warning("Watch the tail!")
			end
		end
	end
end)


-- SARTHARION
local sartharion = 28860

-- This frame will not be here in final version.
local event_frame = CreateFrame("Frame")
event_frame:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
event_frame:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
-- tenebron, 30s
-- shadron, 80s
-- vesperon, 120s

event_frame:SetScript("OnEvent", function(self, event, ...)
	local msg = select(1, ...)

	if event == "CHAT_MSG_RAID_BOSS_EMOTE" or event == "CHAT_MSG_MONSTER_EMOTE" then
		if msg:find("The lava surrounding %s churns!") then
			recBossTimers:warning("Fire Wall")
			recBossTimers:create_timer(30, "Next Fire Wall", 0, 34)
			PlaySoundFile("Sound\\Spells\\PVPFlagTaken.wav")
		elseif msg:find("%s begins to open a Twilight Portal!") then
			if msg:find("Tenebron") then
				-- Whelps from this portal.
				recBossTimers:warning("Portal")
			--elseif msg:find("Vesperon") then
				-- No one goes into this portal anymore - warning needed?
				--recBossTimers:warning("Portal")
			elseif msg:find("Shadron") then
				-- Boss is immune during this portal.
				recBossTimers:warning("Portal")
				PlaySoundFile("Sound\\Spells\\PVPFlagTaken.wav")
			end
		end
	end
	
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local timestamp, event, source_guid, source_name, source_flags, dest_guid, dest_name, dest_flags, spell_id, spell_name, spell_type = ...
		if event == "SPELL_CAST_SUCCESS" then
			if spell_id == 57579 or spell_id == 59127 then
				-- Void zone created
				recBossTimers:warning("Void Zone")
				PlaySoundFile("Sound\\Spells\\PVPFlagTaken.wav")
				-- Void zone collapse
				recBossTimers:create_timer(5, "Void Zone Collapse", 0, 51)
			end
		end
	end
end)


-- This frame will not be here in final version.
--local event_frame = CreateFrame("Frame")
--event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

--event_frame:SetScript("OnEvent", function(self, event, ...)

--	if event == "CHAT_MSG_MONSTER_YELL" then
--		if select(1, ...) == "This meaningless exertion bores me. I'll incinerate you all from above!" then
--			recBossTimers:warning("PHASE 2")
--		end
--	end
	
--	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
--		local timestamp, event, source_guid, source_name, source_flags, dest_guid, dest_name, dest_flags, spell_id, spell_name, spell_type = ...
		
--		if event == "SPELL_CAST_START" then
--			if spell_id == 68958 then
--				recBossTimers:warning("Blast Nova")
--			elseif spell_id == 17086 or spell_id == 18351 or spell_id == 18564 or spell_id == 18576 or spell_id == 18584 or spell_id == 18596 or spell_id == 18609 or spell_id == 18617 then -- Aparently there is a different id for each direction she faces.
--				recBossTimers:warning("DEEP BREATH!")
--				recBossTimers:create_timer(8, "Deep Breath", 0, 17)
--			end
--		end
--	end
--end)


-- This frame will not be here in final version.
--local event_frame = CreateFrame("Frame")
--event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

--event_frame:SetScript("OnEvent", function(self, event, ...)

--	if event == "CHAT_MSG_MONSTER_YELL" then
--		if select(1, ...) == "This meaningless exertion bores me. I'll incinerate you all from above!" then
--			recBossTimers:warning("PHASE 2")
--		end
--	end
	
--	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
--		local timestamp, event, source_guid, source_name, source_flags, dest_guid, dest_name, dest_flags, spell_id, spell_name, spell_type = ...
		
--		if event == "SPELL_CAST_START" then
--			if spell_id == 68958 then
--				recBossTimers:warning("Blast Nova")
--			elseif spell_id == 17086 or spell_id == 18351 or spell_id == 18564 or spell_id == 18576 or spell_id == 18584 or spell_id == 18596 or spell_id == 18609 or spell_id == 18617 then -- Aparently there is a different id for each direction she faces.
--				recBossTimers:warning("DEEP BREATH!")
--				recBossTimers:create_timer(8, "Deep Breath", 0, 17)
--			end
--		end
--	end
--end)


-- FLAME LEVIATHAN
local event_frame = CreateFrame("Frame")
event_frame:RegisterEvent("CHAT_MSG_MONSTER_YELL")
event_frame:RegisterEvent("CHAT_MSG_MONSTER_SAY")

event_frame:SetScript("OnEvent", function(self, event, ...)

	if event == "CHAT_MSG_MONSTER_YELL" or event == "CHAT_MSG_MONSTER_SAY" then
		if select(1, ...) == "Hostile entities detected. Threat assessment protocol active. Primary target engaged. Time minus 30 seconds to re-evaluation." then
			event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
	end
	
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local timestamp, event, source_guid, source_name, source_flags, dest_guid, dest_name, dest_flags, spell_id, spell_name, spell_type = ...
		if event == "SPELL_SUMMON" and spell_id == 62907 then
			recBossTimers:warning("Ward of Life spawned")
			
		elseif event == "SPELL_AURA_APPLIED" then
			if spell_id == 62396 then
				recBossTimers:create_timer(10, "Flame Vents", 0, 17)
			elseif spell_id == 62475 then
				recBossTimers:warning("System Overload")
				recBossTimers:create_timer(20, "System Overload", 0, 34)
			elseif spell_id == 62374 then
				if dest_guid == UnitGUID("player") then
					recBossTimers:warning("PURSUING YOU!")
				else
					recBossTimers:warning("Pursuing: "..dest_name)
				end
				recBossTimers:create_timer(30, "Next Pursuit", 0, 0)
			elseif spell_id == 62297 then
				recBossTimers:warning("Hodir's Fury: "..dest_name)
			end
			
		elseif event == "SPELL_AURA_REMOVED" and spell_id == 62396 then
			recBossTimers:cancel_timer("Flame Vents")
		end
	end
end)

-- IGNIS
--[[
local mod	= DBM:NewMod("Ignis", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2516 $"):sub(12, -3))
mod:SetCreatureID(33118)
mod:SetUsedIcons(8)

mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_CAST_SUCCESS"
)

local announceSlagPot			= mod:NewAnnounce("WarningSlagPot", 3, 63477)

local warnFlameJetsCast			= mod:NewSpecialWarning("SpecWarnJetsCast")

local timerFlameJetsCast		= mod:NewCastTimer(2.7, 63472)
local timerFlameJetsCooldown	= mod:NewCDTimer(35, 63472)
local timerScorchCooldown		= mod:NewNextTimer(25, 63473)
local timerScorchCast			= mod:NewCastTimer(3, 63473)
local timerSlagPot				= mod:NewTargetTimer(10, 63477)
local timerAchieve				= mod:NewAchievementTimer(240, 2930, "TimerSpeedKill")

mod:AddBoolOption("SlagPotIcon")

function mod:OnCombatStart(delay)
	timerAchieve:Start()
	timerScorchCooldown:Start(12-delay)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(62680, 63472) then		-- Flame Jets
		timerFlameJetsCasrecBossTimers:Start()
		warnFlameJetsCasrecBossTimers:Show()
		timerFlameJetsCooldown:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(62548, 63474) then	-- Scorch
		timerScorchCasrecBossTimers:Start()
		timerScorchCooldown:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(62717, 63477) then		-- Slag Pot
		announceSlagPorecBossTimers:Show(args.destName)
		timerSlagPorecBossTimers:Start(args.destName)
		if self.Options.SlagPotIcon then
			self:SetIcon(args.destName, 8, 10)
		end
	end
end--]]