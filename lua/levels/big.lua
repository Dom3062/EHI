local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local pc_hack = { time = 20, id = "PCHack", icons = { Icon.PCHack } }
local bigbank_4 = { special_function = SF.Trigger, data = { 1, 2 } }
local show_achievement = EHI:ShowMissionAchievements()
local hard_and_above = EHI:IsDifficultyOrAbove(EHI.Difficulties.Hard)
local triggers = {
    [105842] = { time = 16.7 * 18, id = "Thermite", icons = { Icon.Fire } },

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

local achievements =
{
    [1] = { time = 720, id = "bigbank_4", class = TT.Achievement, difficulty_pass = hard_and_above },
    [2] = { special_function = SF.RemoveTriggers, data = { 100107, 106140, 106150 } },
    [100107] = bigbank_4,
    [106140] = bigbank_4,
    [106150] = bigbank_4,

    [106250] = { id = "cac_22", special_function = SF.SetAchievementFailed },
    [106247] = { id = "cac_22", special_function = SF.SetAchievementComplete },
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
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

local MissionDoorPositions =
{
    -- Server Room
    [1] = Vector3(733.114, 1096.92, -907.557),
    [2] = Vector3(1419.89, -1897.92, -907.557),
    [3] = Vector3(402.08, -1266.89, -507.56),

    -- Roof
    [4] = Vector3(503.08, 1067.11, 327.432),
    [5] = Vector3(503.08, -1232.89, 327.432),
    [6] = Vector3(3446.92, -1167.11, 327.432),
    [7] = Vector3(3466.11, 1296.92, 327.432)
}
local MissionDoorIndex =
{
    [1] = { w_id = 103457, restore = true, unit_id = 104582 },
    [2] = { w_id = 103461, restore = true, unit_id = 104584 },
    [3] = { w_id = 103465, restore = true, unit_id = 104585 },
    [4] = { w_id = 101306, restore = true, unit_id = 100311 },
    [5] = { w_id = 106362, restore = true, unit_id = 103322 },
    [6] = { w_id = 106372, restore = true, unit_id = 105317 },
    [7] = { w_id = 106382, restore = true, unit_id = 106336 },
}
EHI:SetMissionDoorPosAndIndex(MissionDoorPositions, MissionDoorIndex)