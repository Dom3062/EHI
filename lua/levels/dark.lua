EHIdark5Tracker = class(EHIProgressTracker)
function EHIdark5Tracker:init(panel, params)
    self._bodies = {}
    EHIdark5Tracker.super.init(self, panel, params)
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
EHI.AchievementTrackers.EHIdark5Tracker = true

for _, index in ipairs({ 8750, 17750, 33525, 36525 }) do
    local unit_index = EHI:GetInstanceUnitID(100334, index)
    managers.mission:add_runned_unit_sequence_trigger(unit_index, "interact", function(unit)
        managers.ehi:AddTracker({
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

local achievements =
{
    [100296] = { special_function = SF.Trigger, data = { 1002961, 1002962, 1002963, 1002964, 1002965 } },
    [1002961] = { time = 420, id = "dark_2", class = TT.Achievement },
    [1002962] = { id = "dark_3", class = TT.AchievementStatus },
    [1002963] = { max = 4, id = "dark_5", class = "EHIdark5Tracker", remove_after_reaching_target = false },
    [1002964] = { max = 16, id = "voff_3", class = TT.AchievementProgress, remove_after_reaching_target = false, difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) },
    [1002965] = { special_function = SF.CustomCode, f = function()
        if managers.ehi:TrackerDoesNotExist("voff_3") then
            return
        end
        EHI:AddAchievementToCounter({ achievement = "voff_3" })
    end },

    [100470] = { special_function = SF.Trigger, data = { 1004701, 1004702 } },
    [1004701] = { id = "dark_3", special_function = SF.SetAchievementFailed },
    [1004702] = { id = "voff_3", special_function = SF.SetAchievementFailed },

    [100290] = { id = "dark_2", special_function = SF.SetAchievementComplete }
}
local AddBodyBag = EHI:GetFreeCustomSpecialFunctionID()
local RemoveBodyBag = EHI:GetFreeCustomSpecialFunctionID()
for i = 12850, 13600, 250 do
    local inc = EHI:GetInstanceElementID(100011, i)
    achievements[inc] = { id = "dark_5", special_function = AddBodyBag, element = i }
    achievements[inc + 1] = { id = "dark_5", special_function = RemoveBodyBag, element = i }
end
EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
EHI:ShowLootCounter({ max = 16 })
EHI:RegisterCustomSpecialFunction(AddBodyBag, function(id, trigger, ...)
    managers.ehi:CallFunction(trigger.id, "IncreaseProgress", trigger.element)
end)
EHI:RegisterCustomSpecialFunction(RemoveBodyBag, function(id, trigger, ...)
    managers.ehi:CallFunction(trigger.id, "DecreaseProgress", trigger.element)
end)
if EHI:ShowMissionAchievements() then
    EHI:AddLoadSyncFunction(function(self)
        self:AddTimedAchievementTracker("dark_2", 420)
    end)
end