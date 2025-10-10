local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
---@type ParseAchievementTable
local achievements = {
    -- "fish_4" achievement is not in the Mission Script
    fish_4 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [100244] = { time = 360, class = TT.Achievement.Base },
        },
        load_sync = function(self)
            self._unlockable:AddTimedAchievementTracker("fish_4", 360)
        end,
        mission_end_callback = true
    },
    fish_5 =
    {
        elements =
        {
            [100244] = { class = TT.Achievement.Status },
            [100395] = { special_function = SF.SetAchievementFailed },
            [100842] = { special_function = SF.SetAchievementComplete }
        }
    },
    fish_6 =
    {
        elements =
        {
            [100244] = { show_finish_after_reaching_target = true } -- Maximum is set in the tracker; difficulty dependant
        },
        preparse_callback = function(data)
            ---@class fish_6 : EHIAchievementProgressTracker
            ---@field super EHIAchievementProgressTracker
            local fish_6 = class(EHIAchievementProgressTracker)
            fish_6._forced_icons = EHI:GetAchievementIcon("fish_6")
            function fish_6:pre_init(params)
                params.max = managers.enemy:GetNumberOfEnemies()
                CopDamage.register_listener("EHI_fish_6_listener", { "on_damage" }, function(damage_info)
                    if damage_info.result.type == "death" then
                        self:IncreaseProgress()
                    end
                end)
                fish_6.super.pre_init(self, params)
            end
            function fish_6:pre_destroy()
                fish_6.super.pre_destroy(self)
                CopDamage.unregister_listener("EHI_fish_6_listener")
            end
            data.elements[100244].class_table = fish_6
        end
    }
}

EHI.Mission:ParseTriggers({
    achievement = achievements
})
EHI:ShowLootCounter({ max = 8 + 7 }) -- Mission bags + Artifacts
EHI:AddXPBreakdown({
    objective =
    {
        escape =
        {
            { amount = 4000, stealth = true },
            { amount = 4000, escape_after_alarm_in = 30 }
        }
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
                },
                bonus_xp = { min_max = 4000 }
            }
        }
    }
})