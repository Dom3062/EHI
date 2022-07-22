local EHI = EHI
if EHI:GetOption("show_achievement") and EHI:IsDifficultyOrAbove(EHI.Difficulties.DeathWish) then
    local SF = EHI.SpecialFunctions
    local TT = EHI.Trackers
    local triggers = {
        [100979] = { id = "cac_30", class = TT.AchievementNotification, exclude_from_sync = true },
        [102831] = { id = "cac_30", special_function = SF.SetAchievementComplete },
        [102829] = { id = "cac_30", special_function = SF.SetAchievementFailed }
    }

    EHI:ParseTriggers(triggers)
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