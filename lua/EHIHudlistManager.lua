local EHI = EHI

---@class EHIList
---@field _set_items_y fun()
local EHIList = class()
---@param o Panel
---@param target_y number
EHIList._set_y = function(o, target_y)
    local t, total = 0, 0.15
    local from_y = o:y()
    while t < total do
        t = t + coroutine.yield()
        o:set_y(math.lerp(from_y, target_y, t / total))
    end
    o:set_y(target_y)
end
function EHIList:init()
    self._options = {}
    self._items = {} ---@type table<string, EHILeftItemBase|EHIRightItemBase>
    self._itemized_list = {} ---@type EHILeftItemBase[]|EHIRightItemBase[]
    self._n_of_visible_items = 0
end

---@param x number
---@param y number
---@param scale number
function EHIList:post_init(x, y, scale)
end

function EHIList:SwitchToLoudMode()
    for _, item in ipairs(self._itemized_list) do
        item:SwitchToLoudMode()
    end
end

---@param id string
---@param f string
function EHIList:CallItemFunction(id, f, ...)
    local item = self._items[id]
    if item and item[f] then
        item[f](item, ...)
    end
end

---@param item EHILeftItemBase|EHIRightItemBase
function EHIList:ItemSetVisible(item)
    self._n_of_visible_items = self._n_of_visible_items + 1
    if self._n_of_visible_items == 1 then
        item._panel:set_y(self._options.y)
        return
    end
    self:_set_items_y()
end

function EHIList:ItemSetHidden()
    self._n_of_visible_items = self._n_of_visible_items - 1
    if self._n_of_visible_items <= 0 then
        return
    end
    self:_set_items_y()
end

---@param id string
function EHIList:RemoveItem(id)
    local item = table.remove_key(self._items, id)
    if item then
        item:destroy()
        for i, itm in ipairs(self._itemized_list) do
            if itm == item then
                table.remove(self._itemized_list, i)
                break
            end
        end
    end
end

---@class EHILeftList : EHIList
---@field new fun(self: self): self
---@field super EHIList
local EHILeftList = class(EHIList)
function EHILeftList:post_init(x, y, scale)
    self._options.x = x
    self._options.y = y
    self._options.scale = scale
    self._options.y_offset = 2 * scale
end

---@param class EHILeftItemBase
---@param panel Panel
---@param params table
function EHILeftList:AddItem(class, panel, params)
    local texture, texture_rect = tweak_data.ehi.default.hudlist.get_icon(params.icon)
    params.scale = self._options.scale
    local item = class:new(panel, params, texture, texture_rect)
    self._items[params.id] = item
    table.insert(self._itemized_list, item)
    item._panel:set_x(self._options.x)
end

function EHILeftList:_set_items_y()
    local y = self._options.y
    for _, item in ipairs(self._itemized_list) do
        if item:visible() then
            item._panel:animate(self._set_y, y)
            y = y + item._panel:h() + self._options.y_offset
        end
    end
end

---@class EHIRightList : EHIList
---@field new fun(self: self): self
---@field super EHIList
local EHIRightList = class(EHIList)
function EHIRightList:post_init(y, scale)
    self._options.y = y
    self._options.scale = scale
    self._options.y_offset = 2 * scale
end

---@generic T : EHIRightItemBase
---@param class T|EHIRightItemBase
---@param panel Panel
---@param params table
---@return T
function EHIRightList:AddItem(class, panel, params)
    local item = class:new(panel, params)
    self._items[params.id] = item
    table.insert(self._itemized_list, item)
    return item
end

function EHIRightList:_set_items_y()
    local y = self._options.y
    for _, item in ipairs(self._itemized_list) do
        if item:visible() then
            item._panel:stop()
            item._panel:animate(self._set_y, y)
            y = y + item._panel:h() + self._options.y_offset
        end
    end
end

---@class EHIHudlistManager
local EHIHudlistManager = {}
EHIHudlistManager._left_list = EHILeftList:new()
EHIHudlistManager._right_list = EHIRightList:new()
---@param id string
---@param f string
function EHIHudlistManager:CallLeftListItemFunction(id, f, ...)
    self._left_list:CallItemFunction(id, f, ...)
end

---@param id string
---@param f string
function EHIHudlistManager:CallRightListItemFunction(id, f, ...)
    self._right_list:CallItemFunction(id, f, ...)
end

if EHI:GetOption("show_hudlist") then
    if EHI:GetHudlistOption("show_left_list") then
        dofile(EHI.LuaPath .. "hudlist/left_items.lua")
        EHILeftItemBase._parent = EHIHudlistManager._left_list
        EHILeftItemBase._BG_ALPHA = EHI:GetHudlistOption("left_list_bg_alpha")
        EHILeftItemBase._BG_COLOR = EHI:GetColor(EHI:GetHudlistOption("left_list_bg_color"))
        EHILeftItemBase._PROGRESS_ALPHA = EHI:GetHudlistOption("left_list_progress_alpha")
        EHILeftItemBase._PROGRESS_VISIBILITY = EHI:GetHudlistOption("left_list_progress_visibility")
        EHILeftItemBase._PROGRESS_STATIC = EHI:GetHudlistOption("left_list_progress_static")
        function EHIHudlistManager:_init_left_list()
            self._panel = self._ws:panel():panel({ layer = -5 })
            local x, y = managers.gui_data:safe_to_full(EHI:GetHudlistOption("left_list_x"), EHI:GetHudlistOption("left_list_y"))
            self._left_list:post_init(x, y, EHI:GetHudlistOption("left_list_scale"))
            local options = EHI:GetHudlistOption("left_list")
            local stealth_is_available = tweak_data.levels:IsStealthAvailable()
            if options.show_timers then
                self._left_list:AddItem(EHILeftTimerItem, self._panel, {
                    id = "Timer",
                    icon = { skills = { 3, 6 } },
                    progress = options.timer_progress,
                    jammed = options.timer_jammed,
                    not_powered = options.timer_not_powered,
                    autorepair = options.timer_autorepair,
                    top_text = options.timer_top_text
                })
            else
                EHILeftTimerItem = nil ---@diagnostic disable-line
            end
            if options.show_minions and not tweak_data.levels:IsStealthRequired() then
                self._left_list:AddItem(EHILeftMinionItem, self._panel, {
                    id = "Minion",
                    icon = EHILeftMinionItem._ICON,
                    minion_option = options.minions_option,
                    progress = options.minions_health,
                    top_text = options.minions_top_text
                })
            else
                EHILeftMinionItem = nil ---@diagnostic disable-line
            end
            if options.show_deployables and
                (options.deployable_show_doctor or
                options.deployable_show_ammo or
                options.deployable_show_grenades or
                options.deployable_show_fak or
                (options.deployable_show_bodybags and stealth_is_available)) then
                self._left_list:AddItem(EHILeftDeployableItem, self._panel, {
                    id = "Deployable",
                    icon = { ehi = "deployables" },
                    update_on_alarm = true,
                    top_text = options.deployable_top_text,
                    progress = options.deployable_progress,
                    format = options.deployable_format,
                    show_doctor = options.deployable_show_doctor,
                    show_ammo = options.deployable_show_ammo,
                    show_grenades = options.deployable_show_grenades,
                    block_grenades = options.deployable_grenades_block_on_ability_or_no_throwable,
                    show_fak = options.deployable_show_fak,
                    show_bodybags = options.deployable_show_bodybags and stealth_is_available
                })
            else
                EHILeftDeployableItem = nil ---@diagnostic disable-line
            end
            if options.show_ecm_retrigger then
                self._left_list:AddItem(EHILeftJammerRetriggerItem, self._panel, {
                    id = "JammerRetrigger",
                    icon = EHILeftJammerRetriggerItem._ICON,
                    progress = options.ecm_retrigger_progress
                })
            else
                EHILeftJammerRetriggerItem = nil ---@diagnostic disable-line
            end
            if stealth_is_available then
                if options.show_enemy_pagers then
                    self._left_list:AddItem(EHILeftPagerItem, self._panel, {
                        id = "Pager",
                        icon = { ehi = "pager_icon" },
                        delete_on_alarm = true,
                        progress = options.enemy_pager_progress
                    })
                else
                    EHILeftPagerItem = nil ---@diagnostic disable-line
                end
                if options.show_jammers then
                    self._left_list:AddItem(EHILeftJammerItem, self._panel, {
                        id = "Jammer",
                        icon = EHILeftJammerItem._ICON,
                        delete_on_alarm = true,
                        progress = options.jammer_progress
                    })
                else
                    EHILeftJammerItem = nil ---@diagnostic disable-line
                end
                if options.show_camera_loop and not _G.ch_settings then
                    self._left_list:AddItem(EHILeftCameraLoopItem, self._panel, {
                        id = "Camera",
                        icon = EHILeftCameraLoopItem._ICON,
                        delete_on_alarm = true,
                        progress = options.camera_loop_progress
                    })
                else
                    EHILeftCameraLoopItem = nil ---@diagnostic disable-line
                end
            end
        end
    end
    if EHI:GetHudlistOption("show_right_list") then
        dofile(EHI.LuaPath .. "hudlist/right_items.lua")
        EHIRightItemBase._parent = EHIHudlistManager._right_list
        EHIRightItemBase._BG_ALPHA = EHI:GetHudlistOption("right_list_bg_alpha")
        EHIRightItemBase._BG_COLOR = EHI:GetColor(EHI:GetHudlistOption("right_list_bg_color"))
        EHIRightItemBase._PROGRESS_ALPHA = EHI:GetHudlistOption("right_list_progress_alpha")
        EHIRightItemBase._PROGRESS_VISIBILITY = EHI:GetHudlistOption("right_list_progress_visibility")
        EHIRightItemBase._PROGRESS_STATIC = EHI:GetHudlistOption("right_list_progress_static")
        function EHIHudlistManager:_init_right_list()
            self._panel = self._panel or self._ws:panel():panel({ layer = -5 })
            local x, y = managers.gui_data:safe_to_full(EHI:GetHudlistOption("right_list_x"), EHI:GetHudlistOption("right_list_y"))
            local scale = EHI:GetHudlistOption("right_list_scale") --[[@as number]]
            self._right_list:post_init(y, scale)
            EHIRightItemBase._right_offset = self._panel:w() - x
            EHIRightItemBase._scale = scale
            local options = EHI:GetHudlistOption("right_list")
            local stealth_is_available = tweak_data.levels:IsStealthAvailable()
            if options.show_units then
                local is_holdout = tweak_data.levels:IsLevelSkirmish()
                local item = self._right_list:AddItem(EHIRightUnitItem, self._panel, {
                    id = "Unit",
                    progress = options.unit_progress,
                    aggregate_enemies = options.unit_aggregate_enemies
                })
                item:CreateItemsFromMap(is_holdout, options.unit_types)
            else
                EHIRightUnitItem = nil ---@diagnostic disable-line
            end
            if options.show_loot then
                local item = self._right_list:AddItem(EHIRightLootItem, self._panel, {
                    id = "Loot",
                    progress = options.loot_progress,
                    show_potentional_loot = options.potentional_loot,
                    update_on_alarm = true
                })
                item:CreateItemsFromMap(stealth_is_available, options.loot_top_type)
                if options.loot_color_items_based_on_their_weight then
                    item:ColorItemsBasedOnTheirWeight(options.loot_color_items_light, options.loot_color_items_heavy, options.loot_color_items_body)
                end
            else
                EHIRightLootItem = nil ---@diagnostic disable-line
            end
            if options.show_special_items then
                local item = self._right_list:AddItem(EHIRightSpecialItemsItem, self._panel, {
                    id = "Special",
                    progress = options.special_items_progress
                })
                item:CreateItemsFromMap(options.special_items_type)
            else
                EHIRightSpecialItemsItem = nil ---@diagnostic disable-line
            end
            if options.show_stealth_info and stealth_is_available then
                local item = self._right_list:AddItem(EHIRightStealthItem, self._panel, {
                    id = "Stealth",
                    delete_on_alarm = true,
                    progress = options.stealth_info_progress,
                    bodybags_format = options.stealth_info_bodybags_format
                })
            else
                EHIRightStealthItem = nil ---@diagnostic disable-line
            end
        end
    end
    EHI:AddCallback(EHI.CallbackMessage.InitManagers, function(managers) ---@param managers managers
        EHIHudlistManager._ws = managers.gui_data:create_fullscreen_workspace()
        EHIHudlistManager._ws:hide()
        EHI:AddCallback(EHI.CallbackMessage.HUDVisibilityChanged, function(visibility) ---@param visibility boolean
            if visibility then
                EHIHudlistManager._ws:show()
            else
                EHIHudlistManager._ws:hide()
            end
        end)
        if EHIHudlistManager._init_left_list then
            EHIHudlistManager:_init_left_list()
        end
        if EHIHudlistManager._init_right_list then
            EHIHudlistManager:_init_right_list()
        end
        EHI:AddOnAlarmCallback(function(dropin)
            EHIHudlistManager._left_list:SwitchToLoudMode()
            EHIHudlistManager._right_list:SwitchToLoudMode()
        end)
    end)
end

return EHIHudlistManager