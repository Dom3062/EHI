if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

local EHI = rawget(_G, "EHI")
if EHI._hooks.ElementCounterOperator then -- Don't hook multiple times, pls
    return
else
    EHI._hooks.ElementCounterOperator = true
end

core:module("CoreElementCounter")

local function GetInstanceElementID(id, start_index)
    return 100000 + math.mod(id, 100000) + 30000 + start_index
end

--local EHI = EHI
local level_id = Global.game_settings.level_id
local difficulty = Global.game_settings.difficulty
--local difficulty_index = EHI:DifficultyToIndex(difficulty)
local SF =
{
    AddMoney = 1,
    RemoveTracker = 2,
    PauseTracker = 3,
    UnpauseTracker = 4,
    UnpauseTrackerIfExists = 5,
    ResetTrackerTimeWhenUnpaused = 6,
    AddTrackerIfDoesNotExist = 7,
    CreateTrackerIfDoesNotExistOrAddDelayWhenUnpaused = 8,
    AddToCache = 9,
    GetFromCache = 10,
    ReplaceTrackerWithTracker = 11,
    IncreaseChance = 12,
    ExecuteIfTrackerExists = 13,
    CreateAnotherTrackerWithTracker = 14,
    SetChanceWhenTrackerExists = 15,
    RemoveTriggerWhenExecuted = 16,
    Trigger = 17,
    RemoveTrigger = 18,
    SetTimeOrCreateTracker = 19,
    ExecuteIfElementIsEnabled = 20,
    RemoveTrackers = 21,
    CreateTrackers = 22,
    UnpauseTrackersOrCreateThem = 23,
    AddTime = 24,
    IncreaseProgress = 25,
    SetTimeNoAnimOrCreateTracker = 26,
    SetTrackerAccurate = 27,
    RemoveTriggers = 28
}
local triggers = {}
local trigger_icon = {}
local trigger_id = {}
local trigger_condition = {
    [101256] = { amount = 4 }
}

if level_id == "bph" then -- Hell's Island
    triggers = {
        [101339] = { id = "EnemyDeathShowers", special_function = SF.IncreaseProgress },
        [101412] = { id = "EnemyDeathOutside", special_function = SF.IncreaseProgress },
        [102171] = { id = "bph_10", special_function = SF.IncreaseProgress }
    }
elseif level_id == "hox_2" then -- Hoxton Breakout Day 2
    triggers = {
        [104591] = { id = "RequestCounter", special_function = SF.IncreaseProgress }
    }
elseif level_id == "help" then -- Prison Nightmare
    triggers = {
        [GetInstanceElementID(100474, 21700)] = { id = "orange_5", special_function = SF.IncreaseProgress }
    }
else
    return
end

local function GetTime(id)
    local full_time = triggers[id].time or 0
    full_time = full_time + (triggers[id].random_time and math.random(triggers[id].random_time.low, triggers[id].random_time.high) or 0)
    return full_time
end

local function CreateTrackerForReal(id, icon2)
    if icon2 then
        triggers[id].icons[2] = icon2
    end
    managers.ehi:AddTracker({
        id = triggers[id].id or trigger_id_all,
        time = GetTime(id),
        chance = triggers[id].chance,
        max = triggers[id].max,
        icons = triggers[id].icons or trigger_icon_all,
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

local function Trigger(id)
    --[[if managers.hud and managers.hud.Debug then
        managers.hud:Debug(id, "MissionScriptElement")
    end]]
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
            elseif f == SF.ResetTrackerTimeWhenUnpaused then
                if managers.ehi:TrackerExists(triggers[id].id) then
                    managers.hud:ResetTrackerTimeAndUnpause(triggers[id].id)
                else
                    CreateTracker(id)
                end
            elseif f == SF.AddTrackerIfDoesNotExist then
                if managers.ehi:TrackerDoesNotExist(triggers[id].id) then
                    CreateTracker(id)
                end
            elseif f == SF.CreateTrackerIfDoesNotExistOrAddDelayWhenUnpaused then
                local trigger = triggers[id]
                if managers.ehi:TrackerExists(trigger.id) then
                    managers.hud:AddDelayToTrackerAndUnpause(trigger.id, trigger.delay_time)
                else
                    CreateTracker(id)
                end
            elseif f == SF.AddToCache then
                _cache[triggers[id].id or trigger_id_all] = triggers[id].data
            elseif f == SF.GetFromCache then
                local data = _cache[triggers[id].id or trigger_id_all]
                _cache[triggers[id].id or trigger_id_all] = nil
                CreateTrackerForReal(triggers[id].id or trigger_id_all, data.icon)
            elseif f == SF.ReplaceTrackerWithTracker then
                managers.hud:RemoveTracker(triggers[id].data.id)
                triggers[triggers[id].data.trigger] = nil -- Removes trigger from the list, used in The White House
                CreateTracker(id)
            elseif f == SF.IncreaseChance then
                local trigger = triggers[id]
                managers.hud.ehi:IncreaseChance(trigger.id, trigger.amount)
            elseif f == SF.CreateAnotherTrackerWithTracker then
                CreateTracker(id)
                Trigger(triggers[id].data.fake_id)
            elseif f == SF.ExecuteIfTrackerExists then
                local data = triggers[id].data
                if managers.ehi:TrackerExists(data.id) then
                    managers.hud:SetTime(triggers[id].id, triggers[id].time)
                    managers.hud:RemoveTracker(data.id)
                end
            elseif f == SF.SetChanceWhenTrackerExists then
                local trigger = triggers[id]
                if managers.ehi:TrackerExists(trigger.id) then
                    managers.hud.ehi:SetChance(trigger.id, trigger.chance)
                else
                    CreateTracker(id)
                end
            elseif f == SF.RemoveTriggerWhenExecuted then
                CreateTracker(id)
                triggers[id] = nil
            elseif f == SF.IncreaseProgress then
                managers.hud:IncreaseProgress(triggers[id].id)
            end
        else
            CreateTracker(id)
        end
    end
end

local _f_client_on_executed = ElementCounterOperator.client_on_executed
function ElementCounterOperator:client_on_executed(...)
    _f_client_on_executed(self, ...)
    Trigger(self._id)
end

local _f_on_executed = ElementCounterOperator.on_executed
function ElementCounterOperator:on_executed(instigator)
    _f_on_executed(self, instigator)
    Trigger(self._id)
end