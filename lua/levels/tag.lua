local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = false
local time = 10 -- Normal
if EHI:IsBetweenDifficulties("hard", "very_hard") then
    -- Hard + Very Hard
    time = 15
elseif EHI:IsDifficulty("overkill") then
    -- OVERKILL
    time = 20
    ovk_and_up = true
elseif EHI:IsBetweenDifficulties("mayhem", "death_wish") then
    -- Mayhem + Death Wish
    time = 30
    ovk_and_up = true
elseif EHI:IsDifficulty("death_sentence") then
    -- Death Sentence
    time = 40
    ovk_and_up = true
end
local triggers = {
    [100107] = { special_function = SF.Trigger, data = { 1001071, 1001072, 1001073 } },
    [1001071] = { id = "tag_9", class = TT.AchievementNotification, contidition = show_achievement and ovk_and_up, exclude_from_sync = true },
    [1001072] = { id = "tag_10", status = "ready", class = TT.AchievementNotification, exclude_from_sync = true },
    [101335] = { time = 7, id = "C4BasementWall", icons = { "pd2_c4" } },
    [101968] = { time = 10, id = "LureDelay", icons = { "faster" } },

    [101282] = { time = 5 + time, id = "KeypadReset", icons = { "faster" } },

    [100609] = { id = "tag_9", special_function = SF.SetAchievementComplete },
    [100617] = { id = "tag_9", special_function = SF.SetAchievementFailed }
}
for _, index in pairs({13350, 14450, 14950, 15450, 15950, 16450, 16950, 17450}) do
    triggers[EHI:GetInstanceElementID(100176, index)] = { time = 30, id = "KeypadRebootECM", icons = { "restarter" } }
end
for _, index in pairs({4550, 5450}) do
    triggers[EHI:GetInstanceElementID(100319, index)] = { id = "tag_10", special_function = SF.SetAchievementFailed }
    triggers[EHI:GetInstanceElementID(100321, index)] = { id = "tag_10", status = "ok", special_function = SF.SetAchievementStatus }
    triggers[EHI:GetInstanceElementID(100282, index)] = { id = "tag_10", special_function = SF.SetAchievementComplete }
end

EHI:ParseTriggers(triggers)