if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

local EHI = rawget(_G, "EHI")
if EHI._hooks.CoreMissionScriptElement_BaseDelay then -- Don't hook multiple times, pls
    return
else
    EHI._hooks.CoreMissionScriptElement_BaseDelay = true
end

core:module("CoreMissionScriptElement")

local level_id = Global.game_settings.level_id
local triggers = {}
local trigger_id_all = "Trigger"
local trigger_icon_all = nil
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
    GetFromCache = 10
}
local Icon = EHI:GetIcons()
local TT =
{
    Warning = "EHIWarningTracker"
}
local _cache = {}
if level_id == "pal" then -- Counterfeit
    triggers = {
        [EHI:GetInstanceElementID(100013, 4700)] = { id = "HeliCageDelay", icons = { Icon.Heli, Icon.LootDrop, "faster" }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "HeliCage" }, class = TT.Warning },
        [EHI:GetInstanceElementID(100013, 4750)] = { id = "HeliCageDelay", icons = { Icon.Heli, Icon.LootDrop, "faster" }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "HeliCage" }, class = TT.Warning },
        [EHI:GetInstanceElementID(100013, 4800)] = { id = "HeliCageDelay", icons = { Icon.Heli, Icon.LootDrop, "faster" }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "HeliCage" }, class = TT.Warning },
        [EHI:GetInstanceElementID(100013, 4850)] = { id = "HeliCageDelay", icons = { Icon.Heli, Icon.LootDrop, "faster" }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "HeliCage" }, class = TT.Warning }
    }
else
    return
end

EHI:SetSyncTriggers(triggers)

-- chew
-- ´pilot_on_his_way´ MissionScriptElement 100558
-- BASE DELAY 5-10

local function CreateTrackerForReal(id, delay, icon2)
    managers.ehi:AddTrackerAndSync({
        id = triggers[id].id or trigger_id_all,
        time = (triggers[id].time or 0) + (delay or 0),
        icons = triggers[id].icons,
        class = triggers[id].class
    }, id, delay)
end

local function CreateTracker(id, delay)
    if triggers[id].condition ~= nil then
        if triggers[id].condition == true then
            CreateTrackerForReal(id, delay)
        end
    else
        CreateTrackerForReal(id, delay)
    end
end

local function Trigger(id, delay)
    --[[if managers.hud and managers.hud.Debug then
        managers.hud:Debug(id, "MissionScriptElement")
    end]]
    if triggers[id] then
        if triggers[id].special_function then
            local f = triggers[id].special_function
            if f == SF.AddMoney then
                managers.hud:AddMoney(
                    triggers[id].id,
                    triggers[id].amount
                )
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
                    CreateTracker(id, delay)
                end
            elseif f == SF.AddTrackerIfDoesNotExist then
                if managers.ehi:TrackerDoesNotExist(triggers[id].id) then
                    CreateTracker(id, delay)
                end
            elseif f == SF.CreateTrackerIfDoesNotExistOrAddDelayWhenUnpaused then
                if managers.ehi:TrackerExists(triggers[id].id) then
                    managers.hud:AddDelayToTrackerAndUnpause(triggers[id].id, 1)
                else
                    CreateTracker(id, delay)
                end
            elseif f == SF.AddToCache then
                _cache[triggers[id].id or trigger_id_all] = triggers[id].data
            elseif f == SF.GetFromCache then
                local data = _cache[triggers[id].id or trigger_id_all]
                _cache[triggers[id].id or trigger_id_all] = nil
                CreateTrackerForReal(triggers[id].id or trigger_id_all, nil, data.icon)
            end
        else
            CreateTracker(id, delay)
        end
    end
end

local _f_calc_base_delay = MissionScriptElement._calc_base_delay
function MissionScriptElement:_calc_base_delay()
    local delay = _f_calc_base_delay(self)
    if triggers[self._id] then
        CreateTrackerForReal(self._id, delay)
    end
    return delay
end