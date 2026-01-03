local EHI = EHI
---@type ParseAchievementTable
local achievements =
{
    fort_4 =
    {
        elements =
        {
            [100107] = { time = 240, class = EHI.Trackers.Achievement.Base },
            [101412] = { special_function = EHI.SpecialFunctions.SetAchievementComplete }
        },
        load_sync = function(self)
            self._unlockable:AddTimedAchievementTracker("fort_4", 240)
        end
    }
}
local trackers = {}
if EHI.Mission._SHOW_MISSION_TRACKERS_TYPE.cheaty then
    EHI.Mission:LoadTracker("EHINameTracker")
    local names = {
        [Idstring("g_name_01")] = "Bob Rogers",
        [Idstring("g_name_02")] = "David Meizler",
        [Idstring("g_name_03")] = "Steven Jordan",
        [Idstring("g_name_04")] = "Karen T. Hanley",
        [Idstring("g_name_05")] = "Edward Black",
        [Idstring("g_name_06")] = "Cynthia Lopez",
        [Idstring("g_name_07")] = "Franci Collins",
        [Idstring("g_name_08")] = "Donald Alexander",
        [Idstring("g_name_09")] = "Michael Disarro",
        [Idstring("g_name_10")] = "Amy Herman",
        [Idstring("g_name_11")] = "Matthew Putnick",
        [Idstring("g_name_12")] = "Brandon Martinez",
        [Idstring("g_name_13")] = "David Buono",
        [Idstring("g_name_14")] = "Mary Brown",
        [Idstring("g_name_15")] = "Carson Daniels",
        [Idstring("g_name_16")] = "Marc Bailey",
        [Idstring("g_name_17")] = "Carolyn Worster",
    }
    trackers[100222] = EHI:AddCustomCode(function(self)
        local whiteboard = managers.worlddefinition:get_unit(101889)
        if not whiteboard then
            return
        end
        for object, name in pairs(names) do
            if whiteboard:get_object(object):visibility() then
                self._trackers:AddTracker({
                    id = "EmployeeName",
                    name = name,
                    icons = { EHI.Icons.PCHack },
                    double_size = true,
                    hint = "cage_it_guy",
                    class = "EHINameTracker"
                })
                break
            end
        end
    end)
    trackers[100216] = { id = "EmployeeName", special_function = EHI.SpecialFunctions.RemoveTracker }
end

EHI.Mission:ParseTriggers({
    mission = trackers,
    achievement = achievements
})

EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 3000, name = "correct_pc_hack" },
        { amount = 3000, name = "c4_set_up" },
        { amount = 1000, name = "car_shop_car_secured" },
        { escape = 3000, ghost_bonus = tweak_data.levels:GetLevelStealthBonus() }
    },
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                objectives =
                {
                    car_shop_car_secured = { max = 4 }
                }
            }
        }
    }
})