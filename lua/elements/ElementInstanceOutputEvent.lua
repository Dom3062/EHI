if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

local EHI = rawget(_G, "EHI")
if EHI._hooks.ElementInstanceOutputEvent then
    return
else
    EHI._hooks.ElementInstanceOutputEvent = true
end

core:module("CoreElementInstance")
local level_id = Global.game_settings.level_id
local difficulty = Global.game_settings.difficulty
local difficulty_index = EHI:DifficultyToIndex(difficulty)
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = difficulty_index >= 3
local triggers = {}
local trigger_id_all = "Trigger"
local SF = EHI:GetSpecialFunctions()
SF.MeltdownAddCrowbar = 999
if level_id == "pbr" then -- Beneath the Mountain
    triggers = {
        [101774] = { time = 90, id = "EscapeHeli", icons = { "pd2_escape" } }
    }
elseif level_id == "mad" then -- Boiling Point
    triggers = {
        -- EMP Bomb
        [100225] = { time = 120, id = "EMP", icons = { "pd2_defend" }, class = "EHIPausableTracker" },
        [101282] = { id = "EMP", special_function = SF.PauseTracker },
        [101283] = { id = "EMP", special_function = SF.UnpauseTracker },

        -- Scan
        -- No need to track 100228
        [100897] = { id = "scan", special_function = SF.PauseTracker }, -- Scan interrupted
        [100898] = { id = "scan", special_function = SF.PauseTracker }, -- Power interrupted
        -- No need to track if power has been restored
    }
elseif level_id == "vit" then -- The White House
    triggers = {
        [102335] = { time = 60, id = "Thermite", icons = { "pd2_fire" } }, -- units/pd2_dlc_vit/props/security_shutter/vit_prop_branch_security_shutter
        [102104] = { time = 30 + 26, id = "LockeHeliEscape", icons = { "heli", "pd2_escape" } } -- 30s delay + 26s escape zone delay
    }
elseif level_id == "moon" then -- Stealing Xmas
    triggers = {
        [100647] = { time = 10, id = "SantaTalk", icons = { "pd2_talk" }, special_function = SF.ExecuteIfElementIsEnabled },
        [100159] = { time = 5 + 7 + 7.3, id = "Escape", icons = { "pd2_escape" }, special_function = SF.ExecuteIfElementIsEnabled }
    }
elseif level_id == "spa" then -- Brooklyn 10-10
    triggers = {
        [102266] = { max = 6, id = "SniperDeath", icons = { "sniper", "pd2_kill" }, class = "EHIProgressTracker" },
        [100833] = { id = "SniperDeath", special_function = SF.RemoveTracker }
    }
elseif level_id == "nail" then -- Lab Rats
    triggers = {
        [101936] = { time = 30 + 12, id = "Escape", icons = { "heli", "pd2_escape" } }
    }
elseif level_id == "des" then -- Henry's Rock
    triggers = {
        [100296] = { max = 2, id = "uno_5", icons = { "C_Locke_H_HenrysRock_Hack" }, class = "EHIAchievementProgressTracker", condition = show_achievement and ovk_and_up },
        [100423] = { time = 60 + 25 + 3, id = "EscapeHeli", icons = { "heli", "pd2_escape", "pd2_lootdrop" } },
        -- 60s delay after flare has been placed
        -- 25s to land
        -- 3s to open the heli doors

        [102593] = { time = 30, id = "ChemSetReset", icons = { "restarter" } },
        [101217] = { time = 30, id = "ChemSetInterrupted", icons = { "restarter" }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "ChemSetCooking" }},
        [102595] = { time = 30, id = "ChemSetCooking", icons = { "pd2_defend" } },

        [101447] = { id = "Crane", special_function = SF.PauseTracker },
        [101448] = { id = "Crane", special_function = SF.UnpauseTracker }
    }
elseif level_id == "bph" then -- Hell's Island
    triggers = {
        [101221] = { time = 11, id = "Thermite1", icons = { "pd2_fire" } },
        [101714] = { time = 11, id = "Thermite2", icons = { "pd2_fire" } },
        [101715] = { time = 11, id = "Thermite3", icons = { "pd2_fire" } },
        [101716] = { time = 11, id = "Thermite4", icons = { "pd2_fire" } }
    }
elseif level_id == "cane" then -- Santa's Workshop
    triggers = {
        [100476] = { id = "cane_3", special_function = SF.IncreaseProgress }
    }
elseif level_id == "flat" then -- Panic Room
    local kills = 7 -- Normal + Hard
    if difficulty_index == 2 or difficulty_index == 3 then
        -- Very Hard + OVERKILL
        kills = 10
    elseif difficulty_index >= 4 then
        -- Mayhem+
        kills = 15
    end
    triggers = {
        [100068] = { max = kills, id = "SniperDeath", icons = { "sniper", "pd2_kill" }, class = "EHIProgressTracker" },
        [103446] = { time = 20 + 6 + 4, id = "HeliDropsC4", icons = { "heli", "pd2_c4", "pd2_goto" } },
        [100082] = { time = 40, id = "HeliComesWithMagnet", icons = { "heli", "equipment_winch_hook" } }
    }
elseif level_id == "shoutout_raid" then -- Meltdown
    triggers = {
        [107062] = { id = "Vault", special_function = SF.MeltdownAddCrowbar } -- First Fan
    }
elseif level_id == "tag" then -- Breakin' Feds
    local time = 10 -- Normal
    if difficulty_index == 1 or difficulty_index == 2 then
        -- Hard + Very Hard
        time = 15
    elseif difficulty_index == 3 then
        -- OVERKILL
        time = 20
    elseif difficulty_index == 4 or difficulty_index == 5 then
        -- Mayhem + Death Wish
        time = 30
    elseif difficulty_index == 6 then
        -- Death Sentence
        time = 40
    end
    triggers = {
        [101282] = { time = 5 + time, id = "KeypadReset", icons = { "faster" } }
    }
elseif level_id == "chas" then -- Dragon Heist
    triggers = {
        [102863] = { time = 41.5, id = "TramArrivesWithDrill", icons = { "pd2_drill", "pd2_generic_interact" } },
        [101660] = { time = 120, id = "Gas", icons = { "teargas" } }
    }
elseif level_id == "rat" then -- Cook Off
    triggers = {
        [102611] = { id = "voff_5", special_function = SF.IncreaseProgress }
    }
elseif level_id == "brb" then -- Brooklyn Bank
    triggers = {
        [100837] = { random_time = { low = 50, high = 60 }, id = "VaultThermite", icons = { "pd2_fire" }, class = "EHIInaccurateTracker", trigger_at = 4, trigger_count = 0 }
    }
elseif level_id == "arena" then -- The Alesso Heist
    triggers = {
        [100304] = { time = 5, id = "live_3", icons = { "C_Bain_H_Arena_Even" } }
    }
elseif level_id == "dah" then -- Diamond Heist
    triggers = {
        [101343] = { time = 30, id = "KeypadReset", icons = { "restarter" } }
    }
elseif level_id == "mex_cooking" then -- Border Crystals
    triggers = {
        [103573] = { time = 30, random_time = { low = 0, high = 10 }, id = "CookingStartDelay", icons = { "pd2_methlab", "faster" }, class = "EHIInaccurateTracker" },
        [103574] = { time = 30, random_time = { low = 0, high = 10 }, id = "CookingStartDelay", icons = { "pd2_methlab", "faster" }, class = "EHIInaccurateTracker" }
    }
elseif level_id == "fex" then -- Buluc's Mansion
    triggers = {
        [102943] = { time = 180 + 2, id = "HeliEscape", icons = { "heli", "pd2_escape", "pd2_lootdrop" } }
    }
else
    return
end

local function GetTime(id)
    local full_time = triggers[id].time or 0
    full_time = full_time + (triggers[id].random_time and math.random(triggers[id].random_time.low, triggers[id].random_time.high) or 0)
    return full_time
end

local function CreateTrackerForReal(id)
    local trigger_times = triggers[id].trigger_times
    local trigger_count = triggers[id].trigger_count
    local trigger_at = triggers[id].trigger_at
    if trigger_times then
        if trigger_times == 0 then
            return
        else
            triggers[id].trigger_times = triggers[id].trigger_times - 1
        end
    end
    if trigger_at then
        if trigger_at ~= trigger_count then
            triggers[id].trigger_count = triggers[id].trigger_count + 1
            return
        end
    end
    managers.hud:AddTracker({
        id = triggers[id].id or trigger_id_all,
        max = triggers[id].max,
        time = GetTime(id),
        icons = triggers[id].icons,
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
        managers.hud:Debug(id, "ElementInstanceOutputEvent")
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
            elseif f == SF.IncreaseProgress then
                managers.hud:IncreaseProgress(triggers[id].id)
            elseif f == SF.ExecuteIfElementIsEnabled then
                if enabled then
                    CreateTracker(id)
                end
            elseif f == SF.MeltdownAddCrowbar then
                managers.hud.ehi:CallFunction(triggers[id].id, "AddCrowbar")
            end
        else
            CreateTracker(id)
        end
    end
end

local _f_client_on_executed = ElementInstanceOutputEvent.client_on_executed
function ElementInstanceOutputEvent:client_on_executed(...)
    _f_client_on_executed(self, ...)
    Trigger(self._id, self._values.enabled)
end

local _f_on_executed = ElementInstanceOutputEvent.on_executed
function ElementInstanceOutputEvent:on_executed(...)
    _f_on_executed(self, ...)
    Trigger(self._id, self._values.enabled)
end