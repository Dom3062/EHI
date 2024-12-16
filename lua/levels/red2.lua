---@class EHIcac10Tracker : EHIAchievementTracker, EHIProgressTracker
EHIcac10Tracker = class(EHIAchievementTracker)
EHIcac10Tracker._update = false
EHIcac10Tracker.FormatProgress = EHIProgressTracker.FormatProgress
EHIcac10Tracker.IncreaseProgress = EHIProgressTracker.IncreaseProgress
EHIcac10Tracker.IncreaseProgressMax = EHIProgressTracker.IncreaseProgressMax
---@param class EHIcac10Tracker
EHIcac10Tracker._anim_warning = function(o, old_color, color, start_t, class)
    local c = Color(old_color.r, old_color.g, old_color.b)
    local progress = class._progress_text
    local t = 1
    while true do
        while t > 0 do
            t = t - coroutine.yield()
            local n = math.sin(t * 180)
            c.r = math.lerp(old_color.r, color.r, n)
            c.g = math.lerp(old_color.g, color.g, n)
            c.b = math.lerp(old_color.b, color.b, n)
            o:set_color(c)
            progress:set_color(c)
        end
        t = 1
    end
end
function EHIcac10Tracker:OverridePanel()
    self._max = 0
    self._progress = 0
    self:SetBGSize()
    self._progress_text = self:CreateText({
        text = self:FormatProgress(),
        w = self._bg_box:w() / 2,
        left = 0,
        FitTheText = true
    })
    self._text:set_left(self._progress_text:right())
    self:SetIconsX()
end

function EHIcac10Tracker:SetProgressMax(max)
    self._max = max
    self._progress_text:set_text(self:FormatProgress())
end

function EHIcac10Tracker:SetProgress(progress)
    if self._progress ~= progress then
        self._progress = progress
        self._progress_text:set_text(self:FormatProgress())
        self:FitTheText(self._progress_text)
        self:AnimateBG()
    end
end

function EHIcac10Tracker:SetCompleted(force)
    self._status = "completed"
    self._text:stop()
    self:SetTextColor(Color.green)
    self.update = self.update_fade
    self._achieved_popup_showed = true
end

function EHIcac10Tracker:SetTextColor(color)
    EHIcac10Tracker.super.SetTextColor(self, color)
    self._progress_text:set_color(color)
end

local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local CF = EHI.ConditionFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers = {
    [101299] = { time = 300, id = "Thermite", icons = { Icon.Fire }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1012991 }, hint = Hints.Thermite },
    [1012991] = { time = 90, id = "ThermiteShorterTime", icons = { Icon.Fire, Icon.Wait }, class = TT.Warning, hint = Hints.red2_Thermite }, -- Triggered by 101299
    [101325] = { special_function = SF.TriggerIfEnabled, data = { 1013251, 1013252 } },
    [1013251] = { time = 180, id = "Thermite", icons = { Icon.Fire }, special_function = SF.SetTimeOrCreateTracker, hint = Hints.Thermite },
    [1013252] = { id = "ThermiteShorterTime", special_function = SF.RemoveTracker },
    [101684] = { time = 5.1, id = "C4", icons = { Icon.C4 }, hint = Hints.Explosion, waypoint = { data_from_element_and_remove_vanilla_waypoint = 101667 } },
    [100211] = { chance = 10, id = "PCChance", icons = { Icon.PCHack }, class = TT.Chance, hint = Hints.man_Code, remove_on_alarm = true },
    [101226] = { id = "PCChance", special_function = SF.IncreaseChanceFromElement }, -- +17%
    [106680] = { id = "PCChance", special_function = SF.RemoveTracker }
}

---@type ParseAchievementTable
local achievements =
{
    green_3 =
    {
        elements =
        {
            [103373] = { time = 817, class = TT.Achievement.Base },
            [102567] = { special_function = SF.SetAchievementFailed },
            [103491] = { special_function = SF.SetAchievementComplete }
        },
        load_sync = function(self)
            if self.ConditionFunctions.IsStealth() then
                self._unlockable:AddTimedAchievementTracker("green_3", 817)
            end
        end
    },
    cac_10 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [101341] = { time = 30, class = "EHIcac10Tracker", condition_function = CF.IsLoud },
            [107072] = { special_function = SF.SetAchievementComplete },
            [101544] = { special_function = SF.CallTrackerManagerFunction, f = "StartTrackerCountdown", arg = { "cac_10" }, trigger_once = true },
            [107066] = { special_function = SF.IncreaseProgressMax },
            [107067] = { special_function = SF.IncreaseProgress },
        },
        cleanup_class = "EHIcac10Tracker"
    }
}

local other =
{
    [100850] = EHI:AddAssaultDelay({ control = 20, trigger_once = true }),
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[102506] = { chance = 90, time = 1 + 10, recheck_t = 20 + 10, id = "Snipers", class = TT.Sniper.TimedChance, single_sniper = EHI:IsDifficulty(EHI.Difficulties.Normal) }
    other[102224] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 25%
    other[102423] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +10%
    other[103088] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess" }
    other[101840] = { id = "Snipers", special_function = SF.DecreaseCounter }
    other[101841] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[102082] = { id = "Snipers", time = 30 + 10, special_function = EHI.Manager:RegisterCustomSF(function(self, trigger, element, ...) ---@param element ElementCounterFilter
        if EHI.IsHost and not element:_values_ok() then
            return
        elseif self._trackers:CallFunction2(trigger.id, "SnipersKilled", trigger.time) then
            self._trackers:AddTracker({
                id = trigger.id,
                chance = 25,
                time = trigger.time,
                recheck_t = 20 + 10,
                single_sniper = EHI:IsDifficulty(EHI.Difficulties.Normal),
                class = TT.Sniper.TimedChance
            })
        end
    end) }
end

EHI.Manager:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:ShowLootCounter({
    max = 14,
    triggers =
    {
        [106684] = { max = 70, special_function = SF.IncreaseProgressMax2 }
    }
})

local min_bags = EHI:GetValueBasedOnDifficulty({
    hard_or_below = 4,
    veryhard = 6,
    overkill = 6,
    mayhem_or_above = 8
})
local loud_objectives =
{
    { amount = 2000, name = "fwb_server_room_open" },
    { amount = 2000, name = "pc_hack" },
    { amount = 4000, name = "fwb_gates_open" },
    { amount = 6000, name = "thermite_done" },
    { amount = 2000, name = "fwb_c4_escape" },
    { escape = 4000 } -- 2000 + 2000 (loud escape)
}
local custom_plan =
{
    {
        name = "stealth",
        plan =
        {
            objectives =
            {
                { amount = 2000, name = "fwb_server_room_open" },
                { amount = 1500, name = "fwb_rewired_circuit_box" },
                { amount = 1000, name = "fwb_found_code" },
                { amount = 2000, name = "fwb_gates_open" },
                { amount = 2000, name = "vault_open" },
                { escape = 2000 }
            },
            loot_all = 1000,
            total_xp_override =
            {
                params =
                {
                    min_max =
                    {
                        objectives =
                        {
                            fwb_rewired_circuit_box = { min_max = 3 }
                        },
                        loot_all = { min = min_bags, max = 14 }
                    }
                }
            }
        }
    },
    {
        name = "loud",
        plan =
        {
            objectives = loud_objectives,
            loot_all = 1000,
            total_xp_override =
            {
                params =
                {
                    min_max =
                    {
                        loot_all = { min = min_bags, max = 14 }
                    }
                }
            }
        }
    }
}
if EHI:IsDifficultyOrAbove(EHI.Difficulties.DeathWish) then
    custom_plan[3] = {
        name = "loud",
        additional_name = "fwb_overdrill",
        plan =
        {
            objectives = deep_clone(loud_objectives),
            loot =
            {
                money = 1000,
                gold = 143
            },
            total_xp_override =
            {
                params =
                {
                    min_max =
                    {
                        loot =
                        {
                            money = { min = min_bags, max = 14 },
                            gold = { min = 0, max = 70 }
                        }
                    }
                }
            }
        },
        objectives_override =
        {
            add_objectives_with_pos =
            {
                { objective = { amount = 40000, name = "fwb_overdrill", optional = true }, pos = 5 }
            }
        }
    }
end
EHI:AddXPBreakdown({
    plan =
    {
        custom = custom_plan
    }
})