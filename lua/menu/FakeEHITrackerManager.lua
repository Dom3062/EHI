local EHI = EHI
local Icon = EHI.Icons
local panel_size_original = tweak_data.ehi.default.tracker.size_h
local panel_offset_original = tweak_data.ehi.default.tracker.offset
local panel_size = panel_size_original
local panel_offset = panel_offset_original
---@class FakeEHITrackerManager
FakeEHITrackerManager = {}
FakeEHITrackerManager.make_fine_text = BlackMarketGui.make_fine_text
---@param panel Panel
---@param aspect_ratio number
function FakeEHITrackerManager:new(panel, aspect_ratio)
    dofile(EHI.LuaPath .. "menu/FakeEHITracker.lua")
    self._hud_panel = panel:panel({ alpha = 1 })
    if _G.IS_VR then
        self._scale = EHI:GetOption("vr_scale") --[[@as number]]
        local x, y = managers.gui_data:safe_to_full(EHI:GetOption("vr_x_offset"), EHI:GetOption("vr_y_offset"))
        self._x = x
        self._y = y
    else
        self._scale = EHI:GetOption("scale") --[[@as number]]
        local x_offset, y_offset = EHI:GetOption("x_offset"), EHI:GetOption("y_offset")
        if aspect_ratio == EHIMenu.AspectRatio._4_3 then
            self._x, self._y = managers.gui_data:safe_to_full_16_9(x_offset, y_offset)
        else
            self._x, self._y = managers.gui_data:safe_to_full(x_offset, y_offset)
        end
    end
    self._text_scale = EHI:GetOption("text_scale")
    self._bg_visibility = EHI:GetOption("show_tracker_bg")
    self._corner_visibility = EHI:GetOption("show_tracker_corners")
    self._icons_visibility = EHI:GetOption("show_one_icon")
    self._tracker_alignment = EHI:GetOption("tracker_alignment") --[[@as 1|2|3|4]]
    self._tracker_vertical_anim = EHI:GetOption("tracker_vertical_w_anim") --[[@as 1|2]]
    self._icons_pos = EHI:GetOption("show_icon_position")
    panel_size = panel_size_original * self._scale
    panel_offset = panel_offset_original * self._scale
    self._horizontal = {
        x = self._x,
        y = self._y,
        x_offset = 0
    }
    self._vertical = {
        x = self._x,
        y = self._y,
        y_offset = 0,
        max_icons = 4
    }
    self._tracker_format_data =
    {
        time = EHI:GetOption("time_format"), ---@type number
        equipment = EHI:GetOption("equipment_format"), ---@type number
        killed_civilians = EHI:GetOption("show_trade_delay_amount_of_killed_civilians"), ---@type boolean
        show_alarm_enemies = EHI:GetOption("show_enemy_count_show_pagers"), ---@type boolean
        civilian_count = EHI:GetOption("civilian_count_tracker_format"), ---@type number
        hostage_count = EHI:GetOption("hostage_count_tracker_format"), ---@type number
        minion = EHI:GetOption("show_minion_option") ---@type number
    }
    self:AddFakeTrackers()
    return self
end

function FakeEHITrackerManager:AddFakeTrackers()
    self._n_of_trackers = 0
    self._fake_trackers = {} ---@type FakeEHITracker[]?
    self:AddFakeTracker({ id = "show_mission_trackers", time = math.rand(0.5, 9.99), icons = { Icon.Wait } })
    self:AddFakeTracker({ id = "show_mission_trackers", time = math.random(60, 180), icons = { Icon.Car, Icon.Escape } })
    if EHI:GetOption("show_unlockables") then
        if EHI:GetUnlockableOption("show_achievements") then
            local icon = table.random_key(tweak_data.achievement.visual)
            self:AddFakeTracker({ ids = { "achievement", "show_achievements" }, time = math.random(60, 180), icons = { { icon = EHI:GetAchievementIconString(icon), color = EHI:GetColorFromOption("unlockables", "achievement") } } })
        end
        if EHI:GetUnlockableOption("show_trophies") then
            self:AddFakeTracker({ ids = { "trophy", "show_trophies" }, time = math.random(60, 180), icons = { { icon = Icon.Trophy, color = EHI:GetColorFromOption("unlockables", "trophy") } } })
        end
        if EHI:GetUnlockableOption("show_dailies") then
            self:AddFakeTracker({ ids = { "sidejob", "show_dailies" }, time = math.random(60, 180), icons = { { icon = Icon.Trophy, color = EHI:GetColorFromOption("unlockables", "sidejob") } } })
        end
    end
    do
        local xp_panel = EHI:GetOption("xp_panel")
        if xp_panel <= 2 then
            self:AddFakeTracker({ id = "show_gained_xp", icons = { "xp" }, extend_half = xp_panel == 2, class = "FakeEHIXPTracker" })
        end
    end
    self:AddFakeTracker({ id = "show_trade_delay", icons = { { icon = "mugshot_in_custody", color = self:GetLocalPeerColor() } }, extend_half = EHI:GetOption("show_trade_delay_amount_of_killed_civilians"), class = "FakeEHITradeDelayTracker" })
    self:AddFakeTracker({ id = "show_timers", time = math.random(60, 240), icons = { Icon.Drill, Icon.Wait, "silent", Icon.Loop } })
    self:AddFakeTracker({ id = "show_timers", time = math.random(60, 120), icons = { Icon.PCHack } })
    self:AddFakeTracker({ id = "show_timers", time = math.random(60, 120), icons = { Icon.PCHack }, extend = true, class = "FakeEHITimerTracker" })
    self:AddFakeTracker({ id = "show_camera_loop", time = math.random(10, 25), icons = { "camera_loop" } })
    self:AddFakeTracker({ id = "show_enemy_turret_trackers", time = math.random(10, 30), icons = { Icon.Turret, "reload" } })
    self:AddFakeTracker({ id = "show_enemy_turret_trackers", time = math.random(10, 30), icons = { Icon.Turret, Icon.Fix } })
    self:AddFakeTracker({ id = "show_zipline_timer", time = math.rand(1, 8) * 2, icons = { table.random({ "zipline_bag", "Other_H_Any_DidntSee" }) } })
    if EHI:GetOption("gage_tracker_panel") == 1 then
        self:AddFakeTracker({ id = "show_gage_tracker", icons = { "gage" }, class = "FakeEHIProgressTracker" })
    end
    self:AddFakeTracker({ id = "show_captain_damage_reduction", icons = { "buff_shield" }, class = "FakeEHIChanceTracker" })
    self:AddFakeTracker({ id = "show_captain_spawn_chance", time = math.random(0, 120), icons = { "buff_shield" }, extend = true, class = "FakeEHIPhalanxChanceTracker" })
    self:AddFakeTracker({ id = "show_equipment_tracker", show_placed = true, icons = { "doctor_bag" }, class = "FakeEHIEquipmentTracker" })
    self:AddFakeTracker({ id = "show_minion_tracker", min = 1, charges = 4, icons = { "minion" }, class = "FakeEHIMinionTracker" })
    self:AddFakeTracker({ id = "show_difficulty_tracker", icons = { "enemy" }, class = "FakeEHIChanceTracker" })
    self:AddFakeTracker({ id = "show_drama_tracker", chance = math.random(100), icons = { "C_Escape_H_Street_Bullet" }, class = "FakeEHIChanceTracker" })
    self:AddFakeTracker({ id = "show_pager_tracker", progress = 3, max = 4, icons = { Icon.Pager }, class = "FakeEHIProgressTracker" })
    self:AddFakeTracker({ id = "show_pager_callback", time = math.rand(0.5, 12), icons = { "pager_icon" } })
    self:AddFakeTracker({ id = "show_enemy_count_tracker", count = math.random(20, 80), icons = { "pager_icon", { icon = "enemy", visible = false } }, class = "FakeEHIEnemyCountTracker" })
    self:AddFakeTracker({ id = "show_civilian_count_tracker", count = math.random(1, 15), icons = { "civilians", "hostage" }, class = "FakeEHICivilianCountTracker" })
    self:AddFakeTracker({ id = "show_hostage_count_tracker", count = math.random(4, 10), icons = { "hostage", { icon = "hostage", color = Color(0, 1, 1) } }, class = "FakeEHIHostageCountTracker" })
    self:AddFakeTracker({ id = "show_laser_tracker", time = math.rand(0.5, 4), icons = { EHI.Icons.Lasers } })
    if EHI:CombineAssaultDelayAndAssaultTime() then
        self:AddFakeTracker({ ids = { "assault" }, time = math.random(0, 240), diff = math.random(0, 100), count = math.random(0, 100), icons = { "assaultbox" }, class = "FakeEHIAssaultTimeTracker", control = math.random() <= 0.5 })
    else
        self:AddFakeTracker({ id = "show_assault_delay_tracker", time = math.random(30, 120), diff = math.random(0, 100), count = math.random(0, 100), icons = { "assaultbox" }, class = "FakeEHIAssaultTimeTracker", control = true })
        self:AddFakeTracker({ id = "show_assault_time_tracker", time = math.random(0, 240), diff = math.random(0, 100), count = math.random(0, 100), icons = { "assaultbox" }, class = "FakeEHIAssaultTimeTracker" })
    end
    self:AddFakeTracker({ id = "show_loot_counter", icons = { Icon.Loot }, class = "FakeEHIProgressTracker" })
    self:AddFakeTracker({ id = "show_bodybags_counter", count = math.random(1, 3), icons = { "equipment_body_bag" }, class = "FakeEHICountTracker" })
    self:AddFakeTracker({ id = "show_escape_chance", icons = { Icon.Car }, chance = math.random(100), class = "FakeEHIEscapeChanceTracker" })
    self:AddFakeTracker({ id = "show_sniper_tracker", icons = { "sniper" }, class = "FakeEHISniperTracker" })
    self:AddFakeTracker({ id = "show_marshal_initial_time", time = math.random(0, 480), icons = { "equipment_sheriff_star" } })
    self:AddPreviewText()
end

function FakeEHITrackerManager:AddFakeTracker(params)
    if params.id and not EHI:GetOption(params.id) then
        return
    elseif self._n_of_trackers == 0 then
        self:CreateFirstFakeTracker(params)
    else
        self:CreateFakeTracker(params)
    end
end

function FakeEHITrackerManager:CreateFakeTracker(params)
    params.x, params.y = self:GetPos(self._n_of_trackers)
    params.scale = self._scale
    params.text_scale = self._text_scale
    params.bg = self._bg_visibility
    params.corners = self._corner_visibility
    params.one_icon = self._icons_visibility
    params.icon_pos = self._icons_pos
    params.tracker_alignment = self._tracker_alignment
    params.tracker_vertical_anim = self._tracker_vertical_anim
    params.format = self._tracker_format_data
    local tracker = _G[params.class or "FakeEHITracker"]:new(self._hud_panel, params, self) --[[@as FakeEHITracker]]
    self._n_of_trackers = self._n_of_trackers + 1
    self._fake_trackers[self._n_of_trackers] = tracker
    if self._tracker_alignment == 4 then -- Horizontal; Right to Left
        tracker:SetPos(self:GetPos2(tracker, self._n_of_trackers - 1))
    end
end

function FakeEHITrackerManager:CreateFirstFakeTracker(params)
    params.first = true
    self:CreateFakeTracker(params)
    self:_update_border_color(self._fake_trackers[1]._bg_box)
end

---@param bg_box Panel
function FakeEHITrackerManager:_update_border_color(bg_box)
    bg_box:child("right_bottom"):set_color(Color.white)
    bg_box:child("left_bottom"):set_color(Color.white)
    bg_box:child("right_top"):set_color(Color.white)
    bg_box:child("left_top"):set_color(Color.white)
    if self._tracker_alignment == 2 then
        if self._tracker_vertical_anim == 2 then
            bg_box:child("right_bottom"):set_color(Color.red)
        else
            bg_box:child("left_bottom"):set_color(Color.red)
        end
    elseif self._tracker_alignment <= 2 and self._tracker_vertical_anim == 2 then
        bg_box:child("right_top"):set_color(Color.red)
    else
        bg_box:child("left_top"):set_color(Color.red)
    end
end

function FakeEHITrackerManager:GetLocalPeerColor()
    if CustomNameColor and CustomNameColor.GetOwnColor then
        return CustomNameColor:GetOwnColor()
    end
    local i = 1
    local session = managers.network and managers.network:session()
    if session and session:local_peer() then
        i = session:local_peer():id()
    end
    return tweak_data.chat_colors[i] or tweak_data.chat_colors[#tweak_data.chat_colors] or Color.white
end

function FakeEHITrackerManager:GetOtherPeerColor()
    local colors = deep_clone(tweak_data.chat_colors)
    local i = 1
    local session = managers.network and managers.network:session()
    if session and session:local_peer() then
        i = session:local_peer():id()
    end
    table.remove(colors, i)
    return colors[math.random(#colors - 1)]
end

function FakeEHITrackerManager:AddPreviewText()
    if self._n_of_trackers == 0 then
        self:UpdatePreviewTextVisibility(false)
        return
    elseif not self._preview_text then
        self._preview_text = self._hud_panel:text({
            name = "preview_text",
            text = managers.localization:text("ehi_preview"),
            font_size = 23,
            font = tweak_data.menu.pd2_large_font,
            align = "center",
            vertical = "center",
            layer = 401,
            visible = EHI:GetOption("show_preview_text")
        })
        self:make_fine_text(self._preview_text)
    end
    self:SetPreviewTextPosition()
end

function FakeEHITrackerManager:SetPreviewTextPosition()
    if self._preview_text then
        self._preview_text:set_x(self._x)
        if self._tracker_alignment == 2 then -- Vertical; Bottom to Top
            self._preview_text:set_top(self:GetY(1) + panel_offset)
        else
            self._preview_text:set_bottom(self:GetY(0) - panel_offset)
        end
    end
end

---@param visibility boolean
function FakeEHITrackerManager:UpdatePreviewTextVisibility(visibility)
    if self._preview_text then
        self._preview_text:set_visible(visibility)
    end
end

---@param pos number
function FakeEHITrackerManager:GetPos(pos)
    local x, y = self._x, self._y
    if self._tracker_alignment <= 2 then -- Vertical
        local from_bottom = self._tracker_alignment == 2
        local new_y = self:GetY(pos, true, from_bottom)
        local h = from_bottom and (new_y - panel_offset - panel_size) or (new_y + panel_offset + panel_size)
        if (from_bottom and h < 0) or h > self._hud_panel:h() then
            self._vertical.y_offset = pos
            local new_x
            if self._tracker_vertical_anim == 2 then
                new_x = self._vertical.x - self:GetTrackerSize(self._vertical.max_icons)
            else
                new_x = self._vertical.x + self:GetTrackerSize(self._vertical.max_icons)
            end
            self._vertical.x = new_x
            x = new_x
        else
            x = self._vertical.x
            y = new_y
        end
    elseif pos > 0 and self._tracker_alignment == 3 then -- Horizontal; Left to Right
        local tracker = self._fake_trackers[pos]
        x = tracker._panel:right() + (tracker:GetSize() - tracker._panel:w()) + panel_offset
    end
    return x, y
end

---@param tracker FakeEHITracker
---@param pos number
function FakeEHITrackerManager:GetPos2(tracker, pos)
    local x = self._x
    if pos > 0 then
        local previous_tracker = self._fake_trackers[pos]
        x = previous_tracker._panel:left() - tracker:GetSize() - panel_offset
    end
    return x, self._y
end

---@param pos number
---@param vectical boolean?
---@param vertical_from_bottom boolean?
function FakeEHITrackerManager:GetY(pos, vectical, vertical_from_bottom)
    local corrected_pos = vectical and (pos - self._vertical.y_offset) or pos
    if vertical_from_bottom then
        return self._y - (corrected_pos * (panel_size + panel_offset))
    end
    return self._y + (corrected_pos * (panel_size + panel_offset))
end

---@param n_of_icons number
function FakeEHITrackerManager:GetTrackerSize(n_of_icons)
    local panel_with_offset = panel_size + panel_offset
    local gap = 5 * n_of_icons
    local icons = panel_size_original * n_of_icons
    local final_size = (64 + panel_with_offset + gap + icons) * self._scale
    return final_size
end

---@param id string
function FakeEHITrackerManager:UpdateTracker(id, value)
    local tracker = self:GetTracker(id)
    if not not tracker ~= value then
        self:Redraw()
    end
end

---@param format_key string
---@param tracker_id string
function FakeEHITrackerManager:UpdateTrackerInternalFormat(format_key, tracker_id, value)
    self._tracker_format_data[format_key] = value
    local tracker = self:GetTracker(tracker_id)
    if tracker then
        tracker:UpdateInternalFormat(format_key, value)
    end
end

---@param format number
function FakeEHITrackerManager:UpdateTimeFormat(format)
    self._tracker_format_data.time = format
    for _, tracker in ipairs(self._fake_trackers) do
        tracker:UpdateTimeFormat()
    end
end

---@param format number
function FakeEHITrackerManager:UpdateEquipmentFormat(format)
    self._tracker_format_data.equipment = format
    for _, tracker in ipairs(self._fake_trackers) do ---@cast tracker FakeEHIEquipmentTracker
        if tracker.UpdateEquipmentFormat then
            tracker:UpdateEquipmentFormat()
        end
    end
end

---@param x number?
function FakeEHITrackerManager:_update_tracker_x(x)
    self._vertical.x = x or self._x
    self._vertical.y_offset = 0
    if self._tracker_alignment == 4 then -- Horizontal; Right to Left
        for i, tracker in ipairs(self._fake_trackers) do
            tracker:SetPos(self:GetPos2(tracker, i - 1))
        end
    else
        for i, tracker in ipairs(self._fake_trackers) do
            local x_new, _ = self:GetPos(i - 1)
            tracker:SetX(x_new)
        end
    end
end

---@param x number
function FakeEHITrackerManager:UpdateXOffset(x)
    local x_full, _ = managers.gui_data:safe_to_full(x, 0)
    self._x = x_full
    self:_update_x_offset_fast(x_full)
end

---@param x_full number?
function FakeEHITrackerManager:_update_x_offset_fast(x_full)
    self:_update_tracker_x(x_full)
    self:SetPreviewTextPosition()
end

---@param y number
function FakeEHITrackerManager:UpdateYOffset(y)
    local _, y_full = managers.gui_data:safe_to_full(0, y)
    self._y = y_full
    self._vertical.x = self._x
    self._vertical.y = y_full
    self._vertical.y_offset = 0
    if self._tracker_alignment == 4 then -- Horizontal; Right to Left
        for _, tracker in ipairs(self._fake_trackers) do
            tracker:SetY(y_full)
        end
    else
        for i, tracker in ipairs(self._fake_trackers) do
            local x_new, y_new = self:GetPos(i - 1)
            tracker:SetPos(x_new, y_new)
        end
    end
    self:SetPreviewTextPosition()
end

---@param id string
function FakeEHITrackerManager:SetSelected(id)
    for _, tracker in ipairs(self._fake_trackers) do
        tracker:SetSelected(id)
    end
end

---@param scale number
function FakeEHITrackerManager:UpdateTextScale(scale)
    self._text_scale = scale
    for _, tracker in ipairs(self._fake_trackers) do
        tracker:UpdateTextScale(scale)
    end
end

---@param scale number
function FakeEHITrackerManager:UpdateScale(scale)
    self._scale = scale
    panel_size = panel_size_original * scale
    panel_offset = panel_offset_original * scale
    self:Redraw()
end

function FakeEHITrackerManager:UpdateBGVisibility(visibility)
    self._bg_visibility = visibility
    for _, tracker in ipairs(self._fake_trackers) do
        tracker:UpdateBGVisibility(visibility, self._corner_visibility)
    end
end

function FakeEHITrackerManager:UpdateCornerVisibility(visibility)
    self._corner_visibility = visibility
    if self._bg_visibility then
        for _, tracker in ipairs(self._fake_trackers) do
            tracker:UpdateCornerVisibility(visibility)
        end
    end
end

function FakeEHITrackerManager:UpdateIconsVisibility(visibility)
    self._icons_visibility = visibility
    for _, tracker in ipairs(self._fake_trackers) do
        tracker:UpdateIconsVisibility(visibility)
    end
    if self._tracker_alignment >= 3 then -- Horizontal Alignment
        self:UpdateXOffset(EHI:GetOption("x_offset"))
    end
end

function FakeEHITrackerManager:UpdateIconsPosition(position)
    self._icons_pos = position
    for _, tracker in ipairs(self._fake_trackers) do
        tracker:UpdateIconsPosition(position)
    end
    self:_update_x_offset_fast()
end

function FakeEHITrackerManager:UpdateTrackerAlignment(alignment)
    if self._tracker_alignment == alignment then
        return
    end
    self._tracker_alignment = alignment
    self:Redraw()
end

function FakeEHITrackerManager:UpdateTrackerVerticalAnim(anim)
    if self._tracker_vertical_anim == anim then
        return
    end
    self._tracker_vertical_anim = anim
    for _, tracker in ipairs(self._fake_trackers) do
        tracker:UpdateTrackerVerticalAnim(anim)
    end
    self:_update_tracker_x()
end

function FakeEHITrackerManager:Redraw()
    for _, tracker in ipairs(self._fake_trackers) do
        tracker:destroy()
    end
    self._horizontal.x = self._x
    self._horizontal.y = self._y
    self._horizontal.x_offset = 0
    self._vertical.x = self._x
    self._vertical.y = self._y
    self._vertical.y_offset = 0
    self:AddFakeTrackers()
end

---@param id string
---@return FakeEHITracker?
function FakeEHITrackerManager:GetTracker(id)
    for _, tracker in ipairs(self._fake_trackers) do
        if tracker:CompareID(id) then
            return tracker
        end
    end
end

function FakeEHITrackerManager:ForceReposition()
    if self._tracker_alignment >= 3 then -- Horizontal Alignment
        self:UpdateXOffset(EHI:GetOption("x_offset"))
    end
end

---@param id string
---@param f string
function FakeEHITrackerManager:CallFunction(id, f, ...)
    local tracker = self:GetTracker(id)
    if tracker and tracker[f] then
        tracker[f](tracker, ...)
    end
end