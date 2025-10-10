---@generic T: table
---@param super T? A base achievement class
---@return T
function _G.ehi_sidejob_class(super)
    local klass = class(super)
    klass._hint_vanilla_localization = true
    klass._forced_icon_color = EHISideJobTracker._forced_icon_color
    klass._show_started = EHISideJobTracker._show_started
    klass._show_failed = EHISideJobTracker._show_failed
    klass._show_desc = EHISideJobTracker._show_desc
    klass.PrepareHint = EHISideJobTracker.PrepareHint
    klass.ShowStartedPopup = EHISideJobTracker.ShowStartedPopup
    klass.ShowFailedPopup = EHISideJobTracker.ShowFailedPopup
    klass.ShowUnlockableDescription = EHISideJobTracker.ShowUnlockableDescription
    klass._ShowStartedPopup = EHISideJobTracker._ShowStartedPopup
    klass._ShowFailedPopup = EHISideJobTracker._ShowFailedPopup
    klass._ShowUnlockableDescription = EHISideJobTracker._ShowUnlockableDescription
    return klass
end

---@class EHISideJobTracker : EHIUnlockableTracker
---@field super EHIUnlockableTracker
EHISideJobTracker = class(EHIUnlockableTracker)
EHISideJobTracker._hint_vanilla_localization = true
EHISideJobTracker._forced_icon_color = { EHI:GetColorFromOption("unlockables", "sidejob") }
EHISideJobTracker._show_started = EHI:GetUnlockableOption("show_daily_started_popup")
EHISideJobTracker._show_failed = EHI:GetUnlockableOption("show_daily_failed_popup")
EHISideJobTracker._show_desc = EHI:GetUnlockableOption("show_daily_description")
function EHISideJobTracker:post_init(params)
    self._daily_job = params.daily_job
    EHISideJobTracker.super.post_init(self, params)
end

function EHISideJobTracker:PrepareHint(params)
    local id = self._id or params.id
    params.hint = params.desc or (params.daily_job and ("menu_challenge_" .. id) or id)
    self._desc = params.desc
end

function EHISideJobTracker:_ShowStartedPopup()
    managers.hud:ShowSideJobStartedPopup(self._id, self._daily_job, self._desc)
end

function EHISideJobTracker:_ShowFailedPopup()
    managers.hud:ShowSideJobFailedPopup(self._id, self._daily_job, self._desc)
end

function EHISideJobTracker:_ShowUnlockableDescription()
    managers.hud:ShowSideJobDescription(self._id, self._daily_job)
end

---@class EHISideJobProgressTracker : EHIUnlockableProgressTracker
---@field super EHIUnlockableProgressTracker
EHISideJobProgressTracker = ehi_sidejob_class(EHIUnlockableProgressTracker)
function EHISideJobProgressTracker:pre_init(params)
    self._daily_job = params.daily_job
    EHISideJobProgressTracker.super.pre_init(self, params)
end