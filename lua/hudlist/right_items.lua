---@alias EHIRightItemBase.Item { anims: { move: thread, visibility: thread }, panel: Panel, progress_bar: Color, progress: Bitmap, text: Text, count: number, i: integer, visible: boolean, ignore: boolean, force_visible: boolean, data: table }

---@class EHIRightItemBase
---@field new fun(self: self, panel: Panel, params: table): self
---@field _update_callback fun(t: number, dt: number)
---@field _update_id string
EHIRightItemBase = class()
EHIRightItemBase._PROGRESS_RECT = {
    { 32, 0, -32, 32 },
    { 128, 0, -128, 128 }
}
---@param o Bitmap
---@param text Text
---@param progress Color
---@param start_color Color
EHIRightItemBase._animate_item_up = function(o, text, progress, start_color)
    over(0.5, function(lerp, t)
        progress.red = math.lerp(0, 1, lerp)
        o:set_color(progress)
        text:set_color(math.lerp(start_color, Color.green, lerp))
    end)
    text:set_color(start_color)
end
---@param o Bitmap
---@param text Text
---@param progress Color
---@param start_color Color
EHIRightItemBase._animate_item_down = function(o, text, progress, start_color)
    over(0.5, function(lerp, t)
        progress.red = math.lerp(1, 0, lerp)
        o:set_color(progress)
        text:set_color(math.lerp(start_color, Color.red, lerp))
    end)
    progress.red = 1
    o:set_color(progress)
    text:set_color(start_color)
end
---@param o Panel
---@param a number
---@param target_alpha number
EHIRightItemBase._animate_item_visibility = function(o, a, target_alpha)
    over(0.15, function(lerp, t)
        o:set_alpha(math.lerp(a, target_alpha, lerp))
    end)
end
---@param o Panel
---@param target_right number
EHIRightItemBase._animate_item_right = function(o, target_right)
    local right = o:right()
    over(0.15, function(lerp, t)
        o:set_right(math.lerp(right, target_right, lerp))
    end)
end
---@param panel Panel
---@param params table
function EHIRightItemBase:init(panel, params)
    self._id = params.id
    self._panel = panel:panel({
        y = 90,
        w = panel:w(),
        h = 64 * self._SCALE,
        visible = false
    })
    self._delete_on_alarm = params.delete_on_alarm
    self._update_on_alarm = params.update_on_alarm
    self._update_on_spawn = params.update_on_spawn
    self:RegisterListeners(params)
end

---@param params table
function EHIRightItemBase:RegisterListeners(params)
end

function EHIRightItemBase:SwitchToLoudMode()
    if self._delete_on_alarm then
        self:delete()
    elseif self._update_on_alarm then
        self:OnAlarm()
    end
end

function EHIRightItemBase:OnAlarm()
end

function EHIRightItemBase:Spawned()
    if self._update_on_spawn then
        self:OnSpawn()
    end
end

function EHIRightItemBase:OnSpawn()
end

---@param id string
---@param params table
function EHIRightItemBase:CreateItem(id, params)
    self._items = self._items or {} ---@type table<string, EHIRightItemBase.Item>
    if params.ignore then
        -- Ignore items are still accessible through self._items but they are not itemized down below
        -- They do not have any panel data associated, game will crash if you try to access it
        self._items[id] = { ignore = true }
        return self._items[id]
    end
    self._itemized_items = self._itemized_items or {} ---@type EHIRightItemBase.Item[]
    self._n_of_items = self._n_of_items or 0
    local pos = params.pos or self._n_of_items + 1
    local w = 32 * self._SCALE
    local panel = self._panel:panel({
        alpha = 0,
        w = w,
        h = self._panel:h(), -- Scale is already applied here
        visible = true
    })
    panel:set_right(self._RIGHT_OFFSET)
    local progress
    local progress_bar = Color(1, 1, 0.125, 1)
    if self._PROGRESS == 1 then
        progress = panel:bitmap({
            alpha = self._PROGRESS_ALPHA,
            render_template = "VertexColorTexturedRadialFlex",
            layer = 2,
            y = w,
            w = w,
            h = w,
            texture = string.format("guis/textures/pd2_mod_ehi/buffs/buff_sframe_%s", self._PROGRESS_COLOR_STRING),
            texture_rect = self._PROGRESS_RECT[1],
            color = progress_bar,
            visible = self._PROGRESS_VISIBILITY
        })
        panel:rect({
            blend_mode = "normal",
            halign = "grow",
            alpha = self._BG_ALPHA,
            layer = -1,
            valign = "grow",
            y = w,
            w = w,
            h = w,
            color = self._BG_COLOR
        })
    else
        progress = panel:bitmap({
            alpha = self._PROGRESS_ALPHA,
            render_template = "VertexColorTexturedRadial",
            layer = 2,
            y = w,
            w = w,
            h = w,
            texture = string.format("guis/textures/pd2_mod_ehi/buffs/buff_cframe_%s", self._PROGRESS_COLOR_STRING),
            texture_rect = self._PROGRESS_RECT[2],
            color = progress_bar,
            visible = self._PROGRESS_VISIBILITY
        })
        panel:bitmap({
            alpha = self._BG_ALPHA,
            layer = -1,
            y = w,
            w = w,
            h = w,
            texture = "guis/textures/pd2_mod_ehi/buffs/buff_cframe_bg",
            color = self._BG_COLOR:with_alpha(0.2)
        })
    end
    local text = panel:text({
        name = "count",
        y = w,
        w = w,
        h = w,
        text = "0",
        font = tweak_data.menu.pd2_large_font,
        font_size = 24 * self._SCALE,
        align = "center",
        vertical = "center",
        color = self._PROGRESS_COLOR
    })
    local texture, texture_rect = tweak_data.ehi.default.hudlist.get_icon(params.icon)
    local icon = panel:bitmap({
        name = "icon",
        w = w,
        h = w,
        texture = texture,
        texture_rect = texture_rect,
        color = params.icon.color or self._PROGRESS_COLOR
    })
    if params.icon.scale then
        local w_new = w * params.icon.scale
        local offset = math.abs(w - w_new) / 2
        icon:set_size(w_new, w_new)
        icon:move(offset, 0)
    end
    local data = {
        anims = {},
        data = params.data or {},
        panel = panel,
        progress_bar = progress_bar,
        progress = progress,
        text = text,
        count = 0,
        i = pos,
        visible = false
    }
    if params.force_visible then
        data.visible = true
        data.force_visible = true
        panel:set_alpha(1)
        self:set_visible()
    end
    self._items[id] = data
    if not params.not_itemized then
        self._itemized_items[pos] = data
    end
    self._n_of_items = self._n_of_items + 1
    return data
end

---@param items table
function EHIRightItemBase:CreateItems(items)
    self._items = self._items or {} ---@type table<string, EHIRightItemBase.Item>
    self._itemized_items = self._itemized_items or {} ---@type EHIRightItemBase.Item[]
    self._n_of_items = self._n_of_items or 0
    local w = 32 * self._SCALE
    for _, item in ipairs(items) do
        local panel = self._panel:panel({
            alpha = 0,
            w = w,
            h = self._panel:h(), -- Scale is already applied here
            visible = true
        })
        panel:set_right(self._RIGHT_OFFSET)
        local progress
        local progress_bar = Color(1, 1, 0.125, 1)
        if self._PROGRESS == 1 then
            progress = panel:bitmap({
                render_template = "VertexColorTexturedRadialFlex",
                layer = 2,
                y = w,
                w = w,
                h = w,
                texture = string.format("guis/textures/pd2_mod_ehi/buffs/buff_sframe_%s", self._PROGRESS_COLOR_STRING),
                texture_rect = self._PROGRESS_RECT[1],
                color = progress_bar,
                visible = self._PROGRESS_VISIBILITY
            })
            panel:rect({
                blend_mode = "normal",
                halign = "grow",
                alpha = self._BG_ALPHA,
                layer = -1,
                valign = "grow",
                y = w,
                w = w,
                h = w,
                color = self._BG_COLOR
            })
        else
            progress = panel:bitmap({
                render_template = "VertexColorTexturedRadial",
                layer = 2,
                y = w,
                w = w,
                h = w,
                texture = string.format("guis/textures/pd2_mod_ehi/buffs/buff_cframe_%s", self._PROGRESS_COLOR_STRING),
                texture_rect = self._PROGRESS_RECT[2],
                color = progress_bar,
                visible = self._PROGRESS_VISIBILITY
            })
            panel:bitmap({
                alpha = self._BG_ALPHA,
                layer = -1,
                y = w,
                w = w,
                h = w,
                texture = "guis/textures/pd2_mod_ehi/buffs/buff_cframe_bg",
                color = self._BG_COLOR:with_alpha(0.2)
            })
        end
        local text = panel:text({
            name = "count",
            y = w,
            w = w,
            h = w,
            text = "0",
            font = tweak_data.menu.pd2_large_font,
            font_size = 24 * self._SCALE,
            align = "center",
            vertical = "center",
            color = self._PROGRESS_COLOR
        })
        local texture, texture_rect = tweak_data.ehi.default.hudlist.get_icon(item.icon)
        local icon = panel:bitmap({
            name = "icon",
            layer = 1,
            w = w,
            h = w,
            texture = texture,
            texture_rect = texture_rect,
            color = params.icon.color or self._PROGRESS_COLOR
        })
        if item.icon.scale then
            local w_new = w * item.icon.scale
            local offset = math.abs(w - w_new) / 2
            icon:set_size(w_new, w_new)
            icon:move(offset, 0)
        end
        local pos = self._n_of_items + 1
        local data = {
            anims = {},
            data = {},
            panel = panel,
            progress_bar = progress_bar,
            progress = progress,
            text = text,
            count = 0,
            i = pos,
            visible = false
        }
        self._items[item.id] = data
        self._itemized_items[pos] = data
        self._n_of_items = pos
    end
end

---@param text Text
function EHIRightItemBase:FitTheText(text)
    text:set_font_size(text:h())
    local w = select(3, text:text_rect())
    if w > text:w() then
        text:set_font_size(text:font_size() * (text:w() / w))
    end
end

function EHIRightItemBase:set_visible()
    if self._visible then
        return
    end
    self._visible = true
    self._panel:show()
    self._parent:ItemSetVisible(self)
end

function EHIRightItemBase:set_hidden()
    if not self._visible then
        return
    end
    self._visible = false
    self._panel:hide()
    self._parent:ItemSetHidden()
end

function EHIRightItemBase:visible()
    return self._visible
end

---Same as `_update_items_visibility()` but without any animations  
---Useful if items needs to be sorted during loading screen or on spawn
function EHIRightItemBase:_update_items_visibility_fast()
    local right = self._RIGHT_OFFSET
    local offset = 0
    local space = 5 * self._SCALE
    local items_visible = 0
    for _, item in ipairs(self._itemized_items) do
        local panel = item.panel
        if item.force_visible or item.count > 0 then
            item.visible = true
            panel:set_alpha(1)
            panel:set_right(right - offset)
            offset = offset + panel:w() + space
            items_visible = items_visible + 1
        else
            item.visible = false
            panel:set_alpha(0)
        end
    end
    if items_visible > 0 then
        self:set_visible()
    else
        self:set_hidden()
    end
end

function EHIRightItemBase:_update_items_visibility()
    local right = self._RIGHT_OFFSET
    local offset = 0
    local space = 5 * self._SCALE
    local items_visible = 0
    for _, item in ipairs(self._itemized_items) do
        local panel = item.panel
        local a = panel:alpha()
        if item.force_visible or item.count > 0 then
            item.visible = true
            if a < 1 then
                if item.anims.visibility then
                    panel:stop(item.anims.visibility)
                end
                item.anims.visibility = panel:animate(self._animate_item_visibility, a, 1)
            end
            if item.anims.move then
                panel:stop(item.anims.move)
            end
            item.anims.move = panel:animate(self._animate_item_right, right - offset)
            offset = offset + panel:w() + space
            items_visible = items_visible + 1
        else
            item.visible = false
            if a > 0 then
                if item.anims.visibility then
                    panel:stop(item.anims.visibility)
                end
                item.anims.visibility = panel:animate(self._animate_item_visibility, a, 0)
            end
        end
    end
    if items_visible > 0 then
        self:set_visible()
    else
        self:set_hidden()
    end
end

---@param item EHIRightItemBase.Item
---@param no_reorganization boolean?
---@return boolean?
function EHIRightItemBase:_set_item_ignored(item, no_reorganization)
    if item.ignore then
        return
    end
    local i = item.i
    item.panel:parent():remove(item.panel)
    item.i = nil
    item.panel = nil
    item.progress = nil
    item.progress_bar = nil
    item.text = nil
    item.anims = nil
    item.data = nil
    item.visible = nil
    item.ignore = true
    table.remove(self._itemized_items, i)
    for _, itm in ipairs(self._itemized_items) do
        if i < itm.i then -- Reposition other items that were created after our now destroyed item
            itm.i = itm.i - 1
        end
    end
    if item.count > 0 and not no_reorganization then
        self:_update_items_visibility()
    end
    item.count = nil
    return true
end

function EHIRightItemBase:UnregisterListeners()
end

---@param item EHIRightItemBase.Item
---@param previous_count number
---@param count number?
function EHIRightItemBase:AnimateItem(item, previous_count, count)
    if self._PROGRESS_STATIC then
        return
    end
    count = count or item.count
    if previous_count < count then
        item.progress:stop()
        item.progress:animate(self._animate_item_up, item.text, item.progress_bar, self._PROGRESS_COLOR)
    elseif previous_count > count and count > 0 then -- There is no point in animating the panel when it is getting hidden during the check in an anim thread
        item.progress:stop()
        item.progress:animate(self._animate_item_down, item.text, item.progress_bar, self._PROGRESS_COLOR)
    end
end

function EHIRightItemBase:delete()
    self:UnregisterListeners()
    if self._visible then
        self._parent:ItemSetHidden()
    end
    self._parent:RemoveItem(self._id)
end

function EHIRightItemBase:destroy()
    if self._panel and alive(self._panel) then
        self._panel:parent():remove(self._panel)
    end
end

---@class EHIRightUnitItem : EHIRightItemBase
---@field super EHIRightItemBase
EHIRightUnitItem = class(EHIRightItemBase)
EHIRightUnitItem._update_id = "EHIRightUnitItem"
EHIRightUnitItem._UNITS = {
    cop = "enemy",
    cop_female = "enemy",
    fbi = "enemy",
    fbi_female = "enemy",
    swat = "enemy",
    heavy_swat = "enemy",
    heavy_swat_sniper = "enemy",
    fbi_swat = "enemy",
    fbi_heavy_swat = "enemy",
    city_swat = "enemy",
    security = "enemy",
    security_undominatable = "enemy",
    security_mex_no_pager = "enemy",
    security_mex = "enemy",
    gensec = "enemy",
    bolivian_indoors = "enemy",
    bolivian_indoors_mex = "enemy",
    bolivian = "enemy",
    gangster = "enemy",
    triad = "enemy",
    mobster = "enemy",
    biker = "enemy",
    biker_female = "enemy",
    biker_escape = "enemy",
    tank = "enemy",
    tank_green = "enemy",
    tank_black = "enemy",
    tank_skull = "enemy",
    tank_hw = "enemy",
    tank_medic = "enemy",
    tank_mini = "enemy",
    spooc = "enemy",
    shadow_spooc = "enemy",
    taser = "enemy",
    shield = "enemy",
    sniper = "enemy",
    medic = "enemy",
    biker_boss = "enemy",
    chavez_boss = "enemy",
    drug_lord_boss = "enemy",
    drug_lord_boss_stealth = "enemy",
    hector_boss = "enemy",
    hector_boss_no_armor = "enemy",
    mobster_boss = "enemy",
    triad_boss = "enemy",
    triad_boss_no_armor = "enemy",
    ranchmanager = "enemy",
    marshal_marksman = "enemy",
    marshal_shield = "enemy",
    marshal_shield_break = "enemy",
    zeal_heavy_swat = "enemy",
    zeal_swat = "enemy",
    phalanx_vip = "enemy",
    phalanx_minion = "enemy",

    old_hoxton_mission = "ignore", -- Hoxton (Hoxton Breakout) / Locke (Beneath the Mountain)
    spa_vip = "ignore", -- Charon (Brooklyn 10-10)
    captain = "ignore", -- Cabin Crew + Captain (Alaskan Deal)
    captain_female = "ignore" -- Cabin Crew (Alaskan Deal)
}
EHIRightUnitItem._TWEAK_NAME_TO_STATS_NAME = {}
function EHIRightUnitItem:RegisterListeners(params)
    self._minions_without_snipers = 0
    self._minions = 0
    self._minions_key = {} ---@type table<userdata, { is_heavy_zeal_sniper: boolean }?>
    self._police_hostages = 0
    self._civilian_hostages = 0
    self._enemy_turrets = 0
    Hooks:PostHook(EnemyManager, "on_enemy_registered", "EHI_right_items_on_enemy_registered", function(em, unit, ...) ---@param unit UnitEnemy
        local base = unit:base()
        self:EnemySpawned(base._tweak_table, base._stats_name)
    end)
    Hooks:PostHook(EnemyManager, "on_enemy_unregistered", "EHI_right_items_on_enemy_unregistered", function(em, unit, ...) ---@param unit UnitEnemy
        local base = unit:base()
        self:EnemyDespawned(base._tweak_table, base._stats_name)
    end)
    local CountCivilian = tweak_data.ehi.functions.CountCivilian
    Hooks:PostHook(EnemyManager, "register_civilian", "EHI_right_items_register_civilian", function(em, unit, ...) ---@param unit UnitCivilian
        local unit_data = em._civilian_data.unit_data
        if CountCivilian(unit_data[unit:key()]) then
            self:CivilianSpawned()
        end
    end)
    Hooks:PreHook(EnemyManager, "on_civilian_died", "EHI_right_items_on_civilian_died", function(em, dead_unit, ...) ---@param dead_unit UnitCivilian
        local unit_data = em._civilian_data.unit_data
        if CountCivilian(unit_data[dead_unit:key()]) then
            self:CivilianDespawned()
        end
    end)
    Hooks:PreHook(EnemyManager, "on_civilian_destroyed", "EHI_right_items_on_civilian_destroyed", function(em, civilian, ...) ---@param civilian UnitCivilian
        local civilian_data = em._civilian_data.unit_data
        local unit_data = civilian_data[civilian:key()]
        if unit_data and CountCivilian(unit_data) then
            self:CivilianDespawned()
        end
    end)
    EHI:AddCallback(EHI.CallbackMessage.OnMinionAdded, function(unit, ...) ---@param unit UnitEnemy
        local key = unit:key()
        if not self._minions_key[key] then
            local data = {}
            local base = unit:base()
            if base and base._tweak_table == "heavy_swat_sniper" and self._items.sniper_heavy then
                data.is_heavy_zeal_sniper = true
                self:EnemyDespawned("heavy_swat_sniper", "heavy_swat_sniper") -- Subtract the amount as the converted unit is Heavy ZEAL Sniper (the item only shows number of hostile units)
            else
                self._minions_without_snipers = self._minions_without_snipers + 1
            end
            self._minions = self._minions + 1
            self._minions_key[key] = data
            self:_update_converts(1)
        end
    end)
    EHI:AddCallback(EHI.CallbackMessage.OnMinionKilled, function(key, ...) ---@param key userdata
        local data = table.remove_key(self._minions_key, key)
        if data then
            self._minions = math.max(self._minions - 1, 0)
            if data.is_heavy_zeal_sniper then
                self:EnemySpawned("heavy_swat_sniper", "heavy_swat_sniper") -- Add subtracted number here in killed callback for item to work properly
            else
                self._minions_without_snipers = math.max(self._minions_without_snipers - 1, 0)
            end
            self:_update_converts(-1)
        end
    end)
    if EHI.IsHost then
        Hooks:PostHook(GroupAIStateBase, "on_hostage_state", "EHI_right_items_on_hostage_state", function(ai_state, ...)
            local total_hostages = ai_state._hostage_headcount
            self._police_hostages = ai_state._police_hostage_headcount
            self:SetEnemyCount()
            self:SetCivilianHostages(total_hostages - self._police_hostages)
            self:SetPoliceHostages(self._police_hostages)
        end)
    else
        Hooks:PostHook(GroupAIStateBase, "sync_hostage_headcount", "EHI_right_items_sync_hostage_headcount", function(...)
            self._t = 5
            self:AddToUpdate()
        end)
        self._t = 0
        self._update_callback = function(t, dt) ---@param dt number
            self._t = self._t - dt
            if self._t <= 0 then
                self:RemoveFromUpdate()
                self:_update_hostages_client()
            end
        end
    end
    Hooks:PostHook(GroupAIStateBase, "register_turret", "EHI_right_items_register_turret", function(...)
        self:EnemyTurretSpawned()
    end)
    Hooks:PostHook(GroupAIStateBase, "unregister_turret", "EHI_right_items_unregister_turret", function(...)
        self:EnemyTurretDespawned()
    end)
end

function EHIRightUnitItem:AddToUpdate()
    if not self._update_created then
        managers.hud:add_updator(self._update_id, self._update_callback)
        self._update_created = true
    end
end

function EHIRightUnitItem:RemoveFromUpdate()
    if self._update_created then
        managers.hud:remove_updator(self._update_id)
        self._update_created = false
    end
end

---@param is_holdout boolean
---@param u_options table
function EHIRightUnitItem:CreateItemsFromMap(is_holdout, u_options)
    local slots = {} ---@type EHIRightItemBase.Item[]
    local occupied_slots = {} ---@type EHIRightItemBase.Item[]
    ---@param item EHIRightItemBase.Item
    ---@param slot integer
    local function handle_new_item_in_the_slot(item, slot)
        if slots[slot] then
            table.insert(occupied_slots, item)
        else
            slots[slot] = item
        end
    end
    local is_playing_safehouse_nightmare = Global.game_settings.level_id == "haunted"
    local stealth_required = tweak_data.levels:IsStealthRequired()
    if managers.crime_spree:is_active() then
        self._update_on_spawn = true
        self._playing_crime_spree = true
        self._crime_spree_modifiers = {
            ModifierHeavySniper = "sniper_heavy",
            ModifierSkulldozers = "dozer_skull",
            ModifierShieldPhalanx = "phalanx",
            ModifierDozerMinigun = "dozer_mini",
            ModifierDozerMedic = "dozer_medic"
        }
    end
    if is_holdout then
        self._update_on_spawn = true
        self._playing_holdout = true
        self._assault_modifiers = {
            [3] = "dozer_skull",
            [5] = "sniper_heavy",
            [7] = "dozer_medic",
            [9] = "dozer_mini"
        }
        ---@param wave_number integer
        local function activate_item_in_wave(wave_number)
            local modifier = self._assault_modifiers[wave_number]
            local item = modifier and self._items[modifier]
            local data = item and item.data
            if data and data.persistent and not item.force_visible then
                item.force_visible = true
                self:_update_items_visibility()
            end
        end
        managers.ehi_assault:AddAssaultStartCallback(activate_item_in_wave)
        if EHI.IsClient then
            managers.ehi_assault:AddAssaultNumberSyncCallback(function(assault_number)
                for i = 0, assault_number, 1 do
                    activate_item_in_wave(i)
                end
            end)
        end
    end
    self:CreateItem("ignore", { ignore = true })
    local regular_icon = (EHI:IsDifficulty(EHI.Difficulties.DeathSentence) and u_options.regular_ds_icon == 2) and {
        ehi = EHI:GetAchievementIconString("gage5_6")
    } or { skills = { 6, 1 } }
    regular_icon.color = EHI:GetColor(u_options.regular_color)
    handle_new_item_in_the_slot(self:CreateItem("enemy", {
        icon = regular_icon,
        force_visible = u_options.regular_persistent,
        not_itemized = true
    }), u_options.regular_pos)
    if u_options.converts_count and not stealth_required then
        handle_new_item_in_the_slot(self:CreateItem("minion", {
            icon = {
                skills = { 6, 8 },
                color = EHI:GetColor(u_options.converts_count_color)
            },
            data = {
                persistent = u_options.converts_count_persistent,
                check = true
            },
            not_itemized = true
        }), u_options.converts_count_pos)
    end
    if u_options.enemy_tied_count then
        handle_new_item_in_the_slot(self:CreateItem("enemy_tied", {
            icon = {
                skills = { 2, 8 },
                color = EHI:GetColor(u_options.enemy_tied_count_color)
            },
            data =
            {
                persistent = u_options.enemy_tied_count_persistent,
                check = true
            },
            not_itemized = true
        }), u_options.enemy_tied_count_pos)
    end
    if not stealth_required then -- Do not create special enemy items if we are playing stealth only heist; it is pointless
        self._update_on_alarm = true
        local group_ai = tweak_data.group_ai
        local OVK_or_Above = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
        if u_options.dozer_count then
            local spawns_enabled = EHI:IsDifficultyOrAbove(EHI.Difficulties.Hard) and group_ai:IsSpecialEnemyAllowedToSpawn("tank")
            if u_options.dozer_count_separate then
                self._TWEAK_NAME_TO_STATS_NAME.tank = true
                if u_options.dozer_count_hw then
                    local dozer_hw_visible = false
                    if u_options.dozer_count_hw_persistent then
                        if is_playing_safehouse_nightmare then
                            dozer_hw_visible = true
                        elseif (Global.game_settings.level_id == "nail" or Global.game_settings.level_id == "help" or Global.game_settings.level_id == "hvh") and OVK_or_Above then -- Headless dozers are allowed on OVK or above
                            dozer_hw_visible = true
                        end
                    end
                    handle_new_item_in_the_slot(self:CreateItem("dozer_hw", {
                        icon = {
                            ehi = "heavy",
                            color = EHI:GetColor(u_options.dozer_count_hw_color)
                        },
                        data = {
                            persistent = true,
                            check = dozer_hw_visible
                        },
                        not_itemized = true
                    }), u_options.dozer_count_hw_pos)
                    self._UNITS.tank_hw = "dozer_hw"
                end
                if not is_playing_safehouse_nightmare then
                    if u_options.dozer_count_medic then
                        handle_new_item_in_the_slot(self:CreateItem("dozer_medic", {
                            icon = {
                                ehi = "crime_spree_dozer_medic",
                                color = EHI:GetColor(u_options.dozer_count_medic_color)
                            },
                            data = {
                                persistent = u_options.dozer_count_medic_persistent,
                                check = spawns_enabled and EHI:IsDifficulty(EHI.Difficulties.DeathSentence)
                            },
                            not_itemized = true
                        }), u_options.dozer_count_medic_pos)
                        self._UNITS.tank_medic = "dozer_medic"
                    end
                    if u_options.dozer_count_mini then
                        handle_new_item_in_the_slot(self:CreateItem("dozer_mini", {
                            icon = {
                                ehi = "crime_spree_dozer_minigun",
                                color = EHI:GetColor(u_options.dozer_count_mini_color)
                            },
                            data = {
                                persistent = u_options.dozer_count_mini_persistent,
                                check = spawns_enabled and EHI:IsDifficultyOrAbove(EHI.Difficulties.DeathWish)
                            },
                            not_itemized = true
                        }), u_options.dozer_count_mini_pos)
                        self._UNITS.tank_mini = "dozer_mini"
                    end
                    if u_options.dozer_count_skull then
                        handle_new_item_in_the_slot(self:CreateItem("dozer_skull", {
                            icon = {
                                ehi = "crime_spree_dozer_lmg",
                                color = EHI:GetColor(u_options.dozer_count_skull_color)
                            },
                            data = {
                                persistent = u_options.dozer_count_skull_persistent,
                                check = spawns_enabled and EHI:IsMayhemOrAbove()
                            },
                            not_itemized = true
                        }), u_options.dozer_count_skull_pos)
                        self._UNITS.tank_skull = "dozer_skull"
                    end
                    if u_options.dozer_count_black then
                        handle_new_item_in_the_slot(self:CreateItem("dozer_black", {
                            icon = {
                                ehi = "heavy",
                                color = EHI:GetColor(u_options.dozer_count_black_color)
                            },
                            data = {
                                persistent = u_options.dozer_count_black_persistent,
                                check = spawns_enabled and OVK_or_Above
                            },
                            not_itemized = true
                        }), u_options.dozer_count_black_pos)
                        self._UNITS.tank_black = "dozer_black"
                    end
                    if u_options.dozer_count_green then
                        handle_new_item_in_the_slot(self:CreateItem("dozer_green", {
                            icon = {
                                ehi = "heavy",
                                color = EHI:GetColor(u_options.dozer_count_green_color)
                            },
                            data = {
                                persistent = u_options.dozer_count_green_persistent,
                                check = spawns_enabled
                            },
                            not_itemized = true
                        }), u_options.dozer_count_green_pos)
                        self._UNITS.tank_green = "dozer_green"
                    end
                end
            else
                self._UNITS.tank = "dozer"
                self._UNITS.tank_hw = "dozer"
                self._UNITS.tank_medic = "dozer"
                self._UNITS.tank_mini = "dozer"
                handle_new_item_in_the_slot(self:CreateItem("dozer", {
                    icon = {
                        ehi = "heavy",
                        color = EHI:GetColor(u_options.dozer_count_color)
                    },
                    data = {
                        persistent = u_options.dozer_count_persistent,
                        check = is_playing_safehouse_nightmare or spawns_enabled
                    },
                    not_itemized = true
                }), u_options.dozer_count_pos)
            end
        end
        if u_options.sniper_count then
            self._UNITS.sniper = "sniper"
            handle_new_item_in_the_slot(self:CreateItem("sniper", {
                icon = {
                    ehi = "sniper",
                    color = EHI:GetColor(u_options.sniper_count_color)
                },
                data = {
                    persistent = u_options.sniper_count_persistent,
                    check = false
                },
                not_itemized = true
            }), u_options.sniper_count_pos)
        end
        if u_options.heavy_sniper_count then
            self._UNITS.heavy_swat_sniper = "sniper_heavy"
            handle_new_item_in_the_slot(self:CreateItem("sniper_heavy", {
                icon = {
                    ehi = "crime_spree_heavy_sniper",
                    color = EHI:GetColor(u_options.heavy_sniper_count_color)
                },
                data = {
                    persistent = u_options.heavy_sniper_count_persistent,
                    check = false
                },
                not_itemized = true
            }), u_options.heavy_sniper_count_pos)
        end
        if u_options.marshal_sniper_count then
            local marshal_spawn_group = group_ai.enemy_spawn_groups and group_ai.enemy_spawn_groups.marshal_squad
            self._UNITS.marshal_marksman = "sniper_marshal"
            handle_new_item_in_the_slot(self:CreateItem("sniper_marshal", {
                icon = {
                    ehi = EHI:GetAchievementIconString("cac_4"),
                    color = EHI:GetColor(u_options.marshal_sniper_count_color),
                    scale = 0.95
                },
                data = {
                    persistent = u_options.marshal_sniper_count_persistent,
                    check = marshal_spawn_group ~= nil
                },
                not_itemized = true
            }), u_options.marshal_sniper_count_pos)
        end
        if u_options.taser_count then
            self._UNITS.taser = "taser"
            handle_new_item_in_the_slot(self:CreateItem("taser", {
                icon = {
                    ehi = EHI:GetAchievementIconString("halloween_5"),
                    color = EHI:GetColor(u_options.taser_count_color)
                },
                data = {
                    persistent = u_options.taser_count_persistent,
                    check = group_ai:IsSpecialEnemyAllowedToSpawn("taser")
                },
                not_itemized = true
            }), u_options.taser_count_pos)
        end
        if u_options.medic_count then
            self._UNITS.medic = "medic"
            handle_new_item_in_the_slot(self:CreateItem("medic", {
                icon = {
                    texture = "guis/textures/pd2_mod_ehi/medic_icon",
                    color = EHI:GetColor(u_options.medic_count_color)
                },
                data = {
                    persistent = u_options.medic_count_persistent,
                    check = group_ai:IsSpecialEnemyAllowedToSpawn("medic") and OVK_or_Above
                },
                not_itemized = true
            }), u_options.medic_count_pos)
        end
        if u_options.cloaker_count then
            self._UNITS.spooc = "cloaker"
            self._UNITS.shadow_spooc = "cloaker"
            local visible = false
            if u_options.cloaker_count_persistent then
                if is_playing_safehouse_nightmare then
                    visible = EHI:IsDifficultyOrAbove(EHI.Difficulties.Hard) -- Cloakers are hardcoded to spawn on Hard or above
                else
                    visible = group_ai:IsSpecialEnemyAllowedToSpawn("spooc")
                end
            end
            handle_new_item_in_the_slot(self:CreateItem("cloaker", {
                icon = {
                    ehi = EHI:GetAchievementIconString("gage2_8"),
                    scale = 0.9,
                    color = EHI:GetColor(u_options.cloaker_count_color)
                },
                data = {
                    persistent = true,
                    check = visible
                },
                not_itemized = true
            }), u_options.cloaker_count_pos)
        end
        if u_options.shield_count then
            self._UNITS.shield = "shield"
            handle_new_item_in_the_slot(self:CreateItem("shield", {
                icon = {
                    ehi = EHI:GetAchievementIconString("gage4_6"),
                    color = EHI:GetColor(u_options.shield_count_color)
                },
                data = {
                    persistent = u_options.shield_count_persistent,
                    check = group_ai:IsSpecialEnemyAllowedToSpawn("shield")
                },
                not_itemized = true
            }), u_options.shield_count_pos)
        end
        if u_options.marshal_shield_count then
            local marshal_spawn_group = group_ai.enemy_spawn_groups and group_ai.enemy_spawn_groups.marshal_squad
            self._UNITS.marshal_shield = "shield_marshal"
            self._UNITS.marshal_shield_break = "shield_marshal"
            handle_new_item_in_the_slot(self:CreateItem("shield_marshal", {
                icon = {
                    ehi = "equipment_sheriff_star",
                    color = EHI:GetColor(u_options.marshal_shield_count_color)
                },
                data = {
                    persistent = u_options.marshal_shield_count_persistent,
                    check = marshal_spawn_group ~= nil
                },
                not_itemized = true
            }), u_options.marshal_shield_count_pos)
        end
        if u_options.captain_count then
            self._UNITS.phalanx_vip = "captain"
            handle_new_item_in_the_slot(self:CreateItem("captain", {
                icon = {
                    ehi = EHI:GetAchievementIconString("farm_1"),
                    color = EHI:GetColor(u_options.captain_count_color)
                },
                not_itemized = true
            }), u_options.captain_count_pos)
        end
        if u_options.phalanx_count then
            self._UNITS.phalanx_minion = "phalanx"
            handle_new_item_in_the_slot(self:CreateItem("phalanx", {
                icon = {
                    ehi = "crime_spree_shield_phalanx",
                    color = EHI:GetColor(u_options.phalanx_count_color)
                },
                data = {
                    persistent = false,
                    check = false
                },
                not_itemized = true
            }), u_options.phalanx_count_pos)
        end
        if u_options.turret_count then
            handle_new_item_in_the_slot(self:CreateItem("turret", {
                icon = {
                    skills = { 7, 5 },
                    color = EHI:GetColor(u_options.turret_count_color)
                },
                not_itemized = true
            }), u_options.turret_count_pos)
        end
    end
    if is_holdout or is_playing_safehouse_nightmare then
        self._items.civilian = self._items.ignore
        self._items.civilian_tied = self._items.ignore
        self._all_civilians_blocked = true
    else
        if u_options.civilian_count then
            handle_new_item_in_the_slot(self:CreateItem("civilian", {
                icon = {
                    skills = { 6, 7 },
                    color = EHI:GetColor(u_options.civilian_count_color)
                },
                not_itemized = true
            }), u_options.civilian_count_pos)
        end
        if u_options.civilian_tied_count then
            handle_new_item_in_the_slot(self:CreateItem("civilian_tied", {
                icon = {
                    skills = { 4, 7 },
                    color = EHI:GetColor(u_options.civilian_tied_count_color)
                },
                not_itemized = true
            }), u_options.civilian_tied_count_pos)
        end
    end
    local list_count, offset = table.ehi_size(self._itemized_items), 1
    for i = 1, 22, 1 do
        local slot = slots[i]
        if slot then -- Some slots could be nil as items could have moved or are not created at all
            local j = list_count + offset
            slot.i = j
            self._itemized_items[j] = slot
            offset = offset + 1
        end
    end
    for _, item in ipairs(occupied_slots) do
        local i = list_count + offset
        item.i = i
        self._itemized_items[i] = item
        offset = offset + 1
    end
    self:CreateItem("unknown", {
        icon = {
            ehi = "default"
        }
    })
    self._units_map = {} ---@type table<string, EHIRightItemBase.Item?>
    for key, group in pairs(self._UNITS) do
        self._units_map[key] = self._items[group] or self._items.unknown
    end
    self:_update_items_visibility_fast()
end

function EHIRightUnitItem:EnablePersistentSniperItem()
    local snp = self._items.sniper
    if snp and snp.data.persistent then
        snp.data.check = true
    end
end

function EHIRightUnitItem:OnAlarm()
    self._alarm = true
    local set_visible = 0
    for _, item in pairs(self._items) do
        local data = item.data
        if data and data.persistent and data.check ~= false then
            item.force_visible = true
            set_visible = set_visible + 1
        end
    end
    if set_visible > 0 then
        self:_update_items_visibility()
    end
end

function EHIRightUnitItem:OnSpawn()
    if self._playing_crime_spree then
        for mod, name in pairs(self._crime_spree_modifiers) do
            if managers.modifiers:IsModifierActive(mod, "crime_spree") then
                local item = self._items[name]
                local data = item and item.data
                if data then
                    if self._alarm then
                        if data.persistent and not item.force_visible then
                            item.force_visible = true
                        end
                    elseif data.persistent and data.check == false then
                        data.check = true
                    end
                end
                if mod == "ModifierShieldPhalanx" then -- Disable persistent normal shields
                    local shield = self._items.shield
                    local d_shield = shield and shield.data
                    if d_shield and d_shield.persistent then
                        shield.force_visible = nil
                        d_shield.check = false
                    end
                end
            end
        end
        if self._alarm then
            self:_update_items_visibility_fast()
        end
    end
    if self._playing_holdout then
        if managers.modifiers:IsModifierActive("ModifierShieldPhalanx", "skirmish_weekly") then
            local phalanx_shield = self._items.phalanx
            if phalanx_shield and phalanx_shield.data and phalanx_shield.data.persistent then
                phalanx_shield.force_visible = true
            end
            local shield = self._items.shield
            if shield and shield.data and shield.data.persistent then
                shield.force_visible = nil
            end
            self:_update_items_visibility_fast()
        end
    end
end

--- Also called Unobtanium  
--- Players entered the secret area in The White House (if they are worthy)
function EHIRightUnitItem:uno()
    local cloaker_id = self._items.cloaker and "cloaker" or "enemy"
    local removed = 0
    for key, item in pairs(self._items) do
        if key ~= cloaker_id and self:_set_item_ignored(item, true) then
            removed = removed + 1
            break
        end
    end
    if removed > 0 then
        self:_update_items_visibility()
    end
end

function EHIRightUnitItem:AnimateItem(item, previous_count, count)
    EHIRightUnitItem.super.AnimateItem(self, item, previous_count, count)
    if self._PROGRESS_STATIC then
        return
    elseif (count or item.count) == 0 and item.force_visible then
        item.progress:stop()
        item.progress:animate(self._animate_item_down, item.text, item.progress_bar, self._PROGRESS_COLOR)
    end
end

function EHIRightUnitItem:SetEnemyCount()
    local count = 0
    for _, data in pairs(managers.enemy:all_enemies()) do
        local unit = alive(data.unit) and data.unit:base()
        if unit and unit._tweak_table and self._UNITS[unit._tweak_table] == "enemy" then
            count = count + 1
        end
    end
    local en = self._items.enemy
    local previous_count = en.count
    local final = count - self._minions_without_snipers - self._police_hostages + self._enemy_turrets
    en.count = final
    en.text:set_text(tostring(final))
    self:AnimateItem(en, previous_count, final)
    if (final > 0 and not en.visible) or (en.visible and final <= 0) then
        self:_update_items_visibility()
    end
end

---@param diff integer
function EHIRightUnitItem:_update_converts(diff)
    local min = self._items.minion
    if min.ignore then
        self:SetEnemyCount()
        return
    end
    min.count = self._minions
    min.text:set_text(tostring(self._minions))
    self:SetEnemyCount()
    self:AnimateItem(min, diff > 0 and -math.huge or math.huge)
    self:_update_items_visibility()
end

function EHIRightUnitItem:_update_hostages_client()
    local police_hostages = 0
    local hostages = managers.groupai:state()._hostage_headcount

    for _, u_data in pairs(managers.enemy:all_enemies()) do
        if alive(u_data.unit) and u_data.unit:brain():surrendered() then
            police_hostages = police_hostages + 1
        end
    end

    self:SetCivilianHostages(hostages - police_hostages)
    self:SetPoliceHostages(police_hostages)
end

function EHIRightUnitItem:CivilianSpawned()
    local civ = self._items.civilian
    if not civ or civ.ignore then
        return
    end
    civ.count = civ.count + 1
    civ.text:set_text(tostring(civ.count))
    self:AnimateItem(civ, -math.huge)
    if not civ.visible then
        self:_update_items_visibility()
    end
end

function EHIRightUnitItem:CivilianDespawned()
    local civ = self._items.civilian
    if not civ or civ.ignore then
        return
    end
    local final = math.max(civ.count - 1, 0)
    civ.count = final
    civ.text:set_text(tostring(final))
    self:AnimateItem(civ, math.huge)
    if final <= 0 and civ.visible then
        self:_update_items_visibility()
    end
end

---@param count integer
function EHIRightUnitItem:SetCivilianHostages(count)
    if self._civilian_hostages == count or self._all_civilians_blocked then
        return
    end
    self._civilian_hostages = count
    local civ_t = self._items.civilian_tied
    if civ_t then
        local civ_t_previous = civ_t.count
        civ_t.count = count
        civ_t.text:set_text(tostring(count))
        self:AnimateItem(civ_t, civ_t_previous, count)
    end
    local civ = self._items.civilian
    if civ then
        local civ_previous = civ.count
        local civilians = table.count(managers.enemy:all_civilians(), tweak_data.ehi.functions.CountCivilian)
        local civ_final = math.max(civilians - count, 0)
        civ.count = civ_final
        civ.text:set_text(tostring(civ_final))
        self:AnimateItem(civ, civ_previous, civ_final)
    end
    if not self._items.enemy_tied then
        self:_update_items_visibility() -- Update visibility if tied enemies item is disabled
    end
end

---@param count integer
function EHIRightUnitItem:SetPoliceHostages(count)
    local cop = self._items.enemy_tied
    if not cop then
        return
    end
    local previous_count = cop.count
    cop.count = count
    cop.text:set_text(tostring(count))
    self:AnimateItem(cop, previous_count, count)
    self:_update_items_visibility() -- Civilian hostages are updated before police hostages
end

---@param tweak_data string
---@param stats_data string
function EHIRightUnitItem:EnemySpawned(tweak_data, stats_data)
    local id = self._TWEAK_NAME_TO_STATS_NAME[tweak_data] and stats_data or tweak_data
    local group = self._units_map[id] or self._items.unknown
    if group.ignore then
        return
    end
    local previous_count = group.count
    local final = previous_count + 1
    group.count = final
    group.text:set_text(tostring(final))
    self:AnimateItem(group, previous_count, final)
    if final > 0 and not group.visible then
        self:_update_items_visibility()
    end
end

---@param tweak_data string
---@param stats_data string
function EHIRightUnitItem:EnemyDespawned(tweak_data, stats_data)
    local id = self._TWEAK_NAME_TO_STATS_NAME[tweak_data] and stats_data or tweak_data
    local group = self._units_map[id] or self._items.unknown
    if group.ignore then
        return
    end
    local previous_count = group.count
    local final = math.max(previous_count - 1, 0)
    group.count = final
    group.text:set_text(tostring(final))
    self:AnimateItem(group, previous_count, final)
    if final <= 0 and group.visible then
        self:_update_items_visibility()
    end
end

function EHIRightUnitItem:IgnoreEnemyTurret()
    local t = self._items.turret
    if t then
        self:_set_item_ignored(t)
    else
        self._enemy_turrets = 0
        self:SetEnemyCount()
    end
end

function EHIRightUnitItem:EnemyTurretSpawned()
    local t = self._items.turret
    if t then
        if t.ignore then
            return
        end
        local previous_count = t.count
        t.count = previous_count + 1
        t.text:set_text(tostring(t.count))
        self:AnimateItem(t, previous_count)
        if t.count > 0 and not t.visible then
            self:_update_items_visibility()
        end
    else
        self._enemy_turrets = self._enemy_turrets + 1
        self:SetEnemyCount()
    end
end

function EHIRightUnitItem:EnemyTurretDespawned()
    local t = self._items.turret
    if t then
        if t.ignore then
            return
        end
        local previous_count = t.count
        t.count = previous_count - 1
        t.text:set_text(tostring(t.count))
        self:AnimateItem(t, previous_count)
        if t.count <= 0 and t.visible then
            self:_update_items_visibility()
        end
    else
        self._enemy_turrets = math.max(self._enemy_turrets - 1, 0)
        self:SetEnemyCount()
    end
end

---@class EHIRightLootItem : EHIRightItemBase
---@field super EHIRightItemBase
EHIRightLootItem = class(EHIRightItemBase)
EHIRightLootItem._DEFERRED_GROUPS =
{
    money = { text = { name = "Money" }, icon = { ehi = "equipment_plates" } },
    gold = { text = { name = "Gold" }, icon = { texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4", texture_rect = { 348, 0, 85, 60 } } },
    jewelry = { text = { name = "Jewelry" }, icon = { texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2", texture_rect = { 97, 783, 65, 60 } } },
    coke = { text = { name = "Coke" }, icon = { skills = { 0, 10 } } },
    diamonds = { text = { name = "Diamonds" }, icon = { texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7", texture_rect = { 87, 0, 71, 61 } } },
    diamond = { text = { name = "Diamond" }, icon = { ehi = EHI:GetAchievementIconString("dah_9") } },
    artifact = { text = { name = "Artifact" }, icon = { ehi = EHI:GetAchievementIconString("bat_6") } },
    bomb = { text = { name = "Bomb" }, icon = { texture = tweak_data.preplanning.gui.type_icons_path, texture_rect = { 10 * 48, 4 * 48, 48, 48 } } },
    meth = { text = { name = "Meth" }, icon = { ehi = "pd2_methlab" } },
    weapon = { text = { name = "Weapons" }, icon = { ehi = EHI:GetAchievementIconString("halloween_9") } },
    server = { text = { name = "Server" }, icon = { ehi = "wp_server" } },
    wine = { text = { name = "Wine" }, icon = { ehi = EHI:GetAchievementIconString("born_4") } },
    painting = { text = { name = "Painting" }, icon = { texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7", texture_rect = { 358, 611, 65, 59 } } },
    goat = { text = { name = "Goat" }, icon = { ehi = EHI:GetAchievementIconString("peta_3") } },
    safe = { text = { name = "Safe" }, icon = { ehi = EHI:GetAchievementIconString("bob_6") } },
    pig = { text = { name = "Pig" }, icon = { ehi = EHI:GetAchievementIconString("farm_6") } },
    teaset = { text = { name = "Teaset" }, icon = { ehi = EHI:GetAchievementIconString("pent_11") } },
    gnome = { text = { name = "Gnome" }, icon = { ehi = EHI:GetAchievementIconString("pent_12") } },
    plates = { text = { name = "Plates" }, icon = { ehi = "equipment_plates" } },
    papers = { text = { name = "Papers" }, icon = { ehi = "equipment_files" } },
    vr = { text = { name = "VR" }, icon = { texture = "guis/dlcs/humble_summer_2015/textures/pd2/blackmarket/icons/masks/starvr" } },
    turret = { text = { name = "Turret" }, icon = { skills = { 7, 5 } } },
    shell = { text = { name = "Ammo" }, icon = { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = { 64, 0, 64, 64 } } },
    evidence = { text = { name = "Evidence" }, icon = { ehi = "equipment_evidence" } }
}
EHIRightLootItem._LOOT =
{
    ammo = "shell",
    artifact_statue = "artifact",
    bike_part_light = "bike",
    bike_part_heavy = "bike",
    circuit = "server",
    chas_artifact = "dragon",
    chas_teaset = "teaset",
    cloaker_cocaine = "coke",
    cloaker_gold = "gold",
    cloaker_money = "money",
    coke = "coke",
    coke_pure = "coke",
    counterfeit_money = "money",
    cro_loot1 = "bomb",
    cro_loot2 = "bomb",
    diamonds = "jewelry",
    diamond_necklace = "jewelry",
    din_pig = "pig",
    drk_bomb_part =	"bomb",
    drone_control_helmet = "vr",--"drone_ctrl",
    evidence_bag = "evidence",
    expensive_vine = "wine",
    faberge_egg = "egg",
    gnome = "gnome",
    goat = "goat",
    gold = "gold",
    hope_diamond = "diamond",
    diamonds_dah = "diamonds",
    red_diamond = "diamond",
    lost_artifact = "artifact",
    mad_master_server_value_1 =	"server",
    mad_master_server_value_2 =	"server",
    mad_master_server_value_3 =	"server",
    mad_master_server_value_4 =	"server",
    master_server = "server",
    masterpiece_painting = "painting",
    meth = "meth",
    meth_half = "meth",
    money = "money",
    mus_artifact = "artifact",
    mus_artifact_paint = "painting",
    old_wine = "wine",
    ordinary_wine = "wine",
    painting = "painting",
    person = "body",
    present = "present",
    prototype = "prototype",
    robot_toy = "toy",
    safe_ovk = "safe",
    safe_wpn = "safe",
    samurai_suit = "armor",
    roman_armor = "armor",
    sandwich = "toast",
    special_person = "body",
    toothbrush = "toothbrush",
    treasure = "treasure",
    turret = "turret",
    turret_part = "turret",
    unknown = "dentist",
    box_unknown = "dentist",
    box_unknown_tag = "dentist",
    black_tablet = "dentist",
    vr_headset = "vr",
    warhead = "bomb",
    weapon = "weapon",
    weapon_glock = "weapon",
    weapon_scar = "weapon",
    women_shoes = "shoes",
    yayo = "coke",
    ranc_weapon = "weapon",
    trai_printing_plates = "plates",
    corp_papers = "papers",
    corp_prototype = "prototype"
}
EHIRightLootItem._IGNORE_LOOT = { "vehicle_falcogini" }
EHIRightLootItem._POTENTIAL_LOOT = table.set("crate_loot", "crate_loot_crowbar", "crate_loot_close", "weapon_case", "weapon_case_axis_z")
EHIRightLootItem._IGNORE_CRATE_IN_LEVELS = table.set(
    "election_day_2", -- Election Day D2 (Warehouse)
    "pal", -- Counterfeit
    "pbr2", -- Birth of Sky
    "moon" -- Stealing Xmas
)
EHIRightLootItem._BAG_ICON = { texture = "guis/textures/pd2/hud_tabs", texture_rect = { 32, 33, 32, 32 } }
EHIRightLootItem._TEXT_COLOR = Color(0.0, 0.5, 0.0)
function EHIRightLootItem:RegisterListeners(params)
    self._loot = {} ---@type table<userdata, string>
    self._ignored_loot = {} ---@type table<userdata, boolean>
    self._queued_loot = {} ---@type table<userdata, Unit>
    Hooks:PreHook(CarryInteractionExt, "set_active", "EHI_CarryInteractionExt_EHIRightLootItem_set_active", function(interact, active, ...) ---@param active boolean
        if active and interact:disabled() then
            return
        elseif active ~= interact._active then
            local unit = interact._unit
            local key = unit:key()
            if self._ignored_loot[key] then
                return
            end
            local carry_data = unit:carry_data()
            if active then
                if carry_data then
                    self._loot[key] = carry_data:carry_id()
                    self:_refresh_item(carry_data, 1)
                else
                    self._queued_loot[key] = unit
                    call_on_next_update(self._refresh_on_next_update, true)
                end
            elseif carry_data then
                self:_refresh_item(carry_data, -1)
                self._loot[key] = nil
            elseif self._loot[key] then
                self:_refresh_item(nil, -1, self._loot[key])
                self._loot[key] = nil
            else
                self._queued_loot[key] = nil
            end
        end
    end)
    if params.show_potentional_loot and not self._IGNORE_CRATE_IN_LEVELS[Global.game_settings.level_id] then
        self._ignored_crate = {} ---@type table<userdata, boolean>
        local preplanning = tweak_data.preplanning
        self._DEFERRED_GROUPS.potentional_loot = { text = { name = "Crate" }, icon = { texture = preplanning.gui.type_icons_path, texture_rect = preplanning:get_type_texture_rect(preplanning.types.ranc_marked_crate.icon) } }
        self._LOOT.potentional_loot = "potentional_loot"
        Hooks:PreHook(UseInteractionExt, "set_active", "EHI_EHIRightLootItem_potentional_loot_UseInteractionExt_set_active", function(interact, active, ...) ---@param active boolean
            if active and interact:disabled() then
                return
            elseif self._POTENTIAL_LOOT[interact.tweak_data] then
                if active == false and interact._active == nil then -- Don't do anything if the crate with potentional spawned and interact is set to false
                    return
                elseif active ~= interact._active and not self._ignored_crate[interact._unit:key()] then
                    self:_refresh_item(nil, active and 1 or -1, "potentional_loot")
                end
            end
        end)
    end
    self._refresh_on_next_update = function()
        for key, unit in pairs(self._queued_loot) do
            if alive(unit) then
                local carry_data = unit:carry_data()
                if carry_data then
                    self._loot[key] = carry_data:carry_id()
                    self:_refresh_item(carry_data, 1)
                end
            end
            self._queued_loot[key] = nil
        end
    end
end

function EHIRightLootItem:CreateItem(id, params)
    local valid_item = self._SHOW_TEXT and params.text and not params.ignore
    if valid_item then
        params.icon = self._BAG_ICON
    end
    local item = EHIRightLootItem.super.CreateItem(self, id, params)
    if valid_item then
        local def = params.text
        local panel = item.panel
        local panel_w = panel:w()
        local icon = panel:child("icon") --[[@as Bitmap]]
        local text = panel:text({
            name = "text",
            text = def.name:sub(1, 10) or "",
            align = "center",
            vertical = "center",
            w = panel_w,
            h = panel_w,
            color = def.color or self._TEXT_COLOR,
            blend_mode = "normal",
            font = tweak_data.hud_corner.assault_font,
            font_size = panel_w * 0.45,
            layer = 2
        })
        local _, _, w, _ = text:text_rect()
        text:set_font_size(math.min(text:font_size() * (text:w() / w) * 0.9, text:font_size()))
        text:set_center(icon:center())
        text:set_y(text:y() + text:h() * 0.1)
        local previous_w = icon:w()
        icon:set_w(previous_w * 1.2)
        icon:set_center(text:center())
        text:move(0, 2 * self._SCALE)
    end
    return item
end

---@param stealth_is_available boolean
---@param text_or_icon integer
function EHIRightLootItem:CreateItemsFromMap(stealth_is_available, text_or_icon)
    self._SHOW_TEXT = text_or_icon == 2
    local is_playing_boiling_point = Global.game_settings.level_id == "mad"
    if stealth_is_available or is_playing_boiling_point then
        self._DEFERRED_GROUPS.body = { text = { name = "Body" }, icon = { ehi = EHI:GetAchievementIconString("dark_5") } }
        self._delete_body_loot_group = not is_playing_boiling_point
    end
    self:CreateItem("ignore", { ignore = true })
    local group_count = table.size(self._DEFERRED_GROUPS)
    --- Manually set position for bodybags and potentional loot
    if self._DEFERRED_GROUPS.body then
        self._DEFERRED_GROUPS.body.pos = group_count - (self._DEFERRED_GROUPS.potentional_loot and 1 or 0)
    end
    if self._DEFERRED_GROUPS.potentional_loot then
        self._DEFERRED_GROUPS.potentional_loot.pos = group_count
    end
    self:CreateItem("unknown", {
        icon = { ehi = "default" },
        pos = group_count + 1 -- Unknown loot will appear last
    })
    self._n_of_items = self._n_of_items - 1 -- Start from the first item and not second
    -- Fill out our itemized items list with fake items to not crash later  
    -- Once items are created, the data in the list will get replaced with actual item
    local fake_item = { count = 0, panel = { alpha = function(...)
        return 0
    end, set_alpha = function(...) end }, i = -1 }
    for i = 1, group_count, 1 do
        self._itemized_items[i] = fake_item
    end
    self._units_map = {} ---@type table<string, EHIRightItemBase.Item?>
    for _, loot in ipairs(self._IGNORE_LOOT) do
        self._units_map[loot] = self._items.ignore
    end
end

---@param light table
---@param heavy table
---@param body table
function EHIRightLootItem:ColorItemsBasedOnTheirWeight(light, heavy, body)
    ---@param group string
    ---@param new_group string
    ---@param carry_id string?
    local function clone_group(group, new_group, carry_id)
        self._DEFERRED_GROUPS[new_group] = deep_clone(self._DEFERRED_GROUPS[group])
        self._LOOT[carry_id or new_group] = new_group
    end
    ---@param group string
    ---@param icon string|table
    ---@param text string?
    local function adjust_group(group, icon, text)
        local def = self._DEFERRED_GROUPS[group]
        def.text.name = text or def.text.name
        if type(icon) == "table" then
            def.icon = icon
        else
            def.icon.ehi = icon
        end
    end
    clone_group("weapon", "weapon_heavy", "weapon")
    clone_group("weapon", "weapon_scar")
    adjust_group("weapon_scar", { texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4", texture_rect = { 696, 702, 85, 34 } })
    clone_group("weapon", "weapon_glock")
    adjust_group("weapon_glock", EHI:GetAchievementIconString("halloween_9"), "Pistols")
    clone_group("coke", "coke_medium", "cloaker_cocaine")
    clone_group("artifact", "artifact_statue")
    clone_group("gold", "gold_medium", "cloaker_gold")
    clone_group("bomb", "bomb_heavy", "cro_loot2")
    clone_group("bomb", "bomb_very_heavy", "warhead")
    clone_group("wine", "wine_heavy", "old_wine")
    clone_group("turret", "turrent_heavy", "turret")
    local preloaded_groups = table.size(self._itemized_items) - 1 -- Don't count the unknown group
    local all_with_new_groups = table.size(self._DEFERRED_GROUPS)
    if all_with_new_groups > preloaded_groups then -- Adjust preloaded list to be accurate
        local fake_item = self._itemized_items[1]
        for i = preloaded_groups, all_with_new_groups, 1 do
            self._itemized_items[i] = fake_item
        end
        local pos = all_with_new_groups + 1
        local unknown = self._items.unknown
        unknown.i = pos
        self._itemized_items[pos] = unknown
        if self._DEFERRED_GROUPS.body then
            self._DEFERRED_GROUPS.body.pos = all_with_new_groups - (self._DEFERRED_GROUPS.potentional_loot and 1 or 0)
        end
        if self._DEFERRED_GROUPS.potentional_loot then
            self._DEFERRED_GROUPS.potentional_loot.pos = all_with_new_groups
        end
    end
    light = EHI:GetColor(light)
    heavy = EHI:GetColor(heavy)
    if self._DEFERRED_GROUPS.body then
        local color = EHI:GetColor(body)
        self._DEFERRED_GROUPS.body.icon.color = color
        self._DEFERRED_GROUPS.body.text.color = color
    end
    local carry = tweak_data.carry
    local min_range, max_range, delta_range = math.huge, -math.huge, 0
    for key, data in pairs(carry.types) do
        if key ~= "being" then
            min_range = math.min(min_range, data.move_speed_modifier)
            max_range = math.max(max_range, data.move_speed_modifier)
        end
    end
    delta_range = max_range - min_range
    local types = {}
    for key, data in pairs(carry.types) do
        if key ~= "being" then
            types[key] = math.lerp(light, heavy, (max_range - data.move_speed_modifier) / delta_range)
        end
    end
    local forbidden_types =
    {
        person = true,
        special_person = true,
        potentional_loot = true
    }
    for id, redirect in pairs(self._LOOT) do
        if not forbidden_types[id] then
            local group = self._DEFERRED_GROUPS[redirect]
            local carry_tweak = carry[id]
            if group and carry_tweak then
                local type = carry_tweak.type
                local color = types[type]
                if color then
                    if not group.icon.color then
                        group.icon.color = color
                        group.text.color = color
                    elseif group.icon.color ~= color then
                        EHI:Log(string.format("[EHIRightLootItem] Trying to assign a different color to type: '%s', carry_id: '%s' and loot group: '%s'; color was not changed!", type, id, redirect))
                    end
                else
                    EHI:Log(string.format("[EHIRightLootItem] Color not found for type: '%s', carry_id: '%s' and loot group: '%s'", type, id, redirect))
                end
            end
        end
    end
end

---@param key userdata
---@param carry_data CarryData
---@param interact_active boolean
function EHIRightLootItem:IgnoreCarry(key, carry_data, interact_active)
    self._ignored_loot[key] = true
    self._loot[key] = nil
    -- If the interact is active and our unit is queued, DO NOT subtract the amount
    -- Doing so will cause the item to be not visible when it should be
    -- Instead, remove the unit from the queue and block it so the Hook above will skip it
    if interact_active and not self._queued_loot[key] then
        self:_refresh_item(carry_data, -1)
    end
    self._queued_loot[key] = nil
end

---@param key userdata
---@param interact_active boolean
function EHIRightLootItem:IgnorePotentionalCarry(key, interact_active)
    if self._ignored_crate then
        self._ignored_crate[key] = true
        if interact_active then
            self:_refresh_item(nil, -1, "potentional_loot")
        end
    end
end

---@param carry_id string
function EHIRightLootItem:_deferred_item(carry_id)
    local group = self._LOOT[carry_id]
    if group and self._items[group] then -- 2 or more different loot may use the same item, check if it already exists
        local item = self._items[group]
        self._units_map[carry_id] = item
        return item
    end
    local def = group and self._DEFERRED_GROUPS[group]
    if def then
        local item = self:CreateItem(group, def)
        self._units_map[carry_id] = item
        return item
    elseif group then -- Return unknown loot if loot is defined, but no group exists
        local unknown = self._items.unknown
        self._units_map[carry_id] = unknown
        return unknown
    else
        local ignore = self._items.ignore
        self._units_map[carry_id] = ignore
        return ignore
    end
end

---@overload fun(self: EHIRightLootItem, carry_data: nil, diff: integer, carry_id: string)
---@param carry_data CarryData
---@param diff integer
---@param carry_id string?
function EHIRightLootItem:_refresh_item(carry_data, diff, carry_id)
    local id = carry_id or carry_data._carry_id or ""
    local item = self._units_map[id] or self:_deferred_item(id)
    if not item or item.ignore then
        return
    end
    local previous_count = item.count
    local count = previous_count + diff
    item.count = count
    item.text:set_text(tostring(count))
    self:AnimateItem(item, previous_count, count)
    if (count > 0 and not item.visible) or (item.visible and count <= 0) then
        self:_update_items_visibility()
    end
end

function EHIRightLootItem:OnAlarm()
    if self._delete_body_loot_group then
        local body = self._items.body
        if body then
            self:_set_item_ignored(body)
        else
            self._DEFERRED_GROUPS.body.ignore = true
        end
    end
    self._delete_body_loot_group = nil
end

---@class EHIRightSpecialItemsItem : EHIRightItemBase
---@field super EHIRightItemBase
EHIRightSpecialItemsItem = class(EHIRightItemBase)
EHIRightSpecialItemsItem._DEFERRED_GROUPS =
{
    crowbar = { icon = { ehi = "equipment_crowbar" } },
    keycard = { icon = { ehi = "equipment_bank_manager_key" } },
    gage_assignment = { icon = { ehi = "gage" } },
    planks = { icon = { ehi = "equipment_planks" } },
    mu = { icon = { ehi = "equipment_muriatic_acid" } },
    cs = { icon = { ehi = "equipment_caustic_soda" } },
    hcl = { icon = { ehi = "equipment_hydrogen_chloride" } },
    blowtorch = { icon = { ehi = "equipment_blow_torch" } },
    thermite = { icon = { ehi = "equipment_flammable" } },
    c4 = { icon = { ehi = "equipment_c4" } },
    small_loot = { icon = { ehi = "equipment_plates" } },
    eng_1 = { icon = { ehi = EHI:GetAchievementIconString("eng_1") } },
    eng_2 = { icon = { ehi = EHI:GetAchievementIconString("eng_2") } },
    eng_3 = { icon = { ehi = EHI:GetAchievementIconString("eng_3") } },
    eng_4 = { icon = { ehi = EHI:GetAchievementIconString("eng_4") } },
    ring_band = { icon = { ehi = EHI:GetAchievementIconString("voff_4") } },
    poster = { icon = { ehi = "equipment_files" } },
    briefcase = { icon = { ehi = "equipment_briefcase" } },
    weapon_part_stock = { icon = { ehi = "equipment_stock" } },
    weapon_part_receiver = { icon = { ehi = "equipment_receiver" } },
    weapon_part_barrel = { icon = { ehi = "equipment_barrel" } },
    handcuffs = { icon = { texture = "guis/textures/hud_icons", texture_rect = { 294, 469, 40, 40 } } },
    moon_mask = { icon = { ehi = EHI:GetAchievementIconString("moon_4") } },
    lrm_keycard = { icon = { ehi = "equipment_rfid_tag_01" } },
    born_wine = { icon = { ehi = EHI:GetAchievementIconString("born_4") } },
    harddrive = { icon = { ehi = "equipment_harddrive" } },
    --blueprint = { icon = { ehi = "" } },
    secret_item = { icon = { ehi = "default" } } -- ? gets returned
}
EHIRightSpecialItemsItem._PICKUPS =
{
    gen_pku_crowbar = "crowbar",
    pickup_keycard = "keycard",
    pickup_hotel_room_keycard = "keycard",
    gage_assignment = "gage_assignment",
    pickup_case = "gage_case",
    pickup_keys = "gage_key",
    pickup_boards = "planks",
    stash_planks_pickup = "planks",
    muriatic_acid = "mu",
    caustic_soda = "cs",
    hydrogen_chloride = "hcl",
    gen_pku_blow_torch = "blowtorch",
    drk_pku_blow_torch = "blowtorch",
    thermite = "thermite",
    gasoline_engine = "thermite",
    gen_pku_thermite = "thermite",
    gen_pku_thermite_paste = "thermite",
    gen_int_thermite_rig = "thermite",
    hold_take_gas_can = "thermite",
    gen_pku_thermite_paste_z_axis = "thermite",
    c4_bag = "c4",
    money_wrap_single_bundle = "small_loot",
    money_wrap_single_bundle_active = "small_loot",
    money_wrap_single_bundle_dyn = "small_loot",
    cas_chips_pile = "small_loot",
    diamond_pickup = "small_loot",
    diamond_pickup_pal = "small_loot",
    diamond_pickup_axis = "small_loot",
    safe_loot_pickup = "small_loot",
    pickup_tablet = "small_loot",
    pickup_phone = "small_loot",
    pickup_harddrive = "harddrive",
    hold_take_mask = "moon_mask", -- Paycheck masks in Stealing Xmas
    press_pick_up = "secret_item",
    hold_pick_up_turtle = "secret_item",
    diamond_single_pickup_axis = "secret_item",
    federali_medal = "secret_item",
    fex_take_churros = "secret_item",
    mex_pickup_murky_uniforms = "secret_item",
    pex_medal = "secret_item",
    xm20_int_mask = "secret_item",
    pickup_horseshoe = "secret_item",
    sheriff_star = "secret_item",
    ring_band = "ring_band",
    glc_hold_take_handcuffs = "handcuffs",
    hold_take_missing_animal_poster = "poster",
    press_take_folder = "poster",
    hold_take_vault_blueprint = "poster", --"blueprint",
    take_jfr_briefcase = "briefcase",
    ranc_hold_take_stock = "weapon_part_stock",
    ranc_hold_take_receiver = "weapon_part_receiver",
    ranc_hold_take_barrel = "weapon_part_barrel",
    pda9_collective_1 =	"secret_item",
    pda9_collective_2 =	"secret_item",
    pda9_collective_3 =	"secret_item",
    pda9_collective_4 =	"secret_item",
    trai_usb_key = "secret_item",
    corp_key_fob = "secret_item",
    corp_achi_blueprint = "poster", --"blueprint"
}
EHIRightSpecialItemsItem._ACHIEVEMENT_REDIRECT =
{
    press_pick_up = {
        eng_1_stats = "eng_1",
        eng_2_stats = "eng_2",
        eng_3_stats = "eng_3",
        eng_4_stats = "eng_4"
    }
}
EHIRightSpecialItemsItem._ACHIEVEMENT_UNIT_REDIRECT =
{
    [Idstring("units/pd2_dlc_born/pickups/gen_pku_whiskey_starbreeze/gen_pku_whiskey_starbreeze"):key()] = "born_wine"
}
EHIRightSpecialItemsItem._SPECIAL_ITEM_REDIRECT =
{
    pickup_keycard = {
        lrm_keycard = "lrm_keycard"
    }
}
function EHIRightSpecialItemsItem:RegisterListeners(params)
    self._ignore_interact = {} ---@type table<userdata, boolean>
    Hooks:PostHook(ObjectInteractionManager, "add_unit", "EHI_ObjectInteractionManager_EHIRightSpecialItemsItem_add_unit", function(oim, unit, ...)
        if not self._ignore_interact[unit:key()] then
            self:_refresh_item(unit, 1)
        end
    end)
    Hooks:PostHook(ObjectInteractionManager, "remove_unit", "EHI_ObjectInteractionManager_EHIRightSpecialItemsItem_remove_unit", function(oim, unit, ...)
        if not self._ignore_interact[unit:key()] then
            self:_refresh_item(unit, -1)
        end
    end)
end

function EHIRightSpecialItemsItem:OnSpawn()
    if self._itemized_items then -- Check if any item was created before spawn, otherwise it will crash
        self:_update_items_visibility_fast() -- Removes items that are spawned and then hidden in the same frame during level init (item count is 0)
    end
end

---@param types table
function EHIRightSpecialItemsItem:CreateItemsFromMap(types)
    self:CreateItem("ignore", { ignore = true })
    if not types.small_loot then
        self._DEFERRED_GROUPS.small_loot = nil
        for key, group in pairs(self._PICKUPS) do
            if group == "small_loot" then
                self._PICKUPS[key] = "ignore"
            end
        end
    end
    if not types.gage_packages then
        self._DEFERRED_GROUPS.gage_assignment = nil
        self._PICKUPS.gage_assignment = "ignore"
    end
    if not types.crowbar then
        self._DEFERRED_GROUPS.crowbar = nil
        self._PICKUPS.gen_pku_crowbar = "ignore"
    end
    if not types.keycard then
        self._DEFERRED_GROUPS.keycard = nil
        self._PICKUPS.pickup_keycard = "ignore"
        self._PICKUPS.pickup_hotel_room_keycard = "ignore"
    end
    if not types.planks then
        self._DEFERRED_GROUPS.planks = nil
        self._PICKUPS.pickup_boards = "ignore"
        self._PICKUPS.stash_planks_pickup = "ignore"
    end
    if not types.mission_equipment then
        self._DEFERRED_GROUPS.mu = nil
        self._DEFERRED_GROUPS.cs = nil
        self._DEFERRED_GROUPS.hcl = nil
        self._PICKUPS.muriatic_acid = "ignore"
        self._PICKUPS.caustic_soda = "ignore"
        self._PICKUPS.hydrogen_chloride = "ignore"
        self._DEFERRED_GROUPS.thermite = nil
        for key, group in pairs(self._PICKUPS) do
            if group == "thermite" then
                self._PICKUPS[key] = "ignore"
            end
        end
        self._DEFERRED_GROUPS.c4 = nil
        self._PICKUPS.c4_bag = "ignore"
        self._DEFERRED_GROUPS.harddrive = nil
        self._PICKUPS.pickup_harddrive = "ignore"
        self._DEFERRED_GROUPS.weapon_part_stock = nil
        self._DEFERRED_GROUPS.weapon_part_receiver = nil
        self._DEFERRED_GROUPS.weapon_part_barrel = nil
        self._PICKUPS.ranc_hold_take_stock = "ignore"
        self._PICKUPS.ranc_hold_take_receiver = "ignore"
        self._PICKUPS.ranc_hold_take_barrel = "ignore"
    end
    if not types.collectables then
        for key, group in pairs(self._PICKUPS) do
            if group == "secret_item" then
                self._PICKUPS[key] = "ignore"
            end
        end
        self._DEFERRED_GROUPS.moon_mask = nil
        self._PICKUPS.hold_take_mask = "ignore"
        self._PICKUPS.ring_band = "ignore"
        self._PICKUPS.glc_hold_take_handcuffs = "ignore"
        self._PICKUPS.hold_take_missing_animal_poster = "ignore"
        self._PICKUPS.press_take_folder = "ignore"
        self._PICKUPS.hold_take_vault_blueprint = "ignore"
        self._PICKUPS.corp_achi_blueprint = "ignore"
        for tweak, tbl in pairs(self._ACHIEVEMENT_REDIRECT) do
            for key, _ in pairs(tbl) do
                self._ACHIEVEMENT_REDIRECT[tweak][key] = "ignore"
            end
        end
        self._DEFERRED_GROUPS.eng_1 = nil
        self._DEFERRED_GROUPS.eng_2 = nil
        self._DEFERRED_GROUPS.eng_3 = nil
        self._DEFERRED_GROUPS.eng_4 = nil
        for key, _ in pairs(self._ACHIEVEMENT_UNIT_REDIRECT) do
            self._ACHIEVEMENT_UNIT_REDIRECT[key] = "ignore"
        end
        for tweak, tbl in pairs(self._SPECIAL_ITEM_REDIRECT) do
            for key, _ in pairs(tbl) do
                self._SPECIAL_ITEM_REDIRECT[tweak][key] = "ignore"
            end
        end
        self._DEFERRED_GROUPS.lrm_keycard = nil
    end
    self._units_map = {} ---@type table<string, EHIRightItemBase.Item>
end

---@param unit Unit
---@param interact_active boolean
function EHIRightSpecialItemsItem:IgnoreInteract(unit, interact_active)
    self._ignore_interact[unit:key()] = true
    if interact_active then
        self:_refresh_item(unit, -1)
    end
end

---@param final_item string
---@param tweak_data string
function EHIRightSpecialItemsItem:_deferred_item(final_item, tweak_data)
    local id = self._PICKUPS[final_item]
    if id and self._items[id] then -- 2 or more special pickups may use the same item, check if it already exists
        local item = self._items[id]
        self._units_map[final_item] = item
        return item
    end
    local def = id and self._DEFERRED_GROUPS[id]
    local def2 = self._DEFERRED_GROUPS[final_item]
    if def or def2 then
        local item = self:CreateItem(id or final_item, def or def2)
        self._units_map[id or final_item] = item
        return item
    else
        local ignore = self._items.ignore
        self._units_map[tweak_data] = ignore
        return ignore
    end
end

---@param unit Unit
---@param diff integer
function EHIRightSpecialItemsItem:_refresh_item(unit, diff)
    local interact = unit:interaction() ---@cast interact -?
    local tweak_data = interact and unit:interaction().tweak_data
    if not tweak_data then
        return
    end
    local final_item = tweak_data
    if self._ACHIEVEMENT_REDIRECT[tweak_data] then
        final_item = self._ACHIEVEMENT_REDIRECT[tweak_data][interact._achievement_stat or ""] or self._ACHIEVEMENT_UNIT_REDIRECT[unit:name():key()] or tweak_data
    elseif self._SPECIAL_ITEM_REDIRECT[tweak_data] then
        final_item = self._SPECIAL_ITEM_REDIRECT[tweak_data][interact._special_equipment or ""] or tweak_data ---@diagnostic disable-line
    end
    local item = self._units_map[final_item] or self:_deferred_item(final_item, tweak_data)
    if not item or item.ignore then
        return
    end
    local previous_count = item.count
    local count = item.count + diff
    item.count = count
    item.text:set_text(tostring(count))
    self:AnimateItem(item, previous_count, count)
    if (count > 0 and not item.visible) or (item.visible and count <= 0) then
        self:_update_items_visibility()
    end
end

---@class EHIRightStealthItem : EHIRightItemBase
---@field super EHIRightItemBase
EHIRightStealthItem = class(EHIRightItemBase)
EHIRightStealthItem._callback_key = "EHIRightStealthItem"
---@param o Bitmap
---@param text Text
---@param progress Color
---@param start_color Color
---@param self EHIRightStealthItem
---@param warning_color Color
---@param warning_color_string string
EHIRightStealthItem._animate_item_down_warning = function(o, text, progress, start_color, self, warning_color, warning_color_string)
    over(0.5, function(lerp, t)
        progress.red = math.lerp(1, 0, lerp)
        o:set_color(progress)
        text:set_color(math.lerp(start_color, warning_color, lerp))
    end)
    progress.red = 1
    o:set_color(progress)
    self:SetColorTexture(o, warning_color_string)
end
EHIRightStealthItem._camera_is_enabled = function(item, key)
    return item.enabled and (item.active or Network:is_client())
end
function EHIRightStealthItem:RegisterListeners(params)
    self:CreateItem("alarm", {
        icon = { ehi = "pager_icon" }
    })
    self._alarm_enemies = {}
    for name, data in pairs(tweak_data.character) do
        if type(data) == "table" and data.has_alarm_pager then
            self._alarm_enemies[name] = true
        end
    end
    Hooks:PostHook(EnemyManager, "on_enemy_registered", "EHI_EHIRightStealthItem_EnemyManager_on_enemy_registered", function(em, unit, ...) ---@param unit UnitEnemy
        if self._alarm_enemies[unit:base()._tweak_table] then
            self:EnemyWithAlarmSpawned()
        end
    end)
    Hooks:PostHook(EnemyManager, "on_enemy_unregistered", "EHI_EHIRightStealthItem_EnemyManager_on_enemy_unregistered", function(em, unit, ...) ---@param unit UnitEnemy
        if self._alarm_enemies[unit:base()._tweak_table] then
            self:EnemyWithAlarmDespawned()
        end
    end)
    self._alarm_enemies_answered = {} ---@type table<userdata, UnitEnemy>
    ---@param unit UnitEnemy
    local function PagerEnemyKilled(unit)
        self:AlarmEnemyKilled(unit)
        unit:base():remove_destroy_listener(self._callback_key)
    end
    ---@param unit UnitEnemy
    local function PagerEnemyDestroyed(unit)
        self:AlarmEnemyKilled(unit)
        unit:character_damage():remove_listener(self._callback_key)
    end
    Hooks:PostHook(IntimitateInteractionExt, "_at_interact_start", "EHI_EHIRightStealthItem_IntimitateInteractionExt__at_interact_start", function(iie, ...)
        if iie.tweak_data == "corpse_alarm_pager" and not iie._unit:character_damage():dead() then
            self:AlarmEnemyAnswered(iie._unit)
            iie._unit:base():add_destroy_listener(self._callback_key, PagerEnemyDestroyed)
            iie._unit:character_damage():add_listener(self._callback_key, { "death" }, PagerEnemyKilled)
        end
    end)
    Hooks:PreHook(IntimitateInteractionExt, "sync_interacted", "EHI_EHIRightStealthItem_IntimitateInteractionExt_sync_interacted", function(iie, peer, player, status, ...) ---@param status string|number
        if iie.tweak_data == "corpse_alarm_pager" and (status == "started" or status == 1) and not iie._unit:character_damage():dead() then
            self:AlarmEnemyAnswered(iie._unit)
            iie._unit:base():add_destroy_listener(self._callback_key, PagerEnemyDestroyed)
            iie._unit:character_damage():add_listener(self._callback_key, { "death" }, PagerEnemyKilled)
        end
    end)
    self:CreateItem("pager", {
        icon = { ehi = "pagers_used", scale = 0.9 },
        force_visible = true
    })
    if EHI.IsHost then
        local max_pagers = self:GetAmountOfPagers()
        Hooks:PostHook(GroupAIStateBase, "on_successful_alarm_pager_bluff", "EHI_EHIRightStealthItem_GroupAIStateBase_sync_pager_count", function(ai_state, ...)
            self:UpdatePagerCount(max_pagers - ai_state._nr_successful_alarm_pager_bluffs)
        end)
        self:UpdatePagerCount(max_pagers, true)
    else
        local max_pagers = -1 -- Disable pagers until clients are spawned
        Hooks:PostHook(GroupAIStateBase, "sync_alarm_pager_bluff", "EHI_EHIRightStealthItem_GroupAIStateBase_sync_pager_count", function(ai_state, ...)
            if max_pagers >= 0 then
                self:UpdatePagerCount(max_pagers - ai_state._nr_successful_alarm_pager_bluffs)
            end
        end)
        EHI:AddOnSpawnedCallback(function()
            local ai_state = managers.groupai:state()
            if ai_state and ai_state:whisper_mode() then
                max_pagers = self:GetAmountOfPagers()
                self:UpdatePagerCount(max_pagers - ai_state._nr_successful_alarm_pager_bluffs, true)
            end
        end)
    end
    self:CreateItem("camera", {
        icon = { ehi = "camera_loop" }
    })
    self._cameras = {} ---@type table<userdata, { enabled: boolean, active: boolean }>
    Hooks:PostHook(SecurityCamera, "init", "EHI_EHIRightStealthItem_SecurityCamera_init", function(base, ...)
        self._cameras[base._unit:key()] = { enabled = true, active = false }
        self:_update_camera_count()
    end)
    Hooks:PostHook(SecurityCamera, "on_unit_set_enabled", "EHI_EHIRightStealthItem_SecurityCamera_on_unit_set_enabled", function(base, enabled, ...) ---@param enabled boolean
        local cam = self._cameras[base._unit:key()]
        if cam then
            cam.enabled = enabled
            self:_update_camera_count()
        end
    end)
    Hooks:PostHook(SecurityCamera, "set_update_enabled", "EHI_EHIRightStealthItem_SecurityCamera_set_update_enabled", function(base, state, ...) ---@param state boolean
        local cam = self._cameras[base._unit:key()]
        if cam then
            cam.active = state
            self:_update_camera_count()
        end
    end)
    Hooks:PostHook(SecurityCamera, "generate_cooldown", "EHI_EHIRightStealthItem_SecurityCamera_generate_cooldown", function(base, ...)
        self:CameraDespawned(base._unit:key())
    end)
    Hooks:PostHook(SecurityCamera, "destroy", "EHI_EHIRightStealthItem_SecurityCamera_destroy", function(base, ...)
        self:CameraDespawned(base._unit:key())
    end)
    self:CreateItem("bodybags", {
        icon = {
            texture = "guis/textures/pd2/skilltree/icons_atlas",
            texture_rect = { 320, 704, 64, 64 }
        },
        force_visible = true
    })
    if params.bodybags_format == 1 then
        self._bodybags_macro = "$mine;/$placed;"
    elseif params.bodybags_format == 2 then
        self._bodybags_macro = "$placed;/$mine;"
    elseif params.bodybags_format == 3 then
        self._bodybags_macro = "$mine;"
    else -- 4
        self._bodybags_macro = "$placed;"
    end
    self._bodybags_amount = 0
    self._bodybags = {} ---@type table<userdata, integer>
    ---@param equipment AmmoBagBase|GrenadeCrateBase|FirstAidKitBase
    local function destroy_equipment(equipment, ...)
        self._bodybags[equipment._unit:key()] = nil
        self:UpdateBodyBagsAmount()
    end
    Hooks:PostHook(BodyBagsBagBase, "init", "EHI_EHIRightStealthItem_BodyBagsBagBase_init", function(base, unit, ...) ---@param unit UnitDeployable
        self._bodybags[unit:key()] = base._max_bodybag_amount
        self:UpdateBodyBagsAmount()
    end)
    Hooks:PostHook(BodyBagsBagBase, "_set_visual_stage", "EHI_EHIRightStealthItem_BodyBagsBagBase__set_visual_stage", function(base, ...)
        if base._bodybag_amount > 0 then
            self._bodybags[base._unit:key()] = base._bodybag_amount
            self:UpdateBodyBagsAmount()
        end
    end)
    Hooks:PreHook(BodyBagsBagBase, "_set_empty", "EHI_EHIRightStealthItem_BodyBagsBagBase__set_empty", destroy_equipment)
    Hooks:PostHook(BodyBagsBagBase, "destroy", "EHI_EHIRightStealthItem_BodyBagsBagBase_destroy", destroy_equipment)
    Hooks:PostHook(PlayerManager, "_set_body_bags_amount", "EHI_EHIRightStealthItem_PlayerManager__set_body_bags_amount", function(pm, ...)
        self._bodybags_amount = pm._local_player_body_bags
        self:UpdateBodyBagsAmount()
    end)
    self._warning_color, self._warning_color_string = tweak_data.ehi:GetBuffColorFromIndex(params.warning_index)
end

function EHIRightStealthItem:UnregisterListeners()
    Hooks:RemovePostHook("EHI_EHIRightStealthItem_EnemyManager_on_enemy_registered")
    Hooks:RemovePostHook("EHI_EHIRightStealthItem_EnemyManager_on_enemy_unregistered")
    Hooks:RemovePostHook("EHI_EHIRightStealthItem_IntimitateInteractionExt__at_interact_start")
    Hooks:RemovePreHook("EHI_EHIRightStealthItem_IntimitateInteractionExt_sync_interacted")
    Hooks:RemovePostHook("EHI_EHIRightStealthItem_GroupAIStateBase_sync_pager_count")
    Hooks:RemovePostHook("EHI_EHIRightStealthItem_SecurityCamera_init")
    Hooks:RemovePostHook("EHI_EHIRightStealthItem_SecurityCamera_on_unit_set_enabled")
    Hooks:RemovePostHook("EHI_EHIRightStealthItem_SecurityCamera_set_update_enabled")
    Hooks:RemovePostHook("EHI_EHIRightStealthItem_SecurityCamera_generate_cooldown")
    Hooks:RemovePostHook("EHI_EHIRightStealthItem_SecurityCamera_destroy")
    Hooks:RemovePostHook("EHI_EHIRightStealthItem_BodyBagsBagBase_init")
    Hooks:RemovePostHook("EHI_EHIRightStealthItem_BodyBagsBagBase__set_visual_stage")
    Hooks:RemovePreHook("EHI_EHIRightStealthItem_BodyBagsBagBase__set_empty")
    Hooks:RemovePostHook("EHI_EHIRightStealthItem_BodyBagsBagBase_destroy")
    Hooks:RemovePostHook("EHI_EHIRightStealthItem_PlayerManager__set_body_bags_amount")
    for _, enemy in pairs(self._alarm_enemies_answered) do
        if alive(enemy) then
            enemy:base():remove_destroy_listener(self._callback_key)
            enemy:character_damage():remove_listener(self._callback_key)
        end
    end
end

function EHIRightStealthItem:GetAmountOfPagers()
    local max_pagers = 0
    for _, value in ipairs(tweak_data.player.alarm_pager.bluff_success_chance) do
        if value > 0 then
            max_pagers = max_pagers + 1
        end
    end
    return EHI.ModUtils:SELH_GetModifiedPagerCount(max_pagers)
end

---@param bitmap Bitmap
---@param color string
function EHIRightStealthItem:SetColorTexture(bitmap, color)
    local texture = self._PROGRESS == 1 and "sframe" or "cframe"
    bitmap:set_image(string.format("guis/textures/pd2_mod_ehi/buffs/buff_%s_%s", texture, color), unpack(self._PROGRESS_RECT[self._PROGRESS]))
end

function EHIRightStealthItem:AnimateItem(item, previous_count, count)
    EHIRightStealthItem.super.AnimateItem(self, item, previous_count, count)
    if (count or item.count) == 0 and item.force_visible then
        item.data.needs_color_refresh = true
        item.progress:stop()
        item.progress:animate(self._animate_item_down_warning, item.text, item.progress_bar, self._PROGRESS_COLOR, self, self._warning_color, self._warning_color_string)
    end
end

function EHIRightStealthItem:EnemyWithAlarmSpawned()
    local al = self._items.alarm
    al.count = al.count + 1
    al.text:set_text(tostring(al.count))
    self:_update_items_visibility()
    self:AnimateItem(al, 0)
end

function EHIRightStealthItem:EnemyWithAlarmDespawned()
    local al = self._items.alarm
    al.count = math.max(al.count - 1, 0)
    al.text:set_text(tostring(al.count))
    self:_update_items_visibility()
    self:AnimateItem(al, math.huge)
end

---@param unit UnitEnemy
function EHIRightStealthItem:AlarmEnemyAnswered(unit)
    local key = unit:key()
    if not self._alarm_enemies_answered[key] then
        self._alarm_enemies_answered[key] = unit
        self:EnemyWithAlarmDespawned()
    end
end

---@param unit UnitEnemy
function EHIRightStealthItem:AlarmEnemyKilled(unit)
    if table.remove_key(self._alarm_enemies_answered, unit:key()) then
        self:EnemyWithAlarmSpawned()
    end
end

---@param count integer
---@param skip_anim boolean?
function EHIRightStealthItem:UpdatePagerCount(count, skip_anim)
    local pc = self._items.pager
    local previous_count = pc.count
    pc.count = count
    pc.text:set_text(tostring(count))
    self:_update_items_visibility()
    if skip_anim then
        if count <= 0 then
            pc.data.needs_color_refresh = true
            pc.text:set_color(self._warning_color)
            self:SetColorTexture(pc.progress, self._warning_color_string)
        end
    else
        self:AnimateItem(pc, previous_count, count)
    end
end

function EHIRightStealthItem:_update_camera_count()
    local cam = self._items.camera
    local previous_count = cam.count
    local count = table.count(self._cameras, self._camera_is_enabled)
    cam.count = count
    cam.text:set_text(tostring(count))
    self:_update_items_visibility()
    self:AnimateItem(cam, previous_count, count)
end

---@param key userdata
function EHIRightStealthItem:CameraDespawned(key)
    local camera = table.remove_key(self._cameras, key)
    if camera and camera.enabled then
        local cam = self._items.camera
        cam.count = cam.count - 1
        if alive(cam.text) then
            cam.text:set_text(tostring(cam.count))
            self:_update_items_visibility()
            self:AnimateItem(cam, math.huge)
        end
    end
end

function EHIRightStealthItem:UpdateBodyBagsAmount()
    local bb = self._items.bodybags
    local previous_count = bb.count
    local bodybags_amount = self:_get_all_bodybags_amount()
    local final_count = self._bodybags_amount + bodybags_amount
    bb.count = final_count
    bb.text:set_text(managers.localization:_text_macroize(self._bodybags_macro, { mine = self._bodybags_amount, placed = bodybags_amount }))
    self:AnimateItem(bb, previous_count, final_count)
    if bb.data.needs_color_refresh and final_count > 0 then
        bb.data.needs_color_refresh = nil
        self:SetColorTexture(bb.progress, self._PROGRESS_COLOR_STRING)
    end
end

function EHIRightStealthItem:_get_all_bodybags_amount()
    local stored_bodybags = 0
    for _, value in pairs(self._bodybags) do
        stored_bodybags = stored_bodybags + value
    end
    return stored_bodybags
end