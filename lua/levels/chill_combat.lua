local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers

---@type ParseAchievementTable
local achievements =
{
    cac_30 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.DeathWish),
        elements =
        {
            [100979] = { status = EHI.Const.Trackers.Achievement.Status.Defend, class = TT.Achievement.Status },
            [102831] = { special_function = SF.SetAchievementComplete },
            [102829] = { special_function = SF.SetAchievementFailed }
        },
        sync_params = { from_start = true }
    }
}

local other =
{
    [101213] = EHI:AddAssaultDelay({})
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    -- Script sets required amount of snipers for each difficulty, however, ´spawn_random_sniper´ ElementRandom 102462 only spawns 1
    other[102447] = { chance = 100, id = "Snipers", class = TT.Sniper.Chance, single_sniper = true }
    other[102452] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[102453] = { id = "Snipers", special_function = SF.DecreaseCounter }
    other[102460] = { id = "Snipers", special_function = SF.RemoveTracker } -- Failed chance does not TRIGGER sniper_spawn again, it only increases chance
    other[102461] = { special_function = EHI.Manager:RegisterCustomSF(function(self, trigger, element, ...) ---@param element ElementLogicChanceOperator
        local chance = element._values.chance -- 30%
        if self._trackers:CallFunction2("Snipers", "SniperSpawnsSuccess", chance) then
            self._trackers:AddTracker({
                id = "Snipers",
                chance = chance,
                single_sniper = true,
                chance_success = true,
                class = TT.Sniper.Chance
            })
        end
    end) }
end

EHI.Manager:ParseTriggers({
    achievement = achievements,
    other = other,
    assault = { diff = 1 }
})
EHI:UpdateUnits({
    --units/payday2/props/stn_prop_armory_shelf_ammo/stn_prop_armory_shelf_ammo
    [100751] = { f = "IgnoreDeployable" },
    [101242] = { f = "IgnoreDeployable" }
})
EHI:AddXPBreakdown({
    wave_all = { amount = 14000, times = 3 }
})