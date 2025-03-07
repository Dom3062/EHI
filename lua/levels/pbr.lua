local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
---@type ParseTriggerTable
local triggers = {
    [101770] = { time = 90, id = "EscapeHeli", icons = { Icon.Escape }, hint = Hints.Escape, waypoint = { position_from_element = EHI:GetInstanceElementID(100031, 20050) } }
}

local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
---@type ParseAchievementTable
local achievements =
{
    berry_3 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [102292] = { time = 600, class = TT.Achievement.Base },
            [102290] = { special_function = SF.SetAchievementComplete }
        }
    },
    berry_4 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [102292] = { special_function = EHI.Manager:RegisterCustomSF(function(self, trigger, ...)
                local function berry_4_fail()
                    managers.player:remove_listener("EHI_berry_4_fail")
                    EHI:Unhook("berry_4_HuskPlayerMovement_sync_bleed_out")
                    EHI:Unhook("berry_4_HuskPlayerMovement_sync_incapacitated")
                    self._unlockable:SetAchievementFailed("berry_4")
                end
                self._unlockable:AddAchievementStatusTracker(trigger.id, "no_down")
                -- Player (Local)
                managers.player:add_listener("EHI_berry_4_fail", { "bleed_out", "incapacitated" }, berry_4_fail)
                -- Clients
                Hooks:PostHook(HuskPlayerMovement, "_sync_movement_state_bleed_out", "EHI_berry_4_HuskPlayerMovement_sync_bleed_out", berry_4_fail)
                Hooks:PostHook(HuskPlayerMovement, "_sync_movement_state_incapacitated", "EHI_berry_4_HuskPlayerMovement_sync_incapacitated", berry_4_fail)
            end) }
        },
        sync_params = { from_start = true }
    }
}

---@param self EHIManager
---@param disable boolean
local function ToggleAssaultTracker(self, disable)
    self._assault:SetControlStateBlock(disable, 30)
end
local other =
{
    [102292] = EHI:AddAssaultDelay({ control = 75 }),
    [101492] = { special_function = SF.CustomCode2, f = ToggleAssaultTracker, arg = true },
    [101491] = { special_function = SF.CustomCode2, f = ToggleAssaultTracker, arg = false },

    [100237] = EHI:AddSniperSpawnedPopup(true),
    [101502] = EHI:AddSniperSpawnedPopup(true),
    [101610] = EHI:AddSniperSpawnedPopup(true, true),
    [EHI:GetInstanceElementID(100239, 10950)] = EHI:AddSniperSpawnedPopup()
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[EHI:GetInstanceElementID(101410, 10950)] = { id = "Snipers", class = TT.Sniper.Count, single_sniper = true }
    other[EHI:GetInstanceElementID(100019, 10950)] = { id = "Snipers", special_function = EHI.Manager:RegisterCustomSF(function(self, trigger, ...)
        if self._trackers:CallFunction2(trigger.id, "SniperSpawnsSuccess", 1) then
            self._trackers:AddTracker({
                id = trigger.id,
                count = 1,
                single_sniper = true,
                snipers_spawned = true,
                class = TT.Sniper.Count
            })
        end
    end) }
    other[EHI:GetInstanceElementID(100021, 10950)] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI.Manager:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:ShowAchievementLootCounter({
    achievement = "berry_2",
    max = 10,
    show_loot_counter = true,
    triggers =
    {
        [EHI:GetInstanceElementID(100041, 20050)] = { special_function = SF.FinalizeAchievement }
    },
    add_to_counter = true,
    waypoint_loot_counter = { element = EHI:GetInstanceElementID(100013, 20050) }
})

EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 2000, name = "btm_blasted_entrance" },
        { amount = 2500, name = "btm_used_keycard" },
        { amount = 3000, name = "btm_request_approved" },
        { amount = 1000, name = "btm_vault_open_loot" },
        { amount = 1500, name = "btm_destroyed_comm" },
        { amount = 3000, name = "btm_heli_refueled" },
        { escape = 4000 }
    },
    loot_all = 700,
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                objectives =
                {
                    btm_vault_open_loot = { min = 2, max = 4 },
                    btm_destroyed_comm = { min_max = 3 }
                },
                loot_all = { min = 2, max = 10 }
            }
        }
    }
})