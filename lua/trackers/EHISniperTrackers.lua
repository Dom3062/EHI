---@class EHISniperWarningTracker : EHIWarningTracker
---@field super EHIWarningTracker
EHISniperWarningTracker = class(EHIWarningTracker)
EHISniperWarningTracker._forced_hint_text = "enemy_snipers"
EHISniperWarningTracker._forced_icons = { "sniper" }
EHISniperWarningTracker._snipers_spawned_popup = EHI:GetOption("show_sniper_spawned_popup")
---@param params EHITracker.params
function EHISniperWarningTracker:pre_init(params)
    self._single_sniper = params.single_sniper
end

function EHISniperWarningTracker:delete()
    if self._snipers_spawned_popup then
        managers.hud:ShowSnipersSpawned(self._single_sniper)
    end
    EHISniperWarningTracker.super.delete(self)
end

---@class EHISniperCountTracker : EHICountTracker
---@field super EHICountTracker
EHISniperCountTracker = class(EHICountTracker)
EHISniperCountTracker._forced_hint_text = "enemy_snipers"
EHISniperCountTracker._forced_icons = { "sniper" }
EHISniperCountTracker._text_color = EHIProgressTracker._progress_bad
EHISniperCountTracker._snipers_spawned_popup = EHI:GetOption("show_sniper_spawned_popup")
---@param params EHITracker.params
function EHISniperCountTracker:pre_init(params)
    EHISniperCountTracker.super.pre_init(self, params)
    if self._snipers_spawned_popup then
        self._current_sniper_count = 0
        self._sniper_count = params.sniper_count or params.single_sniper and 1 or -1
        self._popup_title = params.single_sniper and "SNIPER!" or "SNIPERS!"
        self._popup_desc = params.single_sniper and managers.localization:text("ehi_popup_sniper_spawned") or managers.localization:text("ehi_popup_snipers_spawned")
    end
    if params.snipers_spawned then
        self:SniperSpawnsSuccess()
    end
end

function EHISniperCountTracker:SniperSpawnsSuccess()
    if self._snipers_spawned_popup and self._sniper_count ~= self._count then
        self._current_sniper_count = self._count
        managers.hud:custom_ingame_popup_text(self._popup_title, self._popup_desc, "EHI_Sniper")
    end
end

---@param count number?
function EHISniperCountTracker:DecreaseCount(count)
    EHISniperCountTracker.super.DecreaseCount(self, count)
    self._current_sniper_count = self._current_sniper_count - (count or 1)
end

---@class EHISniperChanceTracker : EHIChanceTracker, EHICountTracker
---@field super EHIChanceTracker
EHISniperChanceTracker = class(EHIChanceTracker)
EHISniperChanceTracker._forced_hint_text = "enemy_snipers"
EHISniperChanceTracker._forced_icons = { "sniper" }
EHISniperChanceTracker.SetCount = EHICountTracker.SetCountNoNegative
EHISniperChanceTracker.IncreaseCount = EHICountTracker.IncreaseCount
EHISniperChanceTracker.DecreaseCount = EHICountTracker.DecreaseCount
EHISniperChanceTracker.FormatCount = EHICountTracker.FormatCount
EHISniperChanceTracker._snipers_spawned_popup = EHISniperCountTracker._snipers_spawned_popup
---@param params EHITracker.params
function EHISniperChanceTracker:pre_init(params)
    EHISniperChanceTracker.super.pre_init(self, params)
    EHICountTracker.pre_init(self, params)
    self._anim_flash_set_count = 1
end

---@param params EHITracker.params
function EHISniperChanceTracker:post_init(params)
    EHISniperChanceTracker.super.post_init(self, params)
    if params.chance_success then
        self:SniperSpawnsSuccess()
    end
end

function EHISniperChanceTracker:OverridePanel()
    local w = self._bg_box:w() / 2
    self._text:set_w(w)
    self._text:set_x(0)
    self:FitTheText()
    self._count_text = self:CreateText({
        text = self:FormatCount(),
        w = w,
        color = EHIProgressTracker._progress_bad,
        left = self._text:right()
    })
    self:FitTheText(self._count_text)
end

---@param chance number?
function EHISniperChanceTracker:SniperSpawnsSuccess(chance)
    if chance then
        self:SetChance(chance)
    end
    self:AnimateBG()
    if self._snipers_spawned_popup then
        managers.hud:custom_ingame_popup_text("SNIPERS", managers.localization:text("ehi_popup_snipers_spawned"), "EHI_Sniper")
    end
end

function EHISniperChanceTracker:SnipersKilled()
    self:SetCount(0)
    self:AnimateBG()
end

---@class EHISniperTimedTracker : EHITracker, EHICountTracker
---@field super EHITracker
EHISniperTimedTracker = class(EHITracker)
EHISniperTimedTracker._forced_hint_text = "enemy_snipers"
EHISniperTimedTracker._forced_icons = { "sniper" }
EHISniperTimedTracker.SetCount = EHICountTracker.SetCountNoNegative
EHISniperTimedTracker.IncreaseCount = EHICountTracker.IncreaseCount
EHISniperTimedTracker.DecreaseCount = EHICountTracker.DecreaseCount
EHISniperTimedTracker.FormatCount = EHICountTracker.FormatCount
EHISniperTimedTracker.Format = EHISniperTimedTracker.ShortFormat
EHISniperTimedTracker._snipers_spawned_popup = EHISniperCountTracker._snipers_spawned_popup
---@param params EHITracker.params
function EHISniperTimedTracker:pre_init(params)
    self._refresh_on_delete = true
    self._count = params.count or 0
    self._refresh_t = params.refresh_t or 0
    self._anim_flash_set_count = 1
    if self._snipers_spawned_popup then
        self._sniper_count = self._count
        self._popup_title = params.single_sniper and "SNIPER!" or "SNIPERS!"
        self._popup_desc = params.single_sniper and managers.localization:text("ehi_popup_sniper_spawned") or managers.localization:text("ehi_popup_snipers_spawned")
    end
    if self._count > 0 then
        self:AnnounceSniperSpawn()
    end
end

function EHISniperTimedTracker:OverridePanel()
    local w = self._bg_box:w() / 2
    self._text:set_w(w)
    self._count_text = self:CreateText({
        text = self:FormatCount(),
        color = EHIProgressTracker._progress_bad,
        w = w,
        left = self._text:right()
    })
end

function EHISniperTimedTracker:Refresh()
    self._time = self._time + self._refresh_t
end

---@param count number
function EHISniperTimedTracker:SniperSpawnsSuccess(count)
    self:AnnounceSniperSpawn()
    self:SetCount(count)
end

function EHISniperTimedTracker:AnnounceSniperSpawn()
    if self._snipers_spawned_popup and self._sniper_count ~= self._count then
        managers.hud:custom_ingame_popup_text(self._popup_title, self._popup_desc, "EHI_Sniper")
    end
end

---@class EHISniperTimedCountTracker : EHIWarningTracker, EHISniperTimedTracker
---@field super EHIWarningTracker
EHISniperTimedCountTracker = class(EHIWarningTracker)
EHISniperTimedCountTracker._forced_hint_text = "enemy_snipers"
EHISniperTimedCountTracker._forced_icons = { "sniper" }
EHISniperTimedCountTracker.IncreaseCount = EHICountTracker.IncreaseCount
EHISniperTimedCountTracker.DecreaseCount = EHICountTracker.DecreaseCount
EHISniperTimedCountTracker.FormatCount = EHICountTracker.FormatCount
EHISniperTimedCountTracker.SetCount = EHISniperTimedTracker.SetCount
EHISniperTimedCountTracker._snipers_spawned_popup = EHISniperCountTracker._snipers_spawned_popup
---@param params EHITracker.params
function EHISniperTimedCountTracker:pre_init(params)
    self._refresh_on_delete = true
    self._count = params.count or 0
    self._count_on_refresh = params.count_on_refresh
    if self._snipers_spawned_popup then
        local single = params.single_sniper or (self._count_on_refresh and self._count_on_refresh == 1)
        self._popup_title = single and "SNIPER!" or "SNIPERS!"
        self._popup_desc = single and managers.localization:text("ehi_popup_sniper_spawned") or managers.localization:text("ehi_popup_snipers_spawned")
    end
end

---@param params EHITracker.params
function EHISniperTimedCountTracker:post_init(params)
    if params.snipers_spawned then
        self._update = false
        self:Refresh()
    end
end

function EHISniperTimedCountTracker:OverridePanel()
    self._count_text = self:CreateText({
        text = self:FormatCount(),
        color = EHIProgressTracker._progress_bad,
        visible = false
    })
end

---@param t number
function EHISniperTimedCountTracker:SetRespawnTime(t)
    self._time = t
    self._check_anim_progress = t <= 10
    self._time_warning = false
    self:AddTrackerToUpdate()
    self._text:set_visible(true)
    self._count_text:set_visible(false)
end

function EHISniperTimedCountTracker:Refresh()
    self:RemoveTrackerFromUpdate()
    self:SetTextColor()
    self._count_text:set_visible(true)
    self._text:set_visible(false)
    if self._count_on_refresh then
        self:SetCount(self._count_on_refresh)
    end
    if self._snipers_spawned_popup then
        managers.hud:custom_ingame_popup_text(self._popup_title, self._popup_desc, "EHI_Sniper")
    end
end

---@class EHISniperTimedChanceTracker : EHITracker, EHIChanceTracker, EHICountTracker
---@field super EHITracker
EHISniperTimedChanceTracker = class(EHITracker)
EHISniperTimedChanceTracker._forced_hint_text = "enemy_snipers"
EHISniperTimedChanceTracker._forced_icons = { "sniper" }
EHISniperTimedChanceTracker.FormatChance = EHIChanceTracker.FormatChance
EHISniperTimedChanceTracker.FormatCount = EHICountTracker.FormatCount
EHISniperTimedChanceTracker.IncreaseCount = EHICountTracker.IncreaseCount
EHISniperTimedChanceTracker.DecreaseCount = EHICountTracker.DecreaseCount
EHISniperTimedChanceTracker.IncreaseChance = EHIChanceTracker.IncreaseChance
EHISniperTimedChanceTracker.DecreaseChance = EHIChanceTracker.DecreaseChance
EHISniperTimedChanceTracker.Format = EHISniperTimedChanceTracker.ShortFormat
EHISniperTimedChanceTracker._snipers_spawned_popup = EHISniperCountTracker._snipers_spawned_popup
---@param params EHITracker.params
function EHISniperTimedChanceTracker:pre_init(params)
    self._refresh_on_delete = true
    self._count = params.count or 0
    self._chance = params.chance or 0
    self._recheck_t = params.recheck_t or 0
    self._no_chance_reset = params.no_chance_reset
    self._delay_on_max_chance = params.delay_on_max_chance
    if self._snipers_spawned_popup then
        local single_sniper = params.single_sniper or params.heli_sniper or self._count == 1
        self._popup_title = single_sniper and "SNIPER!" or "SNIPERS!"
        self._popup_desc = single_sniper and managers.localization:text("ehi_popup_sniper_spawned") or managers.localization:text("ehi_popup_snipers_spawned")
        self._popup_icon = params.heli_sniper and "EHI_Heli" or "EHI_Sniper"
    end
end

---@param params EHITracker.params
function EHISniperTimedChanceTracker:post_init(params)
    if params.chance_success then
        self._update = false
        self:SniperSpawnsSuccess()
    end
end

function EHISniperTimedChanceTracker:OverridePanel()
    local w = self._bg_box:w() / 2
    self._text:set_w(w)
    self._chance_text = self:CreateText({
        text = self:FormatChance(),
        x = 0,
        w = w,
        FitTheText = true
    })
    self._text:set_left(self._chance_text:right())
    self:FitTheTextBasedOnTime(self._recheck_t)
    self._count_text = self:CreateText({
        text = self:FormatCount(),
        color = EHIProgressTracker._progress_bad,
        visible = false
    })
end

function EHISniperTimedChanceTracker:SniperSpawnsSuccess()
    self._count_text:set_visible(true)
    self._chance_text:set_visible(false)
    self._text:set_visible(false)
    self:RemoveTrackerFromUpdate()
    self:AnimateBG()
    if self._snipers_spawned_popup then
        managers.hud:custom_ingame_popup_text(self._popup_title, self._popup_desc, self._popup_icon)
    end
end

---@param t number
function EHISniperTimedChanceTracker:SnipersKilled(t)
    self._count_text:set_visible(false)
    if self._max_chance_reached then
        self._time = self._delay_on_max_chance
    else
        self._time = t or self._recheck_t
        self._chance_text:set_visible(true)
    end
    self._text:set_visible(true)
    self:AddTrackerToUpdate()
    self:AnimateBG()
end

function EHISniperTimedChanceTracker:Refresh()
    if not self._max_chance_reached then
        self._time = self._time + self._recheck_t
    end
end

---@param count number
function EHISniperTimedChanceTracker:SetCount(count)
    self._count = math.max(0, count)
    self._count_text:set_text(self:FormatCount())
    self:AnimateBG(1)
end

---@param amount number
function EHISniperTimedChanceTracker:SetChance(amount)
    self._chance = math.max(0, amount)
    if self._no_chance_reset and self._chance >= 100 then
        self._max_chance_reached = true
        self._text:set_w(self._bg_box:w())
        self._text:set_x(0)
        self:SetTimeNoAnim(self._delay_on_max_chance)
        self._chance_text:set_visible(false)
    else
        self._chance_text:set_text(self:FormatChance())
        self:FitTheText(self._chance_text)
    end
    self:AnimateBG(1)
end

---@class EHISniperLoopTracker : EHITracker, EHIChanceTracker, EHICountTracker
---@field super EHITracker
EHISniperLoopTracker = class(EHITracker)
EHISniperLoopTracker._forced_hint_text = "enemy_snipers_loop"
EHISniperLoopTracker._forced_icons = { "sniper" }
EHISniperLoopTracker.FormatCount = EHICountTracker.FormatCount
EHISniperLoopTracker.SetCount = EHICountTracker.SetCountNoNegative
EHISniperLoopTracker.ResetCount = EHICountTracker.ResetCount
EHISniperLoopTracker.IncreaseCount = EHICountTracker.IncreaseCount
EHISniperLoopTracker._DecreaseCount = EHICountTracker.DecreaseCount
EHISniperLoopTracker.FormatChance = EHIChanceTracker.FormatChance
EHISniperLoopTracker.SetChance = EHIChanceTracker.SetChance
EHISniperLoopTracker.IncreaseChance = EHIChanceTracker.IncreaseChance
EHISniperLoopTracker.DecreaseChance = EHIChanceTracker.DecreaseChance
EHISniperLoopTracker.Format = EHISniperLoopTracker.ShortFormat
EHISniperLoopTracker._snipers_spawned_popup = EHISniperCountTracker._snipers_spawned_popup
---@param params EHITracker.params
function EHISniperLoopTracker:pre_init(params)
    self._refresh_on_delete = true
    self._count = 0
    self._anim_flash_set_count = 1
    self._chance = params.chance or 0
    self._anim_flash_set_chance = 1
    self._on_fail_refresh_t = params.on_fail_refresh_t or 0
    self._on_success_refresh_t = params.on_success_refresh_t or 0
    if self._snipers_spawned_popup then
        self._current_sniper_count = 0
        self._sniper_count_multiple = params.single_sniper and params.sniper_count
        self._sniper_count = params.single_sniper and 1 or params.sniper_count or -1
        self._popup_title = params.single_sniper and "SNIPER!" or "SNIPERS!"
        self._popup_desc = params.single_sniper and managers.localization:text("ehi_popup_sniper_spawned") or managers.localization:text("ehi_popup_snipers_spawned")
    end
end

function EHISniperLoopTracker:OverridePanel()
    self._original_bg_size = self._bg_box:w()
    self:SetBGSize(self._bg_box:w() / 2)
    local w = self._bg_box:w() / 3
    self._text:set_w(w)
    self._chance_text = self:CreateText({
        text = self:FormatChance(),
        x = 0,
        w = w,
        FitTheText = true
    })
    self._text:set_left(self._chance_text:right())
    self:FitTheTextBasedOnTime(self._on_fail_refresh_t, self._on_success_refresh_t)
    self._count_text = self:CreateText({
        text = self:FormatCount(),
        w = w,
        color = EHIProgressTracker._progress_bad,
        left = self._text:right()
    })
    self:SetIconX()
end

---@param time number
function EHISniperLoopTracker:SetTimeNoAnim(time)
    self._time = time
    self._text:set_text(self:Format())
end

function EHISniperLoopTracker:SetMultipleSniperSpawns()
    if self._snipers_spawned_popup then
        self._popup_title = "SNIPERS!"
        self._popup_desc = managers.localization:text("ehi_popup_snipers_spawned")
        self._sniper_count = self._sniper_count_multiple or self._sniper_count
        self._sniper_count_multiple = nil
    end
end

---@param t number?
function EHISniperLoopTracker:OnChanceFail(t)
    self:SetTimeNoAnim(t or self._on_fail_refresh_t)
end

function EHISniperLoopTracker:OnChanceSuccess()
    self:SetTimeNoAnim(self._on_success_refresh_t)
    self:AnnounceSniperSpawn()
end

function EHISniperLoopTracker:AnnounceSniperSpawn()
    if self._snipers_spawned_popup and self._sniper_count ~= self._current_sniper_count then
        self._current_sniper_count = self._count
        managers.hud:custom_ingame_popup_text(self._popup_title, self._popup_desc, "EHI_Sniper")
    end
end

---@param count number?
function EHISniperLoopTracker:DecreaseCount(count)
    self:_DecreaseCount(count)
    self._current_sniper_count = self._current_sniper_count - (count or 1)
end

---@param count number
function EHISniperLoopTracker:SetCountRemovalCheck(count)
    self._count = math.max(0, count)
    if self._count == 0 then
        self:ForceDelete()
    else
        self._count_text:set_text(self:FormatCount())
        self:AnimateBG(1)
    end
end

---@param amount number
function EHISniperLoopTracker:DisableChanceUpdate(amount)
end

function EHISniperLoopTracker:RequestRemoval()
    if self._count == 0 then
        self:ForceDelete()
        return
    end
    self.SetCount = self.SetCountRemovalCheck
    self.SetChance = self.DisableChanceUpdate
    self._chance_text:set_visible(false)
    self._text:set_visible(false)
    self:RemoveTrackerFromUpdate()
    self:SetBGSize(self._original_bg_size, "set", true)
    self._count_text:set_w(self._bg_box:w())
    self._count_text:set_x(0)
    self:FitTheText(self._count_text)
    local panel_w = self._original_bg_size + (self._icon_gap_size_scaled * self._n_of_icons)
    self:AnimatePanelW(panel_w)
    self:AnimIconX(self._original_bg_size + self._gap_scaled)
    self:ChangeTrackerWidth(panel_w)
end

---@class EHISniperLoopRestartTracker : EHISniperLoopTracker
---@field super EHISniperLoopTracker
EHISniperLoopRestartTracker = class(EHISniperLoopTracker)
---@param params EHITracker.params
function EHISniperLoopRestartTracker:post_init(params)
    EHISniperLoopRestartTracker.super.post_init(self, params)
    self._sniper_respawn = true
    self._initial_spawn = params.initial_spawn or self._chance >= 100
    self._initial_spawn_chance_set = params.initial_spawn_chance_set
    self._reset_t = params.reset_t
    if params.chance_success then
        self:OnChanceSuccess(self._chance)
    end
end

---@param chance_reset number
function EHISniperLoopRestartTracker:OnChanceSuccess(chance_reset)
    if self._removal_requested then
        return
    end
    self:SetChance(chance_reset)
    self:RemoveTrackerFromUpdate()
    self._sniper_respawn = false
    if self._snipers_spawned_popup then
        managers.hud:custom_ingame_popup_text(self._popup_title, self._popup_desc, "EHI_Sniper")
    end
end

function EHISniperLoopRestartTracker:DecreaseCount()
    EHISniperLoopRestartTracker.super.DecreaseCount(self)
    self:SniperLoopStart()
end

function EHISniperLoopRestartTracker:SniperLoopStart()
    if self._sniper_respawn then
        return
    end
    self._sniper_respawn = true
    self:OnChanceFail(self._reset_t)
    self:AddTrackerToUpdate()
end

function EHISniperLoopRestartTracker:Refresh()
    if self._initial_spawn then
        self:OnChanceSuccess(self._initial_spawn_chance_set or 0)
        self._initial_spawn = nil
        self._initial_spawn_chance_set = nil
    end
end

function EHISniperLoopRestartTracker:RequestRemoval()
    self._sniper_respawn = true
    self._removal_requested = true
    EHISniperLoopRestartTracker.super.RequestRemoval(self)
end

---@class EHISniperTimedChanceOnceTracker : EHISniperTimedChanceTracker
---@field super EHISniperTimedChanceTracker
EHISniperTimedChanceOnceTracker = class(EHISniperTimedChanceTracker)
---@param count number
function EHISniperTimedChanceOnceTracker:SniperSpawnsSuccess(count)
    EHISniperTimedChanceOnceTracker.super.SniperSpawnsSuccess(self)
    if count then
        self:SetCount(count)
    end
end

---@param count number
function EHISniperTimedChanceOnceTracker:SetCount(count)
    EHISniperTimedChanceOnceTracker.super.SetCount(self, count)
    if self._count == 0 then
        self:ForceDelete()
    else
        self:AnimateBG(1)
    end
end

---@class EHISniperHeliTracker : EHITracker
---@field super EHITracker
EHISniperHeliTracker = class(EHITracker)
EHISniperHeliTracker._forced_hint_text = "enemy_snipers_heli"
EHISniperHeliTracker._forced_icons = EHISniperHeliTracker._ONE_ICON and { { icon = EHI.Icons.Heli, color = Color.red } } or { EHI.Icons.Heli, "sniper" }
EHISniperHeliTracker._snipers_spawned_popup = EHISniperCountTracker._snipers_spawned_popup
EHISniperHeliTracker._refresh_on_delete = true
---@param params EHITracker.params
function EHISniperHeliTracker:pre_init(params)
    self._refresh_t = params.refresh_t or 0
    if self._snipers_spawned_popup then
        self._popup_desc = managers.localization:text("ehi_popup_sniper_spawned")
    end
end

function EHISniperHeliTracker:OverridePanel()
    self._count_text = self:CreateText({
        text = "1",
        color = EHIProgressTracker._progress_bad,
        visible = false
    })
end

function EHISniperHeliTracker:SniperRespawn()
    self._time = self._refresh_t
    self._text:set_visible(true)
    self._count_text:set_visible(false)
    self:AddTrackerToUpdate()
    self:AnimateBG()
end

function EHISniperHeliTracker:SniperKilledUpdateCount()
    self._count_text:set_text("0")
    self:AnimateBG()
end

function EHISniperHeliTracker:Refresh()
    self._count_text:set_text("1")
    self._count_text:set_visible(true)
    self._text:set_visible(false)
    self:RemoveTrackerFromUpdate()
    self:AnimateBG()
    if self._snipers_spawned_popup then
        managers.hud:custom_ingame_popup_text("SNIPER!", self._popup_desc, "EHI_Heli")
    end
end

---@class EHISniperHeliTimedChanceTracker : EHISniperTimedChanceTracker
---@field super EHISniperTimedChanceTracker
EHISniperHeliTimedChanceTracker = class(EHISniperTimedChanceTracker)
EHISniperHeliTimedChanceTracker._forced_hint_text = "enemy_snipers_heli"
EHISniperHeliTimedChanceTracker._forced_icons = EHISniperHeliTracker._forced_icons
---@param params EHITracker.params
function EHISniperHeliTimedChanceTracker:pre_init(params)
    params.heli_sniper = true
    EHISniperHeliTimedChanceTracker.super.pre_init(self, params)
end

function EHISniperHeliTimedChanceTracker:OverridePanel()
    EHISniperHeliTimedChanceTracker.super.OverridePanel(self)
    self._text_font_size = self._text:font_size()
end

---@param t number
function EHISniperHeliTimedChanceTracker:SniperSpawnsSuccess(t)
    self._time = t
    self._sniper_incoming = true
    if not self._max_chance_reached then
        self._chance_text:set_visible(false)
        self._text:set_w(self._bg_box:w())
        self._text:set_x(0)
        self:FitTheText()
    end
end

---@param t number
function EHISniperHeliTimedChanceTracker:SnipersKilled(t)
    if not self._max_chance_reached then
        self._text:set_w(self._chance_text:w())
        self._text:set_left(self._chance_text:right())
        self._text:set_font_size(self._text_font_size)
    end
    EHISniperHeliTimedChanceTracker.super.SnipersKilled(self, t)
end

function EHISniperHeliTimedChanceTracker:Refresh()
    if self._sniper_incoming then
        self._sniper_incoming = false
        EHISniperHeliTimedChanceTracker.super.SniperSpawnsSuccess(self)
    elseif not self._max_chance_reached then
        self._time = self._time + self._recheck_t
    end
end