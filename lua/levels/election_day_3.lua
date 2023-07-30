local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local drill_spawn_delay = { time = 30, id = "DrillSpawnDelay", icons = { Icon.Drill, Icon.Goto } }
local CrashIcons = { Icon.PCHack, Icon.Fix, "pd2_question" }
if EHI:GetOption("show_one_icon") then
    CrashIcons = { Icon.Fix }
end
local triggers = {
    [101284] = { chance = 50, id = "CrashChance", icons = { Icon.PCHack, Icon.Fix }, class = TT.Chance },
    [103568] = { time = 60, id = "Hack", icons = { Icon.PCHack } },
    [103585] = { id = "Hack", special_function = SF.RemoveTracker },
    [103579] = { amount = 25, id = "CrashChance", special_function = SF.DecreaseChance },
    [100741] = { id = "CrashChance", special_function = SF.RemoveTracker },
    [103572] = { time = 50, id = "CrashChanceTime", icons = CrashIcons },
    [103573] = { time = 40, id = "CrashChanceTime", icons = CrashIcons },
    [103574] = { time = 30, id = "CrashChanceTime", icons = CrashIcons },
    [103478] = { time = 5, id = "C4Explosion", icons = { Icon.C4 } },
    [103169] = drill_spawn_delay,
    [103179] = drill_spawn_delay,
    [103190] = drill_spawn_delay,
    [103195] = drill_spawn_delay,

    [103535] = { time = 5, id = "C4Explosion", icons = { Icon.C4 } }
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    local refresh_t = 60 -- Normal
    if EHI:IsDifficulty(EHI.Difficulties.Hard) then
        refresh_t = 50
    elseif EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard) then
        refresh_t = 40
    end
    other[100356] = { time = refresh_t, special_function = EHI:RegisterCustomSpecialFunction(function(self, trigger, element, ...)
        if element:_check_mode() then
            if self._trackers:TrackerExists("Snipers") then
                self._trackers:SetTrackerCount("Snipers", 2)
            else
                self._trackers:AddTracker({
                    id = "Snipers",
                    time = trigger.time,
                    refresh_t = trigger.time,
                    count = 2,
                    class = TT.Sniper.Timed
                })
            end
        end
    end ) }
    other[100348] = { id = "Snipers", special_function = SF.DecreaseCounter }
    other[100351] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({ mission = triggers })
EHI:AddXPBreakdown({
    objective =
    {
        escape = 20000
    },
    loot_all = 1000
})