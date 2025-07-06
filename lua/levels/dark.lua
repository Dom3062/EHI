---@class dark_5 : EHIProgressTracker
---@field super EHIProgressTracker
local dark_5 = class(EHIProgressTracker)
function dark_5:pre_init(...)
    self._bodies = {}
    dark_5.super.pre_init(self, ...)
end

function dark_5:SetProgress(...)
    self:SetTextColor(Color.white)
    dark_5.super.SetProgress(self, ...)
end

---@param value number
---@param key any Unused
function dark_5.is_in_dumpster(value, key)
    return value == 1 -- Mission Script expects exactly 1 body bag in dumpster
end

---@param element number
function dark_5:IncreaseProgress(element)
    self._bodies[element] = (self._bodies[element] or 0) + 1
    self:SetProgress(table.count(self._bodies, self.is_in_dumpster))
end

---@param element number
function dark_5:DecreaseProgress(element)
    self._bodies[element] = (self._bodies[element] or 1) - 1
    self:SetProgress(table.count(self._bodies, self.is_in_dumpster))
end

function dark_5:SetCompleted(...)
    dark_5.super.SetCompleted(self, ...)
    self._disable_counting = false
    self._status = nil
end

local EHI = EHI
local Icon = EHI.Icons
local Hints = EHI.Hints
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [106026] = { time = 10, id = "Van", icons = Icon.CarEscape, hint = Hints.LootEscape },

    [106036] = { time = 410/30, id = "Boat", icons = Icon.BoatEscape, hint = Hints.LootEscape }
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
            self._unlockable:AddTimedAchievementTracker("dark_2", 420)
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
            [100296] = { max = 4, class_table = dark_5, show_finish_after_reaching_target = true },
        },
        preparse_callback = function(data)
            local AddBodyBag = EHI.Trigger:RegisterCustomSF(function(self, trigger, ...)
                self._trackers:CallFunction(trigger.id, "IncreaseProgress", trigger.element)
            end)
            local RemoveBodyBag = EHI.Trigger:RegisterCustomSF(function(self, trigger, ...)
                self._trackers:CallFunction(trigger.id, "DecreaseProgress", trigger.element)
            end)
            for i = 12850, 13600, 250 do
                local inc = EHI:GetInstanceElementID(100011, i)
                data.elements[inc] = { special_function = AddBodyBag, element = i }
                data.elements[inc + 1] = { special_function = RemoveBodyBag, element = i }
            end
        end
    },
    voff_3 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [100296] = { max = 16, class = TT.Achievement.Progress, show_finish_after_reaching_target = true, special_function = SF.AddAchievementToCounter },
            [100470] = { special_function = SF.SetAchievementFailed }
        }
    }
}

EHI.Mission:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
EHI:ShowLootCounter({ max = 16 }, { element = { 105873, 105874 } })
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 1000, name = "murky_station_equipment_found", times = 1 },
        { amount = 2000, name = "murky_station_found_emp_part", times = 2 },
        { escape = 2000, ghost_bonus = tweak_data.levels:GetLevelStealthBonus() }
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