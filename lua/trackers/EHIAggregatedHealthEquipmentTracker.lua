---@class EHIAggregatedHealthEquipmentTracker : EHIAggregatedEquipmentTracker
---@field super EHIAggregatedEquipmentTracker
EHIAggregatedHealthEquipmentTracker = class(EHIAggregatedEquipmentTracker)
EHIAggregatedHealthEquipmentTracker._ids = { "doctor_bag", "first_aid_kit" }
EHIAggregatedHealthEquipmentTracker._forced_icons = { { icon = "doctor_bag", visible = false }, { icon = "first_aid_kit", visible = false } }
EHIAggregatedHealthEquipmentTracker._init_create_text = true
function EHIAggregatedHealthEquipmentTracker:post_init(...)
    EHIAggregatedHealthEquipmentTracker.super.post_init(self, ...)
    self._active_icons = 0
    if self._ICON_LEFT_SIDE_START then
        if self._VERTICAL_ALIGNMENT then
            self._bg_box:move(-self._icon_gap_size_scaled, 0)
        else
            self._bg_box:set_x(0)
        end
    end
end

function EHIAggregatedHealthEquipmentTracker:Format()
    local s = ""
    for _, id in ipairs(self._ids) do
        if self._count[id].amount > 0 then
            if s ~= "" then
                s = s .. " | "
            end
            s = s .. self:FormatDeployable(id)
        end
    end
    return s
end

---@param i number
---@param icons_visible number
---@param icon_i number
function EHIAggregatedHealthEquipmentTracker:GetIconPosition(i, icons_visible, icon_i)
    if self._ICON_LEFT_SIDE_START and (self._VERTICAL_ANIM_W_LEFT or self._HORIZONTAL_ALIGNMENT) then
        if icons_visible == 2 and icon_i == 1 then -- Hardcoded positioning so it will look the same regardless of options
            return 0
        end
        return self._bg_box:x() - self._icon_gap_size_scaled
    else
        local start = self._ICON_LEFT_SIDE_START and 0 or self._bg_box:w()
        local gap = self._ICON_LEFT_SIDE_START and 0 or self._gap_scaled
        start = start + (self._icon_size_scaled * i)
        gap = gap + (self._gap_scaled * i)
        return start + gap
    end
end

function EHIAggregatedHealthEquipmentTracker:UpdateIconsVisibility()
    local visibility = {}
    for _, icon in ipairs(self._icons) do
        icon:set_visible(false)
    end
    local visible_icons = 0
    for i, id in ipairs(self._ids) do
        if self._count[id].amount > 0 then
            visibility[i] = true
            visible_icons = visible_icons + 1
        end
    end
    local icons = 0
    for i, _ in pairs(visibility) do
        local icon = self._icons[i]
        if icon then
            icon:set_visible(true)
            icon:set_x(self:GetIconPosition(icons, visible_icons, i))
            icons = icons + 1
        end
    end
    if self._active_icons ~= icons then
        self:AnimateMovement(icons > self._active_icons and self._anim_params.IconCreated or self._anim_params.IconDeleted)
        self._active_icons = icons
    end
end

function EHIAggregatedHealthEquipmentTracker:UpdateText(id)
    self:SetAndFitTheText()
    self:UpdateIconsVisibility()
    self:AnimateBG()
end

function EHIAggregatedHealthEquipmentTracker:_anim_icons_x(x_offset)
end

function EHIAggregatedHealthEquipmentTracker:PositionHint(x, y)
    if self._ICON_LEFT_SIDE_START and self._VERTICAL_ANIM_W_LEFT and not self._ONE_ICON then
        x = x + (self._icon_gap_size_scaled * (self._hint_positioned and 1 or 2))
        self._hint_positioned = true
    end
    EHIAggregatedHealthEquipmentTracker.super.PositionHint(self, x, y)
end