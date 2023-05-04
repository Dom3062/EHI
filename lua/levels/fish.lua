local EHI = EHI
EHIfish6Tracker = class(EHIAchievementProgressTracker)
EHIfish6Tracker._forced_icons = EHI:GetAchievementIcon("fish_6")
function EHIfish6Tracker:init(panel, params)
    params.max = managers.enemy:GetNumberOfEnemies()
    EHIfish6Tracker.super.init(self, panel, params)
    CopDamage.register_listener("EHI_fish_6_listener", { "on_damage" }, function(damage_info)
        if damage_info.result.type == "death" then
            self:IncreaseProgress()
        end
    end)
end

local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local achievements = {
    -- "fish_4" achievement is not in the Mission Script
    fish_4 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100244] = { time = 360, id = "fish_4", class = TT.Achievement },
        },
        load_sync = function(self)
            self._trackers:AddTimedAchievementTracker("fish_4", 360)
        end,
        mission_end_callback = true
    },
    fish_5 =
    {
        elements =
        {
            [100244] = { class = TT.AchievementStatus },
            [100395] = { special_function = SF.SetAchievementFailed },
            [100842] = { special_function = SF.SetAchievementComplete }
        }
    },
    fish_6 =
    {
        elements =
        {
            -- 100244 is ´Players_spawned´
            [100244] = { class = TT.AchievementProgress, remove_after_reaching_target = false } -- Maximum is set in the tracker; difficulty dependant
        }
    }
}

EHI:ParseTriggers({
    achievement = achievements
})
EHI:ShowLootCounter({
    max = 8, -- Mission bags
    additional_loot = 7 -- Artifacts
})
EHI:AddXPBreakdown({
    objective =
    {
        escape = 4000
    },
    loot =
    {
        money = 1000,
        mus_artifact = 500
    },
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot =
                {
                    money = { min_max = 8 },
                    mus_artifact = { max = 7 }
                }
            }
        }
    }
})