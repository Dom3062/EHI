local EHI = EHI
---@class EHIbex11Tracker : EHIAchievementProgressTracker
---@field super EHIAchievementProgressTracker
EHIbex11Tracker = class(EHIAchievementProgressTracker)
---@param params EHITracker.params
function EHIbex11Tracker:pre_init(params)
    params.max = 11 -- Loot
    params.show_progress_on_finish = true
    self._box_max = 240
    self._box_progress = 0
    self._objectives_to_complete = 2 -- Loot and Deposit boxes
    EHIbex11Tracker.super.pre_init(self, params)
    EHI:AddAchievementToCounter({
        achievement = "bex_11",
        no_sync = true
    })
end

function EHIbex11Tracker:FormatBoxProgress()
    return self._box_progress .. "/" .. self._box_max
end

function EHIbex11Tracker:OverridePanel()
    self._icon_previous_pos = self._icon1 and self._icon1:x()
    self._finish_status_text = self:CreateText({
        name = "finish_status_text",
        status_text = "finish",
        color = Color.green
    })
    self._finish_status_text:set_visible(false)
    self._box_progress_text = self:CreateText({
        name = "box_progress_text",
        text = self:FormatBoxProgress()
    })
    self:SetBGSize()
    self._box_progress_text:set_left(self._text:right())
    self:SetIconX()
end

function EHIbex11Tracker:SetFailed()
    EHIbex11Tracker.super.SetFailed(self)
    self:SetTextColor(Color.red, self._box_progress_text)
    self:SetTextColor(Color.red, self._finish_status_text)
    self:SetStatusText("fail", self._finish_status_text)
end

function EHIbex11Tracker:SetCompleted(...)
    EHIbex11Tracker.super.SetCompleted(self, ...)
    if self._status and self._status == "completed" and not self._loot_objective_done then
        self._loot_objective_done = true
        self:ObjectiveComplete()
    end
end

function EHIbex11Tracker:IncreaseBoxProgress()
    self:SetBoxProgress(self._box_progress + 1)
end

---@param progress number
function EHIbex11Tracker:SetBoxProgress(progress)
    if self._box_progress ~= progress and not self._disable_counting_box then
        self._box_progress = progress
        self._box_progress_text:set_text(self:FormatBoxProgress())
        self:FitTheText(self._box_progress_text)
        self:AnimateBG(1)
        if self._box_progress == self._box_max then
            self._disable_counting_box = true
            self:ObjectiveComplete()
            self:SetTextColor(Color.green, self._box_progress_text)
        end
    end
end

function EHIbex11Tracker:ObjectiveComplete()
    self._objectives_to_complete = self._objectives_to_complete - 1
    if self._objectives_to_complete == 0 then -- Both objectives complete
        self._finish_status_text:set_visible(true)
        self._text:set_visible(false)
        self._box_progress_text:set_visible(false)
        self._bg_box:set_w(self._bg_box:w() / 2)
        local panel_w = self._panel:w() / 2
        self:AnimatePanelW(panel_w)
        self:AnimIconX(self._icon_previous_pos)
        self:ChangeTrackerWidth(panel_w)
        self:AnimateBG()
    end
end

local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local element_sync_triggers =
{
    [102290] = { id = "VaultGas", icons = { Icon.Teargas }, hook_element = 102157, hint = Hints.Teargas }
}
local hack_start = EHI:GetInstanceElementID(100015, 20450)
---@type ParseTriggerTable
local triggers = {
    [102302] = { time = 28.05 + 418/30, id = "Suprise", icons = { "pd2_question" }, hint = Hints.Question },
    [EHI:GetInstanceElementID(100108, 35450)] = { time = 4.8, id = "SuprisePull", icons = { Icon.Wait } },

    [hack_start] = { id = "ServerHack", icons = { Icon.PCHack }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExistsAccurate, element = EHI:GetInstanceElementID(100014, 20450), hint = Hints.Hack },
    [EHI:GetInstanceElementID(100016, 20450)] = { id = "ServerHack", special_function = SF.PauseTracker },

    [101818] = { additional_time = 50 + 9.3, random_time = 30, id = "HeliDropLance", icons = Icon.HeliDropDrill, hint = Hints.DrillPartsDelivery },
    [101820] = { time = 9.3, id = "HeliDropLance", icons = Icon.HeliDropDrill, special_function = SF.SetTrackerAccurate, hint = Hints.DrillPartsDelivery },

    [103919] = { additional_time = 25 + 1 + 13, random_time = 5, id = "Van", icons = Icon.CarEscape, trigger_times = 1, hint = Hints.LootEscape },
    [100840] = { time = 1 + 13, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTrackerAccurate, hint = Hints.LootEscape }
}
-- levels/instances/unique/bex/bex_computer
for i = 7250, 9050, 150 do
    local id = "PCHack" .. i
    triggers[EHI:GetInstanceElementID(100006, i)] = { time = 30, id = id, icons = { Icon.PCHack }, waypoint = { position_by_unit = EHI:GetInstanceUnitID(100000, i) } }
    triggers[EHI:GetInstanceElementID(100138, i)] = { id = id, special_function = SF.RemoveTracker } -- Alarm
end
if EHI:IsClient() then
    triggers[hack_start].client = { time = 90, random_time = 10, special_function = SF.UnpauseTrackerIfExists }
    triggers[EHI:GetInstanceElementID(100011, 20450)] = { id = "ServerHack", special_function = SF.RemoveTracker }
    triggers[102157] = { additional_time = 60, random_time = 15, id = "VaultGas", icons = { Icon.Teargas }, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.Teargas }
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, "element")
end

---@type ParseAchievementTable
local achievements =
{
    bex_10 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [103701] = { special_function = EHI:RegisterCustomSpecialFunction(function(self, trigger, element, enabled)
                if enabled then
                    self._trackers:SetAchievementStatus("bex_10", "defend")
                    self:UnhookTrigger(103704)
                end
            end) },
            [103702] = { special_function = SF.SetAchievementFailed },
            [103704] = { special_function = SF.SetAchievementFailed },
            [102602] = { special_function = SF.SetAchievementComplete },
            [100107] = { status = "loud", class = TT.Achievement.Status },
        }
    },
    bex_11 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100107] = { class = "EHIbex11Tracker" },
            [103677] = { special_function = SF.CallCustomFunction, f = "IncreaseBoxProgress" },
            [103772] = { special_function = SF.SetAchievementFailed }
        }
    }
}

local tbl =
{
    [100000] = { remove_vanilla_waypoint = 100005 }
}
EHI:UpdateInstanceUnits(tbl, 22450)

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 60 + 30 })
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
    achievement = achievements,
    other = other
})
EHI:ShowLootCounter({ max = 11 })
local xp_override =
{
    params =
    {
        min_max =
        {
            loot_all = { min = 4, max = 11 }
        }
    }
}
EHI:AddXPBreakdown({
    tactic =
    {
        stealth =
        {
            objectives =
            {
                { amount = 3000, name = "mex2_found_managers_safe" },
                { amount = 1000, name = "mex2_picked_up_tape" },
                { amount = 1000, name = "mex2_used_tape" },
                { amount = 3000, name = "mex2_picked_up_keychain" },
                { amount = 2000, name = "mex2_found_manual" },
                { amount = 3000, name = "pc_hack" },
                { amount = 2000, name = "ggc_laser_disabled" },
                { escape = 2000 }
            },
            loot_all = 1000,
            total_xp_override = xp_override
        },
        loud =
        {
            objectives =
            {
                { amount = 8000, name = "vault_found" },
                { amount = 3000, name = "mex2_it_guy_escorted" },
                { amount = 3000, name = "pc_hack" },
                { amount = 3000, name = "mex2_beast_arrived" },
                { amount = 12000, name = "vault_open" },
                { escape = 3000 }
            },
            loot_all = 1000,
            total_xp_override = xp_override
        }
    }
})