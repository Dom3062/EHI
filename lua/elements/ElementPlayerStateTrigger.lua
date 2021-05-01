if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

local EHI = EHI
if EHI._hooks.ElementPlayerStateTrigger then
    return
else
    EHI._hooks.ElementPlayerStateTrigger = true
end
local level_id = Global.game_settings.level_id
local difficulty = Global.game_settings.difficulty
local difficulty_index = EHI:DifficultyToIndex(difficulty)
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = difficulty_index >= 3
local triggers = {}
local SF = EHI:GetSpecialFunctions()
SF.SetAchievementFailed = 99
if level_id == "flat" then -- Panic Room
    if show_achievement and ovk_and_up then
        triggers = {
            [100809] = { time = 60, id = "cac_9", icons = { "C_Classics_H_PanicRoom_QuickDraw" }, class = "EHIAchievementTracker", condition = ovk_and_up and show_achievement, special_function = SF.RemoveTriggerWhenExecuted },
            [1008091] = { id = "ThugDeath", icons = { "pd2_kill" }, class = "EHIProgressTracker", dont_flash = true, special_function = SF.GetFromGlobalCache, condition = ovk_and_up and show_achievement }
        }
    else
        return
    end
elseif level_id == "help" then -- Prison Nightmare
    triggers = {
        [EHI:GetInstanceElementID(100471, 21700)] = { id = "orange_5", special_function = SF.SetAchievementFailed }
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
        triggers[id].icons[1] = icon2
    end
    managers.hud:AddTracker({
        id = triggers[id].id or trigger_id_all,
        time = GetTime(id),
        chance = triggers[id].chance,
        max = triggers[id].max,
        dont_flash = triggers[id].dont_flash,
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

local function Trigger(id, enabled)
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
                managers.hud:PauseTracker(triggers[id].id)
            elseif f == SF.UnpauseTracker then
                managers.hud:UnpauseTracker(triggers[id].id)
            elseif f == SF.UnpauseTrackerIfExists then
                if managers.hud:TrackerExists(triggers[id].id) then
                    managers.hud:UnpauseTracker(triggers[id].id)
                else
                    CreateTracker(id)
                end
            elseif f == SF.ResetTrackerTimeWhenUnpaused then
                if managers.hud:TrackerExists(triggers[id].id) then
                    managers.hud:ResetTrackerTimeAndUnpause(triggers[id].id)
                else
                    CreateTracker(id)
                end
            elseif f == SF.AddTrackerIfDoesNotExist then
                if not managers.hud:TrackerExists(triggers[id].id) then
                    CreateTracker(id)
                end
            elseif f == SF.CreateTrackerIfDoesNotExistOrAddDelayWhenUnpaused then
                local trigger = triggers[id]
                if managers.hud:TrackerExists(trigger.id) then
                    managers.hud:AddDelayToTrackerAndUnpause(trigger.id, trigger.delay_time)
                else
                    CreateTracker(id)
                end
            elseif f == SF.AddToCache then
                _cache[triggers[id].id or trigger_id_all] = triggers[id].data
            elseif f == SF.GetFromCache then
                local data = _cache[triggers[id].id or trigger_id_all]
                _cache[triggers[id].id or trigger_id_all] = nil
                CreateTrackerForReal(id, data.icon)
            elseif f == SF.ReplaceTrackerWithTracker then
                managers.hud:RemoveTracker(triggers[id].data.id)
                if triggers[id].data.trigger then
                    triggers[triggers[id].data.trigger] = nil -- Removes trigger from the list, used in The White House
                end
                CreateTracker(id)
            elseif f == SF.IncreaseChance then
                local trigger = triggers[id]
                managers.hud.ehi:IncreaseChance(trigger.id, trigger.amount)
            elseif f == SF.CreateAnotherTrackerWithTracker then
                CreateTracker(id)
                Trigger(triggers[id].data.fake_id)
            elseif f == SF.ExecuteIfTrackerExists then
                local data = triggers[id].data
                if managers.hud:TrackerExists(data.id) then
                    managers.hud:SetTime(triggers[id].id, triggers[id].time)
                    managers.hud:RemoveTracker(data.id)
                end
            elseif f == SF.SetChanceWhenTrackerExists then
                local trigger = triggers[id]
                if managers.hud:TrackerExists(trigger.id) then
                    managers.hud.ehi:SetChance(trigger.id, trigger.chance)
                else
                    CreateTracker(id)
                end
            elseif f == SF.RemoveTriggerWhenExecuted then
                CreateTracker(id)
                triggers[id] = nil
            elseif f == SF.SetTimeOrCreateTracker then
                if managers.hud:TrackerExists(triggers[id].id) then
                    managers.hud:SetTime(triggers[id].id, triggers[id].time)
                else
                    CreateTracker(id)
                end
            elseif f == SF.ExecuteIfElementIsEnabled then
                if enabled then
                    CreateTracker(id)
                end
            elseif f == SF.RemoveTrackers then
                for _, tracker in ipairs(triggers[id].data) do
                    managers.hud:RemoveTracker(tracker)
                end
            elseif f == SF.CreateTrackers then
                for _, tracker in ipairs(triggers[id].data) do
                    CreateTracker(tracker)
                end
            elseif f == SF.UnpauseTrackersOrCreateThem then
                for _, tracker in ipairs(triggers[id].data) do
                    if managers.hud:TrackerExists(triggers[tracker].id) then
                        managers.hud:UnpauseTracker(triggers[tracker].id)
                    else
                        CreateTracker(tracker)
                    end
                end
            elseif f == SF.IncreaseProgress then
                managers.hud:IncreaseProgress(triggers[id].id)
            elseif f == SF.SetTimeNoAnimOrCreateTracker then
                if managers.hud:TrackerExists(triggers[id].id) then
                    managers.hud:SetTimeNoAnim(triggers[id].id, GetTime(id))
                else
                    CreateTracker(id)
                end
            elseif f == SF.SetTrackerAccurate then
                if managers.hud:TrackerExists(triggers[id].id) then
                    managers.hud:SetTrackerAccurate(triggers[id].id)
                    managers.hud:SetTime(triggers[id].id, triggers[id].time)
                else
                    CreateTracker(id)
                end
            elseif f == SF.GetFromGlobalCache then
                local max = EHI._cache[triggers[id].id]
                triggers[id].max = max
                CreateTracker(id)
            elseif f == SF.SetAchievementFailed then
                managers.hud.ehi:CallFunction(triggers[id].id, "SetFailed")
                triggers[id] = nil
            elseif f == SFF.PAL_UnpauseOrCreate then
                if managers.hud:TrackerExists(triggers[id].id) then
                    managers.hud.ehi:CallFunction(triggers[id].id, "ResumeAll")
                else
                    CreateTracker(id)
                end
            end
        elseif triggers[id].on_executed then
        else
            CreateTracker(id)
        end
    end
end

local _f_client_on_executed = ElementPlayerStateTrigger.client_on_executed
function ElementPlayerStateTrigger:client_on_executed(...)
    _f_client_on_executed(self, ...)
    Trigger(self._id)
end

local _f_on_executed = ElementPlayerStateTrigger.on_executed
function ElementPlayerStateTrigger:on_executed(instigator)
    _f_on_executed(self, instigator)
    Trigger(self._id)
end