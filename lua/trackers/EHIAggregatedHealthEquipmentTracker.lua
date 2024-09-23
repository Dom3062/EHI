---@param o PanelBaseObject
---@param target_x number
local function left(o, target_x)
    local t, total = 0, 0.18
    local from_x = o:x()
    while t < total do
        t = t + coroutine.yield()
        o:set_x(math.lerp(from_x, target_x, t / total))
    end
    o:set_x(target_x)
end

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
    local icon_size = (self._icon_gap_size_scaled * icons)
    if self._hint_positioned then
        self:AnimateRepositionHintX(icons)
    end
    self:ChangeTrackerWidth(self._bg_box:w() + icon_size, self._active_icons ~= icons)
    self._active_icons = icons
    if self._ICON_LEFT_SIDE_START then
        self._bg_box:set_x(icon_size)
    end
end

---@param id string
function EHIAggregatedHealthEquipmentTracker:UpdateText(id)
    self:SetAndFitTheText()
    self:UpdateIconsVisibility()
    self:AnimateBG()
end

function EHIAggregatedHealthEquipmentTracker:PositionHint(...)
    EHIAggregatedHealthEquipmentTracker.super.PositionHint(self, ...)
    self._hint_positioned = true
    if self._icon2 then
        self:AdjustHintX(-self._icon_gap_size_scaled)
    end
end

function EHIAggregatedHealthEquipmentTracker:AnimateRepositionHintX(n_of_icons)
    if not self._hint or self._active_icons == n_of_icons then
        return
    end
    if self._anim_hint_x then
        self._hint:stop(self._anim_hint_x)
    end
    local x = self._hint_pos.x + (self._active_icons < n_of_icons and (self._icon_gap_size_scaled * (n_of_icons - self._active_icons)) or -(self._icon_gap_size_scaled * (self._active_icons - n_of_icons)))
    self._anim_hint_x = self._hint:animate(left, x)
    self._hint_pos.x = x
end