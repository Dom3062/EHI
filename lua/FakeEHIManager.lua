local EHI = EHI
local panel_size_original = 32
local panel_offset_original = 6
local panel_size = panel_size_original
local panel_offset = panel_offset_original
FakeEHIManager = FakeEHIManager or class()
function FakeEHIManager:init(panel)
    self._hud_panel = panel:panel({
        name = "fake_ehi_panel",
        layer = 0,
        alpha = 1
    })
    local x, y = managers.gui_data:safe_to_full(EHI:GetOption("x_offset"), EHI:GetOption("y_offset"))
    self._x = x
    self._y = y
    if _G.IS_VR then
        self._scale = EHI:GetOption("vr_scale")
    else
        self._scale = EHI:GetOption("scale")
    end
    self._text_scale = EHI:GetOption("text_scale")
    self._bg_visibility = EHI:GetOption("show_tracker_bg")
    self._icons_visibility = EHI:GetOption("show_one_icon")
    self._tracker_alignment = EHI:GetOption("tracker_alignment")
    panel_size = panel_size_original * self._scale
    panel_offset = panel_offset_original * self._scale
    self:AddFakeTrackers()
end

function FakeEHIManager:AddFakeTrackers()
    self._n_of_trackers = 0
    self._fake_trackers = {}
    self:AddFirstFakeTracker({ id = "Default", time = (math.random() * (9.99 - 0.5) + 0.5), icons = { "faster" } } )
    self:AddFakeTracker({ id = "Default", time = math.random(60, 180), icons = { EHI.Icons.Car, EHI.Icons.Escape } } )
    if EHI:GetOption("show_achievement") then
        self:AddFakeTracker({ id = "show_achievement", time = math.random(60, 180), icons = { "milestone_trophy" } } )
    end
    if EHI:GetOption("show_gained_xp") then
        self:AddFakeTracker({ id = "show_gained_xp", icons = { "xp" }, class = "FakeEHIXPTracker" } )
    end
    if EHI:GetOption("show_trade_delay") then
        self:AddFakeTracker({ id = "show_trade_delay", time = 5 + (math.random(1, 4) * 30), icons = { { icon = "mugshot_in_custody", color = tweak_data.chat_colors[1] or tweak_data.chat_colors[#tweak_data.chat_colors] or Color.white, visible = true } } } )
    end
    if EHI:GetOption("show_timers") then
        self:AddFakeTracker({ id = "show_timers", time = math.random(60, 240), icons = { "pd2_drill", "faster", "silent", "restarter" } } )
        self:AddFakeTracker({ id = "show_timers", time = math.random(60, 120), icons = { "wp_hack" } } )
    end
    if EHI:GetOption("show_zipline_timer") then
        local time = math.random() * (8 - 1) + 1
        self:AddFakeTracker({ id = "show_zipline_timer", time = time, icons = { "equipment_winch_hook", "wp_bag", "pd2_goto" } } )
        self:AddFakeTracker({ id = "show_zipline_timer", time = time * 2, icons = { "equipment_winch_hook", "restarter" } } )
    end
    if EHI:GetOption("show_gage_tracker") then
        self:AddFakeTracker({ id = "show_gage_tracker", icons = { "gage" }, class = "FakeEHIProgressTracker" } )
    end
    if EHI:GetOption("show_captain_damage_reduction") then
        self:AddFakeTracker({ id = "show_captain_damage_reduction", icons = { "buff_shield" }, class = "FakeEHIChanceTracker" } )
    end
    if EHI:GetOption("show_equipment_tracker") then
        self:AddFakeTracker({ id = "show_equipment_tracker", show_placed = true, icons = { "doctor_bag" }, class = "FakeEHIEquipmentTracker" } )
    end
    if EHI:GetOption("show_minion_tracker") then
        self:AddFakeTracker({ id = "show_minion_tracker", min = 1, charges = 4, icons = { "minion" }, class = "FakeEHIEquipmentTracker" } )
    end
    if EHI:GetOption("show_difficulty_tracker") then
        self:AddFakeTracker({ id = "show_difficulty_tracker", icons = { "enemy" }, class = "FakeEHIChanceTracker" } )
    end
    if EHI:GetOption("show_drama_tracker") then
        self:AddFakeTracker({ id = "show_drama_tracker", chance = math.random(100), icons = { "C_Escape_H_Street_Bullet" }, class = "FakeEHIChanceTracker" })
    end
    if EHI:GetOption("show_pager_tracker") then
        self:AddFakeTracker({ id = "show_pager_tracker", progress = 3, max = 4, icons = { "pagers_used" }, class = "FakeEHIProgressTracker" } )
    end
    if EHI:GetOption("show_pager_callback") then
        self:AddFakeTracker({ id = "show_pager_callback", time = math.random() * (12 - 0.5) + 0.5, icons = { "pager_icon" } })
    end
    if EHI:GetOption("show_enemy_count_tracker") then
        self:AddFakeTracker({ id = "show_enemy_count_tracker", count = math.random(20, 80), icons = { "enemy" }, class = "FakeEHICountTracker" } )
    end
    if EHI:GetOption("show_laser_tracker") then
        self:AddFakeTracker({ id = "show_laser_tracker", time = math.random() * (4 - 0.5) + 0.5, icons = { EHI.Icons.Lasers } })
    end
    self:AddPreviewText()
end

function FakeEHIManager:AddFakeTracker(params)
    params.x, params.y = self:GetPos(self._n_of_trackers)
    params.scale = self._scale
    params.text_scale = self._text_scale
    params.bg = self._bg_visibility
    params.one_icon = self._icons_visibility
    self._n_of_trackers = self._n_of_trackers + 1
    self._fake_trackers[#self._fake_trackers + 1] = _G[params.class or "FakeEHITracker"]:new(self._hud_panel, params)
end

function FakeEHIManager:AddFirstFakeTracker(params)
    self:AddFakeTracker(params)
    self._fake_trackers[1]._time_bg_box:child("left_top"):set_color(Color.red)
end

function FakeEHIManager:make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

function FakeEHIManager:AddPreviewText()
    self._preview_text = self._hud_panel:text({
        name = "preview_text",
        text = managers.localization:text("ehi_preview"),
        font_size = 23,
        font = tweak_data.menu.pd2_large_font,
        align = "center",
        vertical = "center",
        layer = 401
    })
    self:make_fine_text(self._preview_text)
    self._preview_text:set_bottom(self:GetY(0) - panel_offset)
    self._preview_text:set_x(self._x)
end

function FakeEHIManager:GetPos(pos)
    local x, y = self._x, self._y
    if self._tracker_alignment == 1 then -- Vertical
        y = self._y + (pos * (panel_size + panel_offset))
    elseif pos and pos > 0 then -- Horizontal
        local tracker = self._fake_trackers[pos]
        x = tracker._panel:right() + (tracker:GetSize() - tracker._panel:w()) + panel_offset
    end
    return x, y
end

function FakeEHIManager:GetY(pos)
    return self._y + (pos * (panel_size + panel_offset))
end

function FakeEHIManager:UpdateFormat(format)
    for _, tracker in pairs(self._fake_trackers) do
        tracker:UpdateFormat(format)
    end
end

function FakeEHIManager:UpdateEquipmentFormat(format)
    for _, tracker in pairs(self._fake_trackers) do
        if tracker.UpdateEquipmentFormat then
            tracker:UpdateEquipmentFormat(format)
        end
    end
end

function FakeEHIManager:UpdateXOffset(x)
    local x_full, _ = managers.gui_data:safe_to_full(x, 0)
    self._x = x_full
    for i, tracker in pairs(self._fake_trackers) do
        local x_new, _ = self:GetPos(i - 1)
        tracker:SetX(x_new)
    end
end

function FakeEHIManager:UpdateYOffset(y)
    local _, y_full = managers.gui_data:safe_to_full(0, y)
    self._y = y_full
    for i, tracker in pairs(self._fake_trackers) do
        local _, y_new = self:GetPos(i - 1)
        tracker:SetY(y_new)
    end
    self._preview_text:set_bottom(self:GetY(0) - panel_offset)
end

function FakeEHIManager:SetSelected(id)
    for _, tracker in pairs(self._fake_trackers) do
        tracker:SetTextColor(id == tracker:GetID())
    end
end

function FakeEHIManager:UpdateTextScale(scale)
    self._text_scale = scale
    for _, tracker in pairs(self._fake_trackers) do
        tracker:UpdateTextScale(scale)
    end
end

function FakeEHIManager:UpdateScale(scale)
    self._scale = scale
    panel_size = panel_size_original * self._scale
    panel_offset = panel_offset_original * self._scale
    self:Redraw()
end

function FakeEHIManager:UpdateBGVisibility(visibility)
    self._bg_visibility = visibility
    for _, tracker in pairs(self._fake_trackers) do
        tracker:UpdateBGVisibility(visibility)
    end
end

function FakeEHIManager:UpdateIconsVisibility(visibility)
    self._icons_visibility = visibility
    for _, tracker in pairs(self._fake_trackers) do
        tracker:UpdateIconsVisibility(visibility)
    end
    if self._tracker_alignment == 2 then -- Horizontal Alignment
        self:UpdateXOffset(EHI:GetOption("x_offset"))
    end
end

function FakeEHIManager:UpdateTrackerAlignment(alignment)
    if self._tracker_alignment == alignment then
        return
    end
    self._tracker_alignment = alignment
    self:Redraw()
end

function FakeEHIManager:Redraw()
    for _, tracker in pairs(self._fake_trackers) do
        tracker:destroy()
    end
    self._hud_panel:remove(self._preview_text)
    self:AddFakeTrackers()
end

local icons = tweak_data.ehi.icons

local function GetIcon(icon)
    if icons[icon] then
        return icons[icon].texture, icons[icon].texture_rect
    end
    return tweak_data.hud_icons:get_icon_or(icon, icons.default.texture, icons.default.texture_rect)
end

local function CreateIcon(self, i, texture, texture_rect, color, alpha, visible, x)
    self["_icon" .. i] = self._panel:bitmap({
        name = "icon" .. i,
        texture = texture,
        texture_rect = texture_rect,
        color = color,
        alpha = alpha,
        visible = visible,
        x = x,
        w = 32 * self._scale,
        h = 32 * self._scale
    })
end

local function HUDBGBox_create(panel, params, config) -- Not available when called from menu
	local box_panel = panel:panel(params)
	local color = config and config.color or Color.white
	local bg_color = config and config.bg_color or Color(1, 0, 0, 0)
	local blend_mode = config and config.blend_mode

	box_panel:rect({
		blend_mode = "normal",
		name = "bg",
		halign = "grow",
		alpha = 0.25,
		layer = -1,
		valign = "grow",
		color = bg_color,
        visible = config.visible
	})

	local left_top = box_panel:bitmap({
		texture = "guis/textures/pd2_mod_ehi/hud_corner",
		name = "left_top",
		visible = config.visible,
		layer = 0,
		y = 0,
		halign = "left",
		x = 0,
		valign = "top",
		color = color,
		blend_mode = blend_mode
	})
	local left_bottom = box_panel:bitmap({
		texture = "guis/textures/pd2_mod_ehi/hud_corner",
		name = "left_bottom",
		visible = config.visible,
		layer = 0,
		x = 0,
		y = 0,
		halign = "left",
		rotation = -90,
		valign = "bottom",
		color = color,
		blend_mode = blend_mode
	})

	left_bottom:set_bottom(box_panel:h())

	local right_top = box_panel:bitmap({
		texture = "guis/textures/pd2_mod_ehi/hud_corner",
		name = "right_top",
		visible = config.visible,
		layer = 0,
		x = 0,
		y = 0,
		halign = "right",
		rotation = 90,
		valign = "top",
		color = color,
		blend_mode = blend_mode
	})

	right_top:set_right(box_panel:w())

	local right_bottom = box_panel:bitmap({
		texture = "guis/textures/pd2_mod_ehi/hud_corner",
		name = "right_bottom",
		visible = config.visible,
		layer = 0,
		x = 0,
		y = 0,
		halign = "right",
		rotation = 180,
		valign = "bottom",
		color = color,
		blend_mode = blend_mode
	})

	right_bottom:set_right(box_panel:w())
	right_bottom:set_bottom(box_panel:h())

	return box_panel
end

FakeEHITracker = FakeEHITracker or class()
function FakeEHITracker:init(panel, params)
    self._scale = params.scale
    self._text_scale = params.text_scale
    local number_of_icons = 0
    local gap = 0
    if params.icons then
        number_of_icons = #params.icons
        gap = 5 * number_of_icons
    end
    self._parent_panel = panel
    self._panel = panel:panel({
        name = params.id,
        x = params.x,
        y = params.y,
        w = (64 + gap + (32 * number_of_icons)) * self._scale,
        h = 32 * self._scale
    })
    self._time = params.time or 0
    self._time_bg_box = HUDBGBox_create(self._panel, {
        x = 0,
        y = 0,
        w = 64 * self._scale,
        h = 32 * self._scale
    }, {
        blend_mode = "add",
        visible = params.bg
    })
    self._text = self._time_bg_box:text({
        name = "text1",
        text = self:Format(),
        align = "center",
        vertical = "center",
        w = self._time_bg_box:w(),
        h = self._time_bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h() * self._text_scale,
        color = params.text_color or Color.white
    })
    self:FitTheText()
    self._n_of_icons = number_of_icons
    self._n = number_of_icons
    if number_of_icons > 0 then
        local start = self._time_bg_box:w()
        local icon_gap = 5 * self._scale
        for i, v in ipairs(params.icons) do
            local s_i = tostring(i)
            if type(v) == "string" then
                local texture, rect = GetIcon(v)
                CreateIcon(self, s_i, texture, rect, Color.white, 1, true, start + icon_gap)
            else -- table
                local texture, rect = GetIcon(v.icon)
                CreateIcon(self, s_i, texture, rect, v.color,
                    v.alpha or 1,
                    (not not v.visible),
                    start + icon_gap)
            end
            start = start + (32 * self._scale)
            icon_gap = icon_gap + (5 * self._scale)
        end
        if params.one_icon then
            self:UpdateIconsVisibility(true)
            self._n = 1
        end
    end
    self._id = params.id
end

function FakeEHITracker:GetID()
    return self._id
end

function FakeEHITracker:ResetFontSize()
    self._text:set_font_size(self._panel:h() * self._text_scale)
end

function FakeEHITracker:FitTheText()
    self:ResetFontSize()
    local w = select(3, self._text:text_rect())
    if w > self._text:w() then
        self._text:set_font_size(self._text:font_size() * (self._text:w() / w) * self._text_scale)
    end
end

function FakeEHITracker:UpdateFormat(format)
    self._text:set_text(self:Format(format))
    self:FitTheText()
end

function FakeEHITracker:Format(format)
    format = format or EHI:GetOption("time_format")
    if format == 1 then
        local t = math.floor(self._time * 10) / 10
        if t < 0 then
            return string.format("%d", 0)
        elseif t < 1 then
            return string.format("%.2f", self._time)
        elseif t < 10 then
            return string.format("%.1f", t)
        else
            return string.format("%d", t)
        end
    else
        local t = math.floor(self._time * 10) / 10
        if t < 0 then
            return string.format("%d", 0)
        elseif t < 1 then
            return string.format("%.2f", self._time)
        elseif t < 10 then
            return string.format("%.1f", t)
        elseif t < 60 then
            return string.format("%d", t)
        else
            return string.format("%d:%02d", t / 60, t % 60)
        end
    end
end

function FakeEHITracker:SetX(x)
    self._panel:set_x(x)
end

function FakeEHITracker:SetY(y)
    self._panel:set_y(y)
end

function FakeEHITracker:SetTextColor(selected)
    self._text:set_color(selected and tweak_data.ehi.color.Inaccurate or Color.white)
end

function FakeEHITracker:UpdateBGVisibility(visibility)
    self._time_bg_box:child("bg"):set_visible(visibility)
    self._time_bg_box:child("left_top"):set_visible(visibility)
    self._time_bg_box:child("left_bottom"):set_visible(visibility)
    self._time_bg_box:child("right_top"):set_visible(visibility)
    self._time_bg_box:child("right_bottom"):set_visible(visibility)
end

function FakeEHITracker:UpdateIconsVisibility(visibility)
    local i_start = visibility and 2 or 1
    self._n = visibility and 1 or self._n_of_icons
    for i = i_start, self._n_of_icons, 1 do
        self["_icon" .. i]:set_visible(not visibility)
    end
end

function FakeEHITracker:UpdateTextScale(scale)
    self._text_scale = scale
    self:FitTheText()
end

function FakeEHITracker:GetSize()
    return (64 + (5 * self._n) + (32 * self._n)) * self._scale
end

function FakeEHITracker:destroy()
    if alive(self._panel) and alive(self._parent_panel) then
        self._parent_panel:remove(self._panel)
    end
end

FakeEHIXPTracker = FakeEHIXPTracker or class(FakeEHITracker)
function FakeEHIXPTracker:init(panel, params)
    self._xp = math.random(1000, 100000)
    FakeEHIXPTracker.super.init(self, panel, params)
end

function FakeEHIXPTracker:Format(format)
    return "+" .. self._xp
end

FakeEHIProgressTracker = FakeEHIProgressTracker or class(FakeEHITracker)
function FakeEHIProgressTracker:init(panel, params)
    self._progress = math.random(0, params.progress or 9)
    self._max = params.max or 10
    FakeEHIProgressTracker.super.init(self, panel, params)
end

function FakeEHIProgressTracker:Format(format)
    return self._progress .. "/" .. self._max
end

FakeEHIChanceTracker = FakeEHIChanceTracker or class(FakeEHITracker)
function FakeEHIChanceTracker:init(panel, params)
    self._chance = params.chance or (math.random(1, 10) * 5)
    FakeEHIChanceTracker.super.init(self, panel, params)
end

function FakeEHIChanceTracker:Format(format)
    return self._chance .. "%"
end

FakeEHIEquipmentTracker = FakeEHIEquipmentTracker or class(FakeEHITracker)
function FakeEHIEquipmentTracker:init(panel, params)
    self._show_placed = params.show_placed
    local max = params.charges or 16
    self._charges = math.random(params.min or 2, max)
    self._placed = self._charges > 4 and math.ceil(self._charges / 4) or 1
    FakeEHIEquipmentTracker.super.init(self, panel, params)
end

function FakeEHIEquipmentTracker:Format(format)
    return self:EquipmentFormat()
end

function FakeEHIEquipmentTracker:EquipmentFormat(format)
    format = format or EHI:GetOption("equipment_format")
    if format == 1 then -- Uses (Bags placed)
        if self._show_placed then
            return self._charges .. " (" .. self._placed .. ")"
        else
            return tostring(self._charges)
        end
    elseif format == 2 then -- (Bags placed) Uses
        if self._show_placed then
            return "(" .. self._placed .. ") " .. self._charges
        else
            return tostring(self._charges)
        end
    elseif format == 3 then -- (Uses) Bags placed
        if self._show_placed then
            return "(" .. self._charges .. ") " .. self._placed
        else
            return tostring(self._charges)
        end
    elseif format == 4 then -- Bags placed (Uses)
        if self._show_placed then
            return self._placed .. " (" .. self._charges .. ")"
        else
            return tostring(self._charges)
        end
    elseif format == 5 then -- Uses
        return tostring(self._charges)
    else -- Bags placed
        if self._show_placed then
            return tostring(self._placed)
        else
            return tostring(self._charges)
        end
    end
end

function FakeEHIEquipmentTracker:UpdateEquipmentFormat(format)
    self._text:set_font_size(self._panel:h() * self._text_scale)
    self._text:set_text(self:Format(format))
    self:FitTheText()
end

FakeEHICountTracker = FakeEHICountTracker or class(FakeEHITracker)
function FakeEHICountTracker:init(panel, params)
    self._count = params.count
    FakeEHICountTracker.super.init(self, panel, params)
end

function FakeEHICountTracker:Format(format)
    return tostring(self._count)
end