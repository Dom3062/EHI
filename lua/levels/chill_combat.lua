local EHI = EHI
if EHI:IsDifficultyOrAbove(EHI.Difficulties.DeathWish) then
    local SF = EHI.SpecialFunctions
    local TT = EHI.Trackers
    local achievements =
    {
        cac_30 =
        {
            elements =
            {
                [100979] = { status = "defend", class = TT.AchievementStatus },
                [102831] = { special_function = SF.SetAchievementComplete },
                [102829] = { special_function = SF.SetAchievementFailed }
            }
        }
    }

    EHI:ParseTriggers({
        mission = {},
        achievement = achievements
    })
end

local function ignore(instance, id, unit_data, unit)
    if unit:base() and unit:base().SetIgnore then
        unit:base():SetIgnore()
    end
end

local tbl =
{
    --units/payday2/props/stn_prop_armory_shelf_ammo/stn_prop_armory_shelf_ammo
    [100751] = { f = ignore },
    [101242] = { f = ignore }
}
EHI:UpdateUnits(tbl)
EHI._cache.diff = 1