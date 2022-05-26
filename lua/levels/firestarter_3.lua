local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local dw_and_above = EHI:IsDifficultyOrAbove("death_wish")
local triggers = {}
local level_id = Global.game_settings.level_id
if level_id == "firestarter_3" then
    triggers = {
        [102144] = { time = 90, id = "MoneyBurn", icons = { Icon.Fire, Icon.Money }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1021441 } },
        [1021441] = { status = "ok", id = "slakt_5", icons = { "C_Hector_H_Firestarter_ItsGettingHot" }, class = TT.AchievementNotification, condition = dw_and_above and show_achievement },
        [102146] = { status = "finish", id = "slakt_5", special_function = SF.SetAchievementStatus },
        [105237] = { id = "slakt_5", special_function = SF.SetAchievementComplete },
        [105235] = { id = "slakt_5", special_function = SF.SetAchievementFailed }
    }
else
    -- Branchbank: Random, Branchbank: Gold, Branchbank: Cash, Branchbank: Deposit
    EHI:ShowAchievementBagValueCounter({
        achievement = "uno_1",
        value = tweak_data.achievement.complete_heist_achievements.uno_1.bag_loot_value,
        exclude_from_sync = true,
        remove_after_reaching_target = false,
        counter =
        {
            check_type = EHI.LootCounter.CheckType.ValueOfBags
        }
    })
end
triggers[101425] = { time = 24 + 7, id = "TeargasIncoming1", icons = { "teargas", "pd2_generic_look" }, class = TT.Warning }
triggers[105611] = { time = 24 + 7, id = "TeargasIncoming2", icons = { "teargas", "pd2_generic_look" }, class = TT.Warning }
EHI:AddOnAlarmCallback(function(dropin)
    local start_chance = 5
    if managers.mission:check_mission_filter(2) or managers.mission:check_mission_filter(3) then -- Cash or Gold
        start_chance = 15 -- 5 (start_chance) + 10
    end
    managers.ehi:AddEscapeChanceTracker(dropin, start_chance)
end)

EHI:ParseTriggers(triggers)