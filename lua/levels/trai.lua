local EHI = EHI
local Icon = EHI.Icons
---@class EHICraneFixChanceTracker : EHIWarningTracker, EHIChanceTracker
---@field super EHIWarningTracker
---@field _icon2 PanelBitmap?
EHICraneFixChanceTracker = class(EHIWarningTracker)
EHICraneFixChanceTracker._forced_icons = EHI:GetOption("show_one_icon") and { Icon.Fix } or { Icon.Winch, Icon.Fix }
EHICraneFixChanceTracker._show_completion_color = true
EHICraneFixChanceTracker.FormatChance = EHIChanceTracker.Format
EHICraneFixChanceTracker.IncreaseChance = EHIChanceTracker.IncreaseChance
EHICraneFixChanceTracker.SetFailed = EHIAchievementTracker.SetFailed
---@param panel Panel
---@param params EHITracker_params
---@param parent_class EHITrackerManager
function EHICraneFixChanceTracker:init(panel, params, parent_class)
    self._chance = 30
    params.time = 20
    EHICraneFixChanceTracker.super.init(self, panel, params, parent_class)
end

function EHICraneFixChanceTracker:OverridePanel()
    self:SetBGSize()
    self._chance_text = self._bg_box:text({
        name = "text2",
        text = self:FormatChance(),
        align = "center",
        vertical = "center",
        w = self._bg_box:w() / 2,
        h = self._icon_size_scaled,
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h() * self._text_scale,
        color = self._text_color
    })
    self:FitTheText(self._chance_text)
    self._chance_text:set_left(self._text:right())
    self:SetIconX()
    if self._icon2 then
        self:SetIconX(self._icon1, self._icon2)
    end
end

function EHICraneFixChanceTracker:SetChance(amount)
    self._chance = math.max(0, amount)
    self._chance_text:set_text(self:FormatChance())
    self:AnimateBG()
end

local SF = EHI.SpecialFunctions
local TT = EHI.Trackers

local triggers =
{
    [100975] = { time = 5, id = "C4Pipeline", icons = { Icon.C4 } },

    [102011] = { time = 5, id = "Thermite", icons = { Icon.Fire } },

    [101098] = { time = 5 + 7 + 2, id = "WalkieTalkie", icons = { Icon.Door } },
    [100109] = { id = "WalkieTalkie", special_function = SF.RemoveTracker },

    [EHI:GetInstanceElementID(100209, 10450)] = { time = 3, id = "KeygenHack", icons = { Icon.PCHack } },

    [103130] = { time = 10, id = "LocomotiveRefuel", icons = { Icon.Oil } },

    [EHI:GetInstanceElementID(100024, 11650)] = { time = 25, id = "Turntable", icons = { Icon.Train, Icon.Loop }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [EHI:GetInstanceElementID(100025, 11650)] = { id = "Turntable", special_function = SF.PauseTracker },

    [EHI:GetInstanceElementID(100089, 22250)] = { time = 0.1 + 400/30, id = "CraneLowerHooks", icons = { Icon.Winch } },
    [EHI:GetInstanceElementID(100010, 22250)] = { time = 400/30 + 91.5 + 2 + 400/30, id = "CraneMove", icons = { Icon.Winch }, class = TT.Pausable },
    [EHI:GetInstanceElementID(100047, 22250)] = { id = "CraneMove", special_function = SF.PauseTracker },
    [EHI:GetInstanceElementID(100059, 22250)] = { id = "CraneMove", special_function = SF.UnpauseTracker },
    [EHI:GetInstanceElementID(100060, 22250)] = { id = "CraneMove", special_function = SF.PauseTracker },
    [EHI:GetInstanceElementID(100046, 22250)] = { id = "CraneFixChance", class = "EHICraneFixChanceTracker", trigger_times = 1 },
    [EHI:GetInstanceElementID(100035, 22250)] = { id = "CraneFixChance", special_function = SF.IncreaseChanceFromElement }, -- +10%
    [EHI:GetInstanceElementID(100039, 22250)] = { id = "CraneFixChance", special_function = SF.SetAchievementFailed }, -- Players need to fix the crane, runs once (Won't trigger "ACHIEVEMENT FAILED!" popup)
    [EHI:GetInstanceElementID(100220, 22250)] = { chance = 33, id = "LocomotiveStartChance", icons = { Icon.Power }, class = TT.Chance },
    [EHI:GetInstanceElementID(100193, 22250)] = { id = "LocomotiveStartChance", special_function = SF.IncreaseChanceFromElement }, -- +34%
    [EHI:GetInstanceElementID(100187, 22250)] = { id = "LocomotiveStartChance", special_function = SF.RemoveTracker },
    [EHI:GetInstanceElementID(100031, 22850)] = { time = 1175/30, id = "LocomotiveMoveToTurntable", icons = { Icon.Train } }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 50 + 30 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100015] = { id = "Snipers", class = TT.Sniper.Count, trigger_times = 1 }
    --[[other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%]]
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({
    mission = triggers,
    other = other
})

local required_bags = 6
local bag_multiplier = 2
if EHI:IsMayhemOrAbove() then
    required_bags = 9
    bag_multiplier = 3
end
EHI:ShowLootCounter({
    max = required_bags + ((6 * bag_multiplier) + 8) -- (4 secondary wagons with 2 money bags); total 5 wagons, one is disabled
})