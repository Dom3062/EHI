local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
---@type ParseTriggerTable
local triggers = {
    [100128] = { time = 38, id = "WinchDropTrainA", icons = { Icon.Winch, Icon.Goto }, hint = Hints.brb_WinchDelivery },
    [100164] = { time = 38, id = "WinchDropTrainB", icons = { Icon.Winch, Icon.Goto }, hint = Hints.brb_WinchDelivery },

    [100654] = { time = 120, id = "Winch", icons = { Icon.Winch }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists, hint = Hints.Winch },
    [100655] = { id = "Winch", special_function = SF.PauseTracker },
    [100656] = { id = "Winch", special_function = SF.UnpauseTracker },
    [EHI:GetInstanceElementID(100077, 2900)] = { time = 90, id = "Cutter", icons = { Icon.Glasscutter }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists, waypoint = { position_by_element_and_remove_vanilla_waypoint = EHI:GetInstanceElementID(100021, 2900) }, hint = Hints.Cutter },
    [EHI:GetInstanceElementID(100078, 2900)] = { id = "Cutter", special_function = SF.PauseTracker },
    [EHI:GetInstanceElementID(100103, 2900)] = { time = 5, id = "C4OfficeFloor", icons = { Icon.C4 }, hint = Hints.Explosion },

    [100124] = { time = 300/30, id = "ThermiteSewerGrate", icons = { Icon.Fire }, hint = Hints.Thermite },

    [100275] = { time = 20, id = "Van", icons = Icon.CarEscape, hint = Hints.LootEscape },

    [100142] = { time = 5, id = "C4Vault", icons = { Icon.C4 }, hint = Hints.Explosion }
}

if EHI:GetOption("show_mission_trackers") then
    for index = 1900, 2400, 500 do
        for _, unit_id in ipairs({ 100010, 100039, 100004, 100034 }) do
            local fixed_unit_id = EHI:GetInstanceUnitID(unit_id, index)
            managers.mission:add_runned_unit_sequence_trigger(fixed_unit_id, "interact", function(...)
                managers.ehi_tracker:AddTracker({
                    id = tostring(fixed_unit_id),
                    time = 50 + math.rand(10),
                    icons = { Icon.Fire },
                    class = TT.Inaccurate,
                    hint = Hints.Thermite
                })
            end)
        end
    end
end

---@type ParseAchievementTable
local achievements =
{
    brb_8 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard),
        elements =
        {
            [101136] = { max = 12, class = TT.Achievement.Progress, show_finish_after_reaching_target = true, special_function = SF.AddAchievementToCounter, data = {
                counter = {
                    check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
                    loot_type = "gold"
                }
            }}
        }
    }
}

local other =
{
    [100955] = EHI:AddAssaultDelay({ additional_time = 45 + 30, random_time = 15, special_function = EHI:RegisterCustomSpecialFunction(function(self, trigger, element, ...)
        if (EHI:IsHost() and element:counter_value() ~= 0) or self._trackers:TrackerExists(trigger.id) then
            return
        end
        self:CheckCondition(trigger)
    end) })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[EHI:GetInstanceElementID(100025, 16400)] = { id = "Snipers", class = TT.Sniper.Count }
    other[EHI:GetInstanceElementID(100090, 16400)] = { id = "Snipers", class = TT.Sniper.Count }
    --[[other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%]]
    other[EHI:GetInstanceElementID(100027, 16400)] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[EHI:GetInstanceElementID(100026, 16400)] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})

local tbl =
{
    --levels/instances/unique/brb/brb_vault
    --units/payday2/equipment/gen_interactable_lance_large/gen_interactable_lance_large
    [EHI:GetInstanceUnitID(100058, 1900)] = { remove_vanilla_waypoint = EHI:GetInstanceElementID(100003, 1900) },
    [EHI:GetInstanceUnitID(100058, 2400)] = { remove_vanilla_waypoint = EHI:GetInstanceElementID(100003, 2400) }
}
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 4000, name = "vault_found" },
        { amount = 8000, name = "vault_open" },
        { amount = 4000, name = "brb_medallion_taken" }
    },
    loot_all = 400,
    total_xp_override =
    {
        params =
        {
            min =
            {
                objectives = true
            },
            no_max = true
        }
    }
})