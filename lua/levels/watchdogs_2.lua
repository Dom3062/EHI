local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local anim_delay = 450/30
local boat_delay = 60 + 30 + 30 + 450/30
local boat_icon = { Icon.Boat, Icon.LootDrop }
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove("overkill")
local triggers = {
    [101560] = { time = 35 + 75 + 30 + boat_delay, id = "BoatLootFirst" },
    -- 101127 tracked in 101560
    [101117] = { time = 60 + 30 + boat_delay, id = "BoatLootFirst", special_function = SF.SetTimeOrCreateTracker },
    [101122] = { time = 40 + 30 + boat_delay, id = "BoatLootFirst", special_function = SF.SetTimeOrCreateTracker },
    [101119] = { time = 30 + boat_delay, id = "BoatLootFirst", special_function = SF.SetTimeOrCreateTracker },

    [100323] = { time = 50 + 23, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot },

    [101129] = { time = 180 + anim_delay, special_function = SF.WATCHDOGS_2_AddToCache },
    [101134] = { time = 150 + anim_delay, special_function = SF.WATCHDOGS_2_AddToCache },
    [101144] = { time = 130 + anim_delay, special_function = SF.WATCHDOGS_2_AddToCache },

    [101148] = { icons = boat_icon, special_function = SF.WATCHDOGS_2_GetFromCache },
    [101149] = { icons = boat_icon, special_function = SF.WATCHDOGS_2_GetFromCache },
    [101150] = { icons = boat_icon, special_function = SF.WATCHDOGS_2_GetFromCache },

    [1011480] = { time = 130 + anim_delay, random_time = 50 + anim_delay, id = "BoatLootDropReturnRandom", icons = boat_icon, class = TT.Inaccurate },

    [100124] = { id = "uno_8", class = TT.AchievementNotification, condition = show_achievement and ovk_and_up },
    [102382] = { id = "uno_8", special_function = SF.SetAchievementFailed },
    [102379] = { id = "uno_8", special_function = SF.SetAchievementComplete }
}
if Network:is_client() then
    local boat_return = { time = 450/30, id = "BoatLootDropReturnRandom", id2 = "BoatLootDropReturn", id3 = "BoatLootFirst", special_function = SF.WD2_SetTrackerAccurate }
    triggers[100470] = boat_return
    triggers[100472] = boat_return
    triggers[100474] = boat_return
end

EHI:ParseTriggers(triggers, "BoatLootDropReturn", boat_icon)