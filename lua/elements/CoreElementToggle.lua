if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

local EHI = rawget(_G, "EHI")
if EHI._hooks.ElementToggle then
    return
else
    EHI._hooks.ElementToggle = true
end

core:module("CoreElementToggle")

local level_id = Global.game_settings.level_id
local triggers = {}
local SF = EHI:GetSpecialFunctions()
if level_id == "bex" then -- San Martín Bank
    if Network:is_server() then
        return
    end
    triggers = {
        [102157] = { time = 60, random_time = { low = 0, high = 15 }, id = "VaultGas", icons = { "teargas" }, class = "EHIInaccurateTracker", special_function = SF.AddTrackerIfDoesNotExist }
    }
elseif level_id == "flat" then -- Panic Room
    triggers = {
        [100049] = { time = 20, id = "flat_2", icons = { "C_Classics_H_PanicRoom_Cardio" }, class = "EHIAchievementTracker" },
        [102001] = { time = 5, id = "C4Explosion", icons = { "pd2_c4" } }
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
            elseif f == SF.SetTimeOrCreateTracker then
                if managers.ehi:TrackerExists(triggers[id].id) then
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
                    if managers.ehi:TrackerExists(triggers[tracker].id) then
                        managers.ehi:UnpauseTracker(triggers[tracker].id)
                    else
                        CreateTracker(tracker)
                    end
                end
            elseif f == SF.IncreaseProgress then
                managers.hud:IncreaseProgress(triggers[id].id)
            elseif f == SF.SetTimeNoAnimOrCreateTracker then
                if managers.ehi:TrackerExists(triggers[id].id) then
                    managers.ehi:CallFunction(triggers[id].id, "SetTimeNoAnim", triggers[id].time)
                else
                    CreateTracker(id)
                end
            elseif f == SF.SetTrackerAccurate then
                if managers.ehi:TrackerExists(triggers[id].id) then
                    managers.hud:SetTrackerAccurate(triggers[id].id)
                    managers.hud:SetTime(triggers[id].id, triggers[id].time)
                else
                    CreateTracker(id)
                end
            end
        else
            CreateTracker(id)
        end
    end
end

-- Called also by client (client_on_executed), no need to override that function again
local _f_on_executed = ElementToggle.on_executed
function ElementToggle:on_executed(instigator)
    _f_on_executed(self, instigator)
	if not self._values.enabled then
		return
	end
    Trigger(self._id)
end