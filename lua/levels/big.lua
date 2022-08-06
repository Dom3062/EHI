local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local pc_hack = { time = 20, id = "PCHack", icons = { "wp_hack" } }
local bigbank_4 = { special_function = SF.Trigger, data = { 1, 2 } }
local show_achievement = EHI:GetOption("show_achievement")
local hard_and_above = EHI:IsDifficultyOrAbove(EHI.Difficulties.Hard)
local triggers = {
    [1] = { time = 720, id = "bigbank_4", class = TT.Achievement, difficulty_pass = hard_and_above },
    [2] = { special_function = SF.RemoveTriggers, data = { 100107, 106140, 106150 } },
    [100107] = bigbank_4,
    [106140] = bigbank_4,
    [106150] = bigbank_4,
    [105842] = { time = 16.7 * 18, id = "Thermite", icons = { Icon.Fire } },

    [106250] = { id = "cac_22", special_function = SF.SetAchievementFailed },
    [106247] = { id = "cac_22", special_function = SF.SetAchievementComplete },

    [101377] = { time = 5, id = "C4Explosion", icons = { Icon.C4 } },
    [104532] = pc_hack,
    [103179] = pc_hack,
    [103259] = pc_hack,
    [103590] = pc_hack,
    [103620] = pc_hack,
    [103671] = pc_hack,
    [103734] = pc_hack,
    [103776] = pc_hack,
    [103815] = pc_hack,
    [103903] = pc_hack,
    [103920] = pc_hack,
    [103936] = pc_hack,
    [103956] = pc_hack,
    [103974] = pc_hack,
    [103988] = pc_hack,
    [104014] = pc_hack,
    [104029] = pc_hack,
    [104051] = pc_hack,

    -- Heli escape
    [104126] = { time = 23 + 1, id = "HeliEscape", icons = Icon.HeliEscape },

    [104091] = { time = 200/30, id = "CraneLiftUp", icons = { "piggy" } },
    [104261] = { time = 1000/30, id = "CraneMoveLeft", icons = { "piggy" } },
    [104069] = { time = 1000/30, id = "CraneMoveRight", icons = { "piggy" } },

    [105623] = { time = 8, id = "Bus", icons = { Icon.Wait } }
}
if Network:is_client() then
    triggers[101605] = { time = 16.7 * 17, id = "Thermite", icons = { Icon.Fire }, special_function = SF.AddTrackerIfDoesNotExist }
    local doesnotexists = {
        [101817] = true,
        [101819] = true,
        [101825] = true,
        [101826] = true,
        [101828] = true,
        [101829] = true
    }
    local multiplier = 16
    for i = 101812, 101833, 1 do
        if not doesnotexists[i] then
            triggers[i] = { time = 16.7 * multiplier, id = "Thermite", icons = { Icon.Fire }, special_function = SF.AddTrackerIfDoesNotExist }
            multiplier = multiplier - 1
        end
    end
end

EHI:ParseTriggers(triggers)
EHI:ShowAchievementLootCounter({
    achievement = "bigbank_3",
    max = 16,
    exclude_from_sync = true,
    remove_after_reaching_target = false
})
if show_achievement then
    if hard_and_above then
        EHI:AddLoadSyncFunction(function(self)
            self:AddTimedAchievementTracker("bigbank_4", 720)
        end)
    end
    if EHI:IsDifficultyOrAbove(EHI.Difficulties.DeathWish) then
        EHI:AddOnAlarmCallback(function(dropin)
            if dropin or not managers.preplanning:IsAssetBought(106594) then -- C4 Escape
                return
            end
            managers.ehi:AddTracker({
                id = "cac_22",
                icons = EHI:GetAchievementIcon("cac_22"),
                class = TT.AchievementStatus,
                exclude_from_sync = true
            })
        end)
    end
end

local tbl =
{
    --units/payday2/props/gen_prop_security_timelock/gen_prop_security_timelock
    [101457] = { icons = { Icon.Wait } },
    [104671] = { icons = { Icon.Wait } }
}
EHI:UpdateUnits(tbl)