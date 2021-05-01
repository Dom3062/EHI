if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

core:module("CoreElementInstance")

local level_id = Global.game_settings.level_id
local triggers = {}
local trigger_id_all = "Trigger"
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
    TriggerID = 17,
    RemoveTrigger = 18,
    UnpauseOrSetTimeByPreplanning = 94,
    SetTimeByPreplanning = 95,
    SetTimeByElement = 96
}
if level_id == "sah" then -- Shacklethorne Auction
    triggers = {
        [101050] = { time = 120 + 24 + 5 + 3, id = "EscapeHeli", icons = { "heli", "pd2_escape", "pd2_lootdrop" }, special_function = SF.AddTrackerIfDoesNotExist }, -- West
        [101039] = { time = 120 + 24 + 5 + 3, id = "EscapeHeli", icons = { "heli", "pd2_escape", "pd2_lootdrop" }, special_function = SF.AddTrackerIfDoesNotExist } -- East
    }
elseif level_id == "jolly" then -- Aftershock
    triggers = {
        [101240] = { time = 120 + 25 + 0.25 + 2, id = "C4Drop", icons = { "heli", "pd2_c4", "pd2_goto" } },
        [101241] = { time = 120 + 25 + 0.25 + 2, id = "C4Drop", icons = { "heli", "pd2_c4", "pd2_goto" } },
        [101242] = { time = 120 + 25 + 0.25 + 2, id = "C4Drop", icons = { "heli", "pd2_c4", "pd2_goto" } },
        [101243] = { time = 120 + 25 + 0.25 + 2, id = "C4Drop", icons = { "heli", "pd2_c4", "pd2_goto" } },
        [101249] = { time = 120 + 25 + 0.25 + 2, id = "C4Drop", icons = { "heli", "pd2_c4", "pd2_goto" } }
    }
elseif level_id == "bex" then -- San Martín Bank
    triggers = {
        [102302] = { time = 28.05 + 418/30, id = "Suprise", icons = { "pd2_question" } }
    }
elseif level_id == "bph" then -- Hell's Island
    triggers = {
        [101137] = { max = 10, id = "EnemyDeathOutside", icons = { "pd2_kill" }, dont_flash = true, class = "EHIProgressTracker" },
        [101405] = { id = "EnemyDeathOutside", special_function = SF.RemoveTracker }
    }
elseif level_id == "kenaz" then -- Golden Grin Casino
    triggers = {
        [100159] = { id = "BlimpWithTheDrill", icons = { "pd2_question", "pd2_drill" }, special_function = SF.SetTimeByPreplanning, data = { id = 101854, yes = 976/30, no = 1952/30 } },
        [100426] = { time = 1000/30, id = "BlimpLowerTheDrill", icons = { "pd2_question", "pd2_drill", "pd2_goto" } }
    }
else
    return
end

local function CreateTrackerForReal(id)
    local trigger_times = triggers[id].trigger_times
    if trigger_times then
        if trigger_times == 0 then
            return
        else
            trigger_times = trigger_times - 1
        end
    end
    managers.hud:AddTracker({
        id = triggers[id].id or trigger_id_all,
        time = triggers[id].time,
        max = triggers[id].max,
        icons = triggers[id].icons,
        dont_flash = triggers[id].dont_flash,
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
                CreateTrackerForReal(triggers[id].id or trigger_id_all, data.icon)
            elseif f == SF.ReplaceTrackerWithTracker then
                managers.hud:RemoveTracker(triggers[id].data.id)
                CreateTracker(id)
            elseif f == SF.IncreaseChance then
                local trigger = triggers[id]
                managers.hud.ehi:IncreaseChance(trigger.id, trigger.amount)
            elseif f == SF.RemoveTrigger then
                triggers[triggers[id].data.id] = nil
            elseif f == SF.SetTimeByPreplanning then
                if managers.preplanning:IsAssetBought(triggers[id].data.id) then
                    triggers[id].time = triggers[id].data.yes
                else
                    triggers[id].time = triggers[id].data.no
                end
                CreateTracker(id)
            elseif f == SF.SetTimeByElement then
                local element = managers.mission:get_element_by_id(triggers[id].data.id)
                if element then
                    if element:enabled() then
                        triggers[id].time = triggers[id].data.yes
                    else
                        triggers[id].time = triggers[id].data.no
                    end
                    CreateTracker(id)
                end
            end
        else
            CreateTracker(id)
        end
    end
end

local _f_client_on_executed = ElementInstanceInputEvent.client_on_executed
function ElementInstanceInputEvent:client_on_executed(...)
    _f_client_on_executed(self, ...)
    Trigger(self._id)
end

local _f_on_executed = ElementInstanceInputEvent.on_executed
function ElementInstanceInputEvent:on_executed(...)
    _f_on_executed(self, ...)
    Trigger(self._id)
end