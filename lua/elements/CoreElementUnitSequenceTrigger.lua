if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

core:module("CoreElementUnitSequenceTrigger")

local EHI = rawget(_G, "EHI")
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
SF.CreateTrackerIfDoesNotExistOrAddDelayWhenUnpaused = 99
local Icon = EHI:GetIcons()
if level_id == "des" then -- Henry's Rock
    triggers = {
        [100716] = { time = 30, id = "ChemLabThermite", icons = { Icon.Fire } },
        [101446] = { time = 60, id = "Crane", icons = { Icon.Defend }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [102996] = { id = "Crane", special_function = SF.UnpauseTracker }
    }
elseif level_id == "kosugi" then -- Shadow Raid
    triggers = {
        -- See "EHI/lua/levels/kosugi.lua" for more information
        [105500] = { time = 10, id = "SewerGrate1", icons = { Icon.Fire } },
        [105501] = { time = 10, id = "SewerGrate2", icons = { Icon.Fire } },
        [105502] = { time = 10, id = "SewerGrate3", icons = { Icon.Fire } },
        [105503] = { time = 10, id = "SewerGrate4", icons = { Icon.Fire } }
    }
elseif level_id == "wwh" then -- Alaskan Deal
    triggers = {
        [101226] = { id = "wwh_10", special_function = SF.IncreaseProgress }
    }
elseif level_id == "dinner" then -- Slaughterhouse
    triggers = {
        [100319] = { id = "farm_2", special_function = SF.RemoveTracker }
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
    -- See "EHI/lua/levels/dark.lua" for more information
    triggers = {
        [EHI:GetInstanceElementID(100160, 8750)] = { time = 10, id = "Thermite1", icons = { Icon.Fire } },
        [EHI:GetInstanceElementID(100160, 17750)] = { time = 10, id = "Thermite2", icons = { Icon.Fire } },
        [EHI:GetInstanceElementID(100160, 33525)] = { time = 10, id = "Thermite3", icons = { Icon.Fire } },
        [EHI:GetInstanceElementID(100160, 36525)] = { time = 10, id = "Thermite4", icons = { Icon.Fire } }
    }
elseif level_id == "mia_2" then -- Hotline Miami Day 2
    local trigger = { id = "HostageBomb", special_function = SF.RemoveTracker } -- Hostage blew out
    local start_index =
    {
        3500, 3750, 3900, 4450, 4900, 6100, 17600, 17650
    }
    for _, index in ipairs(start_index) do
        triggers[EHI:GetInstanceElementID(100039, index)] = deep_clone(trigger)
    end
elseif level_id == "nmh" then -- No Mercy
    triggers = {
        [103460] = { id = "nmh_11", special_function = SF.RemoveTracker },

        [103443] = { time = 208, delay_time = 8, id = "EscapeElevator", icons = { "pd2_door" }, class = "EHIPausableTracker", special_function = SF.CreateTrackerIfDoesNotExistOrAddDelayWhenUnpaused },
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
elseif level_id == "hox_2" then
    triggers = {
        [104593] = { id = "RequestCounter", special_function = SF.IncreaseProgress }
    }
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
    managers.hud:AddTracker({
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
                managers.hud:PauseTracker(triggers[id].id)
            elseif f == SF.UnpauseTracker then
                managers.hud:UnpauseTracker(triggers[id].id)
            elseif f == SF.UnpauseTrackerIfExists then
                if managers.hud:TrackerExists(triggers[id].id) then
                    managers.hud:UnpauseTracker(triggers[id].id)
                else
                    CreateTracker(id)
                end
            elseif f == SF.IncreaseProgress then
                managers.hud:IncreaseProgress(triggers[id].id)
            elseif f == SF.CreateTrackerIfDoesNotExistOrAddDelayWhenUnpaused then
                local trigger = triggers[id]
                if managers.hud:TrackerExists(trigger.id) then
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
            end
        else
            CreateTracker(id)
        end
    end
end

local _f_client_on_executed = ElementUnitSequenceTrigger.client_on_executed
function ElementUnitSequenceTrigger:client_on_executed(...)
    _f_client_on_executed(self, ...)
    Trigger(self._id, self._values.enabled)
end

local _f_on_executed = ElementUnitSequenceTrigger.on_executed
function ElementUnitSequenceTrigger:on_executed(...)
    _f_on_executed(self, ...)
    Trigger(self._id, self._values.enabled)
end