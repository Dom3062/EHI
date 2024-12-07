if EHI:CheckLoadHook("CarryData") or not EHI:GetOption("show_colored_bag_contour") then
    return
end

---@class CarryData
---@field carry_id fun(self: self): string
---@field _carry_id string
---@field _unit UnitCarry

local original =
{
    set_carry_id = CarryData.set_carry_id,
    load = CarryData.load
}

function CarryData:set_carry_id(...)
    original.set_carry_id(self, ...)
    self:SetCustomContour()
end

function CarryData:SetCustomContour()
    if self._carry_id and self._carry_id ~= "vehicle_falcogini" and self._unit:interaction() then
        local tweak = tweak_data.carry[self._carry_id] or {}
        self._unit:interaction():set_contour(tweak.type or "medium", nil, true)
    end
end

function CarryData:load(...)
    original.load(self, ...)
    self:SetCustomContour()
end