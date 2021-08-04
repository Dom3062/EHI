EHIGasTracker = EHIGasTracker or class(EHIProgressTracker)
function EHIGasTracker:init(panel, params)
    params.max = params.max or 0
    params.icons = { "pd2_fire" }
    EHIGasTracker.super.init(self, panel, params)
end

function EHIGasTracker:Format()
    if self._max == 0 then
        return self._progress .. "/?"
    end
    return EHIGasTracker.super.Format(self)
end