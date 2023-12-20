local EHI = EHI
local Icon = EHI.Icons
---@class EHICraneFixChanceTracker : EHIWarningTracker, EHIChanceTracker
---@field super EHIWarningTracker
---@field _icon2 PanelBitmap?
EHICraneFixChanceTracker = class(EHIWarningTracker)
EHICraneFixChanceTracker._forced_icons = EHICraneFixChanceTracker._ONE_ICON and { Icon.Fix } or { Icon.Winch, Icon.Fix }
EHICraneFixChanceTracker._show_completion_color = true
EHICraneFixChanceTracker.FormatChance = EHIChanceTracker.FormatChance
EHICraneFixChanceTracker.IncreaseChance = EHIChanceTracker.IncreaseChance
EHICraneFixChanceTracker.SetChance = EHIChanceTracker.SetChance
EHICraneFixChanceTracker.SetFailed = EHIAchievementTracker.SetFailed
---@param panel Panel
---@param params EHITracker.params
---@param parent_class EHITrackerManager
function EHICraneFixChanceTracker:init(panel, params, parent_class)
    self._chance = 30
    params.time = 20
    EHICraneFixChanceTracker.super.init(self, panel, params, parent_class)
end

function EHICraneFixChanceTracker:OverridePanel()
    self:SetBGSize()
    self._chance_text = self:CreateText({
        name = "text2",
        text = self:FormatChance(),
        w = self._bg_box:w() / 2,
        left = self._text:right(),
        FitTheText = true
    })
    self:SetIconX()
    if self._icon2 then
        self:SetIconX(self._icon1, self._icon2)
    end
end

local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local triggers =
{
    [100975] = { time = 5, id = "C4Pipeline", icons = { Icon.C4 }, hint = Hints.Explosion },

    [102011] = { time = 5, id = "Thermite", icons = { Icon.Fire }, hint = Hints.Thermite },

    [101098] = { time = 5 + 7 + 2, id = "WalkieTalkie", icons = { Icon.Door }, hint = Hints.Wait },
    [100109] = { id = "WalkieTalkie", special_function = SF.RemoveTracker },

    [EHI:GetInstanceElementID(100209, 10450)] = { time = 3, id = "KeygenHack", icons = { Icon.Tablet }, hint = Hints.Hack },

    [103130] = { time = 10, id = "LocomotiveRefuel", icons = { Icon.Oil }, hint = Hints.FuelTransfer },

    [EHI:GetInstanceElementID(100024, 11650)] = { time = 25, id = "Turntable", icons = { Icon.Train, Icon.Loop }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists, hint = Hints.Wait },
    [EHI:GetInstanceElementID(100025, 11650)] = { id = "Turntable", special_function = SF.PauseTracker },

    [EHI:GetInstanceElementID(100089, 22250)] = { time = 0.1 + 400/30, id = "CraneLowerHooks", icons = { Icon.Winch }, hint = Hints.des_Crane },
    [EHI:GetInstanceElementID(100010, 22250)] = { time = 400/30 + 91.5 + 2 + 400/30, id = "CraneMove", icons = { Icon.Winch }, class = TT.Pausable, hint = Hints.des_Crane },
    [EHI:GetInstanceElementID(100047, 22250)] = { id = "CraneMove", special_function = SF.PauseTracker },
    [EHI:GetInstanceElementID(100059, 22250)] = { id = "CraneMove", special_function = SF.UnpauseTracker },
    [EHI:GetInstanceElementID(100060, 22250)] = { id = "CraneMove", special_function = SF.PauseTracker },
    [EHI:GetInstanceElementID(100046, 22250)] = { id = "CraneFixChance", class = "EHICraneFixChanceTracker", trigger_times = 1, hint = Hints.trai_Crane },
    [EHI:GetInstanceElementID(100035, 22250)] = { id = "CraneFixChance", special_function = SF.IncreaseChanceFromElement }, -- +10%
    [EHI:GetInstanceElementID(100039, 22250)] = { id = "CraneFixChance", special_function = SF.SetAchievementFailed }, -- Players need to fix the crane, runs once (Won't trigger "ACHIEVEMENT FAILED!" popup)
    [EHI:GetInstanceElementID(100220, 22250)] = { chance = 33, id = "LocomotiveStartChance", icons = { Icon.Power }, class = TT.Chance, hint = Hints.trai_LocoStart },
    [EHI:GetInstanceElementID(100193, 22250)] = { id = "LocomotiveStartChance", special_function = SF.IncreaseChanceFromElement }, -- +34%
    [EHI:GetInstanceElementID(100187, 22250)] = { id = "LocomotiveStartChance", special_function = SF.RemoveTracker },
    [EHI:GetInstanceElementID(100031, 22850)] = { time = 1175/30, id = "LocomotiveMoveToTurntable", icons = { Icon.Train }, hint = Hints.Wait }
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
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
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