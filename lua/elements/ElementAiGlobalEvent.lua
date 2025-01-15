local EHI = EHI
if EHI:CheckLoadHook("ElementAiGlobalEvent") then
    return
end

local original =
{
    client_on_executed = ElementAiGlobalEvent.client_on_executed,
    on_executed = ElementAiGlobalEvent.on_executed
}

local mode = "besiege"
---@param wave_mode string
---@param element_id number
local function NotifyListeners(wave_mode, element_id)
    if wave_mode and wave_mode ~= mode then
        if wave_mode ~= "besiege" and wave_mode ~= "hunt" then
            return
        end
        mode = wave_mode
        managers.ehi_assault:CallAssaultTypeChangedCallback(wave_mode == "besiege" and "normal" or "endless", element_id)
    end
end

function ElementAiGlobalEvent:client_on_executed(...)
    original.client_on_executed(self, ...)
    NotifyListeners(self._wave_modes[self._values.wave_mode], self._id)
end

function ElementAiGlobalEvent:on_executed(...)
    if not self._values.enabled then
        return
    end
    NotifyListeners(self._wave_modes[self._values.wave_mode], self._id)
    original.on_executed(self, ...)
end