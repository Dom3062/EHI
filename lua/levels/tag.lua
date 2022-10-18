local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = false
local time = 10 -- Normal
if EHI:IsBetweenDifficulties(EHI.Difficulties.Hard, EHI.Difficulties.VeryHard) then
    -- Hard + Very Hard
    time = 15
elseif EHI:IsDifficulty(EHI.Difficulties.OVERKILL) then
    -- OVERKILL
    time = 20
    ovk_and_up = true
elseif EHI:IsBetweenDifficulties(EHI.Difficulties.Mayhem, EHI.Difficulties.DeathWish) then
    -- Mayhem + Death Wish
    time = 30
    ovk_and_up = true
elseif EHI:IsDifficulty(EHI.Difficulties.DeathSentence) then
    -- Death Sentence
    time = 40
    ovk_and_up = true
end
local triggers = {
    [101335] = { time = 7, id = "C4BasementWall", icons = { Icon.C4 } },
    [101968] = { time = 10, id = "LureDelay", icons = { Icon.Wait } },

    [101282] = { time = 5 + time, id = "KeypadReset", icons = { Icon.Wait } }
}
for _, index in ipairs({ 13350, 14450, 14950, 15450, 15950, 16450, 16950, 17450 }) do
    --, waypoint = { icon = Icon.Loop, position_by_element = EHI:GetInstanceElementID(100179, index) }
    triggers[EHI:GetInstanceElementID(100176, index)] = { time = 30, id = "KeypadRebootECM", icons = { Icon.Loop } }
end

local achievements =
{
    [100107] = { special_function = SF.Trigger, data = { 1001071, 1001072, 1001073 } },
    [1001071] = { id = "tag_9", class = TT.AchievementStatus, difficulty_pass = ovk_and_up },
    [1001072] = { id = "tag_10", status = "mark", class = TT.AchievementStatus },

    [100609] = { id = "tag_9", special_function = SF.SetAchievementComplete },
    [100617] = { id = "tag_9", special_function = SF.SetAchievementFailed }
}
for _, index in ipairs({ 4550, 5450 }) do
    achievements[EHI:GetInstanceElementID(100319, index)] = { id = "tag_10", special_function = SF.SetAchievementFailed }
    achievements[EHI:GetInstanceElementID(100321, index)] = { id = "tag_10", status = "ok", special_function = SF.SetAchievementStatus }
    achievements[EHI:GetInstanceElementID(100282, index)] = { id = "tag_10", special_function = SF.SetAchievementComplete }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})