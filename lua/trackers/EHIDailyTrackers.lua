local EHI = EHI

---@generic T: table
---@param super T? A base achievement class
---@return T
function ehi_daily_class(super)
    local klass = class(super)
    klass._popup_type = "daily"
    klass._forced_icon_color = EHIDailyTracker._forced_icon_color
    klass._show_started = EHIDailyTracker._show_started
    klass._show_failed = EHIDailyTracker._show_failed
    klass._show_desc = EHIDailyTracker._show_desc
    klass.PrepareHint = EHIDailyTracker.PrepareHint
    return klass
end

---@class EHIDailyTracker : EHIAchievementTracker
---@field super EHIAchievementTracker
EHIDailyTracker = class(EHIAchievementTracker)
EHIDailyTracker._popup_type = "daily"
EHIDailyTracker._forced_icon_color = { EHI:GetColorFromOption("unlockables", "sidejob") }
EHIDailyTracker._show_started = EHI:GetUnlockableOption("show_daily_started_popup")
EHIDailyTracker._show_failed = EHI:GetUnlockableOption("show_daily_failed_popup")
EHIDailyTracker._show_desc = EHI:GetUnlockableOption("show_daily_description")
---@param params EHITracker.params
function EHIDailyTracker:post_init(params)
    self._daily_job = params.daily_job
    EHIDailyTracker.super.post_init(self, params)
end

---@param params EHITracker.params
function EHIDailyTracker:PrepareHint(params)
    local id = self._id or params.id
    params.hint = params.daily_job and ("menu_challenge_" .. id) or id
    self._hint_vanilla_localization = true
end

---@class EHIDailyProgressTracker : EHIAchievementProgressTracker
---@field super EHIAchievementProgressTracker
EHIDailyProgressTracker = ehi_daily_class(EHIAchievementProgressTracker)
---@param panel Panel
---@param params EHITracker.params
function EHIDailyProgressTracker:init(panel, params, ...)
    self._daily_job = params.daily_job
    EHIDailyProgressTracker.super.init(self, panel, params, ...)
end