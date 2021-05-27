EHIAggregatedEquipmentTracker = EHIAggregatedEquipmentTracker or class(EHITracker)
EHIAggregatedEquipmentTracker._update = false
function EHIAggregatedEquipmentTracker:init(panel, params)
    self._dont_show_placed = {}
    self._amount = {}
    self._placed = {}
    self._deployables = {}
    self._pos = params.ids
    for _, id in pairs(params.ids) do
        self._amount[id] = 0
        self._placed[id] = 0
        self._dont_show_placed[id] = params.dont_show_placed[id]
        self._deployables[id] = {}
    end
    EHIAggregatedEquipmentTracker.super.init(self, panel, params)
end

function EHIAggregatedEquipmentTracker:Format()
    local s = ""
    for _, id in pairs(self._pos) do
        if self._amount[id] > 0 then
            if s ~= "" then
                s = s .. " | "
            end
            s = s .. self:FormatDeployable(id)
        end
    end
    return s
end

--[[function EHIAggregatedEquipmentTracker:FormatDeployable(id)
    if self._dont_show_placed[id] then
        return self._amount[id]
    else
        return self._amount[id] .. " (" .. self._placed[id] .. ")"
    end
end]]
do
    local format = EHI:GetOption("equipment_format")
    if format == 1 then -- Uses (Bags placed)
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            if self._dont_show_placed[id] then
                return self._amount[id]
            else
                return self._amount[id] .. " (" .. self._placed[id] .. ")"
            end
        end
    elseif format == 2 then -- (Bags placed) Uses
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            if self._dont_show_placed[id] then
                return self._amount[id]
            else
                return "(" .. self._placed[id] .. ") " .. self._amount[id]
            end
        end
    elseif format == 3 then -- (Uses) Bags placed
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            if self._dont_show_placed[id] then
                return self._amount[id]
            else
                return "(" .. self._amount[id] .. ") " .. self._placed[id]
            end
        end
    elseif format == 4 then -- Bags placed (Uses)
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            if self._dont_show_placed[id] then
                return self._amount[id]
            else
                return self._placed[id] .. " (" .. self._amount[id] .. ")"
            end
        end
    elseif format == 5 then -- Uses
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            return tostring(self._amount[id])
        end
    else -- Bags placed
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            if self._dont_show_placed[id] then
                return tostring(self._amount[id])
            else
                return tostring(self._placed[id])
            end
        end
    end
end

function EHIAggregatedEquipmentTracker:GetTotalAmount()
    local amount = 0
    for _, count in pairs(self._amount) do
        amount = amount + count
    end
    return amount
end

function EHIAggregatedEquipmentTracker:GetIconPosition(i)
    local start = self._time_bg_box:w()
    local gap = 5 * self._scale
    start = start + ((32 * self._scale) * i)
    gap = gap + ((5 * self._scale) * i)
    return start + gap
end

function EHIAggregatedEquipmentTracker:UpdateIconsVisibility()
    local visibility = {}
    for i = 1, #self._pos, 1 do
        local s_i = tostring(i)
        local icon = self["_icon" .. s_i]
        if icon then
            icon:set_visible(false)
        end
    end
    for i, id in ipairs(self._pos) do
        if self._amount[id] > 0 then
            visibility[#visibility + 1] = i
        end
    end
    local move_x = 1
    for _, i in pairs(visibility) do
        local s_i = tostring(i)
        local icon = self["_icon" .. s_i]
        if icon then
            icon:set_visible(true)
            icon:set_x(self:GetIconPosition(move_x - 1))
        end
        move_x = move_x + 1
    end
end

function EHIAggregatedEquipmentTracker:UpdateAmount(id, unit, key, amount)
    if not key then
        EHI:DebugEquipment(self._id, unit, key, amount)
        return
    end
    self._deployables[id][key] = amount
    self._amount[id] = 0
    self._placed[id] = 0
    for _, value in pairs(self._deployables[id]) do
        self._amount[id] = self._amount[id] + value
        if value ~= 0 then
            self._placed[id] = self._placed[id] + 1
        end
    end
    if self:GetTotalAmount() <= 0 then
        self:delete()
    else
        self._text:set_text(self:Format())
        self:UpdateIconsVisibility()
        self:FitTheText()
        self:AnimateBG()
    end
end