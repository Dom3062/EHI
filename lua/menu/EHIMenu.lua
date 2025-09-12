--[[
    Original code by Void UI team

    EHI Menu specific code made by me
    List:
    Items in line
    Focus changed callback
    Callback arguments
    Color animation
]]

---@class Menu
---@field len number?
---@field panel Panel
---@field parent_menu string?
---@field items MenuItem[]
---@field focus_changed_callback string?

---@class MenuItem
---@field id string
---@field blocked_by { check: string, hint: string }
---@field callback string|string[]
---@field callback_arguments string|string[]
---@field desc string
---@field default_value any
---@field enabled boolean
---@field focus_changed_callback string?
---@field load_menu { file_path: string, settings: (string|string[])? }
---@field next_menu string?
---@field num number
---@field panel Panel
---@field parent (string|string[])?
---@field parent_func_update string?
---@field preview_func string
---@field preview_func_params any|any[]
---@field size number?
---@field type string
---@field value any

---@class MenuMultipleChoicesItem : MenuItem
---@field items string[]

---@class MenuMultipleChoiceSliderItem : MenuMultipleChoicesItem
---@field max number

local EHI = EHI
---@param TOTAL_T number
---@param clbk fun(p: number, t: number)
local function do_animation(TOTAL_T, clbk)
    local t = 0
    while t < TOTAL_T do
        coroutine.yield()
        t = t + TimerManager:main():delta_time()
        clbk(t / TOTAL_T, t)
    end
    clbk(1, TOTAL_T)
end
---@param o PanelBaseObject
---@param target_alpha number
local function animate_alpha(o, target_alpha)
    local alpha = o:alpha()
    do_animation(0.2, function(p)
        o:set_alpha(math.lerp(alpha, target_alpha, p))
    end)
    o:set_alpha(target_alpha)
end

EHIMenu = class()
EHIMenu.make_fine_text = BlackMarketGui.make_fine_text
EHIMenu.AspectRatio =
{
    _16_10 = 1,
    _4_3 = 2,
    Other = 3
}
EHIMenu._item_offset =
{
    label = 5,
    button = 10,
    toggle = 34,
    slider = 110,
    multiple_choice = 215,
    color_select = 64
}
---@param text Text
EHIMenu._adjust_font_size = function(text)
    local w = select(3, text:text_rect()) ---@type number
    if w > text:w() then
        text:set_font_size(text:font_size() * (text:w() / w))
    end
end
function EHIMenu:init()
    local aspect_ratio = RenderSettings.resolution.x / RenderSettings.resolution.y
    local _1_33 = 4 / 3
    local AspectRatioEnum
    if aspect_ratio == 1.6 or aspect_ratio == _1_33 then -- 16:10 or 4:3
        AspectRatioEnum = aspect_ratio == 1.6 and self.AspectRatio._16_10 or self.AspectRatio._4_3
        self._ws = managers.gui_data:create_fullscreen_16_9_workspace()
        self._convert_mouse_pos = function(menu, x, y)
            return managers.mouse_pointer:convert_fullscreen_16_9_mouse_pos(x, y)
        end
    else
        AspectRatioEnum = self.AspectRatio.Other
        self._ws = managers.gui_data:create_fullscreen_workspace()
        self._convert_mouse_pos = function(menu, x, y)
            return x, y
        end
    end
    self._ws:connect_keyboard(Input:keyboard())
    self._mouse_id = managers.mouse_pointer:get_id()
    self._menus = {} ---@type table<string, Menu?>
    self._axis_timer = { x = 0, y = 0 }
    self._panel = self._ws:panel():panel({
        layer = 500,
        alpha = 0
    })
    local background_size = managers.gui_data:full_scaled_size()
    local bg = self._panel:bitmap({
        color = Color.black,
        alpha = 0.5,
        layer = -1,
        rotation = 360,
        w = background_size.w
    })
    bg:set_center_x(self._panel:w() / 2)
    local blur_bg = self._panel:bitmap({
        texture = "guis/textures/test_blur_df",
        render_template = "VertexColorTexturedBlur3D",
        w = background_size.w,
        h = self._panel:h(),
        rotation = 360,
        layer = -2,
    })
    blur_bg:set_center_x(self._panel:w() / 2)
    self._tooltip = self._panel:text({
        font_size = 18,
        font = tweak_data.menu.pd2_large_font,
        y = 10,
        w = 500,
        align = "right",
        wrap = true,
        word_wrap = true,
    })
    local options_bg = self._panel:bitmap({
        texture = "guis/textures/pd2_mod_ehi/menu_atlas",
        texture_rect = { 0, 0, 416, 150 },
        w = self._panel:w() / 2.5,
        h = self._panel:h(),
    })
    options_bg:set_right(self._panel:w())
    self._options_panel = self._panel:panel({
        y = 5,
        w = options_bg:w() - 20,
        h = options_bg:h() - 45,
    })
    self._options_panel:set_right(self._panel:w() - 10)
    self._tooltip:set_right(self._options_panel:x() - 20)
    if managers.menu:is_pc_controller() then
        local back_button = self._panel:panel({
            w = 100,
            h = 25,
            layer = 2
        })
        local esc = " %["..utf8.to_upper(managers.controller:get_settings("pc"):get_connection("back"):get_input_name_list()[1]).."%]"
        local title = back_button:text({
            name = "title",
            font_size = 28,
            font = tweak_data.menu.pd2_large_font,
            align = "center",
            text = managers.localization:text("menu_back"):gsub(esc, "")
        })
        self:make_fine_text(title)
        back_button:set_size(title:w() + 16, title:h() + 2)
        title:set_center(back_button:w() / 2, back_button:h() / 2)
        back_button:set_righttop(self._options_panel:right(), self._options_panel:bottom() + 2)
        back_button:bitmap({
            name = "bg",
            alpha = 0,
        })
        self._back_button = { type = "button", panel = back_button, callback = "Cancel", num = 0 }
        if not _G.IS_VR then -- Preview does not work in VR (panel is not visible)
            self._preview_button = self._panel:panel({
                w = 100,
                h = 25,
                layer = 2,
                visible = false
            })
            local preview_title = self._preview_button:text({
                name = "title",
                font_size = 28,
                font = tweak_data.menu.pd2_large_font,
                align = "center",
                text = managers.localization:to_upper_text("ehi_menu_preview", { BTN_PREVIEW = managers.localization:btn_macro("run", true) })
            })
            self:make_fine_text(preview_title)
            self._preview_button:set_size(preview_title:w() + 16, preview_title:h() + 2)
            preview_title:set_center(self._preview_button:w() / 2, self._preview_button:h() / 2)
            self._preview_button:set_righttop(back_button:left(), self._options_panel:bottom() + 2)
        end
    else
        self._button_legends = self._panel:text({
            layer = 2,
            w = options_bg:w() - 20,
            h = 25,
            font_size = 23,
            font = tweak_data.menu.pd2_large_font,
            align = "right",
            text = ""
        })
        self:SetLegends(true, true, false, false)
        self._button_legends:set_right(self._options_panel:right() - 5)
        self._button_legends:set_top(self._options_panel:bottom())
    end
    self._preview_panel = FakeEHITrackerManager:new(self._panel, AspectRatioEnum)
    self._buffs_preview_panel = FakeEHIBuffsManager:new(self._panel)

    self._menu_ver = tonumber(EHI.ModInstance:GetVersion()) or 1

    ---@param dt number
    local function Update(t, dt)
        if self._enabled then
            self:update(dt)
        end
    end
    local update_loop = "MenuUpdate"
    local update_class = MenuManager
    if Utils:IsInGameState() then
        local restart = self._panel:text({
            text = managers.localization:text("ehi_level_restart_required"),
            font_size = 24,
            font = tweak_data.menu.pd2_large_font,
            y = 10,
            w = 500,
            align = "right",
            wrap = true,
            word_wrap = true
        })
        restart:set_right(self._options_panel:x() - 20)
        restart:set_top(self._options_panel:bottom())
        update_loop = "GameSetupUpdate"
        update_class = GameSetup
        Hooks:Add("GameSetupPausedUpdate", "MenuUpdatePaused_EHIMenu", Update) -- Single-Player pauses the update loop above, another loop is needed (down below)
    end

    self:_get_menu_from_json(EHI.MenuPath .. "menu.json")

    self:OpenMenu("ehi_menu")

    Hooks:Add(update_loop, "MenuUpdate_EHIMenu", Update)
    Hooks:PostHook(update_class, "destroy", "destroy_menu_EHIMenu", function(...)
        self._enabled = false
        EHI.Menu = nil
    end)
end

---@param item MenuItem
function EHIMenu:CallCallback(item, params)
    params = params or {}
    if item.callback and not params.skip_call then
        local value = item.value
        if params.to_n then
            value = tonumber(value)
        end
        if params.color then
            local v = params.color_panels
            value = Color(v[1]:child("value"):text(), v[2]:child("value"):text(), v[3]:child("value"):text())
        end
        if params.color_raw then
            value = Color(unpack(params.color_raw))
        end
        local var = type(item.callback_arguments) == "table"
        if type(item.callback) == "table" then
            for _, clbk in ipairs(item.callback --[[@as string[] ]]) do
                if var then
                    self[clbk](self, value, unpack(item.callback_arguments --[[@as string[] ]]))
                else
                    self[clbk](self, value, item.callback_arguments)
                end
            end
        elseif var then
            self[item.callback](self, value, unpack(item.callback_arguments --[[@as string[] ]]))
        else
            self[item.callback](self, value, item.callback_arguments)
        end
    end
end

---@param dt number
function EHIMenu:update(dt)
    if self._axis_timer.y <= 0 then
        if 0.5 < self._controller:get_input_axis("menu_move").y or self._controller:get_input_bool("menu_up") then
            self:MenuUp()
            self:SetAxisTimer("y", 0.18, 0.3, "menu_up")
        elseif -0.5 > self._controller:get_input_axis("menu_move").y or self._controller:get_input_bool("menu_down") then
            self:MenuDown()
            self:SetAxisTimer("y", 0.18, 0.3, "menu_down")
        end
    end
    if self._axis_timer.x <= 0 then
        if 0.5 < self._controller:get_input_axis("menu_move").x or self._controller:get_input_bool("menu_right") then
            self:MenuLeftRight(1)
            self:SetAxisTimer("x", 0.12, 0.22, "menu_right")
        elseif -0.5 > self._controller:get_input_axis("menu_move").x or self._controller:get_input_bool("menu_left") then
            self:MenuLeftRight(-1)
            self:SetAxisTimer("x", 0.12, 0.22, "menu_left")
        end

        if not managers.menu:is_pc_controller() then
            if self._controller:get_input_bool("next_page") then
                self:MenuLeftRight(10, 1)
                self:SetAxisTimer("x", 0.12, 0.22, "next_page")
            elseif self._controller:get_input_bool("previous_page") then
                self:MenuLeftRight(-10, -1)
                self:SetAxisTimer("x", 0.12, 0.22, "previous_page")
            end
        end
    end

    self._axis_timer.y = math.max(self._axis_timer.y - dt, 0)
    self._axis_timer.x = math.max(self._axis_timer.x - dt, 0)
end

---@param axis string
---@param delay number
---@param input_delay number
---@param input string
function EHIMenu:SetAxisTimer(axis, delay, input_delay, input)
    self._axis_timer[axis] = self._controller:get_input_pressed(input) and input_delay or delay
end

function EHIMenu:Open()
    if self._enabled then
        return
    end
    self._enabled = true
    managers.menu._input_enabled = false
    for _, menu in ipairs(managers.menu._open_menus) do
        menu.input._controller:disable()
    end

    if not self._controller then
        self._controller = managers.controller:create_controller("EHIMenu", nil, false)
        self._controller:add_trigger("cancel", callback(self, self, "Cancel"))
        self._controller:add_trigger("confirm", callback(self, self, "Confirm"))
        self._controller:add_trigger("menu_toggle_voice_message", callback(self, self, "SetItem"))
        local Y_button = "menu_modify_item"
        if managers.menu:is_pc_controller() then
            Y_button = "run"
            managers.mouse_pointer:use_mouse({
                mouse_move = callback(self, self, "mouse_move"),
                mouse_press = callback(self, self, "mouse_press"),
                mouse_release = callback(self, self, "mouse_release"),
                id = self._mouse_id
            })
        end
        if not _G.IS_VR then
            self._controller:add_trigger(Y_button, callback(self, self, "Preview"))
        end
    end

    self._panel:stop()
    self._panel:animate(function(o)
        local a = o:alpha()

        do_animation(0.2, function(p)
            local alpha_lerp = math.lerp(a, 1, p)
            o:set_alpha(alpha_lerp)
            self._preview_panel._panel:set_alpha(alpha_lerp)
        end)
        self._controller:enable()

        if PocoHud3 and PocoHud3.dbgLbl then
            self._poco_time_visibility = PocoHud3.dbgLbl:visible()
            PocoHud3.dbgLbl:set_visible(false)
        end
    end)
end

function EHIMenu:Close()
    if not self._enabled then
        return
    end
    self._enabled = false
    managers.mouse_pointer:remove_mouse(self._mouse_id)
    if self._controller then
        self._controller:destroy()
        self._controller = nil
    end
    EHI:SaveOptions()

    self._panel:stop()
    self._panel:animate(function(o)
        local a = o:alpha()

        do_animation(0.2, function(p)
            local alpha_lerp = math.lerp(a, 0, p)
            o:set_alpha(alpha_lerp)
            self._preview_panel._panel:set_alpha(alpha_lerp)
        end)
        o:set_alpha(0)
        self._preview_panel._panel:set_alpha(0)

        if PocoHud3 and PocoHud3.dbgLbl then
            PocoHud3.dbgLbl:set_visible(self._poco_time_visibility)
            self._poco_time_visibility = nil
        end

        managers.menu._input_enabled = true
        for _, menu in ipairs(managers.menu._open_menus) do
            menu.input._controller:enable()
        end
    end)
    self:SetFocus(false, "")
end

-- Mouse Functions
function EHIMenu:mouse_move(o, x, y)
    x, y = self:_convert_mouse_pos(x, y)
    if self._open_menu then
        managers.mouse_pointer:set_pointer_image("arrow")
        if self._open_choice_dialog and self._open_choice_dialog.panel then
            local selected = false
            for i, item in ipairs(self._open_choice_dialog.items) do
                if alive(item) and item:inside(x, y) and not selected then
                    if self._open_choice_dialog.selected > 0 and self._open_choice_dialog.selected ~= i then
                        self._open_choice_dialog.items[self._open_choice_dialog.selected]:set_color(Color(0.6, 0.6, 0.6))
                    end
                    item:set_color(Color.white)
                    self._open_choice_dialog.selected = i
                    selected = true
                    managers.mouse_pointer:set_pointer_image("link")
                end
            end
        elseif self._open_color_dialog and self._open_color_dialog.panel then
            if self._slider then
                self:SetColorSlider(self._slider.slider, x, self._slider.type) ---@diagnostic disable-line
                managers.mouse_pointer:set_pointer_image("grab")
            else
                for i, item in ipairs(self._open_color_dialog.items) do
                    if alive(item) and item:inside(x, y) and item:child("bg"):alpha() ~= 0.1 then
                        if self._open_color_dialog.selected > 0 and self._open_color_dialog.selected ~= i then
                            self._open_color_dialog.items[self._open_color_dialog.selected]:child("bg"):set_alpha(0)
                        end
                        item:child("bg"):set_alpha(0.1)
                        self._open_color_dialog.selected = i
                        managers.mouse_pointer:set_pointer_image("link")
                    end
                end
            end
        elseif self._slider then
            self:SetSlider(self._slider, x)
        elseif self._back_button and self._back_button.panel:inside(x, y) then
            self:HighlightItem(self._back_button)
            managers.mouse_pointer:set_pointer_image("link")
        else
            for _, item in ipairs(self._open_menu.items) do
                if item.enabled and item.panel:inside(x, y) and item.panel:child("bg") then
                    self:HighlightItem(item)
                    if item.type == "slider" then
                        managers.mouse_pointer:set_pointer_image("hand")
                    else
                        managers.mouse_pointer:set_pointer_image("link")
                    end
                end
            end
        end
    end
end

function EHIMenu:mouse_press(o, button, x, y)
    x, y = self:_convert_mouse_pos(x, y)
    if button == Idstring("0") then
        if self._open_choice_dialog then
            if self._open_choice_dialog.panel:inside(x, y) then
                for i, item in ipairs(self._open_choice_dialog.items) do
                    if alive(item) and item:inside(x, y) and item:alpha() == 1 then
                        local parent_item = self._open_choice_dialog.parent_item
                        parent_item.panel:child("title_selected"):set_text(self._open_choice_dialog.items[i]:text()) ---@diagnostic disable-line
                        parent_item.value = i
                        self:CloseMultipleChoicePanel()
                    end
                end
            else
                self:CloseMultipleChoicePanel()
            end
        elseif self._open_color_dialog then
            if self._open_color_dialog.panel:inside(x, y) then
                for i, item in ipairs(self._open_color_dialog.items) do
                    if alive(item) and item:inside(x, y) then
                        if item:child("slider") then
                            self._slider = { slider = item, type = i }
                            self:SetColorSlider(item, x, i)
                            managers.mouse_pointer:set_pointer_image("grab")
                        elseif item:name() == "reset_panel" then
                            self:ResetColorMenu()
                        else
                            self:CloseColorMenu()
                        end
                    end
                end
            else
                self:CloseColorMenu()
            end
        elseif self._highlighted_item then
            if self._highlighted_item.type == "multiple_choice_slider" then
                if self._highlighted_item.panel:child("left_arrow"):inside(x, y) then
                    self:SetMultipleChoiceSlider(self._highlighted_item, -1) ---@diagnostic disable-line
                elseif self._highlighted_item.panel:child("right_arrow"):inside(x, y) then
                    self:SetMultipleChoiceSlider(self._highlighted_item, 1) ---@diagnostic disable-line
                else
                    self:ActivateItem(self._highlighted_item, x)
                end
            elseif self._highlighted_item.panel:inside(x, y) then
                self:ActivateItem(self._highlighted_item, x)
            end
        end
    end
end

function EHIMenu:mouse_release(o, button, x, y)
    if button == Idstring("0") and self._slider then
        self:CallCallback(self._slider, { to_n = true })
        self._slider = nil
        managers.mouse_pointer:set_pointer_image("hand")
    end
end

-- Item interaction
function EHIMenu:Confirm()
    if not self._enabled then
        return
    elseif self._open_choice_dialog then
        for i, item in ipairs(self._open_choice_dialog.items) do
            if alive(item) and self._open_choice_dialog.selected == i then
                local parent_item = self._open_choice_dialog.parent_item
                parent_item.panel:child("title_selected"):set_text(self._open_choice_dialog.items[i]:text()) ---@diagnostic disable-line
                parent_item.value = i
                self:CloseMultipleChoicePanel()
            end
        end
    elseif self._open_color_dialog then
        if self._open_color_dialog.selected == 4 then
            self:CloseColorMenu()
        elseif self._open_color_dialog.selected == 5 then
            self:ResetColorMenu()
        end
    elseif self._highlighted_item then
        self:ActivateItem(self._highlighted_item)
    end
end

function EHIMenu:MenuDown()
    if not self._enabled then
        return
    elseif self._open_choice_dialog then
        if self._open_choice_dialog.selected < #self._open_choice_dialog.items then
            if self._open_choice_dialog.selected > 0 then
                self._open_choice_dialog.items[self._open_choice_dialog.selected]:set_color(Color(0.6, 0.6, 0.6))
            end
            self._open_choice_dialog.items[self._open_choice_dialog.selected + 1]:set_color(Color.white)
            self._open_choice_dialog.selected = self._open_choice_dialog.selected + 1
        end
    elseif self._open_color_dialog then
        if self._open_color_dialog.selected < 5 then
            if self._open_color_dialog.selected > 0 then
                self._open_color_dialog.items[self._open_color_dialog.selected]:child("bg"):set_alpha(0)
            end
            self._open_color_dialog.items[self._open_color_dialog.selected + 1]:child("bg"):set_alpha(0.1)
            self._open_color_dialog.selected = self._open_color_dialog.selected + 1
            self:SetLegends(math.within(self._open_color_dialog.selected, 4, 5), false, self._open_color_dialog.selected < 4, false)
        end
    elseif self._open_menu then
        if self._highlighted_item then
            local current_num = self._highlighted_item.num + 1 > #self._open_menu.items - 1 and 0 or self._highlighted_item.num + 1
            for i = current_num, (#self._open_menu.items - current_num) + current_num do
                local item = self._open_menu.items[i + 1]
                if item and item.enabled and item.panel:child("bg") then
                    self:HighlightItem(item)
                    return
                end
            end
            for i = 0, #self._open_menu.items do
                local item = self._open_menu.items[i]
                if item and item.enabled and item.panel:child("bg") then
                    self:HighlightItem(item)
                    return
                end
            end
        else
            for _, item in ipairs(self._open_menu.items) do
                if item.enabled and item.panel:child("bg") then
                    self:HighlightItem(item)
                    return
                end
            end
        end
    end
end

function EHIMenu:MenuUp()
    if not self._enabled then
        return
    elseif self._open_choice_dialog then
        if self._open_choice_dialog.selected > 1 then
            self._open_choice_dialog.items[self._open_choice_dialog.selected]:set_color(Color(0.7, 0.7, 0.7))
            self._open_choice_dialog.items[self._open_choice_dialog.selected - 1]:set_color(Color.white)
            self._open_choice_dialog.selected = self._open_choice_dialog.selected - 1
        end
    elseif self._open_color_dialog then
        if self._open_color_dialog.selected > 1 then
            self._open_color_dialog.items[self._open_color_dialog.selected]:child("bg"):set_alpha(0)
            self._open_color_dialog.items[self._open_color_dialog.selected - 1]:child("bg"):set_alpha(0.1)
            self._open_color_dialog.selected = self._open_color_dialog.selected - 1
            self:SetLegends(math.within(self._open_color_dialog.selected, 4, 5), false, self._open_color_dialog.selected < 4, false)
        end
    elseif self._open_menu and self._highlighted_item then
        local current_num = self._highlighted_item.num + 1
        for i = current_num, 1, - 1 do
            local item = self._open_menu.items[i - 1]
            if item and item.enabled and item.panel:child("bg") then
                self:HighlightItem(item)
                return
            end
        end
        for i = #self._open_menu.items + 1, 1, -1 do
            local item = self._open_menu.items[i - 1]
            if item and item.enabled and item.panel:child("bg") then
                self:HighlightItem(item)
                return
            end
        end
    end
end

---@param change number
---@param change_no_skip number?
function EHIMenu:MenuLeftRight(change, change_no_skip)
    if not self._enabled then
        return
    elseif self._open_color_dialog and self._open_color_dialog.selected < 4 then
        self:SetColorSlider(self._open_color_dialog.items[self._open_color_dialog.selected], nil, self._open_color_dialog.selected, change)
    elseif self._open_menu then
        if self._highlighted_item then
            if self._highlighted_item.type == "slider" then
                self:SetSlider(self._highlighted_item, nil, change)
                self:CallCallback(self._highlighted_item, { to_n = true })
            elseif self._highlighted_item.type == "multiple_choice_slider" then
                self:SetMultipleChoiceSlider(self._highlighted_item, change_no_skip or change) ---@diagnostic disable-line
            end
        end
    end
end

---@param item MenuItem
---@param x number?
function EHIMenu:ActivateItem(item, x)
    if not item then
        return
    elseif item.type == "button" then
        if item.load_menu and item.next_menu and not self._menus[item.next_menu] then
            local settings_table = EHI.settings
            if type(item.load_menu.settings) == "string" then
                settings_table = settings_table[item.load_menu.settings]
            elseif type(item.load_menu.settings) == "table" then
                for _, setting in ipairs(item.load_menu.settings --[[@as string[] ]]) do
                    settings_table = settings_table[setting]
                end
            end
            self:_get_menu_from_json(EHI.MenuPath .. item.load_menu.file_path, settings_table)
        end
        if item.next_menu and self._menus[item.next_menu] then
            self:OpenMenu(item.next_menu)
        elseif item.callback then
            self:CallCallback(item)
        end
    elseif item.type == "toggle" then
        self:SetItem(item, not item.value, self._open_menu)
    elseif item.type == "multiple_choice" and not self._open_choice_dialog then ---@cast item MenuMultipleChoicesItem 
        self:OpenMultipleChoicePanel(item)
    elseif item.type == "multiple_choice_slider" then ---@cast item MenuMultipleChoiceSliderItem
        local dialog_data = {
            title = managers.localization:text("ehi_colors_menu"),
            text = "",
            button_list = {}
        }
        for i, option in ipairs(item.items) do
            table.insert(dialog_data.button_list, {
                text = option,
                callback_func = function()
                    self:SetMultipleChoiceSlider(item, nil, i)
                end
            })
        end
        local divider = {
            no_text = true,
            no_selection = true
        }
        table.insert(dialog_data.button_list, divider)
        local no_button = {
            text = managers.localization:text("dialog_cancel"),
            cancel_button = true
        }
        table.insert(dialog_data.button_list, no_button)
        dialog_data.image_blend_mode = "normal"
        dialog_data.text_blend_mode = "add"
        dialog_data.use_text_formating = true
        dialog_data.w = 480
        dialog_data.h = 532
        dialog_data.title_font = tweak_data.menu.pd2_medium_font
        dialog_data.title_font_size = tweak_data.menu.pd2_medium_font_size
        dialog_data.font = tweak_data.menu.pd2_small_font
        dialog_data.font_size = tweak_data.menu.pd2_small_font_size
        dialog_data.text_formating_color = Color.white
        dialog_data.text_formating_color_table = {}
        dialog_data.clamp_to_screen = true
        self.__dialog_open = true
        managers.system_menu:show_buttons(dialog_data)
        local function close()
            self.__dialog_open = false
            managers.system_menu:remove_dialog_closed_callback(close) --- Needs to be removed as the callback handler is not cleared after calling
        end
        managers.system_menu:add_dialog_closed_callback(close)
    elseif item.type == "slider" and x then
        self._slider = item
        self:SetSlider(item, x)
        managers.mouse_pointer:set_pointer_image("grab")
    elseif item.type == "color_select" and not self._open_color_dialog then
        self:OpenColorMenu(item)
    end
end

---@param menu Menu
---@param parent_item_id string
---@param enabled boolean
function EHIMenu:SetMenuItemsEnabled(menu, parent_item_id, enabled)
    for _, item in ipairs(menu.items) do
        local parents = item.parent
        if item.parent_func_update then
            self[item.parent_func_update](self, menu, item)
        elseif parents then
            local e
            if type(parents) == "string" and parents == parent_item_id then
                e = enabled
            elseif type(parents) == "table" then
                e = true
                for _, parent in pairs(parents) do
                    for _, menu_item in ipairs(menu.items) do
                        if menu_item.id == parent and menu_item.value == false then
                            e = false
                            break
                        end
                    end
                end
            end
            self:AnimateItemEnabled(item, e)
        end
    end
end

function EHIMenu:GetMenu(menu)
    return self._menus[menu]
end

---@param item MenuItem
---@param enabled boolean
function EHIMenu:AnimateItemEnabled(item, enabled)
    if item.panel and enabled ~= nil and enabled ~= item.enabled then
        item.enabled = enabled
        item.panel:stop()
        item.panel:animate(animate_alpha, enabled and 1 or 0.5)
    end
end

---@param item MenuItem
function EHIMenu:HighlightItem(item)
    if self._highlighted_item and self._highlighted_item == item then
        return
    end
    local previous_had_preview_func = false
    if self._highlighted_item then
        previous_had_preview_func = self._highlighted_item.preview_func ~= nil
        self:UnhighlightItem(self._highlighted_item)
    end
    item.panel:child("bg"):stop()
    item.panel:child("bg"):animate(animate_alpha, 0.3)
    self._highlighted_item = item
    local item_has_preview_func = item.preview_func ~= nil

    self._tooltip:set_text(self._highlighted_item.desc or "")
    if item.blocked_by and self[item.blocked_by.check] and self[item.blocked_by.check](self) then
        local hint_block = self[item.blocked_by.hint](self)
        local blocked_by = managers.localization:text("ehi_item_blocked_by")
        self._tooltip:set_text(string.format("%s\n\n%s\n%s",
            self._highlighted_item.desc or "",
            blocked_by,
            hint_block
        ))
        local text_range = utf8.len(self._tooltip:text())
        self._tooltip:set_range_color(text_range - utf8.len(blocked_by) - utf8.len(hint_block) - 1, text_range, Color(255, 255, 106, 0) / 255)
    end
    if item.focus_changed_callback then
        self[item.focus_changed_callback](self, true, item.callback_arguments)
    end
    if previous_had_preview_func ~= item_has_preview_func then
        self:SetLegends(true, true, false, item_has_preview_func)
        if self._preview_button then
            self._preview_button:set_visible(item_has_preview_func)
        end
    end
end

---@param item MenuItem
function EHIMenu:UnhighlightItem(item)
    if item.focus_changed_callback then
        self[item.focus_changed_callback](self, false, "")
    end
    item.panel:child("bg"):stop()
    item.panel:child("bg"):animate(animate_alpha, 0)
    if item.blocked_by then
        self._tooltip:clear_range_color(0, math.huge)
    end
    self._highlighted_item = nil
end

---@param accept boolean
---@param reset boolean
---@param step boolean
---@param preview boolean
function EHIMenu:SetLegends(accept, reset, step, preview)
    if self._button_legends then
        local text = managers.localization:text("menu_legend_back", {BTN_BACK = managers.localization:btn_macro("back")})
        local separator = "    "
        if accept then text = managers.localization:text("menu_legend_select", {BTN_UPDATE = managers.localization:btn_macro("menu_update")}) .. separator .. text end
        if reset then text = managers.localization:to_upper_text("ehi_menu_reset_to_default", {BTN_RESET = managers.localization:btn_macro("menu_toggle_voice_message")}) .. separator .. text end
        if step then text = managers.localization:to_upper_text("ehi_menu_large_steps", {BTN_STEP = managers.localization:btn_macro("previous_page") .. managers.localization:btn_macro("next_page")}) .. separator .. text end
        if preview then text = managers.localization:to_upper_text("ehi_menu_preview", {BTN_PREVIEW = managers.localization:get_default_macro("BTN_Y")}) .. separator .. text end
        self._button_legends:set_text(text)
    end
end

function EHIMenu:Cancel()
    if self._open_choice_dialog then
        self:CloseMultipleChoicePanel()
    elseif self._open_color_dialog then
        self:CloseColorMenu()
    elseif self.__dialog_open then
        return
    elseif self._open_menu and self._open_menu.parent_menu then
        self:OpenMenu(self._open_menu.parent_menu, true)
    else
        self:Close()
    end
end

function EHIMenu:SetItem(item, value, menu)
    if item == nil or type(item) ~= "table" then
        item = self._highlighted_item
        value = item.default_value
        menu = self._open_menu
    end
    if item and type(item) == "table" and item.default_value ~= nil then
        if item.type == "toggle" then
            item.value = value
            item.panel:child("check"):stop()
            item.panel:child("check"):animate(function(o)
                local alpha = o:alpha()
                local w, h = o:size()
                local check = item.panel:child("check_bg") ---@cast check -?
                do_animation(0.1, function(p)
                    o:set_alpha(math.lerp(alpha, value and 1 or 0, p))
                    o:set_size(math.lerp(w, value and check:w() or check:w() * 2, p), math.lerp(h, value and check:h() or check:h() * 2, p))
                    o:set_center(check:center())
                end)
                o:set_alpha(value and 1 or 0)
            end)
        elseif item.type == "slider" then
            value = string.format("%." .. (item.step or 0) .. "f", value)
            local percentage = (value - item.min) / (item.max - item.min)
            item.panel:child("value_bar"):set_w(math.max(1,item.panel:w() * percentage))
            item.panel:child("value_text"):set_text(item.percentage and math.floor(value * 100).."%" or value .. (item.suffix or "")) ---@diagnostic disable-line
            value = tonumber(value)
            item.value = value
        elseif item.type == "multiple_choice" then
            item.panel:child("title_selected"):set_text(item.items[value]) ---@diagnostic disable-line
            item.value = value
        elseif item.type == "color_select" then
            self:CallCallback(item, { color_raw = value })
            value = Color(unpack(value)) / 255
            item.panel:child("color"):set_color(value) ---@diagnostic disable-line
            item.value = value
        end
        self:CallCallback(item, { to_n = item.type == "slider", skip_call = item.type == "color_select" })
        if item.is_parent then
            self:SetMenuItemsEnabled(menu, item.id, value)
        end
    end
end

function EHIMenu:Preview()
    local item = self._highlighted_item
    if type(item) == "table" and item.preview_func and self[item.preview_func] then
        self[item.preview_func](self, item.preview_func_params)
    end
end

---Menu Creation and activation
---@param path string
---@param settings_table table?
function EHIMenu:_get_menu_from_json(path, settings_table)
    local content = io.load_as_json(path)
    if content then
        settings_table = settings_table or EHI.settings

        local menu_title = managers.localization:text(content.title)
        local items = content.items

        if content.title == "ehi_mod_title" then
            menu_title = menu_title .. " r" .. self._menu_ver
        end

        local menu = self:_create_menu({
            menu_id = content.menu_id,
            parent_menu = content.parent_menu,
            title = menu_title,
            focus_changed_callback = content.focus_changed_callback,
        })

        for _, item in ipairs(items) do
            if item.vr then
                self:_create_item(_G.IS_VR and item.vr[1] or item.vr[2], menu, settings_table)
            elseif item.table then
                self:_create_one_line_items(item.table, menu, settings_table)
            else
                self:_create_item(item, menu, settings_table)
            end
        end
        menu.panel:set_h(content.h or menu.items[#menu.items].panel:bottom())
        if content.created_menu_callback then
            self[content.created_menu_callback](self, menu)
        end
    end
end

---@param item table
---@param menu Menu
---@param settings_table table
---@return MenuItem?
function EHIMenu:_create_item(item, menu, settings_table)
    local item_type = item.type
    local id = item.id
    local title = item.title
    local value = item.default_value
    local default_value = item.default_value
    local parents = item.parent
    local enabled = true
    local new = (item.ehi_ver or 1) > self._menu_ver

    if item.enabled ~= nil then
        enabled = item.enabled
    elseif item.parent_func then
        if self[item.parent_func] then
            enabled = self[item.parent_func](self)
        end
    elseif parents then
        if type(parents) == "string" then
            for _, pitem in ipairs(menu.items) do
                if pitem.id == parents then
                    enabled = pitem.value
                    break
                end
            end
        elseif type(parents) == "table" then
            for _, parent in ipairs(parents) do
                for _, pitem in ipairs(menu.items) do
                    if pitem.id == parent then
                        if not pitem.value then
                            enabled = false
                            break
                        end
                    end
                end
            end
        end
    end

    if item.value and settings_table[item.value] ~= nil then
        value = settings_table[item.value]
    end

    local desc = item.description and managers.localization:text(item.description) or ""
    if item.depends_on then
        local item_name = managers.localization:text(item.depends_on)
        local depends_on_string = managers.localization:text("ehi_item_depends_on", { option = item_name })
        if desc == "" then
            desc = depends_on_string
        else
            desc = string.format("%s\n\n%s", desc, depends_on_string)
        end
    end

    local itm
    if item_type == "label" then
        itm = self:CreateLabel(menu, {
            id = id,
            enabled = enabled,
            title = managers.localization:text(title),
            parent = item.parent,
            center = item.center,
            new = new
        })
    elseif item_type == "divider" then
        itm = self:CreateDivider(menu, { size = item.size })
    elseif item_type == "button" then
        itm = self:CreateButton(menu, {
            id = id,
            title = managers.localization:text(title),
            description = desc,
            next_menu = item.next_menu,
            callback = item.callback,
            callback_arguments = item.callback_arguments,
            enabled = enabled,
            parent = item.parent,
            focus_changed_callback = item.focus_changed_callback,
            new = new,
            load_menu = item.load_menu
        })
    elseif item_type == "toggle" then
        itm = self:CreateToggle(menu, {
            id = id,
            title = managers.localization:text(title),
            description = desc,
            value = value,
            default_value = default_value,
            is_parent = item.is_parent,
            enabled = enabled,
            parent = item.parent,
            callback = item.callback,
            callback_arguments = item.callback_arguments,
            focus_changed_callback = item.focus_changed_callback,
            parent_func_update = item.parent_func_update,
            preview_func = item.preview_func,
            preview_func_params = item.preview_func_params,
            blocked_by = item.blocked_by,
            new = new
        })
    elseif item_type == "slider" then
        itm = self:CreateSlider(menu, {
            id = id,
            title = managers.localization:text(title),
            description = desc,
            percentage = item.percentage,
            callback = item.callback,
            callback_arguments = item.callback_arguments,
            max = item.max,
            min = item.min,
            step = item.step,
            value = value,
            suffix = item.suffix,
            default_value = default_value,
            enabled = enabled,
            parent = item.parent,
            focus_changed_callback = item.focus_changed_callback,
            new = new
        })
    elseif item_type == "multiple_choice" then
        for k = 1, #item.items do
            item.items[k] = managers.localization:text(item.items[k])
        end

        itm = self:CreateMultipleChoice(menu, {
            id = id,
            title = managers.localization:text(title),
            description = desc,
            value = value,
            items = item.items,
            default_value = default_value,
            enabled = enabled,
            parent = item.parent,
            callback = item.callback,
            callback_arguments = item.callback_arguments,
            focus_changed_callback = item.focus_changed_callback,
            parent_func_update = item.parent_func_update,
            new = new
        })
    elseif item_type == "multiple_choice_slider" then
        for k = 1, #item.items do
            item.items[k] = managers.localization:text(item.items[k])
        end

        itm = self:CreateMultipleChoiceSlider(menu, {
            id = id,
            title = managers.localization:text(title),
            description = desc,
            value = value,
            items = item.items,
            default_value = default_value,
            enabled = enabled,
            parent = item.parent,
            callback = item.callback,
            callback_arguments = item.callback_arguments,
            new = new
        })
    elseif item_type == "color_select" then
        local stored_value = EHI.settings
        if item.setting_value and item.setting_value == "colors" then
            if item.color_type then
                stored_value = EHI.settings.colors[item.color_type]
            else
                stored_value = EHI.settings.colors
            end
        end
        value = EHI:GetColor(stored_value[item.value])
        itm = self:CreateColorSelect(menu, {
            id = id,
            title = managers.localization:text(title),
            description = desc,
            value = value,
            default_value = default_value,
            enabled = enabled,
            parent = item.parent,
            callback = item.callback,
            callback_arguments = item.callback_arguments,
            texture = item.texture,
            new = new
        })
    end

    return itm
end

---@param item_table table
---@param menu Menu
---@param settings_table table
function EHIMenu:_create_one_line_items(item_table, menu, settings_table)
    local n = table.size(item_table)
    local previous_item
    for _, v in ipairs(item_table) do
        local item = self:_create_item(v, menu, settings_table)
        if item then
            item.panel:set_w(item.panel:w() / n)
            local item_title = item.panel:child("title") --[[@as Text?]]
            if item_title then
                item_title:set_w(item.panel:w() - (self._item_offset[item.type] or 0))
                self._adjust_font_size(item_title)
            end
            if previous_item then
                item.panel:set_left(previous_item.panel:right())
                item.panel:set_y(previous_item.panel:y())
                menu.len = (menu.len or 50) - (item.panel:h() + 1)
            end
        end
        previous_item = item
    end
end

---@param params table
---@return Menu
function EHIMenu:_create_menu(params)
    if self._menus[params.menu_id] then
        return self._menus[params.menu_id]
    end

    local menu_panel = self._options_panel:panel({
        x = self._options_panel:w(),
        w = self._options_panel:w(),
        h = self._options_panel:h(),
        layer = 1,
        visible = false
    })
    local title = menu_panel:text({
        name = "title",
        font_size = 45,
        font = tweak_data.menu.pd2_large_font,
        text = params.title,
        vertical = "center"
    })
    self:make_fine_text(title)
    if title:w() > menu_panel:w() - 5 then
        local menu_w = menu_panel:w() - 5
        title:set_font_size(title:font_size() * (menu_w/title:w()))
        title:set_w(title:w() * (menu_w/title:w()))
    end
    title:set_right(menu_panel:w() - 5)
    local menu = { panel = menu_panel, parent_menu = params.parent_menu, items = {}, focus_changed_callback = params.focus_changed_callback }
    self._menus[params.menu_id] = menu
    return menu
end

---@param menu string
---@param close boolean?
function EHIMenu:OpenMenu(menu, close)
    local next_menu = self._menus[menu]
    if not next_menu then
        return
    end
    local prev_menu = self._open_menu
    if prev_menu and prev_menu.focus_changed_callback then
        self[prev_menu.focus_changed_callback](self, false, prev_menu.id, menu) -- Ugly focus callback
    end
    if next_menu.focus_changed_callback then
        self[next_menu.focus_changed_callback](self, true, prev_menu.id, "") -- Ugly focus callback
    end
    self._tooltip:set_text("")
    if prev_menu then
        prev_menu.panel:stop()
    end
    next_menu.panel:stop()
    next_menu.panel:animate(function(o)
        local x = next_menu.panel:x()
        local prev_x
        if prev_menu then
            prev_x = prev_menu.panel:x()
        end
        next_menu.panel:set_visible(true)

        do_animation(0.1, function(p)
            next_menu.panel:set_x(math.lerp(x, 0, p))
            if prev_menu then
                prev_menu.panel:set_x(math.lerp(prev_x, close and prev_menu.panel:w() or -prev_menu.panel:w(), p))
            end
        end)

        next_menu.panel:set_x(0)
        local opened
        if prev_menu then
            prev_menu.panel:set_visible(false)
            prev_menu.panel:set_x(close and prev_menu.panel:w() or -prev_menu.panel:w())
            opened = self._open_menu.id
        end
        self._open_menu = next_menu
        self._open_menu.id = menu

        if close and opened ~= nil then
            for _, item in ipairs(self._open_menu.items) do
                if item.panel and item.panel:child("bg") and item.id == opened then
                    self:HighlightItem(item)
                end
            end
        else
            for _, item in ipairs(self._open_menu.items) do
                if item.panel and item.enabled and item.panel:child("bg") then
                    self:HighlightItem(item)
                    return
                end
            end
        end
    end)
end

---@param menu Menu
---@param item MenuItem
---@param total_size number?
function EHIMenu:AddItemToMenu(menu, item, total_size)
    table.insert(menu.items, item)
    if total_size then
        menu.len = (menu.len or 50) + total_size
    else
        menu.len = (menu.len or 50) + (item.panel and item.panel:h() or (item.size or 25)) + 1
    end
end

---@param menu Menu
function EHIMenu:GetLastPosInMenu(menu)
    return menu.len or 50
end

--Label Items
---@param menu Menu
---@param params table
---@return MenuItem
function EHIMenu:CreateLabel(menu, params)
    local label_panel = menu.panel:panel({
        y = self:GetLastPosInMenu(menu),
        h = 25,
        layer = 2,
        alpha = params.enabled and 1 or 0.5
    })
    local title = label_panel:text({
        name = "title",
        font_size = 23,
        font = tweak_data.menu.pd2_large_font,
        text = utf8.to_upper(params.title) or "",
        color = params.new and Color.yellow or Color(0.7, 0.7, 0.7),
        w = label_panel:w(),
        align = params.center and "center" or "right",
        vertical = "center",
        layer = 1
    })
    self._adjust_font_size(title)
    local label = {
        panel = label_panel,
        id = params.id or tostring(#menu.items),
        enabled = params.enabled,
        parent = params.parent,
        type = "label",
        num = #menu.items
    }
    self:AddItemToMenu(menu, label)
    return label
end

--Divider Items
---@param menu Menu
---@param params table
---@return MenuItem
function EHIMenu:CreateDivider(menu, params)
    local div = {
        id = "",
        type = "divider",
        num = #menu.items,
        size = params.size
    }
    self:AddItemToMenu(menu, div)
    return div
end

--Button Items
---@param menu Menu
---@param params table
---@return MenuItem
function EHIMenu:CreateButton(menu, params)
    local button_panel = menu.panel:panel({
        y = self:GetLastPosInMenu(menu),
        h = 25,
        layer = 2,
        alpha = params.enabled and 1 or 0.5
    })
    local button_bg = button_panel:bitmap({
        name = "bg",
        alpha = 0,
    })
    local title = button_panel:text({
        name = "title",
        font_size = 20,
        font = tweak_data.menu.pd2_large_font,
        text = params.title or "",
        x = 5,
        w = button_panel:w() - 10,
        align = "right",
        vertical = "center",
        layer = 1,
        color = params.new and Color.yellow or Color.white
    })
    self._adjust_font_size(title)
    local button = {
        panel = button_panel,
        id = params.id,
        type = "button",
        enabled = params.enabled,
        parent = params.parent,
        desc = params.description,
        next_menu = params.next_menu,
        callback = params.next_menu and nil or params.callback,
        callback_arguments = params.callback_arguments,
        num = #menu.items,
        focus_changed_callback = params.focus_changed_callback,
        load_menu = params.load_menu
    }
    self:AddItemToMenu(menu, button)
    return button
end

--Toggle Items
---@param menu Menu
---@param params table
---@return MenuItem
function EHIMenu:CreateToggle(menu, params)
    local color = params.new and Color.yellow or Color.white
    local toggle_panel = menu.panel:panel({
        y = self:GetLastPosInMenu(menu),
        h = 25,
        layer = 2,
        alpha = params.enabled and 1 or 0.5
    })
    local toggle_bg = toggle_panel:bitmap({
        name = "bg",
        alpha = 0,
    })
    local title = toggle_panel:text({
        name = "title",
        font_size = 20,
        font = tweak_data.menu.pd2_large_font,
        text = params.title or "",
        x = 29,
        w = toggle_panel:w() - 34,
        align = "right",
        vertical = "center",
        layer = 1,
        color = color
    })
    self._adjust_font_size(title)
    local check_bg = toggle_panel:bitmap({
        name = "check_bg",
        texture = "guis/textures/pd2_mod_ehi/menu_atlas",
        texture_rect = { 0, 150, 40, 41 },
        x = 2,
        y = 2,
        w = 22,
        h = 21,
        layer = 1,
        color = color
    })
    local check = toggle_panel:bitmap({
        name = "check",
        texture = "guis/textures/pd2_mod_ehi/menu_atlas",
        texture_rect = { 40, 150, 40, 41 },
        x = 2,
        y = 2,
        w = params.value and 22 or 44,
        h = params.value and 21 or 42,
        alpha = params.value and 1 or 0,
        layer = 2,
        color = color
    })
    check:set_center(check_bg:center())
    local toggle = {
        panel = toggle_panel,
        type = "toggle",
        id = params.id,
        enabled = params.enabled,
        value = params.value,
        default_value = params.default_value,
        parent = params.parent,
        is_parent = params.is_parent,
        desc = params.description,
        num = #menu.items,
        callback = params.callback,
        callback_arguments = params.callback_arguments,
        focus_changed_callback = params.focus_changed_callback,
        parent_func_update = params.parent_func_update,
        preview_func = params.preview_func,
        preview_func_params = params.preview_func_params,
        blocked_by = params.blocked_by
    }
    self:AddItemToMenu(menu, toggle)
    return toggle
end

--Slider Items
---@param menu Menu
---@param params table
---@return MenuItem
function EHIMenu:CreateSlider(menu, params)
    local color = params.new and Color.yellow or Color.white
    local percentage = (params.value - params.min) / (params.max - params.min)
    local slider_panel = menu.panel:panel({
        y = self:GetLastPosInMenu(menu),
        h = 25,
        layer = 2,
        alpha = params.enabled and 1 or 0.5
    })
    slider_panel:bitmap({
        name = "bg",
        alpha = 0,
    })
    local value_bar = slider_panel:bitmap({
        name = "value_bar",
        alpha = 0.2,
        w = math.max(1, slider_panel:w() * percentage)
    })
    local t
    if params.value then
        if params.percentage then
            t = (params.value * 100) .. "%"
        else
            t = string.format("%." .. (params.step or 0) .. "f", params.value)
        end
    else
        t = ""
    end
    if params.suffix then
        t = t .. params.suffix
    end
    local value_text = slider_panel:text({
        name = "value_text",
        font_size = 20,
        font = tweak_data.menu.pd2_large_font,
        text = t,
        x = 5,
        w = 100,
        align = "left",
        vertical = "center",
        layer = 2,
        color = color
    })
    local title = slider_panel:text({
        name = "title",
        font_size = 20,
        font = tweak_data.menu.pd2_large_font,
        text = params.title or "",
        x = 105,
        w = slider_panel:w() - 110,
        align = "right",
        vertical = "center",
        layer = 2,
        color = color
    })
    self._adjust_font_size(title)
    local slider = {
        panel = slider_panel,
        id = params.id,
        type = "slider",
        enabled = params.enabled,
        value = params.value,
        default_value = params.default_value,
        percentage = params.percentage,
        callback = params.callback,
        callback_arguments = params.callback_arguments,
        max = params.max,
        min = params.min,
        step = params.step,
        parent = params.parent,
        desc = params.description,
        suffix = params.suffix,
        num = #menu.items,
        focus_changed_callback = params.focus_changed_callback
    }
    self:AddItemToMenu(menu, slider)
    return slider
end

function EHIMenu:SetSlider(item, x, add)
    local panel_min, panel_max = item.panel:world_x(), item.panel:world_x() + item.panel:w()
    x = math.clamp(x, panel_min, panel_max)
    local value_bar = item.panel:child("value_bar")
    local value_text = item.panel:child("value_text")
    local percentage
    if add then
        local step = 1 / (10^item.step)
        local new_value = math.clamp(item.value + (add * step), item.min, item.max)
        percentage = (new_value - item.min) / (item.max - item.min)
    else
        percentage = (x - panel_min) / (panel_max - panel_min)
    end
    if percentage then
        local value = string.format("%." .. (item.step or 0) .. "f", item.min + (item.max - item.min) * percentage)
        value_bar:set_w(math.max(1,item.panel:w() * percentage))
        value_text:set_text(item.percentage and math.floor(value * 100).."%" or value .. (item.suffix or ""))
        item.value = value
    end
end

--Multiple Choice Items
---@param menu Menu
---@param params table
---@return MenuMultipleChoicesItem
function EHIMenu:CreateMultipleChoice(menu, params)
    local multiple_panel = menu.panel:panel({
        y = self:GetLastPosInMenu(menu),
        h = 25,
        layer = 2,
        alpha = params.enabled and 1 or 0.5
    })
    local multiple_bg = multiple_panel:bitmap({
        name = "bg",
        alpha = 0,
    })
    local title = multiple_panel:text({
        name = "title",
        font_size = 20,
        font = tweak_data.menu.pd2_large_font,
        text = params.title or "",
        x = 210,
        w = multiple_panel:w() - 215,
        align = "right",
        vertical = "center",
        layer = 1,
        color = params.new and Color.yellow or Color.white
    })
    self._adjust_font_size(title)
    local title_selected = multiple_panel:text({
        name = "title_selected",
        font_size = 20,
        font = tweak_data.menu.pd2_large_font,
        text = params.items[params.value],
        x = 5,
        w = 200,
        align = "left",
        vertical = "center",
        layer = 1
    })
    local multiple_choice = {
        panel = multiple_panel,
        id = params.id,
        type = "multiple_choice",
        enabled = params.enabled,
        items = params.items,
        value = params.value,
        default_value = params.default_value,
        parent = params.parent,
        desc = params.description,
        num = #menu.items,
        callback = params.callback,
        callback_arguments = params.callback_arguments,
        focus_changed_callback = params.focus_changed_callback,
        parent_func_update = params.parent_func_update,
    }
    self:AddItemToMenu(menu, multiple_choice)
    return multiple_choice
end

---@param item MenuMultipleChoicesItem
function EHIMenu:OpenMultipleChoicePanel(item)
    local choice_dialog = item.panel:parent():panel({
        x = item.panel:x(),
        y = item.panel:bottom(),
        w = item.panel:w(),
        h = 4 + (#item.items * 25),
        alpha = 0,
        layer = 20,
        rotation = 360,
    })
    if choice_dialog:bottom() > self._options_panel:h() then
        choice_dialog:set_bottom(item.panel:top())
    end
    local border = choice_dialog:bitmap({
        name = "border",
        alpha = 0.3,
        layer = 1,
        h = 0,
        rotation = 360,
    })
    choice_dialog:bitmap({
        name = "blur_bg",
        texture = "guis/textures/test_blur_df",
        render_template = "VertexColorTexturedBlur3D",
        y = 3,
        w = choice_dialog:w(),
        h = choice_dialog:h(),
        layer = 0,
        rotation = 360
    })
    local bg = choice_dialog:bitmap({
        name = "bg",
        alpha = 0.7,
        color = Color.black,
        layer = 2,
        x = 2,
        y = 2,
        w = choice_dialog:w() - 4,
        h = choice_dialog:h() - 4,
        rotation = 360
    })
    self._open_choice_dialog = { parent_item = item, panel = choice_dialog, selected = item.value, items = {} }
    for i, choice in ipairs(item.items) do
        local title = choice_dialog:text({
            name = "title",
            font_size = 18,
            font = tweak_data.menu.pd2_large_font,
            text = choice,
            x = 10,
            y = 2 + (i - 1) * 25,
            w = choice_dialog:w() - 10,
            h = 25,
            color = item.value == i and Color.white or Color(0.6, 0.6, 0.6),
            vertical = "center",
            layer = 3,
            rotation = 360
        })
        self._adjust_font_size(title)
        self._open_choice_dialog.items[i] = title
    end
    choice_dialog:animate(function(o)
        local h = o:h()
        do_animation(0.1, function(p)
            o:set_alpha(math.lerp(0, 1, p))
            border:set_h(math.lerp(0, h, p))
            bg:set_h(border:h() - 4)
        end)
        o:set_alpha(1)
        border:set_h(h)
        bg:set_h(border:h() - 4)
    end)
    self:SetLegends(true, false, false, false)
end

function EHIMenu:CloseMultipleChoicePanel()
    self:SetItem(self._open_choice_dialog.parent_item, self._open_choice_dialog.parent_item.value)
    self._open_choice_dialog.panel:stop()
    self._open_choice_dialog.panel:animate(function(o) ---@param o Panel
        local h = o:h()
        local alpha = o:alpha()
        local border = o:child("border") ---@cast border -?
        local bg = o:child("bg") ---@cast bg -?
        do_animation(0.1, function(p)
            o:set_alpha(math.lerp(alpha, 0, p))
            border:set_h(math.lerp(h, 0, p))
            bg:set_h(border:h() - 4)
        end)
        o:set_alpha(0)
        border:set_h(h)
        bg:set_h(border:h() - 4)
        self._open_choice_dialog.parent_item.panel:parent():remove(o)
        self._open_choice_dialog = nil
    end)
    self:SetLegends(true, true, false, false)
end

---@param menu Menu
---@param params table
---@return MenuMultipleChoiceSliderItem
function EHIMenu:CreateMultipleChoiceSlider(menu, params)
    local value = params.value
    local max = #params.items
    local multiple_panel = menu.panel:panel({
        y = self:GetLastPosInMenu(menu),
        h = 25,
        layer = 2,
        alpha = params.enabled and 1 or 0.5
    })
    local multiple_bg = multiple_panel:bitmap({
        name = "bg",
        alpha = 0,
    })
    local title = multiple_panel:text({
        name = "title",
        font_size = 20,
        font = tweak_data.menu.pd2_large_font,
        text = params.title or "",
        x = 210,
        w = multiple_panel:w() - 215,
        align = "right",
        vertical = "center",
        layer = 1,
        color = params.new and Color.yellow or Color.white
    })
    self._adjust_font_size(title)
    local left_arrow = multiple_panel:bitmap({
        name = "left_arrow",
        texture = "guis/textures/menu_arrows",
        y = 1,
		x = 5,
        layer = 3,
        texture_rect = { value == 1 and 0 or 24, 0, 24, 24 },
        color = value == 1 and tweak_data.screen_colors.button_stage_3 or tweak_data.screen_colors.button_stage_2
    })
    local right_arrow = multiple_panel:bitmap({
        name = "right_arrow",
        texture = "guis/textures/menu_arrows",
        y = 1,
		x = 172,
        layer = 3,
        rotation = 180,
        texture_rect = { value == max and 0 or 24, 0, 24, 24 },
        color = value == max and tweak_data.screen_colors.button_stage_3 or tweak_data.screen_colors.button_stage_2
    })
    multiple_panel:text({
        name = "title_selected",
        font_size = 20,
        font = tweak_data.menu.pd2_large_font,
        text = params.items[value],
        x = left_arrow:right(),
        w = right_arrow:x() - left_arrow:x() - left_arrow:w(),
        align = "center",
        vertical = "center",
        layer = 1
    })
    local multiple_choice = {
        panel = multiple_panel,
        id = params.id,
        type = "multiple_choice_slider",
        enabled = params.enabled,
        items = params.items,
        value = value,
        default_value = params.default_value,
        max = max,
        parent = params.parent,
        desc = params.description,
        num = #menu.items,
        callback = params.callback,
        callback_arguments = params.callback_arguments,
        focus_changed_callback = params.focus_changed_callback
    }
    self:AddItemToMenu(menu, multiple_choice)
    return multiple_choice
end

---@param item MenuMultipleChoiceSliderItem
---@param change number
---@param set_value number?
---@overload fun(self: EHIMenu, item: MenuMultipleChoiceSliderItem, change: nil, set_value: number)
function EHIMenu:SetMultipleChoiceSlider(item, change, set_value)
    if set_value then
        item.value = set_value
        self:UpdateBuffColor(set_value, nil, item.id)
        self:CallCallback(item)
    elseif change > 0 then
        local value = item.value + 1
        if value > item.max then -- Do not allow saving value higher than max; will result in a crash
            return
        end
        item.value = value
        self:UpdateBuffColor(value, nil, item.id)
        self:CallCallback(item)
    elseif change < 0 then
        local value = item.value - 1
        if value < 1 then -- Do not allow saving value lower than 1 (our minimum); will result in a crash
            return
        end
        item.value = value
        self:UpdateBuffColor(value, nil, item.id)
        self:CallCallback(item)
    end
    self:UpdateArrorsInMultiChoiceSlider(item)
end

---@param item MenuMultipleChoiceSliderItem
function EHIMenu:UpdateArrorsInMultiChoiceSlider(item)
    if item.value == 1 then
        item.panel:child("left_arrow"):set_image("guis/textures/menu_arrows", 0, 0, 24, 24) ---@diagnostic disable-line
        item.panel:child("left_arrow"):set_color(tweak_data.screen_colors.button_stage_3) ---@diagnostic disable-line
        item.panel:child("right_arrow"):set_image("guis/textures/menu_arrows", 24, 0, 24, 24) ---@diagnostic disable-line
        item.panel:child("right_arrow"):set_color(tweak_data.screen_colors.button_stage_2) ---@diagnostic disable-line
    elseif item.value == item.max then
        item.panel:child("left_arrow"):set_image("guis/textures/menu_arrows", 24, 0, 24, 24) ---@diagnostic disable-line
        item.panel:child("left_arrow"):set_color(tweak_data.screen_colors.button_stage_2) ---@diagnostic disable-line
        item.panel:child("right_arrow"):set_image("guis/textures/menu_arrows", 0, 0, 24, 24) ---@diagnostic disable-line
        item.panel:child("right_arrow"):set_color(tweak_data.screen_colors.button_stage_3) ---@diagnostic disable-line
    else
        item.panel:child("left_arrow"):set_image("guis/textures/menu_arrows", 24, 0, 24, 24) ---@diagnostic disable-line
        item.panel:child("left_arrow"):set_color(tweak_data.screen_colors.button_stage_2) ---@diagnostic disable-line
        item.panel:child("right_arrow"):set_image("guis/textures/menu_arrows", 24, 0, 24, 24) ---@diagnostic disable-line
        item.panel:child("right_arrow"):set_color(tweak_data.screen_colors.button_stage_2) ---@diagnostic disable-line
    end
end

-- Custom Color Items
---@param menu Menu
---@param params table
---@return MenuItem
function EHIMenu:CreateColorSelect(menu, params)
    local color_panel = menu.panel:panel({
        y = self:GetLastPosInMenu(menu),
        h = 25,
        layer = 2,
        alpha = params.enabled and 1 or 0.5
    })
    color_panel:bitmap({
        name = "bg",
        alpha = 0,
    })
    local title = color_panel:text({
        name = "title",
        font_size = 20,
        font = tweak_data.menu.pd2_large_font,
        text = params.title or "",
        x = 59,
        w = color_panel:w() - 64,
        align = "right",
        vertical = "center",
        layer = 1
    })
    self._adjust_font_size(title)
    color_panel:bitmap({
        name = "color_border",
        x = 3,
        y = 3,
        w = 51,
        h = 19,
        layer = 1
    })
    color_panel:bitmap({
        name = "color",
        x = 4,
        y = 4,
        w = 49,
        h = 17,
        color = params.value,
        layer = 2
    })
    local color = {
        panel = color_panel,
        id = params.id,
        type = "color_select",
        enabled = params.enabled,
        value = params.value,
        default_value = params.default_value,
        parent = params.parent,
        desc = params.description,
        num = #menu.items,
        callback = params.callback,
        callback_arguments = params.callback_arguments
    }

    self:AddItemToMenu(menu, color)

    return color
end

---@param item MenuItem
function EHIMenu:OpenColorMenu(item)
    local item_panel = item.panel
    local dialog = item_panel:parent():panel({
        x = item_panel:x(),
        y = item_panel:bottom(),
        w = item_panel:w(),
        h = 141,
        layer = 20,
        alpha = 0
    })
    if dialog:bottom() > item_panel:parent():h() then
        dialog:set_bottom(item_panel:top())
    end
    local border = dialog:bitmap({
        name = "border",
        alpha = 0.3,
        layer = 1,
        h = 0
    })
    dialog:bitmap({
        name = "blur_bg",
        texture = "guis/textures/test_blur_df",
        render_template = "VertexColorTexturedBlur3D",
        y = 3,
        w = dialog:w(),
        h = dialog:h(),
        layer = 0,
    })
    local bg = dialog:bitmap({
        name = "bg",
        alpha = 0.7,
        color = Color.black,
        layer = 2,
        x = 2,
        y = 2,
        w = dialog:w() - 4,
        h = 0,
    })
    local color = item.value
    local red_panel = dialog:panel({
        name = "red_panel",
        x = 5,
        y = 5,
        w = dialog:w() - 10,
        h = 25,
        layer = 3
    })
    local red_slider = red_panel:bitmap({
        name = "slider",
        alpha = 0.3,
        layer = 2,
        w = math.max(1, red_panel:w() * (color.red / 1)),
        color = Color(color.red, 0, 0)
    })
    red_panel:bitmap({
        name = "bg",
        alpha = 0.1,
    })
    red_panel:text({
        name = "title",
        font_size = 18,
        font = tweak_data.menu.pd2_large_font,
        text = managers.localization:text("ehi_buffs_group_color_red"),
        x = 85,
        w = red_panel:w() - 90,
        h = 25,
        align = "right",
        vertical = "center",
        layer = 3
    })
    red_panel:text({
        name = "value",
        font_size = 18,
        font = tweak_data.menu.pd2_large_font,
        text = string.format("%.0f", color.red * 255),
        x = 5,
        w = 80,
        h = 25,
        vertical = "center",
        layer = 3
    })
    local green_panel = dialog:panel({
        name = "green_panel",
        x = 5,
        y = 32,
        w = dialog:w() - 10,
        h = 25,
        layer = 3
    })
    local green_slider = green_panel:bitmap({
        name = "slider",
        alpha = 0.3,
        layer = 2,
        w =  math.max(1, green_panel:w() * (color.green / 1)),
        color = Color(0, color.green, 0)
    })
    green_panel:bitmap({
        name = "bg",
        alpha = 0,
    })
    green_panel:text({
        name = "title",
        font_size = 18,
        font = tweak_data.menu.pd2_large_font,
        text = managers.localization:text("ehi_buffs_group_color_green"),
        x = 85,
        w = red_panel:w() - 90,
        h = 25,
        align = "right",
        vertical = "center",
        layer = 3
    })
    green_panel:text({
        name = "value",
        font_size = 18,
        font = tweak_data.menu.pd2_large_font,
        text = string.format("%.0f", color.green * 255),
        x = 5,
        w = 80,
        h = 25,
        vertical = "center",
        layer = 3
    })
    local blue_panel = dialog:panel({
        name = "blue_panel",
        x = 5,
        y = 59,
        w = dialog:w() - 10,
        h = 25,
        layer = 3
    })
    local blue_slider = blue_panel:bitmap({
        name = "slider",
        alpha = 0.3,
        layer = 2,
        w = math.max(1, blue_panel:w() * (color.blue / 1)),
        color = Color(0, 0, color.blue)
    })
    blue_panel:bitmap({
        name = "bg",
        alpha = 0,
    })
    blue_panel:text({
        name = "title",
        font_size = 18,
        font = tweak_data.menu.pd2_large_font,
        text = managers.localization:text("ehi_buffs_group_color_blue"),
        x = 85,
        w = red_panel:w() - 90,
        h = 25,
        align = "right",
        vertical = "center",
        layer = 3
    })
    blue_panel:text({
        name = "value",
        font_size = 18,
        font = tweak_data.menu.pd2_large_font,
        text = string.format("%.0f", color.blue * 255),
        x = 5,
        w = 80,
        h = 25,
        vertical = "center",
        layer = 3
    })
    local accept_panel = dialog:panel({
        name = "accept_panel",
        x = 5,
        y = 85,
        w = dialog:w() - 10,
        h = 25,
        layer = 3
    })
    accept_panel:bitmap({
        name = "bg",
        alpha = 0,
    })
    accept_panel:text({
        name = "title",
        font_size = 18,
        font = tweak_data.menu.pd2_large_font,
        text = managers.localization:text("ehi_button_ok"),
        x = 5,
        w = red_panel:w() - 10,
        h = 25,
        align = "right",
        vertical = "center",
        layer = 3,
    })
    local reset_panel = dialog:panel({
        name = "reset_panel",
        x = 5,
        y = 112,
        w = dialog:w() - 10,
        h = 25,
        layer = 3
    })
    reset_panel:bitmap({
        name = "bg",
        alpha = 0
    })
    reset_panel:text({
        name = "title",
        font_size = 18,
        font = tweak_data.menu.pd2_large_font,
        text = managers.localization:text("ehi_color_reset"),
        x = 5,
        w = red_panel:w() - 10,
        h = 25,
        align = "right",
        vertical = "center",
        layer = 3
    })

    self._open_color_dialog = {
        parent_item = item,
        panel = dialog,
        color = item.value,
        selected = 1,
        items = {
            red_panel,
            green_panel,
            blue_panel,
            accept_panel,
            reset_panel
        }
    }

    dialog:animate(function(o)
        local h = o:h()
        do_animation(0.1, function(p)
            o:set_alpha(math.lerp(0, 1, p))
            border:set_h(math.lerp(0, h, p))
            bg:set_h(border:h() - 4)
        end)
        o:set_alpha(1)
        border:set_h(h)
        bg:set_h(border:h() - 4)
    end)
    self:SetLegends(false, false, true, false)
end

---@param item Panel
---@param x number?
---@param type number
---@param add number?
function EHIMenu:SetColorSlider(item, x, type, add)
    local panel_min, panel_max = item:world_x(), item:world_x() + item:w()
    x = math.clamp(x, panel_min, panel_max)
    local value_bar = item:child("slider") --[[@as Bitmap]]
    local value_text = item:child("value") --[[@as Text]]
    local percentage = (math.clamp(value_text:text() + (add or 0), 0, 255) - 0) / 255
    if not add then
        percentage = (x - panel_min) / (panel_max - panel_min)
    end
    local value = string.format("%.0f", 0 + (255 - 0) * percentage) --[[@as number]]
    value_bar:set_w(math.max(1, item:w() * percentage))
    value_bar:set_color(Color(255, type == 1 and value or 0, type == 2 and value or 0, type == 3 and value or 0) / 255)
    value_text:set_text(value) ---@diagnostic disable-line
    local color = self._open_color_dialog.color
    self._open_color_dialog.color = Color(type == 1 and value / 255 or color.red, type == 2 and value / 255 or color.green, type == 3 and value / 255 or color.blue)
    self._open_color_dialog.parent_item.panel:child("color"):set_color(self._open_color_dialog.color) ---@diagnostic disable-line
end

function EHIMenu:CloseColorMenu()
    self._open_color_dialog.panel:stop()
    self._open_color_dialog.panel:animate(function(o) ---@param o Panel
        local h = o:h()
        local alpha = o:alpha()
        local border = o:child("border") ---@cast border -?
        local bg = o:child("bg") ---@cast bg -?
        do_animation(0.1, function(p)
            o:set_alpha(math.lerp(alpha, 0, p))
            border:set_h(math.lerp(h, 0, p))
            bg:set_h(border:h() - 4)
        end)
        o:set_alpha(0)
        border:set_h(h)
        bg:set_h(border:h() - 4)
        self:CallCallback(self._open_color_dialog.parent_item, { color = true, color_panels = self._open_color_dialog.items })
        self._open_color_dialog.parent_item.panel:parent():remove(o)
        local c = self._open_color_dialog.color
        self._open_color_dialog.parent_item.value = c
        self._open_color_dialog.parent_item.panel:child("color"):set_color(c) ---@diagnostic disable-line
        self._open_color_dialog = nil
    end)
    self:SetLegends(true, true, false, false)
end

function EHIMenu:ResetColorMenu()
    local item = self._open_color_dialog
    local c = item.parent_item.default_value
    local colors_to_table = { red = 1, green = 2, blue = 3 }
    local color_panel
    for _, v in ipairs(item.items) do
        color_panel = v:name():gsub("_panel", "")
        local number = colors_to_table[color_panel]
        if number then
            local world_x = v:world_x()
            self:SetColorSlider(v, math.lerp(world_x, world_x + v:w(), c[number] / 255), number)
        end
    end
end

function EHIMenu:IsSharedMenuEnabled()
    return EHI:GetTrackerOrWaypointOption("show_mission_trackers", "show_waypoints_mission")
end

function EHIMenu:GetXPEnabledValue()
    return EHI:GetOption("show_gained_xp")
end

function EHIMenu:UpdateXPDiffEnabled(menu, item)
    local enabled = self:GetXPEnabledValue() and EHI:GetOption("xp_panel") == 2
    local items =
    {
        ehi_total_xp_difference_choice = true
    }
    for _, m_item in ipairs(menu.items) do
        if items[m_item.id or ""] then
            self:AnimateItemEnabled(m_item, enabled)
        end
    end
end

function EHIMenu:IsAssaultTrackerEnabled()
    return EHI:GetOption("show_assault_delay_tracker") or EHI:GetOption("show_assault_time_tracker")
end

function EHIMenu:UpdateAssaultOptions(menu, item)
    local enabled = self:IsAssaultTrackerEnabled()
    local items =
    {
        ehi_show_assault_diff_in_assault_trackers_choice = true,
        ehi_show_assault_enemy_count_choice = true
    }
    for _, m_item in ipairs(menu.items) do
        if items[m_item.id or ""] then
            self:AnimateItemEnabled(m_item, enabled)
        end
    end
end

function EHIMenu:IsFloatingHealthBarPocoBlurVisible()
    return EHI:GetOption("show_floating_health_bar_style") == 1
end

function EHIMenu:UpdateFloatingHealthBarPocoBlurOption(value, option)
    for _, m_item in ipairs(self:GetMenu("ehi_other_floating_health_bar_menu").items) do
        if m_item.id == "ehi_other_show_floating_health_bar_style_poco_blur_choice" then
            self:AnimateItemEnabled(m_item, value == 1)
            break
        end
    end
end

function EHIMenu:IsXOffsetAvailable()
    return EHI:GetOption("buffs_alignment") ~= 2 -- Not Center alignment
end

------------------------------------------------------------------
function EHIMenu:UpdatePreviewTextVisibility(value)
    self._preview_panel:UpdatePreviewTextVisibility(value)
end

function EHIMenu:SetOption(value, option)
    EHI.settings[option] = value
end

function EHIMenu:SetUnlockableOption(value, option)
    EHI.settings.unlockables[option] = value
end

function EHIMenu:SetBuffOption(value, option)
    EHI.settings.buff_option[option] = value
end

function EHIMenu:SetBuffDeckOption(value, deck, option)
    EHI.settings.buff_option[deck][option] = value
end

function EHIMenu:UpdateTrackerPreviewVisibility(visibility)
    self._preview_panel:UpdateTrackerPreview(visibility)
end

function EHIMenu:UpdateTrackerState(value, option)
    self._preview_panel:UpdateTrackerState(value)
end

function EHIMenu:SetXPPanelOption(value, option)
    self._preview_panel:UpdateTracker("show_gained_xp", value <= 2)
end

function EHIMenu:UpdateTradeDelayFormat(value)
    self._preview_panel:UpdateTrackerInternalFormat("killed_civilians", "show_trade_delay", value)
end

function EHIMenu:SetGagePanelOption(value, option)
    self._preview_panel:UpdateTracker("show_gage_tracker", value == 1)
end

function EHIMenu:UpdateCivilianPanelOption(value)
    self._preview_panel:UpdateTrackerInternalFormat("civilian_count", "show_civilian_count_tracker", value)
end

function EHIMenu:UpdateHostagePanelOption(value)
    self._preview_panel:UpdateTrackerInternalFormat("hostage_count", "show_hostage_count_tracker", value)
end

function EHIMenu:UpdateAssaultTracker(value)
    self._preview_panel:CallFunction("assault", "UpdateInternalFormat", value, true)
    self._preview_panel:CallFunction("show_assault_delay_tracker", "UpdateInternalFormat", value, true)
    self._preview_panel:CallFunction("show_assault_time_tracker", "UpdateInternalFormat", value, true)
end

function EHIMenu:UpdateAssaultTracker2(value)
    self._preview_panel:CallFunction("assault", "UpdateInternalFormat2", value, true)
    self._preview_panel:CallFunction("show_assault_delay_tracker", "UpdateInternalFormat2", value, true)
    self._preview_panel:CallFunction("show_assault_time_tracker", "UpdateInternalFormat2", value, true)
end

function EHIMenu:UpdateEnemyCountTracker(value)
    self._preview_panel:UpdateTrackerInternalFormat("show_alarm_enemies", "show_enemy_count_tracker", value)
end

function EHIMenu:SetFocus2(focus, value)
    self:SetFocus(focus, "show_enemy_count_tracker")
end

function EHIMenu:UpdateXOffset(x)
    self._preview_panel:UpdateXOffset(x)
end

function EHIMenu:UpdateYOffset(y)
    self._preview_panel:UpdateYOffset(y)
end

function EHIMenu:UpdateTextScale(scale)
    self._preview_panel:UpdateTextScale(scale)
end

function EHIMenu:UpdateScale(scale)
    self._preview_panel:UpdateScale(scale)
end

function EHIMenu:UpdateTimeFormat(format)
    self._preview_panel:UpdateTimeFormat(format)
end

function EHIMenu:UpdateEquipmentFormat(format)
    self._preview_panel:UpdateEquipmentFormat(format)
end

function EHIMenu:UpdateTrackerVisibility(value, option)
    self._preview_panel:Redraw()
    self:SetFocus(value, option)
end

function EHIMenu:UpdateTrackerVisibility_Assault(value, option)
    self:UpdateTrackerVisibility(value, option)
    self:SetFocus(value, "assault")
end

function EHIMenu:UpdateBGVisibility(visibility)
    self._preview_panel:UpdateBGVisibility(visibility)
end

function EHIMenu:UpdateCornerVisibility(visibility)
    self._preview_panel:UpdateCornerVisibility(visibility)
end

function EHIMenu:UpdateIconsVisibility(visibility)
    self._preview_panel:UpdateIconsVisibility(visibility)
end

function EHIMenu:UpdateIconsPosition(pos)
    self._preview_panel:UpdateIconsPosition(pos)
end

function EHIMenu:UpdateTrackerAlignment(alignment)
    self._preview_panel:UpdateTrackerAlignment(alignment)
end

function EHIMenu:UpdateTrackerVerticalAnim(anim)
    self._preview_panel:UpdateTrackerVerticalAnim(anim)
end

function EHIMenu:SetFocus(focus, value)
    self._preview_panel:SetSelected(value)
end

function EHIMenu:SetFocus_Assault(focus, value)
    self:SetFocus(focus, value)
    self:SetFocus(focus, "assault")
end

function EHIMenu:fcc_equipment_tracker(focus, ...)
    self:SetFocus(focus, focus and "show_equipment_tracker" or "")
end

function EHIMenu:fcc_equipment_tracker_menu(focus, ...)
    DelayedCalls:Add("HighlightDelay", 0.5, function()
        self:SetFocus(focus, focus and "show_equipment_tracker" or "")
    end)
end

function EHIMenu:UpdateMinionTracker(value)
    self._preview_panel:UpdateTrackerInternalFormat("minion", "show_minion_tracker", value)
end

function EHIMenu:UpdateMinionHealthTracker(value)
    self._preview_panel:CallFunction("show_minion_tracker", "SetMinionHealth", value)
end

function EHIMenu:fcc_show_minion_option(focus, ...)
    self:SetFocus(focus, focus and "show_minion_tracker" or "")
end

---@param menu Menu
function EHIMenu:buffs_menu_created_callback(menu)
    local color_items = {}
    for _, item in ipairs(tweak_data.ehi._populate_buff_group_table()) do
        local option = string.format("buffs_group_color_%s", item)
        color_items[string.format("ehi_%s_choice", option)] = option
    end
    for _, item in ipairs(menu.items) do ---@cast item MenuMultipleChoiceSliderItem
        if color_items[item.id] then
            local value = EHI:GetOption(color_items[item.id])
            local color, _ = tweak_data.ehi:GetBuffColorFromIndex(value)
            item.value = value
            item.panel:child("title_selected"):set_text(item.items[value]) ---@diagnostic disable-line
            item.panel:child("title_selected"):set_color(color) ---@diagnostic disable-line
            self:UpdateArrorsInMultiChoiceSlider(item)
        end
    end
end

function EHIMenu:UpdateBuffsPreviewVisibility(visibility)
    self._buffs_preview_panel:UpdatePreviewVisibility(visibility)
end

function EHIMenu:UpdateBuffsVisibility(visibility)
    self._buffs_preview_panel:UpdateBuffsVisibility(visibility)
end

function EHIMenu:UpdateBuffsXOffset(x)
    self._buffs_preview_panel:UpdateXOffset(x)
end

function EHIMenu:UpdateBuffsYOffset(y)
    self._buffs_preview_panel:UpdateYOffset(y)
end

function EHIMenu:UpdateBuffsScale(scale)
    self._buffs_preview_panel:UpdateScale(scale)
end

function EHIMenu:UpdateBuffsAlignment(alignment)
    self._buffs_preview_panel:UpdateAlignment(alignment)
    for _, item in ipairs(self:GetMenu("ehi_buffs_menu").items) do
        if item.id == "ehi_x_offset" then -- ID is the same for both VR and non-VR option
            self:AnimateItemEnabled(item, alignment ~= 2)
            break
        end
    end
end

function EHIMenu:UpdateBuffsShape(value)
    self._buffs_preview_panel:UpdateBuffs("UpdateBuffShape", value)
end

---@param visibility boolean
function EHIMenu:UpdateBuffsProgressVisibility(visibility)
    self._buffs_preview_panel:UpdateBuffs("UpdateProgressVisibility", visibility)
end

function EHIMenu:UpdateBuffsInvertProgress()
    self._buffs_preview_panel:UpdateBuffs("InvertProgress")
end

---@param visibility boolean
function EHIMenu:UpdateBuffUpperTextVisibility(visibility)
    self._buffs_preview_panel:UpdateBuffs("UpdateHintVisibility", visibility)
end

function EHIMenu:UpdateBuffTextColor(value)
end

function EHIMenu:UpdateBuffColor(value, option, item_id)
    for _, item in ipairs(self:GetMenu("ehi_buffs_2_menu").items) do
        if item.id == item_id then
            local color, _ = tweak_data.ehi:GetBuffColorFromIndex(value)
            item.panel:child("title_selected"):set_color(color) ---@diagnostic disable-line
            item.panel:child("title_selected"):set_text(item.items[value]) ---@diagnostic disable-line
            break
        end
    end
end

function EHIMenu:SetColor(color, option, color_type)
    local c = EHI.settings.colors[color_type][option]
    c.r = color.red
    c.g = color.green
    c.b = color.blue
end

function EHIMenu:SetUnlockableColor(color, option, color_type)
    self:SetColor(color, option, color_type)
    self._preview_panel:CallFunction(option, "SetIconColor", Color(255, color.red, color.green, color.blue) / 255)
end

function EHIMenu:SetSniperCountColor(color, option, color_type)
    self:SetColor(color, option, color_type)
    self._preview_panel:CallFunction("show_sniper_tracker", "UpdateSniperCountColor", Color(255, color.red, color.green, color.blue) / 255)
end

function EHIMenu:SetSniperChanceColor(color, option, color_type)
    self:SetColor(color, option, color_type)
    self._preview_panel:CallFunction("show_sniper_tracker", "UpdateSniperChanceColor", Color(255, color.red, color.green, color.blue) / 255)
end

function EHIMenu:UpdateMoneyTrackerFormat(format)
    self._preview_panel:UpdateTrackerInternalFormat("money", "show_money_tracker", format)
end

function EHIMenu:PreviewNotification(params)
    if params.class == "HudChallengeNotification" then
        if not HudChallengeNotification then
            require("lib/managers/hud/HudChallengeNotification")
        end
        HudChallengeNotification.queue(params.id, managers.localization:text(params.desc), params.icon) --- HUDManager does not exist in Menu, needs to be called directly
    end
end

function EHIMenu:CheckBlockForAssaultDiffTracker()
    return EHI:IsAssaultTrackerEnabledAndOption("show_assault_diff_in_assault_trackers")
end

function EHIMenu:HintBlockForAssaultDiffTracker()
    local s, loc = "", managers.localization
    if EHI:CombineAssaultDelayAndAssaultTime() then
        s = string.format("%s\n%s\n%s", loc:text("ehi_show_assault_delay_tracker"), loc:text("ehi_experience_or"), loc:text("ehi_show_assault_time_tracker"))
    elseif EHI:GetOption("show_assault_delay_tracker") then
        s = loc:text("ehi_show_assault_delay_tracker")
    else
        s = loc:text("ehi_show_assault_time_tracker")
    end
    return string.format("%s\n+\n%s", s, loc:text("ehi_show_assault_diff_in_assault_trackers"))
end