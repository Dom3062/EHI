local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers = {
    --[102292] = { time = 75 + 30, id = "AssaultDelay", class = TT.AssaultDelay },

    [EHI:GetInstanceElementID(100108, 3200)] = { time = 45, id = "LockOpen", icons = { Icon.Wait } },
    [EHI:GetInstanceElementID(100124, 3200)] = { id = "LockOpen", special_function = SF.RemoveTracker },

    [101774] = { time = 90, id = "EscapeHeli", icons = { Icon.Escape } }
}

local function berry_4_fail()
    managers.player:remove_listener("EHI_berry_4_bleedout")
    managers.player:remove_listener("EHI_berry_4_incapacitated")
    EHI:Unhook("berry_4_HuskPlayerMovement_sync_bleed_out")
    EHI:Unhook("berry_4_HuskPlayerMovement_sync_incapacitated")
    managers.ehi:SetAchievementFailed("berry_4")
end
local achievements =
{
    [102290] = { id = "berry_3", special_function = SF.SetAchievementComplete },
    [102292] = { special_function = SF.Trigger, data = { 1022921, 1022922, 1022923 } },
    [1022921] = { time = 600, id = "berry_3", class = TT.Achievement, difficulty_pass = ovk_and_up },
    [1022922] = { status = "no_down", id = "berry_4", class = TT.AchievementStatus, difficulty_pass = ovk_and_up },
    [1022923] = { special_function = SF.CustomCode, f = function()
        if EHI:IsAchievementLocked("berry_4") and ovk_and_up and show_achievement then
            -- Player
            managers.player:add_listener("EHI_berry_4_bleedout", {"bleed_out"}, berry_4_fail)
            managers.player:add_listener("EHI_berry_4_incapacitated", {"incapacitated"}, berry_4_fail)

            -- Clients
            EHI:HookWithID(HuskPlayerMovement, "_sync_movement_state_bleed_out", "EHI_berry_4_HuskPlayerMovement_sync_bleed_out", function(...)
                berry_4_fail()
            end)
            EHI:HookWithID(HuskPlayerMovement, "_sync_movement_state_incapacitated", "EHI_berry_4_HuskPlayerMovement_sync_incapacitated", function(...)
                berry_4_fail()
            end)
        end
    end },
    [EHI:GetInstanceElementID(100041, 20050)] = { id = "berry_2", special_function = SF.FinalizeAchievement }
}

EHI:ParseTriggers(triggers, achievements)
EHI:ShowAchievementLootCounter({
    achievement = "berry_2",
    max = 10,
    exclude_from_sync = true,
    show_loot_counter = true
})

local tbl =
{
    [EHI:GetInstanceElementID(100113, 0)] = { icons = { Icon.C4 } }
}
EHI:UpdateUnits(tbl)