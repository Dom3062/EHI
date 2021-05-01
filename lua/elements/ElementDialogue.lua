if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

local EHI = EHI
local level_id = Global.game_settings.level_id
local difficulty = Global.game_settings.difficulty
local difficulty_index = EHI:DifficultyToIndex(difficulty)
local SF = EHI:GetSpecialFunctions()
local triggers = {}
local trigger_icon_all = nil
local trigger_id = nil
if level_id == "rat" then -- Cook Off
    local anim_delay = 743/30 + 3 -- 743/30 is a animation duration; 3s is zone activation delay
    triggers = { -- Time before escape van comes in
        [101972] = { time = 240 + anim_delay, id = "Van" },
        [101973] = { time = 180 + anim_delay, id = "Van" },
        [101974] = { time = 120 + anim_delay, id = "Van" },
        [101975] = { time = 60 + anim_delay, id = "Van" }
    }
    trigger_icon_all = { "pd2_car", "pd2_escape", "pd2_lootdrop" }
elseif level_id == "alex_1" then -- Rats Day 1
    local anim_delay = 2 + 727/30 + 2 -- 2s is function delay; 727/30 is a animation duration; 2s is zone activation delay; total 28,23333
    triggers = {
        -- There is an issue in the scripts. Even if the van driver says 2 minutes, he arrives in a minute
        [101974] = { time = (60 + 30 + anim_delay) - 60, id = "Van", special_function = SF.AddTrackerIfDoesNotExist },
        [101975] = { time = 30 + anim_delay, id = "Van", special_function = SF.AddTrackerIfDoesNotExist }
    }
    trigger_icon_all = { "pd2_car", "pd2_escape", "pd2_lootdrop" }
elseif level_id == "alex_3" then -- Rats Day 3
    local delay = 2
    triggers = {
        [100668] = { time = 240 + delay, id = "HeliLootDrop" },
        [100669] = { time = 180 + delay, id = "HeliLootDrop" },
        [100670] = { time = 120 + delay, id = "HeliLootDrop" }
    }
    trigger_icon_all = { "heli", "pd2_lootdrop" }
elseif level_id == "arm_for" then -- Transport: Train Heist
    triggers = {
        [105183] = { time = 30 + 524/30, id = "TruckSecureAmmo", icons = { "pd2_car", "pd2_lootdrop" }, dont_remove = true }
    }
else
    return
end

local function CreateTracker(id)
    if triggers[id] then
        managers.hud:AddTracker({
            id = triggers[id].id or trigger_id_all,
            time = triggers[id].time,
            chance = triggers[id].chance,
            max = triggers[id].max,
            icons = triggers[id].icons or trigger_icon_all,
            class = triggers[id].class
        })
        if not triggers[id].dont_remove then
            triggers = {} -- Disabled when executed
        end
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
                CreateTracker(triggers[id].data.fake_id)
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
                    managers.hud.ehi:CallFunction(triggers[id].id, "SetTimeNoAnim", GetTime(id))
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

local _f_on_executed = ElementDialogue.on_executed -- Client code also calls this function
function ElementDialogue:on_executed(instigator)
    _f_on_executed(self, instigator)
    Trigger(self._id)
end