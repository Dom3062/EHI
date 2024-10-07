---@class EHIAggregatedHealthEquipmentTracker : EHIAggregatedEquipmentTracker
---@field _icon2 PanelBitmap?
---@field super EHIAggregatedEquipmentTracker
EHIAggregatedHealthEquipmentTracker = class(EHIAggregatedEquipmentTracker)
EHIAggregatedHealthEquipmentTracker._ids = { "doctor_bag", "first_aid_kit" }
EHIAggregatedHealthEquipmentTracker._forced_icons = { { icon = "doctor_bag", visible = false }, { icon = "first_aid_kit", visible = false } }
EHIAggregatedHealthEquipmentTracker._init_create_text = true
function EHIAggregatedHealthEquipmentTracker:pre_init(...)
    EHIAggregatedHealthEquipmentTracker.super.pre_init(self, ...)
    self._active_icons = 1
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
function EHIAggregatedHealthEquipmentTracker:GetIconPosition(i)
    local start = self._ICON_LEFT_SIDE_START and 0 or self._bg_box:w()
    local gap = self._ICON_LEFT_SIDE_START and 0 or self._gap_scaled
    start = start + (self._icon_size_scaled * i)
    gap = gap + (self._gap_scaled * i)
    return start + gap
end

function EHIAggregatedHealthEquipmentTracker:UpdateIconsVisibility()
    local visibility = {}
    for i = 1, 2, 1 do
        local icon = self["_icon" .. tostring(i)]
        if icon then
            icon:set_visible(false)
        end
    end
    for i, id in ipairs(self._ids) do
        if self._count[id].amount > 0 then
            visibility[i] = true
        end
    end
    local icons = 0
    for i, _ in pairs(visibility) do
        local icon = self["_icon" .. tostring(i)]
        if icon then
            icon:set_visible(true)
            icon:set_x(self:GetIconPosition(icons))
            icons = icons + 1
        end
    end
    if self._active_icons ~= icons then
        local icon_size = (self._icon_gap_size_scaled * icons)
        if self._hint_positioned then
            self:AnimateAdjustHintX(self._active_icons < icons and self._icon_gap_size_scaled or -self._icon_gap_size_scaled, true)
        end
        self:ChangeTrackerWidth(self._bg_box:w() + icon_size, true)
        self._active_icons = icons
        if self._ICON_LEFT_SIDE_START then
            self._bg_box:set_x(icon_size)
        end
    end
end

function EHIAggregatedHealthEquipmentTracker:UpdateText(id)
    self:SetAndFitTheText()
    self:UpdateIconsVisibility()
    self:AnimateBG()
end

function EHIAggregatedHealthEquipmentTracker:HintPositioned()
    self._hint_positioned = true
    if self._icon2 then
        if self._VERTICAL_ANIM_W_LEFT then
            if self._ICON_LEFT_SIDE_START then
                self:AdjustHintX(self._icon_gap_size_scaled)
            end
        else
            self:AdjustHintX(-self._icon_gap_size_scaled)
        end
    end
end