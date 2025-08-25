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
EHIAggregatedEquipmentTracker._needs_update = false
EHIAggregatedEquipmentTracker._dont_show_placed = { first_aid_kit = true }
EHIAggregatedEquipmentTracker._ids = { "doctor_bag", "ammo_bag", "grenade_crate", "first_aid_kit", "bodybags_bag" }
EHIAggregatedEquipmentTracker._init_create_text = false
function EHIAggregatedEquipmentTracker:pre_init(params)
    if params then
        params.hide_on_delete = true
    end
    self._n_of_deployables = 0
    self._count = {} ---@type table<string, { amount: number, placed: number, format: string }>
    self._deployables = {}
    self._ignore = self._ignore or params.ignore or {}
    self._equipment = {} ---@type table<string, Text?>
    self._format = self._format or params.format or {}
    for _, id in ipairs(self._ids) do
        self._count[id] = { amount = 0, placed = 0, format = self._format[id] or "charges" }
        self._deployables[id] = {}
    end
end

do
    local format = EHI:GetOption("equipment_format")
    if format == 1 then -- Uses (Bags placed)
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            local deployable = self._count[id]
            if deployable.format == "percent" then
                return string.format("%g (%d)", math.ehi_round(deployable.amount, 0.1), deployable.placed)
            elseif self._dont_show_placed[id] then
                return tostring(deployable.amount)
            end
            return string.format("%d (%d)", deployable.amount, deployable.placed)
        end
    elseif format == 2 then -- (Bags placed) Uses
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            local deployable = self._count[id]
            if deployable.format == "percent" then
                return string.format("(%d) %g", deployable.placed, math.ehi_round(deployable.amount, 0.1))
            elseif self._dont_show_placed[id] then
                return tostring(deployable.amount)
            end
            return string.format("(%d) %d", deployable.placed, deployable.amount)
        end
    elseif format == 3 then -- (Uses) Bags placed
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            local deployable = self._count[id]
            if deployable.format == "percent" then
                return string.format("(%g) %d", math.ehi_round(deployable.amount, 0.1), deployable.placed)
            elseif self._dont_show_placed[id] then
                return tostring(deployable.amount)
            end
            return string.format("(%d) %d", deployable.amount, deployable.placed)
        end
    elseif format == 4 then -- Bags placed (Uses)
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            local deployable = self._count[id]
            if deployable.format == "percent" then
                return string.format("%d (%g)", deployable.placed, math.ehi_round(deployable.amount, 0.1))
            elseif self._dont_show_placed[id] then
                return tostring(deployable.amount)
            end
            return string.format("%d (%d)", deployable.placed, deployable.amount)
        end
    elseif format == 5 then -- Uses
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            local deployable = self._count[id]
            if deployable.format == "percent" then
                return tostring(math.ehi_round(deployable.amount, 0.01))
            end
            return tostring(deployable.amount)
        end
    else -- Bags placed
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            local deployable = self._count[id]
            if self._dont_show_placed[id] then
                if deployable.format == "percent" then
                    return tostring(math.ehi_round(deployable.amount, 0.01))
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
    if not self._deployables then -- Do not do anything if the tracker is hidden waiting (the tables are already clear) to be restored once a valid deployable is placed
        return
    end
    self._deployables[id] = {}
    self._count[id] = { amount = 0, placed = 0 }
    self:CheckAmount(id)
end

---@param key string
---@param amount number
---@param id string
function EHIAggregatedEquipmentTracker:UpdateAmount(key, amount, id)
    if not key or self._ignore[id] then
        return
    elseif self._restore_after_cleanup then
        self._restore_after_cleanup = nil
        self._parent_class:RunTracker(self._id)
        self:pre_init()
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
            local text = self._equipment[id] ---@cast text -?
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
        color = color[id]
    })
    self._equipment[id] = text
    text:set_text(self:FormatDeployable(id))
    self:Reorganize(true)
end

---@param id string
function EHIAggregatedEquipmentTracker:RemoveText(id)
    local _text = table.remove_key(self._equipment, id) ---@cast _text -?
    self._bg_box:remove(_text)
    self._n_of_deployables = self._n_of_deployables - 1
    if self._n_of_deployables == 1 then
        local _, text = next(self._equipment) ---@cast text -?
        text:set_x(0)
        text:set_w(self._bg_box:w())
        self:FitTheText(text)
    end
    self:Reorganize()
end

function EHIAggregatedEquipmentTracker:RedrawPanel()
    for _, text in ipairs(self._bg_box:children()) do ---@cast text Text
        if text.set_text then
            self:FitTheText(text)
        end
    end
end

function EHIAggregatedEquipmentTracker:AlignTextOnHalfPos()
    local pos = 0
    for _, id in ipairs(self._ids) do
        local text = self._equipment[id]
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
            self:AnimateMovement(self._anim_params.PanelSizeDecreaseHalf)
        end
    elseif addition then
        self:AlignTextOnHalfPos()
        self:AnimateMovement(self._anim_params.PanelSizeIncreaseHalf)
    else
        self:AlignTextOnHalfPos()
        self:AnimateMovement(self._anim_params.PanelSizeDecreaseHalf)
    end
end

function EHIAggregatedEquipmentTracker:CleanupOnHide()
    if self._restore_after_cleanup then -- No need to clean up again if the tracker is pending restoration; will also crash the game if cleaning is triggered while the tracker is cleaned and waiting to be activated again
        return
    end
    local _, last_text = next(self._equipment)
    if alive(self._bg_box) and alive(last_text) then
        self._bg_box:remove(last_text) ---@diagnostic disable-line
    end
    self._equipment = nil
    self._count = nil
    self._deployables = nil
    self._restore_after_cleanup = true
end