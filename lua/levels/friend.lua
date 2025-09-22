---@class uno_7 : EHIAchievementTracker
---@field super EHIAchievementTracker
local uno_7 = class(EHIAchievementTracker)
function uno_7:post_init(...)
    self._blocked_warning = true
    self._text:set_color(Color.red)
    self:PrepareHint(...)
end

function uno_7:OnAlarm()
    self._blocked_warning = nil
    self._text:set_color(Color.white)
    if self._time <= 10 then
        self:AnimateColor(true)
    end
end

function uno_7:AnimateColor(...)
    if self._blocked_warning then
        return
    end
    uno_7.super.AnimateColor(self, ...)
end

local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local element_sync_triggers =
{
    [100241] = { time = 662/30, id = "EscapeBoat", icons = Icon.BoatEscape, hook_element = 100216, hint = Hints.LootEscape },
}
local random_car = { time = 18, id = "RandomCar", icons = { Icon.Heli, Icon.Goto }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "BileArrival" }, hint = Hints.friend_HeliRandom }
local caddilac = { time = 18, id = "Caddilac", icons = { Icon.Heli, Icon.Goto }, hint = Hints.friend_HeliCaddilac }
local triggers = {
    [100103] = { additional_time = 15 + 5, random_time = 10, id = "BileArrival", icons = { Icon.Heli }, hint = Hints.friend_Heli },

    [100238] = random_car,
    [100249] = random_car,
    [100310] = random_car,
    [100313] = random_car,
    [100314] = random_car,

    [102231] = { time = 20, id = "BileDropCar", icons = { Icon.Heli, Icon.Car, Icon.Goto }, hint = Hints.friend_HeliDropCar },

    [100718] = caddilac,
    [100720] = caddilac,
    [100732] = caddilac,
    [100733] = caddilac,
    [100734] = caddilac,

    [102253] = { time = 11, id = "BileDropCaddilac", icons = { Icon.Heli, { icon = Icon.Car, color = Color.yellow }, Icon.Goto }, hint = Hints.friend_HeliDropCar },

    [100213] = { time = 450/30, id = "EscapeCar1", icons = Icon.CarEscape, hint = Hints.LootEscape },
    [100214] = { time = 160/30, id = "EscapeCar2", icons = Icon.CarEscape, hint = Hints.LootEscape },

    [102814] = { time = 180, id = "Safe", icons = { Icon.Winch }, special_function = SF.UnpauseTrackerIfExists, class = TT.Pausable, hint = Hints.Winch },
    [102815] = { id = "Safe", special_function = SF.PauseTracker }
}
if EHI.IsClient then
    triggers[100216] = { additional_time = 662/30, random_time = 10, id = "EscapeBoat", icons = Icon.BoatEscape, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.LootEscape }
end

local mayhem_and_up = EHI:IsMayhemOrAbove()
---@type ParseAchievementTable
local achievements =
{
    friend_5 =
    {
        elements =
        {
            [102291] = { max = 2, class = TT.Achievement.Progress },
            [102280] = { special_function = SF.IncreaseProgress }
        }
    },
    friend_6 =
    {
        difficulty_pass = mayhem_and_up,
        elements =
        {
            [102430] = { time = 780, class = TT.Achievement.Base },
            [100801] = { special_function = SF.SetAchievementFailed }
        }
    },
    uno_7 =
    {
        difficulty_pass = mayhem_and_up,
        elements =
        {
            [100107] = { time = 901, class_table = uno_7, update_on_alarm = true }
        }
    }
}

local trophy =
{
    trophy_flamingo =
    {
        parsed_callback = function()
            local trophy = managers.custom_safehouse:get_trophy("trophy_flamingo")
            if trophy.completed then
                return
            end
            local progress, max = EHI._get_objective_progress(trophy.objectives, trophy.id)
            Hooks:PostHook(CustomSafehouseManager, "award", string.format("EHI_%s_AwardProgress", trophy.id), function(csm, id_stat)
                if id_stat == trophy.id then
                    progress = progress + 1
                    if progress < max then
                        managers.hud:custom_ingame_popup_text(managers.localization:to_upper_text(trophy.id), tostring(progress) .. "/" .. tostring(max), "milestone_trophy")
                    end
                end
            end)
        end
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 30 + 1, trigger_once = true })
}

EHI.Mission:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    trophy = trophy,
    other = other,
    sync_triggers = { element = element_sync_triggers }
})
EHI:ShowLootCounter({ max = 16 }, { element = { 101304, 101973, 101980 } })
local xp_override =
{
    params =
    {
        min_max =
        {
            loot_all = { min = EHI:GetValueBasedOnDifficulty({ veryhard_or_below = 4, overkill_or_above = 6 }), max = 16 }
        }
    }
}
EHI:AddXPBreakdown({
    plan =
    {
        stealth =
        {
            objectives =
            {
                { amount = 2000, name = "scarface_got_usb" },
                { amount = 3000, name = "pc_hack" },
                { amount = 1000, name = "scarface_entered_house" },
                { amount = 1000, name = "scarface_shutters_open" },
                { amount = 2000, name = "scarface_searched_planted_yayo" },
                { amount = 1000, name = "scarface_made_a_call" },
                { amount = 2000, name = "scarface_entered_sosa_office" },
                { amount = 1000, name = "scarface_sosa_killed" },
                { amount = 8000, name = "vault_open" },
                { escape_ghost_bonus_only = tweak_data.levels:GetLevelStealthBonus() }
            },
            loot_all = 500,
            total_xp_override = xp_override
        },
        loud =
        {
            objectives =
            {
                { amount = 2000, name = "scarface_got_usb" },
                { amount = 3000, name = "pc_hack" },
                { amount = 1000, name = "scarface_entered_house" },
                { amount = 1000, name = "scarface_shutters_open" },
                { amount = 1000, name = "scarface_gathered_all_paintings" },
                { amount = 2000, name_format = { id = "all_bags_destroyed", macros = { carry = tweak_data.carry:FormatCarryNameID("painting") } } },
                { amount = 1000, name = "scarface_all_cars_hooked_up" },
                { amount = 4000, name = "scarface_defeated_security" },
                { amount = 1000, name = "scarface_sosa_killed" },
                { amount = 8000, name = "vault_open" }
            },
            loot_all = 500,
            total_xp_override = xp_override
        }
    }
})