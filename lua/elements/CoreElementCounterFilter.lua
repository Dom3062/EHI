if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

local level_id = Global.game_settings.level_id
if level_id ~= "mex_cooking" then -- Border Crystals
    return
end

if Network:is_server() then
    return
end

local EHI = rawget(_G, "EHI")
if EHI._hooks.ElementCounterFilter then
    return
else
    EHI._hooks.ElementCounterFilter = true
end

core:module("CoreElementCounter")

local function GetInstanceElementID(id, start_index)
    return 100000 + math.mod(id, 100000) + 30000 + start_index
end

local SF = EHI:GetSpecialFunctions()
--local difficulty_index = EHI:DifficultyToIndex(difficulty)
local triggers = {
    [GetInstanceElementID(100173, 55850)] = { time = 40, delay = 5, id = "NextIngredient", icons = { "pd2_methlab", "restarter" }, class = "EHIInaccurateTracker", special_function = SF.AddTrackerIfDoesNotExist },
    [GetInstanceElementID(100173, 56850)] = { time = 40, delay = 5, id = "NextIngredient", icons = { "pd2_methlab", "restarter" }, class = "EHIInaccurateTracker", special_function = SF.AddTrackerIfDoesNotExist },
    [GetInstanceElementID(100174, 55850)] = { time = 10, delay = 5, id = "MethReady", icons = { "pd2_methlab", "pd2_generic_interact" }, class = "EHIInaccurateTracker", special_function = SF.AddTrackerIfDoesNotExist },
    [GetInstanceElementID(100174, 56850)] = { time = 10, delay = 5, id = "MethReady", icons = { "pd2_methlab", "pd2_generic_interact" }, class = "EHIInaccurateTracker", special_function = SF.AddTrackerIfDoesNotExist }
}
local trigger_icon = {}
local trigger_id = {}

--[[if level_id == "nightclub" then
    triggers = {
        [103088] = 20 + (40/3) -- Time before secure asset van comes in
        -- 20: Base Delay
        -- 40/3: Animation delay
        -- Total 33.33 s
    }
    trigger_icon = {
        [103088] = "pd2_lootdrop"
    }
    trigger_id = {
        [103088] = "AssetDropOff"
    }
    trigger_condition = {}
end]]

local function GetTime(id)
    local full_time = triggers[id].time or 0
    full_time = full_time + (triggers[id].delay and math.rand(triggers[id].delay) or 0)
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
            end
        else
            CreateTracker(id)
        end
    end
end

local _f_client_on_executed = ElementCounterFilter.client_on_executed
function ElementCounterFilter:client_on_executed(...)
    _f_client_on_executed(self, ...)
    Trigger(self._id)
end

local _f_on_executed = ElementCounterFilter.on_executed
function ElementCounterFilter:on_executed(instigator)
    _f_on_executed(self, instigator)
	if not self:_values_ok() then -- Only host needs this condition
		return
	end
    Trigger(self._id)
end