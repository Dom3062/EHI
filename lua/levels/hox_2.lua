local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove("overkill")
local SecurityTearGasRandomElement = EHI:GetInstanceElementID(100061, 6690)
local element_sync_triggers =
{
    [EHI:GetInstanceElementID(100062, 6690)] = { id = "SecurityOfficeTeargas", icons = { Icon.Teargas }, hook_element = SecurityTearGasRandomElement }, -- 45s
    [EHI:GetInstanceElementID(100063, 6690)] = { id = "SecurityOfficeTeargas", icons = { Icon.Teargas }, hook_element = SecurityTearGasRandomElement }, -- 55s
    [EHI:GetInstanceElementID(100064, 6690)] = { id = "SecurityOfficeTeargas", icons = { Icon.Teargas }, hook_element = SecurityTearGasRandomElement } -- 65s
}
local request = { "wp_hack", Icon.Wait }
local hoxton_hack = { "hoxton_character" }
local CheckOkValueHostCheckOnly = EHI:GetFreeCustomSpecialFunctionID()
local AssaultDelay = 30
if EHI._cache.Client then
    AssaultDelay = AssaultDelay + 5
end
local triggers = {
    [100107] = { special_function = SF.Trigger, data = { 1001071, 1001072--[[, 1001073]] } },
    [1001071] = { id = "slakt_3", class = TT.AchievementNotification, condition = show_achievement and ovk_and_up },
    [1001072] = { id = "cac_26", class = TT.AchievementNotification, condition = show_achievement and ovk_and_up, exclude_from_sync = true },
    --[1001073] = { time = AssaultDelay, id = "AssaultDelay", stop_counting = EHI._cache.Host, class = TT.AssaultDelay },
    [100256] = { id = "slakt_3", special_function = SF.SetAchievementFailed },
    [100258] = { id = "slakt_3", special_function = SF.SetAchievementComplete },
    [101884] = { id = "cac_26", status = "finish", special_function = SF.SetAchievementStatus },
    [100320] = { id = "cac_26", special_function = SF.SetAchievementComplete },
    [100322] = { id = "cac_26", special_function = SF.SetAchievementFailed },
    [102016] = { time = 7, id = "Endless", icons = Icon.EndlessAssault, class = TT.Warning },

    [104579] = { time = 15, id = "Request", icons = request },
    [104580] = { time = 25, id = "Request", icons = request },
    [104581] = { time = 20, id = "Request", icons = request },
    [104582] = { time = 30, id = "Request", icons = request }, -- Disabled in the mission script

    [104509] = { time = 30, id = "HackRestartWait", icons = { "wp_hack", "restarter" } },

    [104314] = { max = 4, id = "RequestCounter", icons = { "wp_hack" }, class = TT.Progress, special_function = SF.AddTrackerIfDoesNotExist },

    [104599] = { id = "RequestCounter", special_function = SF.RemoveTracker },

    [104591] = { id = "RequestCounter", special_function = SF.IncreaseProgress },

    [104472] = { max = 4, id = "HoxtonMaxHacks", icons = hoxton_hack, class = TT.Progress },
    [104478] = { max = 4, id = "HoxtonMaxHacks", icons = hoxton_hack, class = TT.Progress, special_function = CheckOkValueHostCheckOnly, data = { progress = 1 } },
    [104480] = { max = 4, id = "HoxtonMaxHacks", icons = hoxton_hack, class = TT.Progress, special_function = CheckOkValueHostCheckOnly, data = { progress = 2 } },
    [104481] = { max = 4, id = "HoxtonMaxHacks", icons = hoxton_hack, class = TT.Progress, special_function = CheckOkValueHostCheckOnly, data = { progress = 3 } },
    [104482] = { max = 4, id = "HoxtonMaxHacks", icons = hoxton_hack, class = TT.Progress, special_function = CheckOkValueHostCheckOnly, data = { progress = 4, dont_create = true } },

    [105113] = { chance = 25, id = "ForensicsMatchChance", icons = { "equipment_evidence" }, class = TT.Chance },
    [102257] = { amount = 25, id = "ForensicsMatchChance", special_function = SF.IncreaseChance },
    [105137] = { id = "ForensicsMatchChance", special_function = SF.RemoveTracker }
}
if Network:is_client() then
    triggers[EHI:GetInstanceElementID(100055, 6690)] = { id = "SecurityOfficeTeargas", icons = { Icon.Teargas }, class = TT.Inaccurate, special_function = SF.SetRandomTime, data = { 45, 55, 65 } }
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end

EHI:ParseTriggers(triggers)
EHI:RegisterCustomSpecialFunction(CheckOkValueHostCheckOnly, function(id, trigger, element, enabled)
    local continue = false
    if EHI._cache.Host then
        if element:_values_ok() then
            continue = true
        end
    else
        continue = true
    end
    if continue then
        if managers.ehi:TrackerExists(trigger.id) then
            managers.ehi:SetTrackerProgress(trigger.id, trigger.data.progress)
        elseif not trigger.data.dont_create then
            EHI:CheckCondition(id)
            managers.ehi:SetTrackerProgress(trigger.id, trigger.data.progress)
        end
    end
end)
EHI:AddLoadSyncFunction(function(self) -- Works only when the hack is running
    local pc = managers.worlddefinition:get_unit(104418) -- 1
    if pc then
        EHI:Log("Checking PC Unit 104418")
        local timer = pc:timer_gui()
        if timer._started and not timer._done then
            EHI:Log("PC Unit 104418 condition is true -> progress 1/4")
            EHI:CheckCondition(104478)
            return
        end
    else -- Just in case, but the PC should exists
        EHI:Log("PC Unit 104418 is nil")
        return
    end
    local pc = managers.worlddefinition:get_unit(102413) -- 2
    if pc then
        EHI:Log("Checking PC Unit 102413")
        local timer = pc:timer_gui()
        if timer._started and not timer._done then
            EHI:Log("PC Unit 102413 condition is true -> progress 2/4")
            EHI:CheckCondition(104480)
            return
        end
    else -- Just in case, but the PC should exists
        EHI:Log("PC Unit 102413 is nil")
        return
    end
    local pc = managers.worlddefinition:get_unit(102414) -- 3
    if pc then
        EHI:Log("Checking PC Unit 102414")
        local timer = pc:timer_gui()
        if timer._started and not timer._done then
            EHI:Log("PC Unit 102414 condition is true -> progress 3/4")
            EHI:CheckCondition(104481)
            return
        end
    else -- Just in case, but the PC should exists
        EHI:Log("PC Unit 102414 is nil")
        return
    end
    -- Pointless to query the last PC
end)

local tbl =
{
    --units/pd2_dlc_old_hoxton/equipment/stn_interactable_computer_director/stn_interactable_computer_director
    [102104] = { remove_vanilla_waypoint = true, waypoint_id = 104571, restore_waypoint_on_done = true }
}
EHI:UpdateUnits(tbl)