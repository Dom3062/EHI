if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

local EHI = rawget(_G, "EHI")
if EHI._hooks.CoreMissionScriptElement then -- Don't hook multiple times, pls
    return
else
    EHI._hooks.CoreMissionScriptElement = true
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
local TT = -- Tracker Type
{
    MallcrasherMoney = "EHIMoneyCounterTracker",
    Warning = "EHIWarningTracker",
    Pausable = "EHIPausableTracker"
}
local _cache = {}
if level_id == "vit" then -- The White House
    triggers = {
        -- Time before the tear gas is removed
        [102074] = { time = 5, id = "TearGasPEOC", icons = { Icon.Teargas } }
    }
elseif level_id == "mia_2" then -- Hotline Miami Day 2
    triggers = {
        [100428] = { time = 24, id = "PickUpThermalDrill", icons = { Icon.Interact, "pd2_drill" } },
        [100430] = { time = 24, id = "PickUpThermalDrill", icons = { Icon.Interact, "pd2_drill" } }
    }
elseif level_id == "dah" then -- Diamond Heist
    triggers = { -- 100438, ElementInstanceOutputEvent, check if enabled
        [103569] = { time = 25, id = "CFOFall", icons = { "hostage", "pd2_goto" } }
    }
elseif level_id == "chas" then -- Dragon Heist
    triggers = {
        [100209] = { time = 5, id = "LoudEscape", icons = { Icon.Car, Icon.Escape, Icon.LootDrop } },
        [100883] = { time = 12.5, id = "HeliArrivesWithDrill", icons = { Icon.Heli, "pd2_drill", "pd2_goto" } }
    }
else
    return
end

EHI:SetSyncTriggers(triggers)

-- chew
-- ´pilot_on_his_way´ MissionScriptElement 100558
-- BASE DELAY 5-10

local function CreateTrackerForReal(id, delay, icon2)
    managers.hud:AddTrackerAndSync({
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
                    CreateTracker(id, delay)
                end
            elseif f == SF.AddTrackerIfDoesNotExist then
                if not managers.hud:TrackerExists(triggers[id].id) then
                    CreateTracker(id, delay)
                end
            elseif f == SF.CreateTrackerIfDoesNotExistOrAddDelayWhenUnpaused then
                if managers.hud:TrackerExists(triggers[id].id) then
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

local _f_calc_element_delay = MissionScriptElement._calc_element_delay
function MissionScriptElement:_calc_element_delay(params)
    local delay = _f_calc_element_delay(self, params)
    if triggers[params.id] then
        CreateTrackerForReal(params.id, delay)
    end
    return delay
end