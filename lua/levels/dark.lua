---@class EHIdark5Tracker : EHIProgressTracker
---@field super EHIProgressTracker
EHIdark5Tracker = class(EHIProgressTracker)
---@param params EHITracker_params
function EHIdark5Tracker:pre_init(params)
    self._bodies = {}
    EHIdark5Tracker.super.pre_init(self, params)
end

function EHIdark5Tracker:SetProgress(progress)
    self:SetTextColor(Color.white)
    EHIdark5Tracker.super.SetProgress(self, progress)
end

function EHIdark5Tracker:GetTotalProgress()
    local total = 0
    for _, value in pairs(self._bodies or {}) do
        if value == 1 then -- Mission Script expects exactly 1 body bag in dumpster
            total = total + 1
        end
    end
    return total
end

function EHIdark5Tracker:IncreaseProgress(element)
    self._bodies[element] = (self._bodies[element] or 0) + 1
    self:SetProgress(self:GetTotalProgress())
end

function EHIdark5Tracker:DecreaseProgress(element)
    self._bodies[element] = (self._bodies[element] or 1) - 1
    self:SetProgress(self:GetTotalProgress())
end

function EHIdark5Tracker:SetCompleted(force)
    EHIdark5Tracker.super.SetCompleted(self, force)
    self._disable_counting = false
    self._status = nil
end

local EHI = EHI
local Icon = EHI.Icons

for _, index in ipairs({ 8750, 17750, 33525, 36525 }) do
    local unit_index = EHI:GetInstanceUnitID(100334, index)
    managers.mission:add_runned_unit_sequence_trigger(unit_index, "interact", function(unit)
        managers.ehi_tracker:AddTracker({
            id = tostring(unit_index),
            time = 10,
            icons = { Icon.Fire }
        })
    end)
end

local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [106026] = { time = 10, id = "Van", icons = Icon.CarEscape },

    [106036] = { time = 410/30, id = "Boat", icons = Icon.BoatEscape }
}

---@type ParseAchievementTable
local achievements =
{
    dark_2 =
    {
        elements =
        {
            [100296] = { time = 420, class = TT.Achievement.Base },
            [100290] = { special_function = SF.SetAchievementComplete }
        },
        load_sync = function(self)
            self._trackers:AddTimedAchievementTracker("dark_2", 420)
        end
    },
    dark_3 =
    {
        elements =
        {
            [100296] = { class = TT.Achievement.Status },
            [100470] = { special_function = SF.SetAchievementFailed }
        }
    },
    dark_5 =
    {
        elements =
        {
            [100296] = { max = 4, class = "EHIdark5Tracker", show_finish_after_reaching_target = true },
        }
    },
    voff_3 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [100296] = { max = 16, class = TT.Achievement.Progress, show_finish_after_reaching_target = true, special_function = SF.AddAchievementToCounter },
            [100470] = { special_function = SF.SetAchievementFailed },
        }
    }
}
local AddBodyBag = EHI:RegisterCustomSpecialFunction(function(self, trigger, ...)
    self._trackers:CallFunction(trigger.id, "IncreaseProgress", trigger.element)
end)
local RemoveBodyBag = EHI:RegisterCustomSpecialFunction(function(self, trigger, ...)
    self._trackers:CallFunction(trigger.id, "DecreaseProgress", trigger.element)
end)
for i = 12850, 13600, 250 do
    local inc = EHI:GetInstanceElementID(100011, i)
    achievements.dark_5.elements[inc] = { special_function = AddBodyBag, element = i }
    achievements.dark_5.elements[inc + 1] = { special_function = RemoveBodyBag, element = i }
end
EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
EHI:ShowLootCounter({ max = 16 })
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 1000, name = "murky_station_equipment_found", times = 1 },
        { amount = 2000, name = "murky_station_found_emp_part", times = 2 },
        { escape = 2000 }
    },
    loot =
    {
        weapon_glock = 1000,
        weapon_scar = 1000,
        drk_bomb_part = 3000
    },
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot =
                {
                    weapon_glock = { max = 7 },
                    weapon_scar = { max = 7 },
                    drk_bomb_part = { min_max = 2 }
                }
            }
        }
    }
})