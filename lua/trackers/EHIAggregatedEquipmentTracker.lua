local color =
{
    doctor_bag = EHI:GetColorFromOption("equipment", "doctor_bag"),
    ammo_bag = EHI:GetColorFromOption("equipment", "ammo_bag"),
    grenade_crate = EHI:GetColorFromOption("equipment", "grenade_crate"),
    first_aid_kit = EHI:GetColorFromOption("equipment", "first_aid_kit"),
    bodybags_bag = EHI:GetColorFromOption("equipment", "bodybags_bag")
}

---@class EHIAggregatedEquipmentTracker : EHITracker
---@field super EHITracker
EHIAggregatedEquipmentTracker = class(EHITracker)
EHIAggregatedEquipmentTracker._update = false
EHIAggregatedEquipmentTracker._dont_show_placed = { first_aid_kit = true }
EHIAggregatedEquipmentTracker._ids = { "doctor_bag", "ammo_bag", "grenade_crate", "first_aid_kit", "bodybags_bag" }
EHIAggregatedEquipmentTracker._init_create_text = false
function EHIAggregatedEquipmentTracker:pre_init(params)
    self._n_of_deployables = 0
    self._count = {} ---@type table<string, { amount: number, placed: number, format: string }>
    self._deployables = {}
    self._ignore = params.ignore or {}
    self._equipment = {} ---@type table<string, PanelText>
    for _, id in ipairs(self._ids) do
        self._count[id] = { amount = 0, placed = 0, format = params.format[id] or "charges" }
        self._deployables[id] = {}
    end
end

function EHIAggregatedEquipmentTracker:post_init(params)
    self._default_panel_w = self._panel:w()
    self._panel_w = self._default_panel_w
end

do
    local format = EHI:GetOption("equipment_format")
    if format == 1 then -- Uses (Bags placed)
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            local deployable = self._count[id]
            if deployable.format == "percent" then
                return string.format("%g (%d)", self._parent_class.RoundNumber(deployable.amount, 0.1), deployable.placed)
            elseif self._dont_show_placed[id] then
                return tostring(deployable.amount)
            end
            return string.format("%d (%d)", deployable.amount, deployable.placed)
        end
    elseif format == 2 then -- (Bags placed) Uses
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            local deployable = self._count[id]
            if deployable.format == "percent" then
                return string.format("(%d) %g", deployable.placed, self._parent_class.RoundNumber(deployable.amount, 0.1))
            elseif self._dont_show_placed[id] then
                return tostring(deployable.amount)
            end
            return string.format("(%d) %d", deployable.placed, deployable.amount)
        end
    elseif format == 3 then -- (Uses) Bags placed
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            local deployable = self._count[id]
            if deployable.format == "percent" then
                return string.format("(%g) %d", self._parent_class.RoundNumber(deployable.amount, 0.1), deployable.placed)
            elseif self._dont_show_placed[id] then
                return tostring(deployable.amount)
            end
            return string.format("(%d) %d", deployable.amount, deployable.placed)
        end
    elseif format == 4 then -- Bags placed (Uses)
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            local deployable = self._count[id]
            if deployable.format == "percent" then
                return string.format("%d (%g)", deployable.placed, self._parent_class.RoundNumber(deployable.amount, 0.1))
            elseif self._dont_show_placed[id] then
                return tostring(deployable.amount)
            end
            return string.format("%d (%d)", deployable.placed, deployable.amount)
        end
    elseif format == 5 then -- Uses
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            local deployable = self._count[id]
            if deployable.format == "percent" then
                return tostring(self._parent_class.RoundNumber(deployable.amount, 0.01))
            end
            return tostring(deployable.amount)
        end
    else -- Bags placed
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            local deployable = self._count[id]
            if self._dont_show_placed[id] then
                if deployable.format == "percent" then
                    return tostring(self._parent_class.RoundNumber(deployable.amount, 0.01))
                end
                return tostring(deployable.amount)
            end
            return tostring(deployable.placed)
        end
    end
end

---@return number
function EHIAggregatedEquipmentTracker:GetTotalAmount()
    local amount = 0
    for _, deployable in pairs(self._count) do
        amount = amount + deployable.amount
    end
    return amount
end

---@param id string
function EHIAggregatedEquipmentTracker:AddToIgnore(id)
    self._ignore[id] = true
    self._deployables[id] = {}
    self._count[id] = { amount = 0, placed = 0 }
    self:CheckAmount(id)
end

---@param id string
---@param key string
---@param amount number
function EHIAggregatedEquipmentTracker:UpdateAmount(id, key, amount)
    if not key or self._ignore[id] then
        return
    end
    self._deployables[id][key] = amount
    local deployable = self._count[id]
    deployable.amount = 0
    deployable.placed = 0
    for _, value in pairs(self._deployables[id]) do
        if value > 0 then
            deployable.amount = deployable.amount + value
            deployable.placed = deployable.placed + 1
        end
    end
    self:CheckAmount(id)
end

---@param id string
function EHIAggregatedEquipmentTracker:CheckAmount(id)
    if self:GetTotalAmount() <= 0 then
        self:delete()
    else
        self:UpdateText(id)
    end
end

---@param id string
function EHIAggregatedEquipmentTracker:UpdateText(id)
    if self._equipment[id] then
        if self._count[id].amount <= 0 then
            self:RemoveText(id)
        else
            local text = self._equipment[id]
            text:set_text(self:FormatDeployable(id))
            self:FitTheText(text)
        end
        self:AnimateBG()
    elseif not self._ignore[id] then
        if self._count[id].amount > 0 then
            self:AddText(id)
            self:AnimateBG()
        end
    end
end

---@param id string
function EHIAggregatedEquipmentTracker:AddText(id)
    self._n_of_deployables = self._n_of_deployables + 1
    local text = self:CreateText({
        name = id,
        color = color[id]
    })
    self._equipment[id] = text
    text:set_text(self:FormatDeployable(id))
    self:Reorganize(true)
end

---@param id string
function EHIAggregatedEquipmentTracker:RemoveText(id)
    local _text = table.remove_key(self._equipment, id)
    self._bg_box:remove(_text)
    self._n_of_deployables = self._n_of_deployables - 1
    if self._n_of_deployables == 1 then
        local _, text = next(self._equipment) ---@cast text PanelText
        text:set_x(0)
        text:set_w(self._bg_box:w())
        self:FitTheText(text)
    end
    self:Reorganize()
end

function EHIAggregatedEquipmentTracker:RedrawPanel()
    for _, text in ipairs(self._bg_box:children()) do ---@cast text PanelText
        if text.set_text then
            self:FitTheText(text)
        end
    end
end

---@param addition boolean?
function EHIAggregatedEquipmentTracker:AnimateMovement(addition)
    self:AnimatePanelWAndRefresh(self._panel_w)
    self:ChangeTrackerWidth(self._panel_w)
    self:AnimIconsX(addition and self._default_bg_size_half or -self._default_bg_size_half)
    self:AnimateAdjustHintX(addition and self._default_bg_size_half or -self._default_bg_size_half)
end

function EHIAggregatedEquipmentTracker:AlignTextOnHalfPos()
    local pos = 0
    for _, id in ipairs(self._ids) do
        local text = self._bg_box:child(id) --[[@as PanelText?]]
        if text then
            text:set_w(self._default_bg_size_half)
            text:set_x(self._default_bg_size_half * pos)
            self:FitTheText(text)
            pos = pos + 1
        end
    end
end

---@param addition boolean?
function EHIAggregatedEquipmentTracker:Reorganize(addition)
    if self._n_of_deployables == 1 then
        return
    elseif self._n_of_deployables == 2 then
        self:AlignTextOnHalfPos()
        if not addition then
            self._panel_w = self._default_panel_w
            self._bg_box:set_w(self._default_bg_size)
            self:AnimateMovement()
        end
    elseif addition then
        self:AlignTextOnHalfPos()
        self._panel_w = self._panel_w + self._default_bg_size_half
        self._bg_box:set_w(self._bg_box:w() + self._default_bg_size_half)
        self:AnimateMovement(true)
    else
        self:AlignTextOnHalfPos()
        self._panel_w = self._panel_w - self._default_bg_size_half
        self._bg_box:set_w(self._bg_box:w() - self._default_bg_size_half)
        self:AnimateMovement()
    end
end