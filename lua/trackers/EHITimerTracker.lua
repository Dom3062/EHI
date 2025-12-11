---@alias EHITimerGroupTracker.Timer { label: Text, time: number, jammed: boolean, not_powered: boolean, autorepair: boolean, animate_warning: boolean?, animate_completion: boolean?, anim_started: thread, anim_autorepair_started: thread, pos: number, timer_gui: TimerGui, is_running: boolean }

local EHI = EHI
local Color = Color

---@class EHITimerTracker : EHIWarningTracker, EHIGroupTracker
---@field super EHIWarningTracker
EHITimerTracker = class(EHIWarningTracker)
EHITimerTracker._needs_update = false
EHITimerTracker._autorepair_color = EHI:GetColorFromOption("tracker_waypoint", "drill_autorepair")
EHITimerTracker._paused_color = EHIPausableTracker._paused_color
EHITimerTracker._not_powered_color = EHI:GetColorFromOption("tracker_waypoint", "drill_not_powered")
EHITimerTracker.StartTimer = EHITimedChanceTracker.StartTimer
EHITimerTracker.StopTimer = EHITimedChanceTracker.StopTimer
EHITimerTracker._upgrade_definition =
{
    faster = 2,
    silent = 3,
    restarter = 4
}
function EHITimerTracker:pre_init(params)
    if params.icons[1] and params.icons[1].icon and params.upgrades and not self._ONE_ICON then
        self._upgradeable = true
        for upgrade, icon in pairs(self._upgrade_definition) do
            local level = params.upgrades[upgrade] or 0
            local upgrade_is_present = level > 0
            params.icons[icon] = { icon = upgrade, alpha = upgrade_is_present and 1 or 0.25, color = upgrade_is_present and self:GetUpgradeColor(level, params.theme) or nil }
        end
    end
end

function EHITimerTracker:post_init(params)
    self._theme = params.theme
    self._jammed = false
    self._not_powered = false
    self:SetAutorepair(params.autorepair)
    self._animate_warning = params.warning
    if params.completion then
        self._animate_warning = true
        self._show_completion_color = true
    end
end

---@param time number
function EHITimerTracker:SetTimeNoAnim(time) -- No fit text function needed, these timers just run down
    self._time = time
    self._text:set_text(self:Format())
    if time <= 10 and self._animate_warning and not self._anim_started then
        self._anim_started = true
        self:AnimateColor()
    end
end

---@param t number
---@param time string
function EHITimerTracker:SetTimeNoFormat(t, time) -- No fit text function needed, these timers just run down
    self._time = t
    self._text:set_text(time)
    if t <= 10 and self._animate_warning and not self._anim_started then
        self._anim_started = true
        self:AnimateColor()
    end
end

---@param completion boolean
function EHITimerTracker:SetAnimation(completion)
    self._animate_warning = true
    if completion then
        self._show_completion_color = true
    end
    if self._time <= 10 and not self._anim_started then
        self._anim_started = true
        self:AnimateColor(true)
    end
end

---@param upgrades table
function EHITimerTracker:SetUpgrades(upgrades)
    if not (self._upgradeable and upgrades) or self._ONE_ICON then
        return
    end
    for upgrade, i in pairs(self._upgrade_definition) do
        local level = upgrades[upgrade] or 0
        if level > 0 then
            local icon = self._icons[i]
            icon:set_color(self:GetUpgradeColor(level))
            icon:set_alpha(1)
        end
    end
end

---@param level number
---@param gui_theme string?
---@return Color
function EHITimerTracker:GetUpgradeColor(level, gui_theme)
    gui_theme = gui_theme or self._theme
    if not gui_theme then
        return TimerGui.upgrade_colors["upgrade_color_" .. level]
    end
    local theme = TimerGui.themes[gui_theme]
    return theme and theme["upgrade_color_" .. level] or TimerGui.upgrade_colors["upgrade_color_" .. level]
end

---@param state boolean
function EHITimerTracker:SetAutorepair(state)
    self:SetIconColor(state and self._autorepair_color or Color.white)
end

---@param jammed boolean
function EHITimerTracker:SetJammed(jammed)
    if self._anim_started then
        self._text:stop()
        self._anim_started = false
    end
    self._jammed = jammed
    self:SetTextColor()
end

---@param powered boolean
function EHITimerTracker:SetPowered(powered)
    if self._anim_started then
        self._text:stop()
        self._anim_started = false
    end
    self._not_powered = not powered
    self:SetTextColor()
end

function EHITimerTracker:SetRunning()
    self:SetJammed(false)
    self:SetPowered(true)
end

---@param color Color? Color is set to `White` or tracker default color if not provided
---@param text Text? Defaults to `self._text` if not provided
function EHITimerTracker:SetTextColor(color, text)
    if color then
        EHITimerTracker.super.SetTextColor(self, color, text)
    elseif self._not_powered then
        self._text:set_color(self._not_powered_color)
    elseif self._jammed then
        self._text:set_color(self._paused_color)
    else
        self._text:set_color(Color.white)
        if self._time <= 10 and self._animate_warning and not self._anim_started then
            self._anim_started = true
            self:AnimateColor(true)
        end
    end
end

function EHITimerTracker:IsTimerRunning()
    return self._started ---@diagnostic disable-line
end

---Workaround for crashes in `TimerGui:update(t, dt)`  
---Class is updated in `HUDManager:add_updator()` as this is a unit
---@class EHITimerGuiTracker : EHITimerTracker
---@field super EHITimerTracker
EHITimerGuiTracker = class(EHITimerTracker)
function EHITimerGuiTracker:post_init(params)
    EHITimerGuiTracker.super.post_init(self, params)
    self._timer_gui = params.timer_gui --[[@as TimerGui]]
    self._callback_id = "ehi_tracker_" .. self._id
    self._update_callback = callback(self, self, "update")
    self:AddTrackerToUpdate()
end

---@param dt number
function EHITimerGuiTracker:update(_, dt)
    local t = self._timer_gui._time_left or self._timer_gui._current_timer or 0
    self._text:set_text(self:FormatTime(t))
    if t <= 10 and self._animate_warning and not self._anim_started then
        self._anim_started = true
        self:AnimateColor()
    end
end

function EHITimerGuiTracker:SetJammed(...)
    EHITimerGuiTracker.super.SetJammed(self, ...)
    self:SetPause()
end

function EHITimerGuiTracker:SetPowered(...)
    EHITimerGuiTracker.super.SetPowered(self, ...)
    self:SetPause()
end

function EHITimerGuiTracker:SetPause()
    if not self._timer_gui then -- For SecurityLockGui, class is using EHIProgressTimerTracker and is not providing `timer_gui`
        return
    elseif self._jammed or self._not_powered then
        self:RemoveTrackerFromUpdate()
    else
        self:AddTrackerToUpdate()
    end
end

function EHITimerGuiTracker:AddTrackerToUpdate()
    managers.hud:add_updator(self._callback_id, self._update_callback)
end

function EHITimerGuiTracker:RemoveTrackerFromUpdate()
    managers.hud:remove_updator(self._callback_id)
end
EHITimerGuiTracker.MissionEnd = EHITimerGuiTracker.RemoveTrackerFromUpdate
EHITimerGuiTracker.pre_destroy = EHITimerGuiTracker.RemoveTrackerFromUpdate

---@class EHITimerGroupTracker : EHITimerTracker
---@field super EHITimerTracker
EHITimerGroupTracker = class(EHITimerTracker)
EHITimerGroupTracker._init_create_text = false
function EHITimerGroupTracker:post_init(params)
    self._group = params.group --[[@as string]]
    self._subgroup = params.subgroup or 1 --[[@as number]]
    self._i_subgroup = params.i_subgroup or 1 --[[@as number]]
    self._timers = {} --[[@as table<string, EHITimerGroupTracker.Timer?>]]
    self._timers_n = 0
    if params.key and params.time then
        self:AddTimer(params.time, params.key, params.warning, params.completion, params.timer_gui)
    end
    EHITimerGroupTracker.super.post_init(self, params)
end

---@param timer EHITimerGroupTracker.Timer
---@param check_progress boolean?
---@param color Color?
---@param text_color Color?
---@param autorepair boolean?
function EHITimerGroupTracker:AnimateColor(timer, check_progress, color, text_color, autorepair)
    local start_t = check_progress and (1 - math.min(math.ehi_round(timer.time, 0.1) - math.floor(timer.time), 0.99)) or 1
    if autorepair then
        timer.anim_autorepair_started = timer.label:animate(self._anim_warning, text_color or self._text_color, color or (timer.animate_completion and self._completion_color or self._warning_color), start_t, self)
    else
        timer.anim_started = timer.label:animate(self._anim_warning, text_color or self._text_color, color or (timer.animate_completion and self._completion_color or self._warning_color), start_t, self)
    end
end

---@param t number
---@param id string Unit Key
---@param warning boolean?
---@param completion boolean?
---@param timer_gui TimerGui
function EHITimerGroupTracker:AddTimer(t, id, warning, completion, timer_gui)
    local label = self:CreateText({
        text = self:FormatTime(t),
        x = self._timers_n * self._default_bg_size,
        w = self._default_bg_size
    })
    self._timers[id] =
    {
        label = label,
        time = t,
        timer_gui = timer_gui,
        not_powered = false,
        animate_warning = warning or completion,
        animate_completion = completion,
        pos = self._timers_n,
        is_running = true
    }
    self._timers_n = self._timers_n + 1
    if self._timers_n >= 2 then
        self:AnimateMovement(self._anim_params.PanelSizeIncrease)
        -- Subtract a tiny bit of the timer so it looks more smooth in the tracker when BG is disabled, jumping from 1:00 to 59 is not smooth at all
        -- This is a visual change and does not affect the calculation
        if not self._BG_START_COLOR then
            if t <= 10 then
                label:set_text(self:FormatTime(t - 0.1))
            else
                label:set_text(self:FormatTime(t - 1))
            end
        end
    end
end

---@param time number
---@param id string Unit Key
function EHITimerGroupTracker:SetTimeNoAnim(time, id) -- No fit text function needed, these timers just run down
    local timer = self._timers[id]
    if timer then
        timer.time = time
        timer.label:set_text(self:FormatTime(time))
        if time <= 10 and timer.animate_warning and not timer.anim_started then
            self:AnimateColor(timer)
        end
    end
end

---@param t number
---@param time string
---@param id string Unit Key
function EHITimerGroupTracker:SetTimeNoFormat(t, time, id) -- No fit text function needed, these timers just run down
    local timer = self._timers[id]
    if timer then
        timer.time = t
        timer.label:set_text(time)
        if t <= 10 and timer.animate_warning and not timer.anim_started then
            self:AnimateColor(timer)
        end
    end
end

---@param id string Unit Key
function EHITimerGroupTracker:StopTimer(id)
    local timer = table.remove_key(self._timers, id)
    if not timer or self._timers_n <= 1 then -- If the amount of timers in this tracker is 1, the manager will delete the tracker
        return
    end
    timer.label:parent():remove(timer.label)
    local pos = timer.pos
    for _, t in pairs(self._timers) do
        if t.pos > pos then
            local new_pos = t.pos - 1
            t.pos = new_pos
            self:AnimateTextPositionLeft(new_pos * self._default_bg_size, t.label)
        end
    end
    if self._timers_n >= 2 then
        self:AnimateMovement(self._anim_params.PanelSizeDecrease)
    end
    self._timers_n = self._timers_n - 1
end

function EHITimerGroupTracker:RedrawPanel()
    for _, timer in pairs(self._timers) do
        self:FitTheText(timer.label)
    end
end

---@param jammed boolean
---@param id string Unit Key
function EHITimerGroupTracker:SetJammed(jammed, id)
    local timer = self._timers[id]
    if timer then
        if timer.anim_started then
            timer.label:stop(timer.anim_started)
            timer.anim_started = nil
        end
        timer.jammed = jammed
        self:SetTextColor(timer)
    end
end

---@param powered boolean
---@param id string Unit Key
function EHITimerGroupTracker:SetPowered(powered, id)
    local timer = self._timers[id]
    if timer then
        if timer.anim_started then
            timer.label:stop(timer.anim_started)
            timer.anim_started = nil
        end
        timer.not_powered = not powered
        self:SetTextColor(timer)
    end
end

---@param id string Unit Key
function EHITimerGroupTracker:SetRunning(id)
    self:SetJammed(false, id)
    self:SetPowered(true, id)
end

---@param timer EHITimerGroupTracker.Timer
function EHITimerGroupTracker:SetTextColor(timer)
    local text = timer.label
    if timer.not_powered then
        text:set_color(self._not_powered_color)
    elseif timer.jammed then
        text:set_color(self._paused_color)
    else
        text:set_color(Color.white)
        if timer.time <= 10 and timer.animate_warning and not timer.anim_started then
            self:AnimateColor(timer, true)
        end
    end
end

---@param state boolean
---@param id string Unit Key
function EHITimerGroupTracker:SetAutorepair(state, id)
    local timer = self._timers[id]
    if timer then
        if timer.jammed then
            if state and not timer.anim_autorepair_started then
                self:AnimateColor(timer, false, self._autorepair_color, self._paused_color, true)
            end
        elseif timer.anim_autorepair_started then
            timer.label:stop(timer.anim_autorepair_started)
            timer.label:set_color(Color.white)
            timer.anim_autorepair_started = nil
        end
    end
end

---@param completion boolean
---@param id string Unit Key
function EHITimerGroupTracker:SetAnimation(completion, id)
    local timer = self._timers[id]
    if timer then
        timer.animate_warning = true
        timer.animate_completion = completion
        if timer.time <= 10 and not timer.anim_started then
            self:AnimateColor(timer, true)
        end
    end
end

function EHITimerGroupTracker:GetGroupData()
    return self._group, self._subgroup, self._i_subgroup
end

---@param id string Unit Key
function EHITimerGroupTracker:IsTimerRunning(id)
    return self._timers[id] ~= nil
end

---Workaround for crashes in `TimerGui:update(t, dt)`
---Class is updated in `HUDManager:add_updator()` as this is a unit
---@class EHITimerGuiGroupTracker : EHITimerGroupTracker
---@field super EHITimerGroupTracker
EHITimerGuiGroupTracker = class(EHITimerGroupTracker)
EHITimerGuiGroupTracker.RemoveTrackerFromUpdate = EHITimerGuiTracker.RemoveTrackerFromUpdate
EHITimerGuiGroupTracker.MissionEnd = EHITimerGuiTracker.MissionEnd
EHITimerGuiGroupTracker.pre_destroy = EHITimerGuiTracker.pre_destroy
function EHITimerGuiGroupTracker:post_init(params)
    EHITimerGuiGroupTracker.super.post_init(self, params)
    self._callback_id = "ehi_" .. self._id
    managers.hud:add_updator(self._callback_id, callback(self, self, "update"))
end

---@param dt number
function EHITimerGuiGroupTracker:update(_, dt)
    for _, timer in pairs(self._timers) do
        if timer.is_running then
            local t = timer.timer_gui._time_left or timer.timer_gui._current_timer or 0
            timer.time = t
            timer.label:set_text(self:FormatTime(t))
            if t <= 10 and timer.animate_warning and not timer.anim_started then
                self:AnimateColor(timer)
            end
        end
    end
end

function EHITimerGuiGroupTracker:SetJammed(jammed, id)
    EHITimerGuiGroupTracker.super.SetJammed(self, jammed, id)
    self:SetPause(id)
end

function EHITimerGuiGroupTracker:SetPowered(powered, id)
    EHITimerGuiGroupTracker.super.SetPowered(self, powered, id)
    self:SetPause(id)
end

---@param id string Unit Key
function EHITimerGuiGroupTracker:SetPause(id)
    local timer = self._timers[id]
    if timer then
        timer.is_running = not (timer.jammed or timer.not_powered)
    end
end

---@class EHIProgressTimerTracker : EHITimerGuiTracker, EHIProgressTracker, EHITimedChanceTracker
---@field super EHITimerGuiTracker
EHIProgressTimerTracker = class(EHITimerGuiTracker)
EHIProgressTimerTracker._progress_bad = EHIProgressTracker._progress_bad
EHIProgressTimerTracker.pre_init = EHIProgressTracker.pre_init
EHIProgressTimerTracker.FormatProgress = EHIProgressTracker.FormatProgress
EHIProgressTimerTracker.IncreaseProgressMax = EHIProgressTracker.IncreaseProgressMax
EHIProgressTimerTracker.DecreaseProgressMax = EHIProgressTracker.DecreaseProgressMax
EHIProgressTimerTracker.SetProgressMax = EHIProgressTracker.SetProgressMax
EHIProgressTimerTracker.IncreaseProgress = EHIProgressTracker.IncreaseProgress
EHIProgressTimerTracker.DecreaseProgress = EHIProgressTracker.DecreaseProgress
EHIProgressTimerTracker.SetProgress = EHIProgressTracker.SetProgress
EHIProgressTimerTracker.SetProgressRemaining = EHIProgressTracker.SetProgressRemaining
EHIProgressTimerTracker.SetCompleted = EHIProgressTracker.SetCompleted
EHIProgressTimerTracker.SetBad = EHIProgressTracker.SetBad
function EHIProgressTimerTracker:post_init(params)
    self._callback_id = "ehi_tracker_" .. self._id
    self._update_callback = callback(self, self, "update")
    self._progress_text = self:CreateText({
        text = self:FormatProgress()
    })
    self._text:set_left(self._progress_text:right())
    if not managers.ehi_sync:IsSyncing() then
        self:SetBad()
    end
end

---@param timer_gui TimerGui
function EHIProgressTimerTracker:SetTimerGui(timer_gui)
    self._timer_gui = timer_gui
end

function EHIProgressTimerTracker:StartTimer(...)
    EHIProgressTimerTracker.super.StartTimer(self, ...)
    if self._progress ~= self._max then
        self:SetTextColor(Color.white, self._progress_text)
    end
end

function EHIProgressTimerTracker:StopTimer()
    EHIProgressTimerTracker.super.StopTimer(self)
    self:SetBad()
end

---@class EHIChanceTimerTracker : EHITimerGuiTracker, EHIChanceTracker
---@field super EHIChanceTracker
EHIChanceTimerTracker = class(EHITimerGuiTracker)
EHIChanceTimerTracker.SetTimerGui = EHIProgressTimerTracker.SetTimerGui
EHIChanceTimerTracker.pre_init = EHIChanceTracker.pre_init
EHIChanceTimerTracker.FormatChance = EHIChanceTracker.FormatChance
EHIChanceTimerTracker.IncreaseChance = EHIChanceTracker.IncreaseChance
EHIChanceTimerTracker.IncreaseChanceIndex = EHIChanceTracker.IncreaseChanceIndex
EHIChanceTimerTracker.DecreaseChance = EHIChanceTracker.DecreaseChance
EHIChanceTimerTracker.SetChance = EHIChanceTracker.SetChance
EHIChanceTimerTracker._anim_chance = EHIChanceTracker._anim_chance
function EHIChanceTimerTracker:post_init(params)
    self._callback_id = "ehi_tracker_" .. self._id
    self._update_callback = callback(self, self, "update")
    self._chance_text = self:CreateText({
        text = self:FormatChance()
    })
    self._text:set_left(self._chance_text:right())
end