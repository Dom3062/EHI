if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

local EHI = EHI
if EHI._hooks.DigitalGui then
	return
else
	EHI._hooks.DigitalGui = true
end
local original =
{
    init = DigitalGui.init,
	timer_start_count_down = DigitalGui.timer_start_count_down,
	timer_pause = DigitalGui.timer_pause,
	timer_resume = DigitalGui.timer_resume,
	_timer_stop = DigitalGui._timer_stop,
	set_visible = DigitalGui.set_visible,
	timer_set = DigitalGui.timer_set
}
local level_id = Global.game_settings.level_id
local ignore = {}
local icons = {}
local remove = {}
local class = {}
if level_id == "hvh" then -- Cursed Kill Room
	ignore =
	{
		-- Clocks
		[100007] = true,
		[100888] = true,
		[100889] = true,
		[100891] = true,
		[100892] = true,
		[100176] = true,
		[100177] = true,
		[100029] = true,

		-- Vault timers
		[EHI:GetInstanceUnitID(100027, 9794)] = true,
		[EHI:GetInstanceUnitID(100028, 9794)] = true,
		[EHI:GetInstanceUnitID(100027, 10294)] = true,
		[EHI:GetInstanceUnitID(100028, 10294)] = true,
		[EHI:GetInstanceUnitID(100027, 10794)] = true,
		[EHI:GetInstanceUnitID(100028, 10794)] = true,
		[EHI:GetInstanceUnitID(100027, 11294)] = true,
		[EHI:GetInstanceUnitID(100028, 11294)] = true,
		[EHI:GetInstanceUnitID(100027, 11794)] = true,
		[EHI:GetInstanceUnitID(100028, 11794)] = true
	}
	icons =
	{
		-- Clock
		[100878] = { "faster" },

		-- Vault timer
		[EHI:GetInstanceUnitID(100029, 9794)] = { EHI.Icons.Vault },
		[EHI:GetInstanceUnitID(100029, 10294)] = { EHI.Icons.Vault },
		[EHI:GetInstanceUnitID(100029, 10794)] = { EHI.Icons.Vault },
		[EHI:GetInstanceUnitID(100029, 11294)] = { EHI.Icons.Vault },
		[EHI:GetInstanceUnitID(100029, 11794)] = { EHI.Icons.Vault }
	}
elseif level_id == "mus" then -- The Diamond
	remove =
	{
		[133922] = true -- Path time lock in the The Diamond chamber
	}
elseif level_id == "hox_3" then -- Hoxton Revenge
	local alarm_box = EHI:GetInstanceUnitID(100021, 9685) -- Alarm Box
	remove =
	{
		[alarm_box] = true
	}
	class =
	{
		[alarm_box] = "EHIWarningTracker"
	}
elseif level_id == "nail" then -- Lab Rats
	ignore =
	{
		[EHI:GetInstanceUnitID(100014, 5020)] = true,
		[EHI:GetInstanceUnitID(100056, 5020)] = true,
		[EHI:GetInstanceUnitID(100226, 5020)] = true
	}
	icons =
	{
		[EHI:GetInstanceUnitID(100227, 5020)] = { EHI.Icons.Vault }
	}
	remove =
	{
		[EHI:GetInstanceUnitID(100227, 5020)] = true
	}
elseif level_id == "big" then -- The Big Bank
	ignore =
	{
		[101457] = true
	}
	icons =
	{
		[104671] = { "faster" }
	}
elseif level_id == "kenaz" then -- Golden Grin Casino
	icons =
	{
		[EHI:GetInstanceUnitID(100000, 37575)] = { "pd2_drill" },
		[EHI:GetInstanceUnitID(100000, 44535)] = { "pd2_drill" }
	}
elseif level_id == "help" then -- Prison Nightmare
	ignore =
	{
		[400003] = true
	}
	icons =
	{
		[EHI:GetInstanceUnitID(100072, 12400)] = { "faster" }
	}
	class =
	{
		[EHI:GetInstanceUnitID(100072, 12400)] = "EHIWarningTracker"
	}
elseif level_id == "chas" then -- Dragon Heist
	ignore =
	{
		[EHI:GetInstanceUnitID(100053, 8350)] = true,
		[EHI:GetInstanceUnitID(100054, 8350)] = true
	}
	icons =
	{
		[EHI:GetInstanceUnitID(100057, 8350)] = { "pd2_c4" }
	}
elseif level_id == "cane" then -- Santa's Workshop
	-- OVK decided to use one timer for fire and fire recharge
	-- This class ignores them and that timer is implemented
	-- in ElementTimerOperator.lua
	ignore =
	{
		[EHI:GetInstanceUnitID(100002, 0)] = true,
		[EHI:GetInstanceUnitID(100002, 120)] = true,
		[EHI:GetInstanceUnitID(100002, 240)] = true,
		[EHI:GetInstanceUnitID(100002, 360)] = true,
		[EHI:GetInstanceUnitID(100002, 480)] = true,

		-- Safe Event
		[EHI:GetInstanceUnitID(100056, 11300)] = true,
		[EHI:GetInstanceUnitID(100226, 11300)] = true,
		[EHI:GetInstanceUnitID(100227, 11300)] = true
	}
	icons =
	{
		-- Safe Event
		[EHI:GetInstanceUnitID(100014, 11300)] = { EHI.Icons.Vault }
	}
	remove =
	{
		-- Safe Event
		[EHI:GetInstanceUnitID(100014, 11300)] = true
	}
elseif level_id == "shoutout_raid" then -- Meltdown
	ignore =
	{
		[EHI:GetInstanceUnitID(100014, 2850)] = true
	}
end

function DigitalGui:init(unit)
    original.init(self, unit)
    self._ehi_key = tostring(unit:key())
end

function DigitalGui:timer_start_count_down(sync)
	original.timer_start_count_down(self, sync)
	local editor_id = self._unit:editor_id()
	if ignore[editor_id] then
		return
	end
	if managers.ehi:TrackerExists(self._ehi_key) then
		managers.hud:SetTimerJammed(self._ehi_key, false)
	else
		managers.ehi:AddTracker({
			id = self._ehi_key,
			time = self._timer,
			icons = icons[editor_id] or { "wp_hack" },
			class = class[editor_id] or "EHITimerTracker"
		})
	end
end

function DigitalGui:timer_pause(sync)
	original.timer_pause(self, sync)
	if remove[self._unit:editor_id()] then
		managers.ehi:RemoveTracker(self._ehi_key)
	else
		managers.hud:SetTimerJammed(self._ehi_key, true)
	end
end

function DigitalGui:timer_resume(sync)
	original.timer_resume(self, sync)
	managers.hud:SetTimerJammed(self._ehi_key, false)
end

local SetTime = function(key, time) end
-- Fixes timer flashing in Beneath the Mountain, The Big Bank and Golden Grin Casino
if level_id == "pbr" or level_id == "big" or level_id == "kenaz" then
	SetTime = function(key, time)
		if managers.hud.ehi then
			managers.hud:SetTimeNoAnim(key, time)
		end
	end
elseif level_id ~= "shoutout_raid" then
	SetTime = function(key, time)
		if managers.hud.ehi then
			managers.hud:SetTime(key, time)
		end
	end
end

function DigitalGui:timer_set(timer, sync)
	original.timer_set(self, timer, sync)
	SetTime(self._ehi_key, timer)
end

function DigitalGui:_timer_stop()
	original._timer_stop(self)
	managers.hud:RemoveTracker(self._ehi_key)
end

function DigitalGui:set_visible(visible)
	original.set_visible(self, visible)
	if not visible and managers.ehi then
		managers.ehi:RemoveTracker(self._ehi_key)
	end
end