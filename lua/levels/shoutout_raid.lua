local EHI = EHI
local Icon = EHI.Icons
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local show_achievement = EHI:GetOption("show_achievement")
local triggers = {
    [100107] = { time = 420, id = "trophy_longfellow", icons = { Icon.Trophy }, class = TT.Warning, condition = ovk_and_up }
}

EHI:ParseTriggers(triggers)
if show_achievement then
    EHI:ShowAchievementLootCounter({
        achievement = "melt_3",
        max = 8,
        exclude_from_sync = true,
        counter =
        {
            check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
            loot_type = { "coke", "gold", "money", "weapon", "weapons" }
        }
    })
end

local max = 6 -- Normal to Very Hard; Mission Loot
if ovk_and_up then
    max = 8
end
EHI:ShowLootCounter(max, 8) -- 14/16

local tbl =
{
    --levels/instances/unique/shout_container_vault
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    [EHI:GetInstanceElementID(100014, 2850)] = { ignore = true }
}
EHI:UpdateUnits(tbl)