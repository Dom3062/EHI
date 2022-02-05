local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local drill_spawn_delay = { time = 30, id = "DrillSpawnDelay", icons = { "pd2_drill", "pd2_goto" } }
local triggers = {
    [101284] = { chance = 50, id = "CrashChance", icons = { "wp_hack", "pd2_fix" }, class = TT.Chance },
    [103568] = { time = 60, id = "Hack", icons = { "wp_hack" } },
    [103585] = { id = "Hack", special_function = SF.RemoveTracker },
    [103579] = { amount = 25, id = "CrashChance", special_function = SF.DecreaseChance },
    [100741] = { id = "CrashChance", special_function = SF.RemoveTracker },
    [103572] = { time = 50, id = "CrashChanceTime", icons = { "wp_hack", "pd2_fix", "pd2_question" } },
    [103573] = { time = 40, id = "CrashChanceTime", icons = { "wp_hack", "pd2_fix", "pd2_question" } },
    [103574] = { time = 30, id = "CrashChanceTime", icons = { "wp_hack", "pd2_fix", "pd2_question" } },
    [103478] = { time = 5, id = "C4Explosion", icons = { "pd2_c4" } },
    [103169] = drill_spawn_delay,
    [103179] = drill_spawn_delay,
    [103190] = drill_spawn_delay,
    [103195] = drill_spawn_delay,

    [103535] = { time = 5, id = "C4Explosion", icons = { "pd2_c4" } }
}

EHI:ParseTriggers(triggers)