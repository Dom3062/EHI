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

local bg_visibility = EHI:GetOption("show_tracker_bg")

EHITracker = EHITracker or class()
EHITracker._update = true
function EHITracker:init(panel, params)
    self._exclude_from_sync = params.exclude_from_sync
    self._icons = params.icons
    self._class = params.class
    self._scale = params.scale
    self._text_scale = params.text_scale
    local number_of_icons = 0
    local gap = 0
    if type(self._icons) == "table" then
        number_of_icons = #self._icons
        gap = 5 * number_of_icons
    end
    self._parent_panel = panel
    self._panel = panel:panel({
        name = params.id,
        x = params.x,
        y = params.y,
        w = (64 + gap + (32 * number_of_icons)) * self._scale,
        h = 32 * self._scale,
        alpha = 0,
        visible = true
    })
    self._time = params.time or 0
    self._former_time = self._time -- Time to reset the tracker to default
    self._time_bg_box = HUDBGBox_create(self._panel, {
        x = 0,
        y = 0,
        w = 64 * self._scale,
        h = 32 * self._scale
    }, {
        blend_mode = "add"
    })
    self._time_bg_box:child("bg"):set_visible(bg_visibility)
    self._time_bg_box:child("left_top"):set_visible(bg_visibility)
    self._time_bg_box:child("left_bottom"):set_visible(bg_visibility)
    self._time_bg_box:child("right_top"):set_visible(bg_visibility)
    self._time_bg_box:child("right_bottom"):set_visible(bg_visibility)
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
    if number_of_icons > 0 then
        self:CreateIcons()
    end
    self._id = params.id
    self._parent_class = params.parent_class
    self:SetPanelVisible()
end

function EHITracker:SetPanelVisible()
    self._panel:animate(function(o)
        local TOTAL_T = 0.18
        local t = 0
        while TOTAL_T > t do
            local dt = coroutine.yield()
            t = math.min(t + dt, TOTAL_T)
            local lerp = t / TOTAL_T
            o:set_alpha(math.lerp(0, 1, lerp))
        end
    end)
end

if EHI:GetOption("show_one_icon") then
    EHITracker.CreateIcons = function(self)
        local icon_pos = self._time_bg_box:w() + (5 * self._scale)
        local first_icon = self._icons[1]
        if type(first_icon) == "string" then
            local texture, rect = GetIcon(first_icon)
            CreateIcon(self, "1", texture, rect, Color.white, 1, true, icon_pos)
        elseif type(first_icon) == "table" then
            local texture, rect = GetIcon(first_icon.icon)
            CreateIcon(self, "1", texture, rect, first_icon.color,
                first_icon.alpha or 1,
                first_icon.visible ~= false,
                icon_pos)
        end
    end
else
    EHITracker.CreateIcons = function(self)
        local start = self._time_bg_box:w()
        local icon_gap = 5 * self._scale
        for i, v in ipairs(self._icons) do
            local s_i = tostring(i)
            if type(v) == "string" then
                local texture, rect = GetIcon(v)
                CreateIcon(self, s_i, texture, rect, Color.white, 1, true, start + icon_gap)
            elseif type(v) == "table" then -- table
                local texture, rect = GetIcon(v.icon)
                CreateIcon(self, s_i, texture, rect, v.color,
                    v.alpha or 1,
                    v.visible ~= false,
                    start + icon_gap)
            end
            start = start + (32 * self._scale)
            icon_gap = icon_gap + (5 * self._scale)
        end
    end
end

function EHITracker:SetTop(from_y, target_y)
    if self._anim_move then
        self._panel:stop(self._anim_move)
        self._anim_move = nil
    end
    self._anim_move = self._panel:animate(function(o)
        local TOTAL_T = 0.18
        local t = (1 - math.abs(from_y - target_y) / math.abs(from_y - target_y)) * TOTAL_T
        while TOTAL_T > t do
            local dt = coroutine.yield()
            t = math.min(t + dt, TOTAL_T)
            local lerp = t / TOTAL_T
            o:set_y(math.lerp(from_y, target_y, lerp))
        end
    end)
end

function EHITracker:SetLeft(from_x, target_x)
    if self._anim_move then
        self._panel:stop(self._anim_move)
        self._anim_move = nil
    end
    self._anim_move = self._panel:animate(function(o)
        local TOTAL_T = 0.18
        local t = (1 - math.abs(from_x - target_x) / math.abs(from_x - target_x)) * TOTAL_T
        while TOTAL_T > t do
            local dt = coroutine.yield()
            t = math.min(t + dt, TOTAL_T)
            local lerp = t / TOTAL_T
            o:set_x(math.lerp(from_x, target_x, lerp))
        end
    end)
end

function EHITracker:SetPanelW(target_w)
    if self._anim_set_w then
        self._panel:stop(self._anim_set_w)
        self._anim_set_w = nil
    end
    self._anim_set_w = self._panel:animate(function(o)
        local TOTAL_T = 0.18
        local from_w = o:w()
        local abs = -(from_w - target_w)
        local t = (1 - abs / abs) * TOTAL_T
        while TOTAL_T > t do
            local dt = coroutine.yield()
            t = math.min(t + dt, TOTAL_T)
            local lerp = t / TOTAL_T
            o:set_w(math.lerp(from_w, target_w, lerp))
        end
    end)
end

function EHITracker:SetIconX(target_x)
    if not self._icon1 then
        return
    end
    if self._anim_icon1_x then
        self._icon1:stop(self._anim_icon1_x)
        self._anim_icon1_x = nil
    end
    self._anim_icon1_x = self._icon1:animate(function(o)
        local TOTAL_T = 0.18
        local from_x = o:x()
        local t = (1 - math.abs(from_x - target_x) / math.abs(from_x - target_x)) * TOTAL_T
        while TOTAL_T > t do
            local dt = coroutine.yield()
            t = math.min(t + dt, TOTAL_T)
            local lerp = t / TOTAL_T
            o:set_x(math.lerp(from_x, target_x, lerp))
        end
    end)
end

do
    local math_floor = math.floor
    local string_format = string.format
    local function SecondsOnly(self)
        local t = math_floor(self._time * 10) / 10

        if t < 0 then
            return string_format("%d", 0)
        elseif t < 1 then
            return string_format("%.2f", self._time)
        elseif t < 10 then
            return string_format("%.1f", t)
        else
            return string_format("%d", t)
        end
    end

    local function MinutesAndSeconds(self)
        local t = math_floor(self._time * 10) / 10

        if t < 0 then
            return string_format("%d", 0)
        elseif t < 1 then
            return string_format("%.2f", self._time)
        elseif t < 10 then
            return string_format("%.1f", t)
        elseif t < 60 then
            return string_format("%d", t)
        else
            return string_format("%d:%02d", t / 60, t % 60)
        end
    end

    if EHI:GetOption("time_format") == 1 then
        EHITracker.Format = SecondsOnly
    else
        EHITracker.Format = MinutesAndSeconds
    end
end

function EHITracker:update(t, dt)
    self._time = self._time - dt
    self._text:set_text(self:Format())
    if self._time <= 0 then
        self:delete()
    end
end

function EHITracker:ResetFontSize()
    self._text:set_font_size(self._panel:h() * self._text_scale)
end

function EHITracker:FitTheText()
    self:ResetFontSize()
    local w = select(3, self._text:text_rect())
    if w > self._text:w() then
        self._text:set_font_size(self._text:font_size() * (self._text:w() / w) * self._text_scale)
    end
end

function EHITracker:SetTime(time)
    self:SetTimeNoAnim(time)
    self:AnimateBG()
end

function EHITracker:SetTimeNoAnim(time)
    self._time = time
    self._text:set_text(self:Format())
    self:FitTheText()
end

function EHITracker:ResetTime()
    self:SetTime(self._former_time)
end

function EHITracker:AddDelay(delay)
    self:SetTime(self._time + delay)
end

function EHITracker:AnimateBG(t)
    local bg = self._time_bg_box:child("bg")
    bg:stop()
    bg:set_color(Color(1, 0, 0, 0))
    bg:animate(callback(self, self, "HUDBGBox_animate_bg_attention"), t or 3)
end

function EHITracker:HUDBGBox_animate_bg_attention(bg, total_t)
	local color = Color.white
	local TOTAL_T = total_t or 3
	local t = TOTAL_T

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local cv = math.abs(math.sin(t * 180 * 1))

		bg:set_color(Color(1, color.red * cv, color.green * cv, color.blue * cv))
	end

	bg:set_color(Color(1, 0, 0, 0))
end

function EHITracker:SetTextColor(color)
    self._text:set_color(color)
end

function EHITracker:SetIconColor(color)
    self._icon1:set_color(color)
end

function EHITracker:SetTrackerAccurate(time)
    self:SetTextColor(Color.white)
    self:SetTimeNoAnim(time)
end

function EHITracker:RemoveTrackerFromUpdate()
    self._parent_class:RemoveTrackerFromUpdate(self._id)
end

function EHITracker:AddTrackerToUpdate()
    self._parent_class:AddTrackerToUpdate(self._id, self)
end

function EHITracker:GetPanelW()
    return self._panel_override_w or self._panel:w()
end

function EHITracker:destroy(skip)
    if alive(self._panel) and alive(self._parent_panel) then
        if self._icon1 then
            self._icon1:stop()
        end
        self._panel:stop()
        self._panel:animate(function(o)
            if not skip then
                local TOTAL_T = 0.18
                local t = 0
                while TOTAL_T > t do
                    local dt = coroutine.yield()
                    t = math.min(t + dt, TOTAL_T)
                    local lerp = t / TOTAL_T
                    o:set_alpha(math.lerp(1, 0, lerp))
                end
            end
            self._time_bg_box:child("bg"):stop()
            self._parent_panel:remove(self._panel)
        end)
    end
end

function EHITracker:delete()
    self:destroy()
    self._parent_class:RemoveTracker(self._id, true)
end