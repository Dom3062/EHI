local EHI = EHI
local Color = Color
---@class ameno_3 : EHIAchievementTracker, EHINeededValueTracker, EHIAchievementProgressTracker
---@field super EHIAchievementTracker
local ameno_3 = class(EHIAchievementTracker)
ameno_3.FormatNumber = EHINeededValueTracker.Format
ameno_3.FormatNumber2 = EHINeededValueTracker.FormatNumberShort
ameno_3.IncreaseProgress = EHIProgressTracker.IncreaseProgress
ameno_3.AddLootListener = EHIAchievementProgressTracker.AddLootListener
---@param class ameno_3
ameno_3._anim_warning = function(o, old_color, color, start_t, class)
    local c = Color(old_color.r, old_color.g, old_color.b)
    local money = class._money_text
    while true do
        local t = 1
        while t > 0 do
            t = t - coroutine.yield()
            local n = math.sin(t * 180)
            c.r = math.lerp(old_color.r, color.r, n)
            c.g = math.lerp(old_color.g, color.g, n)
            c.b = math.lerp(old_color.b, color.b, n)
            o:set_color(c)
            money:set_color(c)
        end
        t = 1
    end
end
function ameno_3:pre_init(params)
    self._cash_sign = managers.localization:text("cash_sign")
    self._max = 1800000
    self._progress = params.progress or 0
    self._progress_formatted = self:FormatNumber2(self._progress)
    self._max_formatted = self:FormatNumber2(self._max)
end

function ameno_3:OverridePanel()
    self:SetBGSize()
    self._money_text = self:CreateText({
        text = self:FormatNumber(),
        w = self._bg_box:w() / 2,
        left = 0,
        FitTheText = true
    })
    self._text:set_left(self._money_text:right())
    self._loot_parent = managers.ehi_loot
    self:AddLootListener({
        counter =
        {
            check_type = EHI.Const.LootCounter.CheckType.ValueOfSmallLoot
        }
    })
end

function ameno_3:SetProgress(progress)
    if self._progress ~= progress and not self._disable_counting then
        self._progress = progress
        self._progress_formatted = self:FormatNumber2(progress)
        self._money_text:set_text(self:FormatNumber())
        self:FitTheText(self._money_text)
        self:AnimateBG()
        self:SetCompleted()
    end
end

function ameno_3:SetCompleted()
    if self._progress >= self._max and not self._status then
        self._status = "completed"
        self._disable_counting = true
        self._achieved_popup_showed = true
        self:delete_with_delay(true)
    end
end

function ameno_3:SetTextColor(color)
    EHINeededValueTracker.super.SetTextColor(self, color)
    self._money_text:set_color(color)
end

function ameno_3:pre_destroy()
    self._loot_parent:RemoveListener("ameno_3")
end

local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local MoneyTrigger = { id = "MallDestruction", special_function = EHI.Trigger:RegisterCustomSF(function(self, trigger, element, ...)
    self._trackers:IncreaseProgress(trigger.id, element._values.amount)
end) }
local OverkillOrBelow = EHI:IsDifficultyOrBelow(EHI.Difficulties.OVERKILL)
local triggers =
{
    -- Time before escape vehicle arrives
    [300248] = { time = (OverkillOrBelow and 120 or 300) + 25, id = "EscapeHeli", icons = Icon.HeliEscapeNoLoot, waypoint = { data_from_element = 300322 }, hint = Hints.Escape },
    -- 120: Base Delay on OVK or below
    -- 300: Base Delay on Mayhem or above
    -- 25: Escape zone activation delay

    [300043] = { max = 50000, id = "MallDestruction", class = TT.NeededValue, icons = { Icon.Destruction }, flash_times = 1, hint = Hints.mallcrasher_Destruction },
    [300843] = MoneyTrigger, -- +40
    [300844] = MoneyTrigger, -- +80
    [300845] = MoneyTrigger, -- +250
    [300846] = MoneyTrigger, -- +500
    [300847] = MoneyTrigger, -- +800
    [300848] = MoneyTrigger, -- +2000
    [300850] = MoneyTrigger, -- +2800
    [300849] = MoneyTrigger, -- +4000
    [300872] = MoneyTrigger, -- +5600
    [300851] = MoneyTrigger -- +8000, appears to be unused
}

if EHI.IsClient then
    triggers[302287] = EHI:ClientCopyTrigger(triggers[300248], { time = (OverkillOrBelow and 115 or 120) + 25 })
    triggers[300223] = EHI:ClientCopyTrigger(triggers[300248], { time = 60 + 25 })
    triggers[302289] = EHI:ClientCopyTrigger(triggers[300248], { time = 30 + 25 })
    triggers[300246] = EHI:ClientCopyTrigger(triggers[300248], { time = 25 })
end

---@type ParseAchievementTable
local achievements =
{
    window_cleaner =
    {
        elements =
        {
            [301056] = { max = 171, flash_times = 1, class = TT.Achievement.Progress },
            [300791] = { special_function = SF.IncreaseProgress }
        }
    },
    ameno_3 =
    {
        difficulty_pass = EHI:IsDifficulty(EHI.Difficulties.OVERKILL),
        elements =
        {
            [301148] = { time = 50, class_table = ameno_3 },
        },
        load_sync = function(self)
            local t = 50 - math.max(self._trackers._t, self._tracking._t)
            local progress = managers.loot:get_real_total_small_loot_value()
            if t > 0 and progress < 1800000 then
                self._trackers:AddTracker({
                    time = t,
                    id = "ameno_3",
                    progress = progress,
                    icons = EHI:GetAchievementIcon("ameno_3"),
                    class_table = ameno_3
                })
            end
        end
    },
    uno_3 =
    {
        difficulty_pass = OverkillOrBelow, -- Can be achieved on any difficulty but the heli takes 5:25 to arrive on Mayhem or above
        elements =
        {
            [301148] = { time = 180, class = TT.Achievement.Base },
            [300241] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local FirstAssaultDelay = 10
local other = {}
if EHI:IsMayhemOrAbove() then
    other[301049] = EHI:AddAssaultDelay({ control = FirstAssaultDelay })
else
    other[301138] = EHI:AddAssaultDelay({ control = 50 + FirstAssaultDelay })
    other[301766] = EHI:AddAssaultDelay({ control = 40 + FirstAssaultDelay })
    other[301771] = EHI:AddAssaultDelay({ control = 30 + FirstAssaultDelay })
    other[301772] = EHI:AddAssaultDelay({ control = 20 + FirstAssaultDelay })
    other[301773] = EHI:AddAssaultDelay({ control = 10 + FirstAssaultDelay })
end
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    ---@class EHIMallcrasherSniperTracker : EHITracker, EHISniperBaseTracker
    local EHIMallcrasherSniperTracker = ehi_sniper_class(EHITracker, { hint = "enemy_snipers_loop" })
    function EHIMallcrasherSniperTracker:OverridePanel()
        self._single_sniper = true
        self._refresh_on_delete = true
        self._count_text = self:CreateText({
            text = "1",
            x = 0,
            color = self._sniper_text_color,
            FitTheText = true,
            visible = false
        })
        self:SniperLogicStarted()
    end
    ---@param t number
    function EHIMallcrasherSniperTracker:StartLoop(t)
        self._time = t
        self:AddTrackerToUpdate()
        self._text:set_visible(true)
        self._count_text:set_visible(false)
        self:AnimateBG()
    end
    function EHIMallcrasherSniperTracker:Refresh()
        self._text:set_visible(false)
        self._count_text:set_visible(true)
        self:RemoveTrackerFromUpdate()
        self:AnimateBG()
        self:SniperSpawned()
    end
    other[301804] = { id = "Snipers", time = 25, class_table = EHIMallcrasherSniperTracker, special_function = SF.ExecuteIfElementIsEnabled }
    other[301805] = { id = "Snipers", time = 21, class_table = EHIMallcrasherSniperTracker, special_function = SF.ExecuteIfElementIsEnabled }
    -- Respawn
    local StartLoop = EHI.Trigger:RegisterCustomSF(function(self, trigger, ...)
        self._trackers:CallFunction("Snipers", "StartLoop", trigger.time)
    end)
    other[301794] = { time = 51, special_function = StartLoop }
    other[301795] = { time = 71, special_function = StartLoop }
    other[301796] = { time = 91, special_function = StartLoop }
    other[301787] = { time = 80, special_function = StartLoop }
    other[301788] = { time = 60, special_function = StartLoop }
    other[301789] = { time = 40, special_function = StartLoop }
end

EHI.Mission:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:AddXPBreakdown({
    objective =
    {
        mallcrasher = { amount = 1000, times = 6 }
    }
})