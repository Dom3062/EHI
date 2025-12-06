local EHI = EHI
if EHI:CheckHook("MenuManager") then
    return
end

---@type FakeEHITrackerManager, FakeEHIBuffsManager
local tracker_preview, buff_preview
local cache = {}
---@param show boolean
local function ShowOrHideMenuStuff(show)
    local menu_component = managers.menu_component
    local blt_notifications = menu_component:blt_notifications_gui()
    if blt_notifications then
        blt_notifications._panel:set_visible(show)
        if blt_notifications._beardlib_panel then
            blt_notifications._beardlib_panel:set_visible(show)
        end
    end
    local player_profile_gui = menu_component._player_profile_gui
    if player_profile_gui and player_profile_gui._panel then
        player_profile_gui._panel:set_visible(show)
    end
    if PocoHud3 and PocoHud3.dbgLbl and (not cache._poco_time_lock or (cache._poco_time_lock and show)) then
        if show then
            PocoHud3.dbgLbl:set_visible(cache._poco_time_visibility)
            cache._poco_time_visibility = nil
            cache._poco_time_lock = nil
        else
            cache._poco_time_lock = true
            cache._poco_time_visibility = PocoHud3.dbgLbl:visible()
            PocoHud3.dbgLbl:hide()
        end
    end
    local contract_gui = menu_component._contract_gui -- Lobby
    if contract_gui then
        contract_gui._panel:set_visible(show)
        contract_gui._fullscreen_panel:set_visible(show)
    end
    local game_chat_gui = menu_component._game_chat_gui
    if game_chat_gui then
        game_chat_gui._hud_panel:set_visible(show)
    end
    tracker_preview._panel:set_visible(not show)
    buff_preview._panel:set_visible(not show)
end

---@param compare { comparator: string, value: integer }
---@param value boolean|integer
---@param type string?
local function check_value(compare, value, type)
    if type == "toggle" then
        value = value == "on"
    end
    local result = true
    local comparator = compare.comparator or "=="
    local value_to_compare = compare.value
    if comparator == "==" then
        result = value == value_to_compare
    elseif comparator == "<" then
        result = value < value_to_compare
    elseif comparator == "<=" then
        result = value <= value_to_compare
    elseif comparator == ">" then
        result = value > value_to_compare
    elseif comparator == ">=" then
        result = value >= value_to_compare
    elseif comparator == "<>" then
        result = value ~= value_to_compare
    end
    return result
end

---Copy of BLT's MenuHelper with EHI specific changes
---Loads a json-formatted text file and automatically parses and converts into a usable menu
---@param file_path string @Path of the file to load and convert into a menu
---@param data_table table? @Table containing the data keys which various menu items can load their value from
local function LoadFromJsonFile(file_path, data_table)
    local file = io.open(file_path, "r")
    if file then
        local file_content = file:read("*all")
        file:close()

        local content = json.decode(file_content)
        local menu_id = content.menu_id
        local parent_menu = content.parent_menu_id
        local items = content.items
        local menu_priority = content.priority or nil

        -- 1.
        Hooks:Add("MenuManagerSetupCustomMenus", "Base_SetupCustomMenus_Json_" .. menu_id, function(menu_manager, nodes)
            MenuHelper:NewMenu(menu_id)
        end)

        -- 3.
        Hooks:Add("MenuManagerBuildCustomMenus","Base_BuildCustomMenus_Json_" .. menu_id, function(menu_manager, nodes)
            local data = {
                focus_changed_callback = content.focus_changed_callback,
                back_callback = content.back_callback,
                area_bg = content.area_bg
            }
            nodes[menu_id] = MenuHelper:BuildMenu(menu_id, data)

            if menu_priority ~= nil then
                for k, v in pairs(nodes[parent_menu]._items) do
                    if menu_priority > (v._priority or 0) then
                        menu_priority = k
                        break
                    end
                end
            end

            if menu_id == "ehi_menu" then
                MenuHelper:AddMenuItem(nodes[parent_menu], menu_id, content.title, content.description, menu_priority)
            end
        end)

        -- 2.
        Hooks:Add("MenuManagerPopulateCustomMenus","Base_PopulateCustomMenus_Json_" .. menu_id, function(menu_manager, nodes)
            local all_items = #items
            local previous_items = {}
            for k, item in ipairs(items) do
                local menu_item
                if item.vr then
                    item = _G.IS_VR and item.vr[1] or item.vr[2]
                end
                local i_type = item.type
                local id = item.id
                local title = item.title
                local desc = item.description
                local callback = item.callback
                local priority = item.priority or all_items - k
                local value = item.default_value
                local localized = item.localized
                local disabled = false
                if data_table and data_table[item.value] ~= nil then
                    value = data_table[item.value]
                end
                if item.disabled_from_start and MenuCallbackHandler then
                    disabled = not _G.callback(MenuCallbackHandler, MenuCallbackHandler, item.disabled_from_start)()
                end
                if i_type == "button" then
                    menu_item = MenuHelper:AddButton({
                        id = id,
                        title = title,
                        desc = desc,
                        callback = callback,
                        next_node = item.next_menu or nil,
                        menu_id = menu_id,
                        priority = priority,
                        localized = localized,
                        disabled = disabled
                    })
                elseif i_type == "toggle" then
                    menu_item = MenuHelper:AddToggle({
                        id = id,
                        title = title,
                        desc = desc,
                        callback = callback,
                        value = value,
                        menu_id = menu_id,
                        priority = priority,
                        localized = localized,
                        disabled = disabled
                    })
                elseif i_type == "slider" then
                    menu_item = MenuHelper:AddSlider({
                        id = id,
                        title = title,
                        desc = desc,
                        callback = callback,
                        value = value,
                        min = item.min or 0,
                        max = item.max or 1,
                        step = item.step or 0.1,
                        show_value = true,
                        display_precision = item.display_precision,
                        display_scale = item.display_scale,
                        is_percentage = item.is_percentage,
                        menu_id = menu_id,
                        priority = priority,
                        localized = localized,
                        disabled = disabled
                    })
                elseif i_type == "divider" then
                    menu_item = MenuHelper:AddDivider({
                        id = "",
                        size = item.size,
                        title = title,
                        menu_id = menu_id,
                        priority = priority,
                        no_text = item.no_text
                    })
                    menu_item:set_parameter("color", Color.white)
                elseif i_type == "keybind" then
                    local key = ""
                    if item.keybind_id then
                        local mod = BLT.Mods:GetModOwnerOfFile(file_path)
                        if mod then
                            local params = {
                                id = item.keybind_id,
                                allow_menu = item.run_in_menu,
                                allow_game = item.run_in_game,
                                show_in_menu = item.show_in_menu,
                                name = title,
                                desc = desc,
                                localize = true,
                                callback = item.func and MenuCallbackHandler[item.func]
                            }
                            BLT.Keybinds:register_keybind(mod, params)
                        end
                        local bind = BLT.Keybinds:get_keybind(item.keybind_id)
                        key = bind and bind:Key() or ""
                    end
                    menu_item = MenuHelper:AddKeybinding({
                        id = id,
                        title = title,
                        desc = desc,
                        connection_name = item.keybind_id,
                        button = key,
                        binding = key,
                        menu_id = menu_id,
                        priority = priority,
                        localized = localized,
                        disabled = disabled
                    })
                elseif i_type == "multiple_choice" then
                    menu_item = MenuHelper:AddMultipleChoice({
                        id = id,
                        title = title,
                        desc = desc,
                        callback = callback,
                        items = item.items,
                        item_values = item.item_values,
                        value = value,
                        menu_id = menu_id,
                        priority = priority,
                        localized = localized,
                        localized_items = item.localized_items,
                        disabled = disabled
                    })
                    if item.items_need_color then
                        for _, option in ipairs(menu_item._all_options) do
                            local color, _ = tweak_data.ehi:GetBuffColorFromIndex(option:value())
                            option:parameters().color = color
                        end
                    end
                elseif i_type == "color" then
                    local settings_table = EHI.settings.colors
                    if item.params.setting then
                    elseif item.params.settings then
                        for _, setting in ipairs(item.params.settings) do
                            settings_table = settings_table[setting]
                        end
                        value = settings_table
                    end
                    local data =
                    {
                        type = "EHIMenuItemColor",
                        {
                            _meta = "option",
                            text_id = "ehi_buffs_group_color_red",
                            name = "r",
                            value = value.r,
                            localize = true
                        },
                        {
                            _meta = "option",
                            text_id = "ehi_buffs_group_color_green",
                            name = "g",
                            value = value.g,
                            localize = true
                        },
                        {
                            _meta = "option",
                            text_id = "ehi_buffs_group_color_blue",
                            name = "b",
                            value = value.b,
                            localize = true
                        }
                    }
                    local params =
                    {
                        name = id,
                        text_id = title,
                        help_id = desc,
                        callback = "ehi_modify_item_color",
                        localize = localized,
                        localize_help = localized,
                        default_color = item.default_value
                    }
                    local menu = MenuHelper:GetMenu(menu_id)
                    menu_item = menu:create_item(data, params)
                    menu_item:set_value(value)
                    menu_item._priority = priority
                    if disabled then
                        menu_item:set_enabled(not disabled)
                    end
                    menu._items_list = menu._items_list or {}
                    table.insert(menu._items_list, menu_item)
                end
                if menu_item and id then -- Dividers do not have ID assigned
                    previous_items[id] = menu_item
                    if item.value then
                        menu_item:set_parameter("option", item.value)
                    end
                    if item.params or content.global_params then
                        for key, param_value in pairs(item.params or content.global_params) do
                            menu_item:set_parameter(key, param_value)
                        end
                    end
                    if item.child then
                        menu_item:set_parameter("child", item.child)
                    elseif item.children then
                        menu_item:set_parameter("children", item.children)
                    end
                    if item.children_f or item.children_f_and then
                        menu_item:set_parameter("children_f", item.children_f_and or item.children_f)
                    end
                    if item.children_f_or then
                        menu_item:set_parameter("children_f_or", item.children_f_or)
                    end
                    if item.child_compare then
                        menu_item:set_parameter("child_compare", item.child_compare)
                    end
                    if item.parent and previous_items[item.parent] then
                        menu_item:set_enabled(previous_items[item.parent]:value() == "on")
                    end
                    if item.parent_compare and item.parent_compare.id and previous_items[item.parent_compare.id] then
                        local data = item.parent_compare
                        local parent = previous_items[data.id]
                        local result = check_value(data, parent:value(), parent:type())
                        if data.enabled then
                            result = result and parent:enabled()
                        end
                        menu_item:set_enabled(result)
                    elseif item.parents_compare then
                        local final_result = true
                        if item.parents_compare.comparator == "and" then
                            for key, data in pairs(item.parents_compare.items) do
                                local parent = previous_items[key]
                                if parent and not check_value(data, parent:value(), parent:type()) then
                                    final_result = false
                                    break
                                end
                            end
                        else -- or
                            final_result = false
                            for key, data in pairs(item.parents_compare.items) do
                                local parent = previous_items[key]
                                if parent and check_value(data, parent:value(), parent:type()) then
                                    final_result = true
                                    break
                                end
                            end
                        end
                        menu_item:set_enabled(final_result)
                    end
                    if item.other_item_compare and item.other_item_compare.id and previous_items[item.other_item_compare.id] then
                        local data = item.other_item_compare
                        previous_items[data.id]:set_enabled(check_value(data, value))
                    end
                end
            end
        end)
    else
        BLT:Log(LogLevel.ERROR, string.format("Could not load file '%s'", file_path))
    end
end

local Languages =
{
    [2] = "english",
    [3] = "czech",
    [4] = "french",
    [5] = "italian",
    [6] = "russian",
    [7] = "thai",
    [8] = "schinese",
    [9] = "portuguese", -- Brazil
    [10] = "spanish",
    [11] = "japanese"
}

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_EHI", function(loc)
    local language_filename = nil
    local lang = EHI:GetOption("mod_language")
    local LocPath = EHI.ModPath .. "loc/"
    if lang == 1 then -- Autodetect
        local LanguageKey =
        {
            ["PAYDAY 2 THAI LANGUAGE Mod"] = "thai",
            --["Ultimate Localization Manager & 正體中文化"] = "tchinese",
            --["Payday 2 Korean patch"] = "korean"
        }
        for _, mod in ipairs(BLT and BLT.Mods and BLT.Mods:Mods() or {}) do
            language_filename = mod:IsEnabled() and LanguageKey[mod:GetName()]
            if language_filename then
                break
            end
        end
        if not language_filename then
            for _, filename in ipairs(file.GetFiles(LocPath)) do
                local str = filename:match('^(.*).json$')
                if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
                    language_filename = str
                    break
                end
            end
        end
        if language_filename then
            loc:load_localization_file(LocPath .. language_filename .. ".json")
        end
    else
        loc:load_localization_file(LocPath .. Languages[lang] .. ".json")
    end
    if lang ~= 2 or not language_filename then
        loc:load_localization_file(LocPath .. "english.json", false)
    end
    loc:load_localization_file(LocPath .. "languages.json")
    EHI:RunOnLocalizationLoaded(loc, Languages[lang] or language_filename or "english")
end)

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_EHI", function(menu_manager)
    LoadFromJsonFile(EHI.MenuPath .. "menu.json", EHI.settings)
    LoadFromJsonFile(EHI.MenuPath .. "trackers.json", EHI.settings)
    LoadFromJsonFile(EHI.MenuPath .. "equipment.json", EHI.settings)
    LoadFromJsonFile(EHI.MenuPath .. "unlockables.json", EHI.settings.unlockables)
    LoadFromJsonFile(EHI.MenuPath .. "visuals.json", EHI.settings)
    LoadFromJsonFile(EHI.MenuPath .. "waypoints.json", EHI.settings)
    LoadFromJsonFile(EHI.MenuPath .. "shared.json", EHI.settings)
    LoadFromJsonFile(EHI.MenuPath .. "buffs.json", EHI.settings)
    LoadFromJsonFile(EHI.MenuPath .. "buff_options/skills.json")
    LoadFromJsonFile(EHI.MenuPath .. "buff_options/skills/mastermind.json", EHI.settings.buff_option)
    LoadFromJsonFile(EHI.MenuPath .. "buff_options/skills/enforcer.json", EHI.settings.buff_option)
    LoadFromJsonFile(EHI.MenuPath .. "buff_options/skills/ghost.json", EHI.settings.buff_option)
    LoadFromJsonFile(EHI.MenuPath .. "buff_options/skills/fugitive.json", EHI.settings.buff_option)
    LoadFromJsonFile(EHI.MenuPath .. "buff_options/perks.json")
    LoadFromJsonFile(EHI.MenuPath .. "buff_options/perks/infiltrator.json", EHI.settings.buff_option.infiltrator)
    LoadFromJsonFile(EHI.MenuPath .. "buff_options/perks/gambler.json", EHI.settings.buff_option.gambler)
    LoadFromJsonFile(EHI.MenuPath .. "buff_options/perks/grinder.json", EHI.settings.buff_option.grinder)
    LoadFromJsonFile(EHI.MenuPath .. "buff_options/perks/maniac.json", EHI.settings.buff_option.maniac)
    LoadFromJsonFile(EHI.MenuPath .. "buff_options/perks/anarchist.json", EHI.settings.buff_option.anarchist)
    LoadFromJsonFile(EHI.MenuPath .. "buff_options/perks/yakuza.json", EHI.settings.buff_option.yakuza)
    LoadFromJsonFile(EHI.MenuPath .. "buff_options/perks/expresident.json", EHI.settings.buff_option.expresident)
    LoadFromJsonFile(EHI.MenuPath .. "buff_options/perks/biker.json", EHI.settings.buff_option.biker)
    LoadFromJsonFile(EHI.MenuPath .. "buff_options/perks/kingpin.json", EHI.settings.buff_option.kingpin)
    LoadFromJsonFile(EHI.MenuPath .. "buff_options/perks/sicario.json", EHI.settings.buff_option.sicario)
    LoadFromJsonFile(EHI.MenuPath .. "buff_options/perks/stoic.json", EHI.settings.buff_option.stoic)
    LoadFromJsonFile(EHI.MenuPath .. "buff_options/perks/tag_team.json", EHI.settings.buff_option.tag_team)
    LoadFromJsonFile(EHI.MenuPath .. "buff_options/perks/hacker.json", EHI.settings.buff_option.hacker)
    LoadFromJsonFile(EHI.MenuPath .. "buff_options/perks/leech.json", EHI.settings.buff_option.leech)
    LoadFromJsonFile(EHI.MenuPath .. "buff_options/perks/copycat.json", EHI.settings.buff_option.copycat)
    LoadFromJsonFile(EHI.MenuPath .. "buff_options/perks/gage_boosts.json", EHI.settings.buff_option.gage_boosts)
    LoadFromJsonFile(EHI.MenuPath .. "buff_options/other.json", EHI.settings.buff_option)
    LoadFromJsonFile(EHI.MenuPath .. "inventory.json", EHI.settings)
    LoadFromJsonFile(EHI.MenuPath .. "other.json", EHI.settings)
    local main_menu = menu_manager:get_menu(menu_manager._is_start_menu and "menu_main" or "menu_pause")
    if main_menu then
        local node = CoreMenuNode.MenuNode:new({
            gui_class = "EHIMenuNodeCustomizeGadgetGui",
            modifier = "EHIMenuSetColorInitiator",
            refresh = "EHIMenuSetColorInitiator"
        })
        node:set_callback_handler(MenuCallbackHandler:new())
        main_menu.data._nodes.ehi_color_select = node
    else
        EHI:Log("!!!!!!!!!!!!!!! Main Menu does not exist !!!!!!!!!!!!!!!")
    end
end)

---@param item MenuItemMultiChoice|CoreMenuItemSlider.ItemSlider|CoreMenuItemToggle.ItemToggle
function MenuCallbackHandler:ehi_set_item_value(item)
    local params, type = item:parameters(), item:type()
    local value
    if type == "slider" then ---@cast item CoreMenuItemSlider.ItemSlider
        value = tonumber(item:raw_value_string())
    elseif type == "toggle" then ---@cast item CoreMenuItemToggle.ItemToggle
        value = item:value() == "on"
    else ---@cast item MenuItemMultiChoice
        value = item:value()
    end
    local settings_table = EHI.settings
    if params.setting then
        settings_table = settings_table[params.setting]
    elseif params.settings then
        for _, setting in ipairs(params.settings) do
            settings_table = settings_table[setting]
        end
    end
    settings_table[params.option] = value
    if params.call_tracker_function and (params.call_tracker_function.update_trackers or params.call_tracker_function.custom_f or tracker_preview[params.call_tracker_function.f]) then
        if params.call_tracker_function.update_trackers then
            tracker_preview:UpdateTracker(params.call_tracker_function.update_trackers.id, check_value(params.call_tracker_function.update_trackers.compare, value --[[@as integer]]))
        elseif params.call_tracker_function.custom_f then
            tracker_preview:CallFunction(params.call_tracker_function.id, params.call_tracker_function.custom_f, value)
        elseif params.call_tracker_function.params then
            tracker_preview[params.call_tracker_function.f](tracker_preview, value, unpack(params.call_tracker_function.params))
        else
            tracker_preview[params.call_tracker_function.f](tracker_preview, value)
        end
    elseif params.call_buff_function and buff_preview[params.call_buff_function.f] then
        if params.call_buff_function.params then
            buff_preview[params.call_buff_function.f](buff_preview, unpack(params.call_buff_function.params), value)
        else
            buff_preview[params.call_buff_function.f](buff_preview, value)
        end
    end
    if params.child then
        for _, row_item in ipairs(params.gui_node.row_items) do
            if row_item.name == params.child then
                row_item.item:set_enabled(value)
                break
            end
        end
    elseif params.children then
        local children = table.list_to_set(params.children)
        for _, row_item in ipairs(params.gui_node.row_items) do
            if children[row_item.name] then
                row_item.item:set_enabled(value)
            end
        end
    end
    if params.child_compare then
        local compare = params.child_compare
        for _, row_item in ipairs(params.gui_node.row_items) do
            local data = compare[row_item.name]
            if data and data.value then
                row_item.item:set_enabled(check_value(data, value --[[@as integer]]))
            end
        end
    end
    if params.children_f then
        for name, f in pairs(params.children_f) do
            for _, row_item in ipairs(params.gui_node.row_items) do
                if row_item.name == name and MenuCallbackHandler[f] then
                    row_item.item:set_enabled(value and MenuCallbackHandler[f]())
                    break
                end
            end
        end
    end
    if params.children_f_or then
        for name, f in pairs(params.children_f_or) do
            for _, row_item in ipairs(params.gui_node.row_items) do
                if row_item.name == name and MenuCallbackHandler[f] then
                    row_item.item:set_enabled(value or MenuCallbackHandler[f]())
                    break
                end
            end
        end
    end
end

---@param item EHIMenuItemColor
function MenuCallbackHandler:ehi_modify_item_color(item)
    managers.menu:open_node("ehi_color_select", { { item = item } })
    managers.menu_component:post_event("menu_enter")
end

function MenuCallbackHandler:ehi_set_item_color()
    local menu = managers.menu:active_menu()
    if not menu then
        return
    end
    if not menu.logic then
        return
    end
    if not menu.logic:selected_node() then
        return
    end
    local color, item = nil, nil
    local active_node_gui = menu.renderer:active_node_gui()
    if active_node_gui and active_node_gui.update_node_colors then
        color = active_node_gui:update_node_colors()
        item = active_node_gui.node:parameters().menu_component_data.item
    end
    if item and color then
        item:set_value(color)
        local params = item:parameters()
        local settings_table = EHI.settings.colors
        if params.setting then
        elseif params.settings then
            for _, setting in ipairs(params.settings) do
                settings_table = settings_table[setting]
            end
        end
        settings_table.r = color.r
        settings_table.g = color.g
        settings_table.b = color.b
        if params.call_tracker_function then
            tracker_preview:CallFunction(params.call_tracker_function.tracker or params.option, params.call_tracker_function.f, Color(255, color.r, color.g, color.b) / 255)
        end
    end
    managers.menu:back()
end

function MenuCallbackHandler.ehi_changed_focus(node, focus)
    if not tracker_preview then
        local AspectRatio = FakeEHITrackerManager.AspectRatio
        local aspect_ratio = RenderSettings.resolution.x / RenderSettings.resolution.y
        local _1_33 = 4 / 3
        local AspectRatioEnum, ws
        if aspect_ratio == 1.6 or aspect_ratio == _1_33 then -- 16:10 or 4:3
            AspectRatioEnum = aspect_ratio == 1.6 and AspectRatio._16_10 or AspectRatio._4_3
            ws = managers.gui_data:create_fullscreen_16_9_workspace()
        else
            AspectRatioEnum = AspectRatio.Other
            ws = managers.gui_data:create_fullscreen_workspace()
        end
        local panel = ws:panel():panel()
        tracker_preview = FakeEHITrackerManager:new(panel, AspectRatioEnum)
        buff_preview = FakeEHIBuffsManager:new(panel)
    end
    if focus then
        ShowOrHideMenuStuff(false)
    end
end

---@param item CoreMenuItemToggle.ItemToggle
function MenuCallbackHandler:ehi_update_tracker_visibility(item)
    tracker_preview:Redraw()
end

function MenuCallbackHandler.ehi_is_shared_menu_available()
    return EHI:GetTrackerOrWaypointOption("show_mission_trackers", "show_waypoints_mission")
end

function MenuCallbackHandler.ehi_is_shared_menu_available_1()
    return EHI:GetOption("show_waypoints")
end

function MenuCallbackHandler.ehi_is_shared_menu_available_2()
    return EHI:GetOption("show_trackers")
end

function MenuCallbackHandler.ehi_are_assault_option_items_available()
    return EHI:GetOption("show_assault_delay_tracker") or EHI:GetOption("show_assault_time_tracker")
end

function MenuCallbackHandler.ehi_are_assault_option_items_available_1()
    return EHI:GetOption("show_assault_time_tracker")
end

function MenuCallbackHandler.ehi_are_assault_option_items_available_2()
    return EHI:GetOption("show_assault_delay_tracker")
end

---@param item CoreMenuItemToggle.ItemToggle
function MenuCallbackHandler:ehi_update_assault_tracker(item)
    local value = item:value() == "on"
    tracker_preview:CallFunction("assault", "UpdateInternalFormat", value, true)
    tracker_preview:CallFunction("show_assault_delay_tracker", "UpdateInternalFormat", value, true)
    tracker_preview:CallFunction("show_assault_time_tracker", "UpdateInternalFormat", value, true)
end

---@param item CoreMenuItemToggle.ItemToggle
function MenuCallbackHandler:ehi_update_assault_tracker_2(item)
    local value = item:value() == "on"
    tracker_preview:CallFunction("assault", "UpdateInternalFormat2", value, true)
    tracker_preview:CallFunction("show_assault_delay_tracker", "UpdateInternalFormat2", value, true)
    tracker_preview:CallFunction("show_assault_time_tracker", "UpdateInternalFormat2", value, true)
end

---@param item CoreMenuItemToggle.ItemToggle
function MenuCallbackHandler:ehi_preview_notification(item)
    local params = item:parameters()
    if params.n_class == "HudChallengeNotification" then
        if not HudChallengeNotification then
            require("lib/managers/hud/HudChallengeNotification")
        end
        HudChallengeNotification.queue(params.n_id, managers.localization:text(params.n_desc), params.n_icon) --- HUDManager does not exist in Menu, needs to be called directly
    end
end

function MenuCallbackHandler.ehi_hide_unlocked_achievements_available_1()
    return EHI:GetUnlockableOption("show_achievements_mission")
end

function MenuCallbackHandler.ehi_hide_unlocked_achievements_available_2()
    return EHI:GetUnlockableOption("show_achievements")
end

function MenuCallbackHandler.ehi_show_floating_health_bar_style_poco_blur_available_1()
    return EHI:GetOption("show_floating_health_bar_style") == 1 -- Poco style
end

function MenuCallbackHandler.ehi_show_floating_text_throwables_block_on_abilities_choice_1()
    return EHI:GetOption("show_floating_text_throwables")
end

function MenuCallbackHandler:ehi_update_buff_text_color(item)
end

function MenuCallbackHandler:ehi_save(item)
    ShowOrHideMenuStuff(true)
    EHI:SaveOptions()
end

local function CacheRank(self, ...)
    self.__ehi_rank = managers.experience:current_rank()
end
local function IncreaseRank(self, ...)
    local xp = managers.experience
    local current_rank = xp:current_rank()
    if self.__ehi_rank ~= current_rank then
        managers.ehi_experience:ExperienceReload(xp)
    end
    self.__ehi_rank = nil
end
EHI:PreHookAndHookWithID(MenuCallbackHandler, "_increase_infamous", "EHI_MenuCallbackHandler_increase_infamous", CacheRank, IncreaseRank)
EHI:PreHookAndHookWithID(MenuCallbackHandler, "_increase_infamous_with_prestige", "EHI_MenuCallbackHandler_increase_infamous_with_prestige", CacheRank, IncreaseRank)

if Global.load_level then
    Hooks:PreHook(MenuCallbackHandler, "_dialog_end_game_yes", "EHI_MenuCallbackHandler_dialog_end_game_yes", function(...)
        EHI:RunEndGameCallback(EHI.Const.GameEnd.Abort)
    end)
end