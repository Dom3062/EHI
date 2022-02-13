local Icon = EHI.Icons
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove("overkill")
local show_achievement = EHI:GetOption("show_achievement")
local triggers = {
    [100107] = { time = 420, id = "trophy_longfellow", icons = { Icon.Trophy }, class = TT.Warning, condition = ovk_and_up }
}

EHI:ParseTriggers(triggers)
local show_loot_counter = false
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
    if managers.ehi:TrackerExists("melt_3") then
        local max = 6 -- Normal to Very Hard; Mission Loot
        if ovk_and_up then
            max = 8
        end
        EHI:ShowLootCounter(max, 0, EHI.LootCounter.CheckType.OneTypeOfLoot, "warhead")
    else
        show_loot_counter = true
    end
else
    show_loot_counter = true
end

if show_loot_counter then
    local max = 6 -- Normal to Very Hard; Mission Loot
    if ovk_and_up then
        max = 8
    end
    max = max + 8 -- Loot
    EHI:ShowLootCounter(max) -- 14/16
end