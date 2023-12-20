local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
---@type ParseTriggerTable
local triggers = {
    [EHI:GetInstanceElementID(100108, 3200)] = { time = 45, id = "LockOpen", icons = { Icon.Wait }, hint = Hints.Wait },
    [EHI:GetInstanceElementID(100124, 3200)] = { id = "LockOpen", special_function = SF.RemoveTracker },

    [101770] = { time = 90, id = "EscapeHeli", icons = { Icon.Escape }, hint = Hints.Escape, waypoint = { position_by_element = EHI:GetInstanceElementID(100031, 20050) } }
}

local function berry_4_fail()
    managers.player:remove_listener("EHI_berry_4_fail")
    EHI:Unhook("berry_4_HuskPlayerMovement_sync_bleed_out")
    EHI:Unhook("berry_4_HuskPlayerMovement_sync_incapacitated")
    managers.ehi_tracker:SetAchievementFailed("berry_4")
end
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
            [102292] = { special_function = SF.Trigger, data = { 1, 2 } },
            [1] = { status = "no_down", class = TT.Achievement.Status },
            [2] = { special_function = SF.CustomCode, f = function()
                -- Player (Local)
                managers.player:add_listener("EHI_berry_4_fail", { "bleed_out", "incapacitated" }, berry_4_fail)

                -- Clients
                EHI:HookWithID(HuskPlayerMovement, "_sync_movement_state_bleed_out", "EHI_berry_4_HuskPlayerMovement_sync_bleed_out", berry_4_fail)
                EHI:HookWithID(HuskPlayerMovement, "_sync_movement_state_incapacitated", "EHI_berry_4_HuskPlayerMovement_sync_incapacitated", berry_4_fail)
            end }
        }
    }
}

---@param disable boolean
local function ToggleAssaultTracker(disable)
    managers.ehi_assault:SetControlStateBlock(disable, 30)
end
local other =
{
    [102292] = EHI:AddAssaultDelay({ time = 75 + 30 }),
    [101492] = { special_function = SF.CustomCode, f = ToggleAssaultTracker, arg = true },
    [101493] = { special_function = SF.CustomCode, f = ToggleAssaultTracker, arg = false }
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[EHI:GetInstanceElementID(101410, 10950)] = { id = "Snipers", class = TT.Sniper.Count, single_sniper = true }
    other[EHI:GetInstanceElementID(100019, 10950)] = { id = "Snipers", special_function = EHI:RegisterCustomSF(function(self, trigger, ...)
        local id = trigger.id
        if self._trackers:TrackerExists(id) then
            self._trackers:SetTrackerCount(id, 1)
            self._trackers:CallFunction(id, "SniperSpawnsSuccess")
        else
            self._trackers:AddTracker({
                id = id,
                count = 1,
                class = TT.Sniper.Count
            })
        end
    end) }
    other[EHI:GetInstanceElementID(100021, 10950)] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({
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
    add_to_counter = true
})

local tbl =
{
    [EHI:GetInstanceUnitID(100113, 0)] = { icons = { Icon.C4 }, hint = Hints.Explosion },

    -- Vaults
    -- Poseidon
    [EHI:GetInstanceUnitID(100005, 16550)] = { icons = { Icon.Vault }, position = Vector3(-6845, -2202, -800) },
    -- Ares
    [EHI:GetInstanceUnitID(100007, 16550)] = { icons = { Icon.Vault }, position = Vector3(-8737.18, -5842.67, -800) },
    -- Chronos
    [EHI:GetInstanceUnitID(100008, 16550)] = { icons = { Icon.Vault }, position = Vector3(-11417.6, -3197.62, -799.999) },
    -- Demeter
    [EHI:GetInstanceUnitID(100039, 16550)] = { icons = { Icon.Vault }, position = Vector3(-12702, -1630, -800) },
    -- Hades
    [EHI:GetInstanceUnitID(100040, 16550)] = { icons = { Icon.Vault }, position = Vector3(-9298, -195, -800) },
    -- Zeus
    [EHI:GetInstanceUnitID(100041, 16550)] = { icons = { Icon.Vault }, position = Vector3(-6845, -4202, -800) }
}
EHI:UpdateUnits(tbl)
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