---@class EHIPermanentForceUpdateParentBuffTracker : EHIPermanentBuffTracker
---@field super EHIPermanentBuffTracker
EHIPermanentForceUpdateParentBuffTracker = class(EHIPermanentBuffTracker)
function EHIPermanentForceUpdateParentBuffTracker:post_init(params)
    EHIPermanentForceUpdateParentBuffTracker.super.post_init(self, params)
    self._parent_buff = params.parent_buff
end

function EHIPermanentForceUpdateParentBuffTracker:Activate(...)
    EHIPermanentForceUpdateParentBuffTracker.super.Activate(self, ...)
    self._parent_class:CallFunction(self._parent_buff, "ForceUpdate")
end

function EHIPermanentForceUpdateParentBuffTracker:Deactivate()
    EHIPermanentForceUpdateParentBuffTracker.super.Deactivate(self)
    self._parent_class:CallFunction(self._parent_buff, "ForceUpdate")
end