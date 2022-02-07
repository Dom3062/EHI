EHIdark5Tracker = EHIdark5Tracker or class(EHIProgressTracker)
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

local start_index =
{
    8750, 17750, 33525, 36525
}

for _, index in pairs(start_index) do
    local unit_index = EHI:GetInstanceUnitID(100334, index)
    managers.mission:add_runned_unit_sequence_trigger(unit_index, "interact", function(unit)
        managers.ehi:AddTracker({
            id = tostring(unit_index),
            time = 10,
            icons = { "pd2_fire" }
        })
    end)
end

local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [100296] = { special_function = SF.Trigger, data = { 1002961, 1002962 } },
    [1002961] = { time = 420, id = "dark_2", class = TT.Achievement },
    [1002962] = { max = 4, id = "dark_5", icons = EHI:GetAchievementIcon("dark_5"), remove_after_reaching_target = false, class = "EHIdark5Tracker" },
    [106026] = { time = 10, id = "Van", icons = Icon.CarEscape },

    [106036] = { time = 410/30, id = "Boat", icons = Icon.BoatEscape }
}
for i = 12850, 13600, 250 do
    local inc = EHI:GetInstanceElementID(100011, i)
    triggers[inc] = { id = "dark_5", special_function = SF.DARK_AddBodyBag, element = i }
    triggers[inc + 1] = { id = "dark_5", special_function = SF.DARK_RemoveBodyBag, element = i }
end

EHI:ParseTriggers(triggers)
EHI:ShowLootCounter(16)