---@class EHIPermanentBuffTracker : EHIBuffTracker
---@field super EHIBuffTracker
EHIPermanentBuffTracker = class(EHIBuffTracker)
function EHIPermanentBuffTracker:post_init(params)
    self._text:set_text("0")
    self._skill_check = params.skill_check
end

function EHIPermanentBuffTracker:Activate(...)
    EHIPermanentBuffTracker.super.Activate(self, ...)
    self._running = true
end

function EHIPermanentBuffTracker:Extend(...)
    EHIPermanentBuffTracker.super.Extend(self, ...)
    if not self._running then
        self._parent_class:_add_buff_to_update(self)
        self._running = true
    end
end

function EHIPermanentBuffTracker:ActivateSoft()
    self._visible = true
end

function EHIPermanentBuffTracker:Deactivate()
    self._parent_class:_remove_buff_from_update(self._id)
    self._running = false
end

function EHIPermanentBuffTracker:DeactivateAndReset()
    self:Deactivate()
    self._text:set_text("0")
    self._progress_bar.red = 0
    self._progress:set_color(self._progress_bar)
end

function EHIPermanentBuffTracker:DeactivateSoft()
    self._visible = false
end

function EHIPermanentBuffTracker:AddVisibleBuff()
end

function EHIPermanentBuffTracker:RemoveVisibleBuff()
end

function EHIPermanentBuffTracker:PreUpdateCheck()
    if self._skill_check then
        return managers.player:has_category_upgrade(self._skill_check.category, self._skill_check.upgrade)
    end
    return false
end

function EHIPermanentBuffTracker:PreUpdate()
    self._skill_check = nil
    self._parent_class:AddBuffNoUpdate(self._id)
end

function EHIPermanentBuffTracker:delete()
    if self._pos then
        EHIPermanentBuffTracker.super.RemoveVisibleBuff(self)
        self._pos = nil
    end
    EHIPermanentBuffTracker.super.delete(self)
end