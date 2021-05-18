local function GetIcon(icon, type)
    if type == "achievement" then
        if icon == "faster" then -- Heat Street
            return "guis/textures/pd2/skilltree/drillgui_icon_faster"
        elseif icon == "hostage" then
            return "guis/textures/pd2/hud_icon_hostage"
        else
            return tweak_data.hud_icons:get_icon_data(icon)
        end
    else
        if icon == "pd2_escape" or icon == "pd2_lootdrop" or icon == "C_Vlad_H_Mallcrasher_Shoot" or icon == "wp_bag" or icon == "pd2_defend" or icon == "pd2_fire" or
        icon == "pd2_generic_interact" or icon == "wp_sentry" or icon == "pd2_fix" or icon == "pd2_drill" or icon == "pd2_generic_saw" or icon == "wp_hack" or
        icon == "pagers_used" or icon == "mugshot_in_custody" or icon == "pd2_car" or icon == "pd2_c4" or icon == "pd2_generic_interact" or icon == "pd2_talk" or
        icon == "equipment_winch_hook" or icon == "pd2_water_tap" or icon == "pd2_goto" or icon == "pd2_methlab" or icon == "pd2_generic_look" or
        icon == "equipment_bloodvialok" or icon == "pd2_door" or icon == "pd2_kill" or icon == "equipment_liquid_nitrogen_canister" or icon == "pd2_question" or
        icon == "equipment_glasscutter" or icon == "C_Elephant_H_ElectionDay_Murphy" or icon == "C_Vlad_H_XMas_Impossible" or icon == "Other_H_None_Merry" or
        icon == "equipment_timer" or icon == "equipment_bloodvial" or icon == "C_Dentist_H_BigBank_Entrapment" or icon == "equipment_bank_manager_key" then
            return tweak_data.hud_icons:get_icon_data(icon)
        elseif icon == "faster" or icon == "silent" or icon == "restarter" then
            return "guis/textures/pd2/skilltree/drillgui_icon_" .. icon
        elseif icon == "xp" then
            return "guis/textures/pd2/blackmarket/xp_drop"
        elseif icon == "heli" or icon == "mad_scan" or icon == "boat" or icon == "enemy" or icon == "piggy" or icon == "assaultbox" then
            return "guis/textures/pd2_mod_ehi/" .. icon
        elseif icon == "reload" then
            return "guis/textures/pd2/skilltree/icons_atlas", {0, 576, 64, 64}
        elseif icon == "trophy" then
            return tweak_data.hud_icons:get_icon_data("milestone_trophy")
        elseif icon == "smoke" then
            return "guis/dlcs/max/textures/pd2/specialization/icons_atlas", {0, 0, 64, 64}
        elseif icon == "teargas" then
            return "guis/dlcs/drm/textures/pd2/crime_spree/modifiers_atlas_2", {128, 256, 128, 128}
        elseif icon == "gage" then
            return "guis/dlcs/gage_pack_jobs/textures/pd2/endscreen/gage_assignment"
        elseif icon == "hostage" then
            return "guis/textures/pd2/hud_icon_hostage"
        elseif icon == "buff_shield" then
            return "guis/textures/pd2/hud_buff_shield"
        elseif icon == "doctor_bag" or icon == "ammo_bag" or icon == "first_aid_kit" or icon == "bodybags_bag" then
            return "guis/textures/pd2/blackmarket/icons/deployables/outline/" .. icon
        elseif icon == "frag_grenade" then
            local icon_definition = tweak_data.hud_icons.frag_grenade
            return icon_definition.texture, icon_definition.texture_rect
        elseif icon == "minion" then
            return "guis/textures/pd2/skilltree/icons_atlas", {384, 512, 64, 64}
        elseif icon == "heavy" then
            return "guis/textures/pd2/skilltree/icons_atlas", {192, 64, 64, 64}
        elseif icon == "money" then
            return tweak_data.hud_icons:get_icon_data("equipment_plates")
        elseif icon == "paper" then
            return tweak_data.hud_icons:get_icon_data("equipment_paper_roll")
        elseif icon == "ink" then
            return tweak_data.hud_icons:get_icon_data("equipment_printer_ink")
        elseif icon == "sniper" then
            return "guis/textures/pd2/skilltree/icons_atlas", {384, 320, 64, 64}
        elseif icon == "camera_loop" then
            return "guis/textures/pd2/skilltree/icons_atlas", {256, 128, 64, 64}
        elseif icon == "pager_icon" then
            return "guis/textures/pd2/specialization/icons_atlas", {64, 256, 64, 64}
        end
    end
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

EHITracker = EHITracker or class()
EHITracker._type = "base"
EHITracker._update = true
function EHITracker:init(panel, params)
    self._scale = params.scale
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
    self._former_time = self._time -- Time to reset the tracker to default
    self._time_bg_box = HUDBGBox_create(self._panel, {
        x = 0,
        y = 0,
        w = 64 * self._scale,
        h = 32 * self._scale
    }, {
        blend_mode = "add"
    })
    self._text = self._time_bg_box:text({
        name = "text1",
        text = self:Format(),
        align = "center",
        vertical = "center",
        w = self._time_bg_box:w(),
        h = self._time_bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h(),
        color = params.text_color or Color.white
    })
    self:FitTheText()
    if number_of_icons > 0 then
        local start = self._time_bg_box:w()
        local icon_gap = 5 * self._scale
        for i, v in ipairs(params.icons) do
            local s_i = tostring(i)
            if type(v) == "string" then
                local texture, rect = GetIcon(v, self._type)
                CreateIcon(self, s_i, texture, rect, Color.white, 1, true, start + icon_gap)
            else -- table
                local texture, rect = GetIcon(v.icon, self._type)
                CreateIcon(self, s_i, texture, rect, v.color,
                    v.alpha or 1,
                    (not not v.visible),
                    start + icon_gap)
            end
            start = start + (32 * self._scale)
            icon_gap = icon_gap + (5 * self._scale)
        end
    end
    self._id = params.id
    self._parent_class = params.parent_class
    self:PostInit(params)
end

if Network:is_server() then
    EHITracker.PostInit = function(self, params) end
else
    EHITracker.PostInit = function(self, params)
        self._last_sync = params.sync_time
        self._start_time = self._time + (Application:time() - params.sync_real_time)
        self._end_time = self._last_sync + self._time
    end
end

function EHITracker:SetTop(y)
    self._panel:set_y(y)
end

local function SecondsOnly(self)
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
end

local function MinutesAndSeconds(self)
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

if EHI:GetOption("time_format") == 1 then
    EHITracker.Format = SecondsOnly
else
    EHITracker.Format = MinutesAndSeconds
end

function EHITracker:update(t, dt)
    self._time = self._time - dt
    self._text:set_text(self:Format())
    if self._time <= 0 then
        self:delete()
    end
end

function EHITracker:Sync(new_time)
    if true then
        return
    end
    local time_diff = new_time - self._last_sync
    local timer_diff = self._start_time - self._time
    if time_diff < timer_diff then
        self._time = self._time - (timer_diff - time_diff)
    elseif time_diff > timer_diff then
        self._time = self._time + (time_diff - timer_diff)
    end
    self._last_sync = new_time
    self._start_time = self._time
    self._end_time = new_time + self._time
end

function EHITracker:FitTheText()
    local w = select(3, self._text:text_rect())
    if w > self._text:w() then
        self._text:set_font_size(self._text:font_size() * (self._text:w() / w))
    end
end

function EHITracker:SetTime(time)
    self:SetTimeNoAnim(time)
    self:AnimateBG()
end

function EHITracker:SetTimeNoAnim(time)
    if self._end_time then
        if time < self._time then
            self._end_time = self._end_time - (self._time - time)
        elseif time > self._time then
            self._end_time = self._end_time + (time - self._time)
        end
    end
    self._time = time
    self._text:set_text(self:Format())
    self:FitTheText()
end

function EHITracker:ResetTime()
    self._time = self._former_time
    self._text:set_text(self:Format())
    self:FitTheText()
    self:AnimateBG()
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

function EHITracker:destroy()
    if alive(self._panel) and alive(self._parent_panel) then
        self._time_bg_box:child("bg"):stop()
        self._parent_panel:remove(self._panel)
    end
end

function EHITracker:delete()
    self:destroy()
    self._parent_class:RemoveTracker(self._id, true)
end