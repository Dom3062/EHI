if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

local EHI = EHI
if EHI._hooks.ElementAreaTrigger then -- Don't hook multiple times, pls
    return
else
    EHI._hooks.ElementAreaTrigger = true
end
local level_id = Global.game_settings.level_id
local difficulty = Global.game_settings.difficulty
local difficulty_index = EHI:DifficultyToIndex(difficulty)
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = difficulty_index >= 3
local triggers = {}
local trigger_id_all = "Trigger"
local trigger_icon_all = nil
local SF = EHI:GetSpecialFunctions()
SF.SetTimeIfMoreThanOrCreateTracker = 497
SF.ExecuteAndDisableTriggers = 498
local CF = EHI:GetConditionFunctions()
if level_id == "red2" then -- First World Bank
    if ovk_and_up and show_achievement then -- Optimization
        triggers = {
            [101544] = { time = 30, id = "cac_10", icons = { "C_Classics_H_FirstWorldBank_Federal" }, class = "EHIAchievementTracker", special_function = SF.RemoveTriggerWhenExecuted, condition_function = CF.IsLoud }
        }
    else
        return
    end
elseif level_id == "run" then -- Heat Street
    triggers = {
        [101521] = { time = 55 + 5 + 10 + 3, id = "HeliArrival", icons = { "heli", "pd2_escape" }, special_function = SF.RemoveTriggerWhenExecuted }
    }
elseif level_id == "firestarter_3" then -- Firestarter Day 3
    triggers = {
        [105217] = { id = "slakt_5", special_function = SF.RemoveTracker }
    }
elseif level_id == "spa" then -- Brooklyn 10-10
    triggers = {
        [101996] = { id = "spa_5", special_function = SF.SetAchievementComplete }
    }
elseif level_id == "kosugi" then -- Shadow Raid
    triggers = {
        [101131] = { time = 300, id = "Blackhawk", icons = { "heli", "pd2_goto" }, special_function = SF.ExecuteAndDisableTriggers, data = { 101131, 100900 } },
        [100900] = { time = 300, id = "Blackhawk", icons = { "heli", "pd2_goto" }, special_function = SF.ExecuteAndDisableTriggers, data = { 101131, 100900 } }
    }
elseif level_id == "alex_1" then -- Rats Day 1
    local assault_delay = 20 + 4 + 3 + 3 + 3 + 5 + 1 + 30
    triggers = {
        [100707] = { time = assault_delay, id = "FirstAssaultDelay", icons = { "assaultbox" }, class = "EHIWarningTracker", special_function = SF.SetTimeIfMoreThanOrCreateTracker, data = { time = assault_delay } }
    }
else
    return
end

local function CreateTrackerForReal(id, icon2)
    if icon2 then
        triggers[id].icons[2] = icon2
    end
    managers.ehi:AddTracker({
        id = triggers[id].id or trigger_id_all,
        time = triggers[id].time,
        chance = triggers[id].chance,
        max = triggers[id].max,
        icons = triggers[id].icons or trigger_icon_all,
        class = triggers[id].class
    })
end

local function CreateTracker2(id)
    if triggers[id].condition_function then
        if triggers[id].condition_function() then
            CreateTrackerForReal(id)
        end
    else
        CreateTrackerForReal(id)
    end
end

local function CreateTracker(id)
    if triggers[id].condition ~= nil then
        if triggers[id].condition == true then
            CreateTracker2(id)
        end
    else
        CreateTracker2(id)
    end
end

local function Trigger(id)
    --[[if managers.hud and managers.hud.Debug then
        managers.hud:Debug(id, "ElementAreaTrigger")
    end]]
    if triggers[id] then
        if triggers[id].special_function then
            local f = triggers[id].special_function
            if f == SF.AddMoney then
                managers.hud:AddMoney(triggers[id].id, triggers[id].amount)
            elseif f == SF.RemoveTracker then
                managers.hud:RemoveTracker(triggers[id].id)
                triggers = {}
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
            elseif f == SF.SetAchievementComplete then
                managers.ehi:CallFunction(triggers[id].id, "SetCompleted", true)
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
                CreateTracker(triggers[id].data.fake_id)
            elseif f == SF.ExecuteIfTrackerExists then
                local data = triggers[id].data
                if managers.ehi:TrackerExists(data.id) then
                    managers.hud:SetTime(triggers[id].id, triggers[id].time)
                    managers.hud:RemoveTracker(data.id)
                end
            elseif f == SF.RemoveTriggerWhenExecuted then
                CreateTracker(id)
                triggers[id] = nil
            elseif f == SF.ExecuteAndDisableTriggers then
                CreateTracker(id)
                for _, ID in ipairs(triggers[id].data) do
                    triggers[ID] = nil
                end
            elseif f == SF.SetTimeIfMoreThanOrCreateTracker then
                if managers.ehi:TrackerExists(triggers[id].id) then
                    local tracker = managers.ehi:GetTracker(triggers[id].id)
                    if tracker then
                        if tracker._time >= triggers[id].data.time then
                            managers.ehi:SetTrackerTime(triggers[id].id, triggers[id].time)
                        end
                    else
                        CreateTracker(id)
                    end
                else
                    CreateTracker(id)
                end
                triggers[id] = nil
            end
        else
            CreateTracker(id)
        end
    end
end

local _f_client_on_executed = ElementAreaTrigger.client_on_executed
function ElementAreaTrigger:client_on_executed(...)
    _f_client_on_executed(self, ...)
    Trigger(self._id)
end

local _f_on_executed = ElementAreaTrigger.on_executed
function ElementAreaTrigger:on_executed(...)
    _f_on_executed(self, ...)
    Trigger(self._id)
end