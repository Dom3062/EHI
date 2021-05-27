if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

core:module("CoreElementUnitSequenceTrigger")

local EHI = rawget(_G, "EHI")
if EHI._hooks.ElementUnitSequenceTrigger then
    return
else
    EHI._hooks.ElementUnitSequenceTrigger = true
end
local function deep_clone(o)
	if type(o) == "userdata" then
		return o
	end

	local res = {}

	setmetatable(res, getmetatable(o))

	for k, v in pairs(o) do
		if type(v) == "table" then
			res[k] = deep_clone(v)
		else
			res[k] = v
		end
	end

	return res
end

local level_id = Global.game_settings.level_id
local triggers = {}
local trigger_id_all = "Trigger"
local SF = EHI:GetSpecialFunctions()
SF.CreateTrackerIfDoesNotExistOrAddDelayWhenUnpaused = 599
local Icon = EHI:GetIcons()
if level_id == "pbr2" then -- Birth of Sky
    triggers = {
        [103248] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103252] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103255] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103258] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103261] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103264] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103267] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103270] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103273] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103276] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103279] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103282] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103285] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103288] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103291] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103294] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103297] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103300] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103303] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103306] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103309] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103312] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103315] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103318] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103321] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103324] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103327] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103330] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103333] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103336] = { id = "voff_4", special_function = SF.IncreaseProgress },
        [103339] = { id = "voff_4", special_function = SF.IncreaseProgress },

        [101985] = { time = 300/30, id = "ThermiteSewerGrate", icons = { Icon.Fire } }, -- First grate
        [101984] = { time = 300/30, id = "ThermiteSewerGrate", icons = { Icon.Fire } } -- Second grate
    }
elseif level_id == "des" then -- Henry's Rock
    triggers = {
        [103391] = { id = "uno_5", special_function = SF.IncreaseProgress },
        [103395] = { id = "uno_5", special_function = SF.SetAchievementFailed },
        [100716] = { time = 30, id = "ChemLabThermite", icons = { Icon.Fire } },
        [101446] = { time = 60, id = "Crane", icons = { Icon.Defend }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [102996] = { id = "Crane", special_function = SF.UnpauseTracker }
    }
elseif level_id == "wwh" then -- Alaskan Deal
    triggers = {
        [101226] = { id = "wwh_10", special_function = SF.IncreaseProgress }
    }
elseif level_id == "dinner" then -- Slaughterhouse
    triggers = {
        [100319] = { id = "farm_2", special_function = SF.SetAchievementFailed }
    }
elseif level_id == "dah" then -- Diamond Heist
    triggers = {
        [104875] = { time = 45 + 26 + 6, id = "HeliEscapeLoud", icons = { Icon.Heli, Icon.Escape } },
        [103159] = { time = 30 + 26 + 6, id = "HeliEscapeLoud", icons = { Icon.Heli, Icon.Escape } }
    }
elseif level_id == "big" then -- The Big Bank
    triggers = {
        [105623] = { time = 8, id = "Bus", icons = { Icon.Wait } }
    }
elseif level_id == "run" then -- Heat Street
    triggers = {
        [100144] = { id = "run_9", special_function = SF.RemoveTracker },
        [102869] = { time = 60, id = "gas1", icons = { Icon.Fire }, special_function = SF.RemoveTriggerWhenExecuted },
        [102870] = { time = 60, id = "gas2", icons = { Icon.Fire }, special_function = SF.RemoveTriggerWhenExecuted },
        [102871] = { time = 60, id = "gas3", icons = { Icon.Fire }, special_function = SF.RemoveTriggerWhenExecuted },
        [102872] = { time = 80, id = "gas4", icons = { Icon.Fire, Icon.Escape }, special_function = SF.RemoveTriggers, data = { 102869, 102870, 102871, 102872 } },
        [100658] = { id = "run_8", special_function = SF.IncreaseProgress }
    }
elseif level_id == "dark" then -- Murky Station
    if true then
        return
    end
    -- See "EHI/lua/levels/dark.lua" for more information
    triggers = {
        [EHI:GetInstanceElementID(100160, 8750)] = { time = 10, id = "Thermite1", icons = { Icon.Fire } },
        [EHI:GetInstanceElementID(100160, 17750)] = { time = 10, id = "Thermite2", icons = { Icon.Fire } },
        [EHI:GetInstanceElementID(100160, 33525)] = { time = 10, id = "Thermite3", icons = { Icon.Fire } },
        [EHI:GetInstanceElementID(100160, 36525)] = { time = 10, id = "Thermite4", icons = { Icon.Fire } }
    }
elseif level_id == "mia_2" then -- Hotline Miami Day 2
    local trigger = { id = "HostageBomb", special_function = SF.SetAchievementFailed } -- Hostage blew out
    local start_index =
    {
        3500, 3750, 3900, 4450, 4900, 6100, 17600, 17650
    }
    for _, index in ipairs(start_index) do
        triggers[EHI:GetInstanceElementID(100039, index)] = deep_clone(trigger)
    end
elseif level_id == "nmh" then -- No Mercy
    triggers = {
        [103460] = { id = "nmh_11", special_function = SF.SetAchievementComplete },

        [103443] = { id = "EscapeElevator", icons = { "pd2_door" }, class = "EHIElevatorTimerTracker", special_function = SF.UnpauseTrackerIfExists },
        [104072] = { id = "EscapeElevator", special_function = SF.UnpauseTracker }
    }
elseif level_id == "moon" then -- Stealing Xmas
    triggers = {
        [104219] = { id = "moon_4", special_function = SF.IncreaseProgress }, -- Chains
        [104220] = { id = "moon_4", special_function = SF.IncreaseProgress } -- Dallas
    }
elseif level_id == "friend" then -- Scarface Mansion
    triggers = {
        [102280] = { id = "friend_5", special_function = SF.IncreaseProgress }
    }
elseif level_id == "pal" then -- Counterfeit
    triggers = {
        [102826] = { id = "PAL", special_function = SF.RemoveTracker }
    }
elseif level_id == "brb" then -- Brooklyn Bank
    triggers = {
        [100124] = { time = 300/30, id = "ThermiteSewerGrate", icons = { Icon.Fire } }
    }
elseif level_id == "arena" then -- The Alesso Heist
    if true then
        return
    end
    -- See "EHI/lua/levels/arena.lua" for more information
    local trigger = { time = 30, id = "Cutter", icons = { "equipment_glasscutter" } }
    local start_index =
    {
        4500, 5400, 5800, 6000, 6200, 6600
    }
    local ids =
    {
        100160, 100161, 100162
    }
    for _, id in pairs(ids) do
        for _, index in ipairs(start_index) do
            local element = EHI:GetInstanceElementID(id, index)
            triggers[element] = deep_clone(trigger)
            triggers[element].id = triggers[element].id .. tostring(element)
        end
    end
elseif level_id == "pex" then -- Breakfast in Tijuana
    triggers = {
        [103735] = { id = "pex_11", special_function = SF.IncreaseProgress }
    }
elseif level_id == "fex" then -- Buluc's Mansions
    triggers = {
        [EHI:GetInstanceElementID(100007, 25580)] = { time = 6, id = "ThermiteWineCellarDoor1", icons = { Icon.Fire } },
        [EHI:GetInstanceElementID(100007, 25780)] = { time = 6, id = "ThermiteWineCellarDoor2", icons = { Icon.Fire } }
    }
elseif level_id == "election_day_3" or level_id == "election_day_3_skip1" or level_id == "election_day_3_skip2" then -- Election Day 2 Plan C
    triggers = {
        [103535] = { time = 5, id = "C4Explosion", icons = { "pd2_c4" } }
    }
else
    return
end

local function CreateTrackerForReal(id)
    managers.ehi:AddTracker({
        id = triggers[id].id or trigger_id_all,
        time = triggers[id].time,
        icons = triggers[id].icons,
        class = triggers[id].class
    })
end

local function CreateTracker(id)
    if triggers[id].condition ~= nil then
        if triggers[id].condition == true then
            CreateTrackerForReal(id)
        end
    else
        CreateTrackerForReal(id)
    end
end

local function Trigger(id, enabled)
    if triggers[id] then
        if triggers[id].special_function then
            local f = triggers[id].special_function
            if f == SF.AddMoney then
                managers.hud:AddMoney(triggers[id].id, triggers[id].amount)
            elseif f == SF.RemoveTracker then
                managers.hud:RemoveTracker(triggers[id].id)
            elseif f == SF.PauseTracker then
                managers.ehi:PauseTracker(triggers[id].id)
            elseif f == SF.UnpauseTracker then
                managers.ehi:UnpauseTracker(triggers[id].id)
            elseif f == SF.UnpauseTrackerIfExists then
                if managers.ehi:TrackerExists(triggers[id].id) then
                    managers.ehi:UnpauseTracker(triggers[id].id)
                else
                    CreateTracker(id)
                end
            elseif f == SF.IncreaseProgress then
                managers.hud:IncreaseProgress(triggers[id].id)
            elseif f == SF.CreateTrackerIfDoesNotExistOrAddDelayWhenUnpaused then
                local trigger = triggers[id]
                if managers.ehi:TrackerExists(trigger.id) then
                    managers.hud:AddDelayToTrackerAndUnpause(trigger.id, trigger.delay_time)
                else
                    CreateTracker(id)
                end
            elseif f == SF.RemoveTriggerWhenExecuted then
                CreateTracker(id)
                triggers[id] = nil
            elseif f == SF.ExecuteIfElementIsEnabled then
                if enabled then
                    CreateTracker(id)
                end
            elseif f == SF.RemoveTrackers then
                for _, tracker in ipairs(triggers[id].data) do
                    managers.hud:RemoveTracker(tracker)
                end
            elseif f == SF.RemoveTrigger then
                CreateTracker(id)
                triggers[id] = nil
            elseif f == SF.RemoveTriggers then
                CreateTracker(id)
                for _, trigger_id in pairs(triggers[id].data) do
                    triggers[trigger_id] = nil
                end
            elseif f == SF.SetAchievementComplete then
                managers.ehi:CallFunction(triggers[id].id, "SetCompleted", true)
            elseif f == SF.SetAchievementFailed then
                managers.ehi:CallFunction(triggers[id].id, "SetFailed")
            end
        else
            CreateTracker(id)
        end
    end
end

local _f_client_on_executed = ElementUnitSequenceTrigger.client_on_executed
function ElementUnitSequenceTrigger:client_on_executed(...)
    _f_client_on_executed(self, ...)
    Trigger(self._id, true)
end

local _f_on_executed = ElementUnitSequenceTrigger.on_executed
function ElementUnitSequenceTrigger:on_executed(...)
    _f_on_executed(self, ...)
    Trigger(self._id, self._values.enabled)
end