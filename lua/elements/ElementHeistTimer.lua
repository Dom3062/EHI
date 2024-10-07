local EHI = EHI
if EHI:CheckLoadHook("ElementHeistTimer") then
    return
end
local original = ElementHeistTimer.init
function ElementHeistTimer:init(...)
    original(self, ...)
    EHI.HeistTimerIsInverted = true
end