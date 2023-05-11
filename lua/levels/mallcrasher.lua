local EHI = EHI
local lerp = math.lerp
local sin = math.sin
local Color = Color
EHIMoneyCounterTracker = class(EHITracker)
EHIMoneyCounterTracker._update = false
function EHIMoneyCounterTracker:init(panel, params)
    self._money = params.money or 0
    EHIMoneyCounterTracker.super.init(self, panel, params)
end

function EHIMoneyCounterTracker:Format()
    return "$" .. self._money
end

function EHIMoneyCounterTracker:AddMoney(money)
    self._money = self._money + money
    self._text:set_text(self:Format())
    self:FitTheText()
end

EHIameno3Tracker = EHI:AchievementClass(EHIAchievementTracker, "EHIameno3Tracker")
EHIameno3Tracker.FormatNumber = EHINeededValueTracker.Format
EHIameno3Tracker.FormatNumber2 = EHINeededValueTracker.FormatNumber
EHIameno3Tracker.IncreaseProgress = EHIProgressTracker.IncreaseProgress
function EHIameno3Tracker:init(panel, params)
    self._secured = params.secured or 0
    self._secured_formatted = "0"
    self._to_secure = params.to_secure or 0
    self._to_secure_formatted = self:FormatNumber2(self._to_secure)
    EHIameno3Tracker.super.init(self, panel, params)
    EHI:AddAchievementToCounter({
        achievement = "ameno_3",
        counter =
        {
            check_type = EHI.LootCounter.CheckType.ValueOfSmallLoot
        }
    })
end

function EHIameno3Tracker:OverridePanel()
    self._panel:set_w(self._panel:w() * 2)
    self._time_bg_box:set_w(self._time_bg_box:w() * 2)
    self._money_text = self._time_bg_box:text({
        name = "text2",
        text = self:FormatNumber(),
        align = "center",
        vertical = "center",
        w = self._time_bg_box:w() / 2,
        h = self._time_bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h() * self._text_scale,
        color = self._text_color
    })
    self:FitTheText(self._money_text)
    self._money_text:set_left(0)
    self._text:set_left(self._money_text:right())
    if self._icon1 then
        self._icon1:set_x(self._icon1:x() * 2)
    end
end

function EHIameno3Tracker:AnimateColor()
    if self._text and alive(self._text) then
        self._text:animate(function(o)
            local c = Color(self._text_color.r, self._text_color.g, self._text_color.b)
            while true do
                local t = 1
                while t > 0 do
                    t = t - coroutine.yield()
                    local n = sin(t * 180)
                    c.r = lerp(self._text_color.r, self._warning_color.r, n)
                    c.g = lerp(self._text_color.g, self._warning_color.g, n)
                    c.b = lerp(self._text_color.b, self._warning_color.b, n)
                    o:set_color(c)
                    self._money_text:set_color(c)
                end
                t = 1
            end
        end)
    end
end

function EHIameno3Tracker:SetProgress(progress)
    if self._secured ~= progress and not self._disable_counting then
        self._secured = progress
        self._secured_formatted = self:FormatNumber2(progress)
        self._money_text:set_text(self:FormatNumber())
        self:FitTheText(self._money_text)
        if self._flash then
            self:AnimateBG(self._flash_times)
        end
        self:SetCompleted()
    end
end

function EHIameno3Tracker:SetCompleted(force)
    if (self._secured >= self._to_secure and not self._status) or force then
        self._status = "completed"
        self._text:stop()
        self:SetTextColor(Color.green)
        if self._remove_after_reaching_counter_target or force then
            self.update = self.update_fade
        else
            self:SetStatusText("finish", self._money_text)
            self:FitTheText(self._money_text)
        end
        self._disable_counting = true
        self._achieved_popup_showed = true
    end
end

function EHIameno3Tracker:SetTextColor(color)
    EHINeededValueTracker.super.SetTextColor(self, color)
    self._money_text:set_color(color)
end

local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local AddMoney = EHI:GetFreeCustomSpecialFunctionID()
local MoneyTrigger = { id = "MallDestruction", special_function = AddMoney }
local OverkillOrBelow = EHI:IsDifficultyOrBelow(EHI.Difficulties.OVERKILL)
local triggers =
{
    -- Time before escape vehicle arrives
    [300248] = { time = (OverkillOrBelow and 120 or 300) + 25, id = "EscapeHeli", icons = Icon.HeliEscapeNoLoot, waypoint = { position_by_element = 300322 } },
    -- 120: Base Delay on OVK or below
    -- 300: Base Delay on Mayhem or above
    -- 25: Escape zone activation delay

    [300043] = { id = "MallDestruction", class = "EHIMoneyCounterTracker", icons = { "C_Vlad_H_Mallcrasher_Shoot" } },
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

if EHI:IsClient() then
    triggers[302287] = EHI:ClientCopyTrigger(triggers[300248], { time = (OverkillOrBelow and 115 or 120) + 25 })
    triggers[300223] = EHI:ClientCopyTrigger(triggers[300248], { time = 60 + 25 })
    triggers[302289] = EHI:ClientCopyTrigger(triggers[300248], { time = 30 + 25 })
    triggers[300246] = EHI:ClientCopyTrigger(triggers[300248], { time = 25 })
end

local achievements =
{
    window_cleaner =
    {
        elements =
        {
            [301056] = { max = 171, flash_times = 1, class = TT.AchievementProgress },
            [300791] = { special_function = SF.IncreaseProgress }
        }
    },
    ameno_3 =
    {
        difficulty_pass = EHI:IsDifficulty(EHI.Difficulties.OVERKILL),
        elements =
        {
            [301148] = { time = 50, to_secure = 1800000, class = "EHIameno3Tracker" },
        },
        load_sync = function(self)
            local t = 50 - self._trackers._t
            if t > 0 then
                self._trackers:AddTracker({
                    time = t,
                    id = "ameno_3",
                    secured = managers.loot:get_real_total_small_loot_value(),
                    to_secure = 1800000,
                    icons = EHI:GetAchievementIcon("ameno_3"),
                    class = "EHIameno3Tracker"
                })
            end
        end,
        cleanup_callback = function()
            EHIameno3Tracker = nil
        end
    },
    uno_3 =
    {
        elements =
        {
            [301148] = { time = 180, class = TT.Achievement },
            [300241] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local FirstAssaultDelay = 10 + 30
local other = {}
if EHI:IsMayhemOrAbove() then
    other[301049] = EHI:AddAssaultDelay({ time = FirstAssaultDelay })
else
    other[301138] = EHI:AddAssaultDelay({ time = 50 + FirstAssaultDelay })
    other[301766] = EHI:AddAssaultDelay({ time = 40 + FirstAssaultDelay })
    other[301771] = EHI:AddAssaultDelay({ time = 30 + FirstAssaultDelay })
    other[301772] = EHI:AddAssaultDelay({ time = 20 + FirstAssaultDelay })
    other[301773] = EHI:AddAssaultDelay({ time = 10 + FirstAssaultDelay })
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:RegisterCustomSpecialFunction(AddMoney, function(self, trigger, element, ...)
    self._trackers:CallFunction(trigger.id, "AddMoney", element._values.amount)
end)
EHI:AddXPBreakdown({
    objective =
    {
        mallcrasher = { amount = 1000, times = 6 }
    }
})