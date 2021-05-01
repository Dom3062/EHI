if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

local EHI = rawget(_G, "EHI")
if EHI._hooks.ElementUnitSequence then -- Don't hook multiple times, pls
    return
else
    EHI._hooks.ElementUnitSequence = true
end

core:module("CoreElementUnitSequence")

local function GetInstanceElementID(id, start_index)
    return 100000 + math.mod(id, 100000) + 30000 + start_index
end

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
    SetTimeOrCreateTracker = 11,
    SetTimeByGlobalOrCreateTracker = 12,
    SetTrackerAccurate = 27,
    ExecuteDifferentTriggerByGlobal = 99
}
local Icon =
{
    Achievement = "achievement",
    Fire = "pd2_fire",
    Escape = "pd2_escape",
    LootDrop = "pd2_lootdrop",
    Fix = "pd2_fix",
    Bag = "wp_bag",
    Defend = "pd2_defend",
    C4 = "pd2_c4",
    Interact = "pd2_generic_interact"
}
local level_id = Global.game_settings.level_id
local triggers = {}
local trigger_id_all = "Trigger"
local trigger_icon_all = {}
if level_id == "moon" then -- Stealing Xmas
    triggers = {
        [100578] = { time = 9, id = "C4", icons = { "heli", Icon.C4, "pd2_goto" }, special_function = SF.SetTimeOrCreateTracker }
    }
elseif level_id == "firestarter_3" or level_id == "branchbank" or level_id == "branchbank_gold" or level_id == "branchbank_cash" or level_id == "branchbank_deposit" then
    -- Firestarter Day 3, Branchbank: Random, Branchbank: Gold, Branchbank: Cash, Branchbank: Deposit
    triggers = {
        [101425] = { time = 24 + 7, id = "TeargasIncoming1", icons = { "teargas", "pd2_generic_look" }, class = "EHIWarningTracker" },
        [105611] = { time = 24 + 7, id = "TeargasIncoming2", icons = { "teargas", "pd2_generic_look" }, class = "EHIWarningTracker" }
    }
elseif level_id == "help" then -- Prison Nightmare
    triggers = {
        [100866] = { time = 5, id = "C4Explosion", icons = { Icon.C4 } }
    }
elseif level_id == "dark" then -- Murky Station
    triggers = {
        [106036] = { time = 410/30, id = "Boat", icons = { "boat", "pd2_escape", "pd2_lootdrop" } }
    }
elseif level_id == "big" then -- The Big Bank
    triggers = {
        [101377] = { time = 5, id = "C4Explosion", icons = { Icon.C4 } },
        [104532] = { time = 20, id = "PCHack", icons = { "wp_hack" } },
        [103179] = { time = 20, id = "PCHack", icons = { "wp_hack" } },
        [103259] = { time = 20, id = "PCHack", icons = { "wp_hack" } },
        [103590] = { time = 20, id = "PCHack", icons = { "wp_hack" } },
        [103620] = { time = 20, id = "PCHack", icons = { "wp_hack" } },
        [103671] = { time = 20, id = "PCHack", icons = { "wp_hack" } },
        [103734] = { time = 20, id = "PCHack", icons = { "wp_hack" } },
        [103776] = { time = 20, id = "PCHack", icons = { "wp_hack" } },
        [103815] = { time = 20, id = "PCHack", icons = { "wp_hack" } },
        [103903] = { time = 20, id = "PCHack", icons = { "wp_hack" } },
        [103920] = { time = 20, id = "PCHack", icons = { "wp_hack" } },
        [103936] = { time = 20, id = "PCHack", icons = { "wp_hack" } },
        [103956] = { time = 20, id = "PCHack", icons = { "wp_hack" } },
        [103974] = { time = 20, id = "PCHack", icons = { "wp_hack" } },
        [103988] = { time = 20, id = "PCHack", icons = { "wp_hack" } },
        [104014] = { time = 20, id = "PCHack", icons = { "wp_hack" } },
        [104029] = { time = 20, id = "PCHack", icons = { "wp_hack" } },
        [104051] = { time = 20, id = "PCHack", icons = { "wp_hack" } },

        -- Heli escape
        [104126] = { time = 23 + 1, id = "HeliEscape", icons = { "heli", "pd2_escape", "pd2_lootdrop" } },

        [104091] = { time = 200/30, id = "CraneLiftUp", icons = { "piggy" } },
        [104261] = { time = 1000/30, id = "CraneMoveLeft", icons = { "piggy" } },
        [104069] = { time = 1000/30, id = "CraneMoveRight", icons = { "piggy" } }
    }
elseif level_id == "dinner" then -- Slaughterhouse
    triggers = {
        [100915] = { time = 4640/30, id = "CraneGasMove", icons = { "equipment_winch_hook", Icon.Fire, "pd2_goto" } },
        [100967] = { time = 3660/30, id = "CraneGoldMove", icons = { Icon.Escape } }
    }
elseif level_id == "flat" then -- Panic Room
    triggers = {
        [100206] = { time = 30, id = "LoweringTheWinch", icons = { "heli", "equipment_winch_hook", "pd2_goto" }}
    }
elseif level_id == "rat" then -- Cook Off
    triggers = {
        [101982] = { special_function = SF.ExecuteDifferentTriggerByGlobal, data = { id = "VanReturn", yes = 1019822, no = 1019821 } },
        [1019821] = { time = 589/30 + 3, id = "Van", icons = { "pd2_car", Icon.Escape, Icon.LootDrop }, special_function = SF.SetTimeOrCreateTracker },
        [1019822] = { time = 589/30, id = "VanReturn", icons = { "pd2_car", Icon.Escape, Icon.LootDrop }, special_function = SF.SetTimeOrCreateTracker },
        [100954] = { time = 24 + 5 + 3, id = "HeliBulldozerSpawn", icons = { "heli", "heavy", "pd2_goto" }, class = "EHIWarningTracker" }
    }
elseif level_id == "alex_1"  then -- Rats Day 1
    triggers = {
        [100954] = { time = 24 + 5 + 3, id = "HeliBulldozerSpawn", icons = { "heli", "heavy", "pd2_goto" }, class = "EHIWarningTracker" }
    }
elseif level_id == "crojob3" or level_id == "crojob3_night" then -- The Bomb: Forest
    triggers = {
        -- Right
        [100283] = { time = 86 },
        [100284] = { time = 86 },
        [100288] = { time = 86 },

        -- Left
        [100285] = { time = 90 },
        [100286] = { time = 90 },
        [100560] = { time = 90 },

        -- Top
        [100282] = { time = 90 },
        [100287] = { time = 90 },
        [100558] = { time = 90 },
        [100559] = { time = 90 }
    }
    trigger_id_all = "Thermite"
    trigger_icon_all = { "pd2_fire" }
elseif level_id == "cane" then -- Santa's Workshop
    triggers = {
        [GetInstanceElementID(100135, 11300)] = { time = 12, id = "SafeEvent", icons = { "heli", "pd2_goto" } }
    }
elseif level_id == "peta2" then -- Goat Simulator Heist Day 2
    triggers = {
        [GetInstanceElementID(100011, 3750)] = { time = 15 + 1 + 60 + 6.5, id = "PilotComingInAgain", icons = { "heli", Icon.Interact } },
        [GetInstanceElementID(100011, 4250)] = { time = 15 + 1 + 60 + 6.5, id = "PilotComingInAgain", icons = { "heli", Icon.Interact } },
        [GetInstanceElementID(100011, 4750)] = { time = 15 + 1 + 60 + 6.5, id = "PilotComingInAgain", icons = { "heli", Icon.Interact } }
    }
elseif level_id == "rvd1" then -- Reservoir Dogs Heist Day 2
    triggers = {
        [100207] = { time = 260/30, id = "Escape", icons = { Icon.Escape, Icon.LootDrop }, special_function = SF.SetTimeOrCreateTracker },
        [100209] = { time = 250/30, id = "Escape", icons = { Icon.Escape, Icon.LootDrop }, special_function = SF.SetTimeOrCreateTracker },

        [101114] = { time = 260/30,  id = "PinkArrival", icons = { "pd2_goto" }, special_function = SF.SetTimeOrCreateTracker },
        [101127] = { time = 201/30,  id = "PinkArrival", icons = { "pd2_goto" }, special_function = SF.SetTimeOrCreateTracker },
        [101108] = { time = 284/30,  id = "PinkArrival", icons = { "pd2_goto" }, special_function = SF.SetTimeOrCreateTracker }
    }
elseif level_id == "arm_fac" then -- Transport: Harbor
    triggers = {
        [100215] = { time = 674/30, id = "Escape", icons = { Icon.Escape, Icon.LootDrop }, special_function = SF.SetTimeOrCreateTracker },
        [100216] = { time = 543/30, id = "Escape", icons = { Icon.Escape, Icon.LootDrop }, special_function = SF.SetTimeOrCreateTracker }
    }
elseif level_id == "brb" then -- Brooklyn Bank
    triggers = {
        [100275] = { time = 20, id = "Van", icons = { "pd2_car", Icon.Escape, Icon.LootDrop } }
    }
elseif level_id == "bex" then -- San Martín Bank
    triggers = {
        [101820] = { time = 9.3, id = "HeliDropLance", icons = { "heli", "pd2_drill", "pd2_goto" }, special_function = SF.SetTrackerAccurate },
        [GetInstanceElementID(100011, 20450)] = { id = "ServerHack", special_function = SF.RemoveTracker }
    }
elseif level_id == "pex" then -- Breakfast in Tijuana
    triggers = {
        [101460] = { time = 18, id = "DoorBreach", icons = { "pd2_door" } }
    }
elseif level_id == "fex" then -- Buluc's Mansion
    triggers = {
        -- Wanker car
        [GetInstanceElementID(100029, 27580)] = { time = 610/30 + 2, id = "CarEscape", icons = { "pd2_car", "pd2_escape", "pd2_lootdrop" }, special_function = SF.SetTimeOrCreateTracker },

        [GetInstanceElementID(100026, 24580)] = { time = 26.5 + 5, id = "CarBurn", icons = { "pd2_car", "pd2_fire" } }
    }
else
    return
end

local function CreateTracker(id)
    managers.hud:AddTracker({
        id = triggers[id].id or trigger_id_all,
        time = triggers[id].time,
        icons = triggers[id].icons or trigger_icon_all,
        class = triggers[id].class
    })
end

local function Trigger(id)
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
            elseif f == SF.SetTimeOrCreateTracker then
                if managers.hud:TrackerExists(triggers[id].id) then
                    managers.hud:SetTime(triggers[id].id, triggers[id].time)
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
            elseif f == SF.ExecuteDifferentTriggerByGlobal then
                if EHI._cache[triggers[id].data.id] then
                    Trigger(triggers[id].data.yes)
                else
                    Trigger(triggers[id].data.no)
                end
                EHI._cache[triggers[id].data.id] = nil
            end
        else
            if triggers[id].condition ~= nil then
            else
                CreateTracker(id)
            end
        end
    end
end

local _f_client_on_executed = ElementUnitSequence.client_on_executed
function ElementUnitSequence:client_on_executed(...)
    _f_client_on_executed(self, ...)
    Trigger(self._id)
end

local _f_on_executed = ElementUnitSequence.on_executed
function ElementUnitSequence:on_executed(...)
    _f_on_executed(self, ...)
    Trigger(self._id)
end