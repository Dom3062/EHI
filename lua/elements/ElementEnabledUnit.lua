local EHI = EHI
if EHI:CheckLoadHook("EHIEnabledUnit") then
    return
end
local DisabledUnits = EHI._cache.DisabledUnits

-- ElementEnableUnit is hooked after ElementDisableUnit
Hooks:PostHook(ElementDisableUnit, "on_executed", "EHI_ElementDisableUnit_on_executed", function(self, ...)
    if not self._values.enabled then
        return
    end
    for _, unit in ipairs(self._units) do
        if alive(unit) then
            DisabledUnits[unit:unit_data().unit_id] = true
        end
    end
end)

Hooks:PostHook(ElementEnableUnit, "on_executed", "EHI_ElementEnableUnit_on_executed", function(self, ...)
    if not self._values.enabled then
        return
    end
    for _, unit in ipairs(self._units) do
        if alive(unit) then
            DisabledUnits[unit:unit_data().unit_id] = nil
        end
    end
end)