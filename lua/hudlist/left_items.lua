---@alias EHILeftItemBase.Item { panel: Panel, progress: Bitmap, progress_static: Bitmap?, progress_bar: Color, text: Text, pos: integer }
---@alias EHILeftTimerItem.Timer { item: EHILeftItemBase.Item, t: number, jammed: boolean, powered: boolean, autorepair: boolean, needs_update: boolean }
---@alias EHILeftDeployableItem.Deployable { item: EHILeftItemBase.Item, eq_data: table, peer_id: integer, name_key: string, max_amount: number, ignored: boolean, max_amount: number?, pos: integer }
---@alias EHILeftDeployableItem.Group { max: number, eq_data: table, item: EHILeftItemBase.Item, deployables: table<userdata, { amount: number, ignored: boolean, max_amount: number }> }
---@alias EHILeftCameraLoopItem.Camera { t: number, t_max: number, t_max_half: number, item: EHILeftItemBase.Item, warning: boolean }

---@class EHILeftItemBase
---@field new fun(self: self, panel: Panel, params: table, texture: string, texture_rect: TextureRect): self
---@field _CUSTOM_PROGRESS boolean
---@field _update_callback function
---@field _update_id string
EHILeftItemBase = class()
EHILeftItemBase._BOTTOM_TEXT = true
EHILeftItemBase._INIT_BOTTOM_TEXT = true
EHILeftItemBase._PROGRESS_RECT = {
    { 32, 0, -32, 32 },
    { 128, 0, -128, 128 }
}
---@param o Panel
EHILeftItemBase._set_visible = function(o)
    local t, total = 0, 0.15
    while t < total do
        t = t + coroutine.yield()
        o:set_alpha(t / total)
    end
    o:set_alpha(1)
end
---@param o Panel
EHILeftItemBase._set_hidden = function(o)
    local t, total = 0.15, 0.15
    while t > 0 do
        t = t - coroutine.yield()
        o:set_alpha(t / total)
    end
    o:set_alpha(0)
end
---@param o Panel
---@param target_x number
EHILeftItemBase._move_item = function(o, target_x)
    local t, total = 0, 0.15
    local from_x = o:x()
    while t < total do
        t = t + coroutine.yield()
        o:set_x(math.lerp(from_x, target_x, t / total))
    end
    o:set_x(target_x)
end
---@param panel Panel
---@param params table
---@param texture string
---@param texture_rect TextureRect
function EHILeftItemBase:init(panel, params, texture, texture_rect)
    self._id = params.id
    self._scale = params.scale --[[@as number]]
    self._show_top_text = params.top_text
    self._delete_on_alarm = params.delete_on_alarm
    self._update_on_alarm = params.update_on_alarm
    self._sizes = {
        w = 32 * self._scale,
        h = 16 * self._scale,
        icon_offset = 4 * self._scale,
        icon_size = 24 * self._scale,
        panel_offset = 5 * self._scale,
        first_item_offset = 10 * self._scale
    }
    self._update_created = false
    local top_offset = params.top_text and 16 or 0
    local bottom_offset = self._BOTTOM_TEXT and 16 or 0
    self._panel = panel:panel({
        alpha = 0,
        y = 80,
        w = panel:w(),
        h = (32 + top_offset + bottom_offset) * self._scale,
        visible = true
    })
    self._panel:bitmap({
        name = "icon",
        x = 0,
        y = top_offset * self._scale,
        w = self._sizes.w,
        h = self._sizes.w,
        texture = texture,
        texture_rect = texture_rect,
        color = self._PROGRESS_COLOR
    })
    self._items = {} ---@type table<userdata, EHILeftItemBase.Item>
    self:RegisterListeners(params)
end

---@param params table
function EHILeftItemBase:RegisterListeners(params)
end

---@param dt number
function EHILeftItemBase:update(_, dt)
end

function EHILeftItemBase:SwitchToLoudMode()
    if self._delete_on_alarm then
        self:delete()
    elseif self._update_on_alarm then
        self:OnAlarm()
    end
end

function EHILeftItemBase:OnAlarm()
end

function EHILeftItemBase:GetFirstItemStartX()
    local icon = self._panel:child("icon") ---@cast icon -?
    return icon:x() + icon:w() + self._sizes.first_item_offset
end

---@return EHILeftItemBase.Item
function EHILeftItemBase:AddItem(...)
    local w = self._sizes.w
    local progress_bar = Color(1, 1, 0.125, 1)
    local y = self._panel:child("icon"):y()
    local panel = self._panel:panel({
        w = w,
        h = self._panel:h() -- Scale is already applied here
    })
    local progress, progress_static
    if self._CUSTOM_PROGRESS then
        progress, progress_static = self:CustomProgress(panel, y, progress_bar)
    elseif self._PROGRESS == 1 then
        progress = panel:bitmap({
            alpha = self._PROGRESS_ALPHA,
            render_template = "VertexColorTexturedRadialFlex",
            layer = 2,
            y = y,
            w = w,
            h = w,
            texture = string.format("guis/textures/pd2_mod_ehi/buffs/buff_sframe_%s", self._PROGRESS_COLOR_STRING),
            texture_rect = self._PROGRESS_RECT[1],
            color = progress_bar,
            visible = self._PROGRESS_VISIBILITY and not self._PROGRESS_STATIC
        })
        if self._PROGRESS_VISIBILITY and self._PROGRESS_STATIC then
            progress_static = panel:bitmap({
                alpha = self._PROGRESS_ALPHA,
                layer = 2,
                y = y,
                w = w,
                h = w,
                texture = string.format("guis/textures/pd2_mod_ehi/buffs/buff_sframe_%s", self._PROGRESS_COLOR_STRING),
                texture_rect = self._PROGRESS_RECT[1]
            })
        end
        panel:rect({
            blend_mode = "normal",
            halign = "grow",
            alpha = self._BG_ALPHA,
            layer = -1,
            valign = "grow",
            y = y,
            w = w,
            h = w,
            color = self._BG_COLOR
        })
    else
        progress = panel:bitmap({
            alpha = self._PROGRESS_ALPHA,
            render_template = "VertexColorTexturedRadial",
            layer = 2,
            y = y,
            w = w,
            h = w,
            texture = string.format("guis/textures/pd2_mod_ehi/buffs/buff_cframe_%s", self._PROGRESS_COLOR_STRING),
            texture_rect = self._PROGRESS_RECT[2],
            color = progress_bar,
            visible = self._PROGRESS_VISIBILITY and not self._PROGRESS_STATIC
        })
        if self._PROGRESS_VISIBILITY and self._PROGRESS_STATIC then
            progress_static = panel:bitmap({
                alpha = self._PROGRESS_ALPHA,
                layer = 2,
                y = y,
                w = w,
                h = w,
                texture = string.format("guis/textures/pd2_mod_ehi/buffs/buff_cframe_%s", self._PROGRESS_COLOR_STRING),
                texture_rect = self._PROGRESS_RECT[2]
            })
        end
        panel:bitmap({
            alpha = self._BG_ALPHA,
            layer = -1,
            y = y,
            w = w,
            h = w,
            texture = "guis/textures/pd2_mod_ehi/buffs/buff_cframe_bg_white",
            color = self._BG_COLOR:with_alpha(0.2)
        })
    end
    local text
    if self._INIT_BOTTOM_TEXT then
        local h = self._sizes.h
        text = panel:text({
            y = y + w,
            w = w,
            h = h,
            text = "",
            font = tweak_data.menu.pd2_large_font,
            font_size = h,
            align = "center",
            vertical = "center",
            color = self._PROGRESS_COLOR
        })
    end
    local pos = table.size(self._items) + 1
    local data =
    {
        pos = pos,
        panel = panel,
        progress = progress,
        progress_static = progress_static,
        progress_bar = progress_bar,
        text = text
    }
    self:_AddItem(panel, y, text, ...)
    self:SortAddedItem(panel, pos)
    self._items[panel:key()] = data
    return data
end

---@param panel Panel
---@param y number
---@param text Text
function EHILeftItemBase:_AddItem(panel, y, text, ...)
end

---@param panel Panel
---@param y number
---@param progress_bar Color
function EHILeftItemBase:CustomProgress(panel, y, progress_bar)
end

---Sorts newly added item panel on the HUD, but not in the memory
---@param panel Panel
---@param pos integer
function EHILeftItemBase:SortAddedItem(panel, pos)
    local x = self:GetFirstItemStartX()
    if pos <= 1 then
        panel:set_x(x)
    else
        pos = pos - 1
        panel:set_x(x + (panel:w() + self._sizes.panel_offset) * pos)
    end
end

---Sorts item panels on the HUD, but not in the memory  
---Every item must provide their sorting mechanism
function EHILeftItemBase:SortItems()
end

---@param panel Panel
function EHILeftItemBase:RemoveItem(panel)
    local removed = table.remove_key(self._items, panel:key())
    if removed then
        self._panel:remove(panel)
        for _, item in pairs(self._items) do
            if item.pos > removed.pos then
                item.pos = item.pos - 1
            end
        end
    end
end

if EHI:GetOption("time_format") == 1 then
    EHILeftItemBase.FormatTime = tweak_data.ehi.functions.ReturnSecondsOnly
else
    EHILeftItemBase.FormatTime = tweak_data.ehi.functions.ReturnMinutesAndSeconds
end

function EHILeftItemBase:set_visible()
    if self._visible then
        return
    end
    self._visible = true
    self._panel:stop()
    self._panel:animate(self._set_visible)
    self._parent:ItemSetVisible(self)
end

function EHILeftItemBase:set_hidden()
    if not self._visible then
        return
    end
    self._visible = false
    self._panel:stop()
    self._panel:animate(self._set_hidden)
    self._parent:ItemSetHidden()
end

function EHILeftItemBase:visible()
    return self._visible
end

function EHILeftItemBase:UnregisterListeners()
end

---@param item EHILeftItemBase.Item
---@param color string
function EHILeftItemBase:SetColorTexture(item, color)
    local texture = self._PROGRESS == 1 and "sframe" or "cframe"
    local path = string.format("guis/textures/pd2_mod_ehi/buffs/buff_%s_%s", texture, color)
    local rect = self._PROGRESS_RECT[self._PROGRESS]
    item.progress:set_image(path, unpack(rect))
    if item.progress_static then
        item.progress_static:set_image(path, unpack(rect))
    end
end

---@param text Text
function EHILeftItemBase:FitTheText(text)
    text:set_font_size(text:h())
    local w = select(3, text:text_rect())
    if w > text:w() then
        text:set_font_size(text:font_size() * (text:w() / w))
    end
end

function EHILeftItemBase:AddToUpdate()
    if not self._update_created and self._update_callback then
        managers.hud:add_updator(self._update_id, self._update_callback)
        self._update_created = true
    end
end

function EHILeftItemBase:RemoveFromUpdate()
    if self._update_created then
        managers.hud:remove_updator(self._update_id)
        self._update_created = false
    end
end

function EHILeftItemBase:delete()
    if self._visible then
        self._parent:ItemSetHidden()
    end
    self._parent:RemoveItem(self._id)
end

function EHILeftItemBase:destroy()
    self:RemoveFromUpdate()
    self:UnregisterListeners()
    if alive(self._panel) then
        self._panel:parent():remove(self._panel)
    end
end

---@class EHILeftTimerItem : EHILeftItemBase
---@field super EHILeftItemBase
EHILeftTimerItem = class(EHILeftItemBase)
function EHILeftTimerItem:RegisterListeners(params)
    self._jammed = params.jammed
    self._not_powered = params.not_powered
    self._autorepair = params.autorepair
    self._normal_color = params.color_index
    self._timers = {} ---@type table<string, EHILeftTimerItem.Timer>
end

---@param params table
function EHILeftTimerItem:AddTimer(params)
    local t = params.time
    -- Subtract a tiny bit of the timer so it looks more smooth in the tracker, jumping from 1:00 to 59 is not smooth at all
    -- This is a visual change and does not affect the calculation
    if t <= 10 then
        t = t - 0.1
    else
        t = t - 1
    end
    local item = self:AddItem(params.icon, params.hint, t)
    local id = params.id
    local needs_update = params.timer_gui ~= nil
    self._timers[id] =
    {
        item = item,
        t = params.time,
        jammed = false,
        powered = true,
        needs_update = needs_update
    }
    if needs_update then
        local timer_gui = params.timer_gui ---@type TimerGui
        managers.hud:add_updator(id, function(_, _)
            local t_new = timer_gui._time_left or timer_gui._current_timer or 0
            self:UpdateTimer(id, t_new)
        end)
    end
    self:set_visible()
end

---@param key string
function EHILeftTimerItem:AddVaultTimer(key)
    local t = 500
    local item = self:AddItem("C_Elephant_H_ElectionDay_Murphy", "timer", t)
    local timer =
    {
        item = item,
        t = t,
        time = t,
        synced_time = 0,
        tick = 0.1,
        jammed = false,
        powered = true,
        needs_update = true
    }
    self._timers[key] = timer
    managers.hud:add_updator(key, function(_, dt)
        local new_t = timer.time - dt
        self:UpdateTimer(key, new_t)
        timer.time = new_t
        if timer.jammed then
            self:RemoveTimer(key)
        end
    end)
    self:set_visible()
end

---@param icon string|table
---@param hint string
---@param t number
function EHILeftTimerItem:_AddItem(panel, y, text, icon, hint, t, ...)
    local w = self._sizes.w
    local h = self._sizes.h
    local icon_offset = self._sizes.icon_offset
    local icon_size = self._sizes.icon_size
    if type(icon) == "table" then
        icon = icon[1]
    end
    local texture, texture_rect = tweak_data.ehi.default.hudlist.get_icon({ ehi = icon })
    panel:bitmap({
        name = "icon",
        x = icon_offset,
        y = y + icon_offset,
        w = icon_size,
        h = icon_size,
        texture = texture,
        texture_rect = texture_rect,
        color = self._PROGRESS_COLOR
    })
    self:FitTheText(panel:text({
        name = "type",
        w = w,
        h = h,
        text = hint and managers.localization:text("ehi_hint_" .. hint) or "Hack",
        font = tweak_data.menu.pd2_large_font,
        font_size = h,
        align = "center",
        vertical = "center",
        visible = self._show_top_text,
        color = self._PROGRESS_COLOR
    }))
    text:set_text(self:FormatTime(t))
    self:FitTheText(text)
end

function EHILeftTimerItem:SortItems()
    local list = {} ---@type EHILeftItemBase.Item[]
    for _, timer in pairs(self._items) do
        list[timer.pos] = timer
    end
    local x = self:GetFirstItemStartX()
    for _, item in ipairs(list) do
        item.panel:stop()
        item.panel:animate(self._move_item, x)
        x = x + item.panel:w() + self._sizes.panel_offset
    end
end

---@param key string
---@param hint string?
function EHILeftTimerItem:UpdateHint(key, hint)
    local timer = self._timers[key]
    if timer then
        local text = timer.item.panel:child("type") --[[@as Text]]
        text:set_text(hint and managers.localization:text("ehi_hint_" .. hint) or "Hack")
        self:FitTheText(text)
    end
end

---@param key string
---@param icon string|table
function EHILeftTimerItem:UpdateIcon(key, icon)
    local timer = self._timers[key]
    if timer then
        if type(icon) == "table" then
            icon = icon[1]
        end
        local timer_icon = timer.item.panel:child("icon") --[[@as Bitmap]]
        local texture, texture_rect = tweak_data.ehi.default.hudlist.get_icon({ ehi = icon })
        if texture_rect then
            timer_icon:set_image(texture, unpack(texture_rect))
        else
            timer_icon:set_image(texture)
        end
    end
end

---@param key string
---@param jammed boolean
function EHILeftTimerItem:SetJammed(key, jammed)
    local timer = self._timers[key]
    if timer then
        timer.jammed = jammed
        self:_set_timer_status(timer)
    end
end

---@param key string
---@param powered boolean
function EHILeftTimerItem:SetPowered(key, powered)
    local timer = self._timers[key]
    if timer then
        timer.powered = powered
        self:_set_timer_status(timer)
    end
end

---@param key string
---@param autorepair boolean
function EHILeftTimerItem:SetAutorepair(key, autorepair)
    local timer = self._timers[key]
    if timer then
        timer.autorepair = autorepair
        self:_set_timer_status(timer)
    end
end

---@param timer EHILeftTimerItem.Timer
function EHILeftTimerItem:_set_timer_status(timer)
    local color, texture = tweak_data.ehi:GetBuffColorFromIndex(timer.autorepair and self._autorepair or
        timer.jammed and self._jammed or
        not timer.powered and self._not_powered or self._normal_color)
    timer.item.text:set_color(color)
    timer.item.panel:child("icon"):set_color(color) ---@diagnostic disable-line
    timer.item.panel:child("type"):set_color(color) ---@diagnostic disable-line
    self:SetColorTexture(timer.item, texture)
end

---@param key string
function EHILeftTimerItem:RemoveTimer(key)
    local timer = table.remove_key(self._timers, key)
    if timer then
        if timer.needs_update then
            managers.hud:remove_updator(key)
        end
        self:RemoveItem(timer.item.panel)
        if next(self._timers) then
            self:SortItems()
        else
            self:set_hidden()
        end
    end
end

---@param key string
---@param t number
function EHILeftTimerItem:UpdateTimer(key, t)
    local timer = self._timers[key]
    if timer and timer.t ~= t then
        local item = timer.item
        item.progress_bar.red = t / timer.t
        item.progress:set_color(item.progress_bar)
        item.text:set_text(self:FormatTime(t))
    end
end

---@param key string
---@param t number
function EHILeftTimerItem:CheckTime(key, t)
    local timer = self._timers[key]
    if timer then
        if timer.synced_time == 0 then
            timer.time = (50 - t) * 10
        else
            local new_tick = t - timer.synced_time
            if new_tick ~= timer.tick then
                timer.time = ((50 - t) / (new_tick * 10)) * 10
                timer.tick = new_tick
            end
        end
        timer.synced_time = t
    end
end

---@class EHILeftMinionItem : EHILeftItemBase
---@field super EHILeftItemBase
EHILeftMinionItem = class(EHILeftItemBase)
EHILeftMinionItem._BOTTOM_TEXT = false
EHILeftMinionItem._INIT_BOTTOM_TEXT = false
EHILeftMinionItem._ICON = { skills = { 6, 8 } }
EHILeftMinionItem._ICON_SKULL = { ehi = EHI:GetAchievementIconString("trk_a_0") }
EHILeftMinionItem._MINION_HEALTH_EVENTS = table.exclude(CopDamage._all_event_types, "death")
EHILeftMinionItem._MINION_NAMES =
{
    security = "Security",
    security_mex = "Security",
    security_mex_no_pager = "Security",
    gensec = "GenSec",
    cop = "Cop",
    cop_female = "Cop",
    cop_scared = "Cop",
    fbi = "FBI",
    fbi_female = "FBI",
    swat = "SWAT",
    heavy_swat = "Heavy",
    fbi_swat = "FBI",
    fbi_heavy_swat 	= "FBI Heavy",
    heavy_swat_sniper = "ZEAL Sniper",
    city_swat = "SWAT",
    zeal_heavy_swat = "Heavy ZEAL",
    zeal_swat = "ZEAL"
}
EHILeftMinionItem.SortAddedItem = function(...) end
function EHILeftMinionItem:RegisterListeners(params)
    self._minions = {} ---@type table<userdata, { unit: UnitEnemy, peer_id: integer, item: EHILeftItemBase.Item, pos: integer }>
    self._CUSTOM_PROGRESS = params.health_circle
    EHI:AddCallback(EHI.CallbackMessage.OnMinionAdded,
    ---@param unit UnitEnemy
    ---@param local_peer boolean
    ---@param peer_id integer
    function(unit, local_peer, peer_id)
        if params.minion_option == 1 or (params.minion_option == 2 and local_peer) then
            self:AddMinion(unit, peer_id)
        end
    end)
    EHI:AddCallback(EHI.CallbackMessage.OnMinionKilled,
    ---@param key userdata
    ---@param local_peer boolean
    ---@param peer_id integer
    function(key, local_peer, peer_id)
        self:RemoveMinion(key)
    end)
    EHI.ModUtils:AddCustomNameColorSyncCallback(self._id, function(peer_id, color)
        for _, minion in pairs(self._minions) do
            if minion.peer_id == peer_id then
                local item = minion.item.panel:child("icon") or minion.item.panel:child("name") --[[@as Bitmap|Text?]]
                if item then
                    item:set_color(color)
                end
                local skull = minion.item.panel:child("skull") --[[@as Bitmap?]]
                if skull then
                    skull:set_color(color)
                end
            end
        end
    end)
end

---@param unit UnitEnemy
---@param peer_id integer
function EHILeftMinionItem:AddMinion(unit, peer_id)
    local key = unit:key()
    if self._minions[key] then
        return
    end
    local pos = self:_get_number_of_minions_for_peer_id(peer_id) + 1
    self._minions[key] =
    {
        unit = unit,
        peer_id = peer_id,
        item = self:AddItem(peer_id, unit:base()._tweak_table),
        pos = pos
    }
    unit:character_damage():add_listener("EHILeftMinionItem", self._MINION_HEALTH_EVENTS, callback(self, self, "_minion_damaged", key))
    self:set_visible()
    self:SortItems()
end

---@param peer_id integer
---@param unit_tweak string
function EHILeftMinionItem:_AddItem(panel, y, text, peer_id, unit_tweak)
    local w = self._sizes.w
    local h = self._sizes.h
    local peer_color = peer_id and tweak_data.chat_colors[peer_id] or self._PROGRESS_COLOR
    if self._CUSTOM_PROGRESS then
        if not self._show_top_text then
            local width = 16 * self._scale
            local texture, texture_rect = tweak_data.ehi.default.hudlist.get_icon(self._ICON_SKULL)
            local skull = panel:bitmap({
                name = "skull",
                w = width,
                h = width,
                texture = texture,
                texture_rect = texture_rect,
                color = peer_color
            })
            skull:set_center(self._panel:child("icon"):center())
        end
    else
        local icon_offset = self._sizes.icon_offset
        local icon_size = self._sizes.icon_size
        local texture, texture_rect = tweak_data.ehi.default.hudlist.get_icon(self._ICON)
        panel:bitmap({
            name = "icon",
            x = icon_offset,
            y = y + icon_offset,
            w = icon_size,
            h = icon_size,
            texture = texture,
            texture_rect = texture_rect,
            color = peer_color
        })
    end
    local name = panel:text({
        name = "name",
        w = w,
        h = h,
        text = self._MINION_NAMES[unit_tweak] or "Convert",
        font = tweak_data.menu.pd2_large_font,
        font_size = h,
        align = "center",
        vertical = "center",
        visible = self._show_top_text,
        color = self._PROGRESS_COLOR
    })
    self:FitTheText(name)
    if self._CUSTOM_PROGRESS then
        name:set_color(peer_color)
    end
end

function EHILeftMinionItem:CustomProgress(panel, y, progress_bar)
    local w = self._sizes.w
    local progress = panel:bitmap({
        render_template = "VertexColorTexturedRadial",
        layer = 2,
        y = y,
        w = w,
        h = w,
        texture = "guis/textures/pd2/hud_health",
        texture_rect = self._PROGRESS_RECT[2],
        color = progress_bar
    })
    local static = panel:bitmap({
        layer = 3,
        y = y,
        w = w,
        h = w,
        texture = string.format("guis/textures/pd2_mod_ehi/buffs/buff_cframe_%s", self._PROGRESS_COLOR_STRING),
        texture_rect = self._PROGRESS_RECT[2],
        visible = self._PROGRESS_VISIBILITY
    })
    panel:bitmap({
        alpha = self._BG_ALPHA,
        layer = -1,
        y = y,
        w = w,
        h = w,
        texture = "guis/textures/pd2_mod_ehi/buffs/buff_cframe_bg_white",
        color = self._BG_COLOR:with_alpha(0.2)
    })
    return progress, static
end

---@param unit_key userdata
function EHILeftMinionItem:RemoveMinion(unit_key)
    local data = table.remove_key(self._minions, unit_key)
    if data then
        data.unit:character_damage():remove_listener("EHILeftMinionItem")
        self:RemoveItem(data.item.panel)
        for _, minion in pairs(self._minions) do
            if minion.peer_id == data.peer_id and minion.pos > data.pos then
                minion.pos = minion.pos - 1
            end
        end
        if next(self._minions) then
            self:SortItems()
        else
            self:set_hidden()
        end
    end
end

---@param peer_id integer
function EHILeftMinionItem:_get_number_of_minions_for_peer_id(peer_id)
    local count = 0
    for _, data in pairs(self._minions) do
        if data.peer_id == peer_id then
            count = count + 1
        end
    end
    return count
end

---@param key userdata
---@param unit UnitEnemy
---@param damage_info CopDamage.AttackData
function EHILeftMinionItem:_minion_damaged(key, unit, damage_info)
    local minion = self._minions[key]
    local item = minion and minion.item
    if item then
        item.progress_bar.red = unit:character_damage():health_ratio()
        item.progress:set_color(item.progress_bar)
    end
end

function EHILeftMinionItem:SortItems()
    local sorted_minions = {} ---@type table<integer, EHILeftItemBase.Item[]>
    for i = 0, HUDManager.PLAYER_PANEL, 1 do
        sorted_minions[i] = {}
        for _, minion in pairs(self._minions) do
            if minion.peer_id == i then
                sorted_minions[i][minion.pos] = minion.item
            end
        end
    end
    local x = self:GetFirstItemStartX()
    for i = 0, HUDManager.PLAYER_PANEL, 1 do
        for _, item in ipairs(sorted_minions[i]) do
            item.panel:stop()
            item.panel:animate(self._move_item, x)
            x = x + item.panel:w() + self._sizes.panel_offset
        end
    end
end

---@class EHILeftDeployableItem : EHILeftItemBase
---@field super EHILeftItemBase
EHILeftDeployableItem = class(EHILeftItemBase)
EHILeftDeployableItem._INIT_BOTTOM_TEXT = false
---@param o Bitmap
---@param ratio number
---@param progress Color
EHILeftDeployableItem._animate_item_progress = function(o, ratio, progress)
    local r = progress.red
    over(0.25, function(p, t)
        progress.red = math.lerp(r, ratio, p)
        o:set_color(progress)
    end)
end
EHILeftDeployableItem._AGGREGATE_DEPLOYABLES = EHI:GetHudlistListOption("left_list", "deployable_aggregate")
EHILeftDeployableItem._AGGREGATE_DEPLOYABLE_GRENADES = EHI:GetHudlistListOption("left_list", "deployable_aggregate_single_grenades")
EHILeftDeployableItem._SORTED_GROUPS = { "doctor", "ammo", "grenades", "grenade", "fak", "bodybags" }
---@param value EHILeftDeployableItem.Deployable
EHILeftDeployableItem._count_of_visible_deployables = function(value, key)
    return value.ignored == false
end
EHILeftDeployableItem.SortAddedItem = function(...) end
EHILeftDeployableItem._EQUIPMENT =
{
    ["8f59e19e1e45a05e"] =
    {
        name = "Ammo Bag",
        texture = "guis/textures/pd2/skilltree/icons_atlas",
        texture_rect = { 64, 0, 64, 64 },
        multiplier_format = "%.2fx",
        group = "ammo"
    },
    ["43ed278b1faf89b3"] =
    {
        name = "Doctor Bag",
        texture = "guis/textures/pd2/skilltree/icons_atlas",
        texture_rect = { 128, 448, 64, 64 },
        group = "doctor"
    },
    a163786a6ddb0291 =
    {
        name = "Bodybags Bag",
        texture = "guis/textures/pd2/skilltree/icons_atlas",
        texture_rect = { 320, 704, 64, 64 },
        max = tweak_data.upgrades.bodybag_crate_base,
        group = "bodybags"
    },
    e1474cdfd02aa274 =
    {
        name = "FAK",
        texture = "guis/textures/pd2/skilltree/icons_atlas",
        texture_rect = { 192, 640, 64, 64 },
        no_amount = true,
        group = "fak"
    },
    f6001ca4eb64a74c =
    {
        name = "Grenades",
        texture = "guis/dlcs/mxm/textures/pd2/blackmarket/icons/deployables/outline/grenade_crate",
        texture_rect = { 0, 0, 128, 128 },
        max = tweak_data.upgrades.grenade_crate_base,
        group = "grenades"
    },
    default =
    {
        name = "?",
        force_console_report = true
    }
}
---units/payday2/props/stn_prop_medic_firstaid_box/stn_prop_medic_firstaid_box
EHILeftDeployableItem._EQUIPMENT["269c288629a7ebc7"] = deep_clone(EHILeftDeployableItem._EQUIPMENT["43ed278b1faf89b3"])
EHILeftDeployableItem._EQUIPMENT["269c288629a7ebc7"].name = "Doctor Box"
EHILeftDeployableItem._EQUIPMENT["269c288629a7ebc7"].aggregate_name = "Doctor Bag"
EHILeftDeployableItem._EQUIPMENT["269c288629a7ebc7"].max = 1
---units/payday2/props/stn_prop_armory_shelf_ammo/stn_prop_armory_shelf_ammo
EHILeftDeployableItem._EQUIPMENT.dad3d39f10a58fbd = deep_clone(EHILeftDeployableItem._EQUIPMENT["8f59e19e1e45a05e"])
EHILeftDeployableItem._EQUIPMENT.dad3d39f10a58fbd.name = "Ammo Shelf"
EHILeftDeployableItem._EQUIPMENT.dad3d39f10a58fbd.aggregate_name = "Ammo Bag"
EHILeftDeployableItem._EQUIPMENT.dad3d39f10a58fbd.max = 3
---units/pd2_dlc_spa/props/spa_prop_armory_shelf_ammo/spa_prop_armory_shelf_ammo
EHILeftDeployableItem._EQUIPMENT["150ebbf1166515e9"] = EHILeftDeployableItem._EQUIPMENT.dad3d39f10a58fbd
---units/pd2_dlc_hvh/props/hvh_prop_armory_shelf_ammo/hvh_prop_armory_shelf_ammo
EHILeftDeployableItem._EQUIPMENT["4f480c9809095026"] = EHILeftDeployableItem._EQUIPMENT.dad3d39f10a58fbd
---units/payday2/equipment/gen_equipment_grenade_crate/gen_equipment_explosives_case_single
EHILeftDeployableItem._EQUIPMENT["02a3ade37a633a71"] = deep_clone(EHILeftDeployableItem._EQUIPMENT.f6001ca4eb64a74c)
EHILeftDeployableItem._EQUIPMENT["02a3ade37a633a71"].texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/preplan_icon_types"
EHILeftDeployableItem._EQUIPMENT["02a3ade37a633a71"].texture_rect = { 48, 0, 48, 48 }
EHILeftDeployableItem._EQUIPMENT["02a3ade37a633a71"].name = "Grenade"
EHILeftDeployableItem._EQUIPMENT["02a3ade37a633a71"].no_amount = true
EHILeftDeployableItem._EQUIPMENT["02a3ade37a633a71"].group = "grenade"
EHILeftDeployableItem._EQUIPMENT["02a3ade37a633a71"].secondary_group = "grenades"
EHILeftDeployableItem._EQUIPMENT["02a3ade37a633a71"].aggregate_name = "Grenades"
---units/pd2_dlc_spa/equipment/spa_equipment_grenade_crate/spa_equipment_grenade_crate
EHILeftDeployableItem._EQUIPMENT.fc520601b50186e4 = EHILeftDeployableItem._EQUIPMENT.f6001ca4eb64a74c
---units/pd2_dlc_mxm/equipment/gen_equipment_grenade_crate/gen_equipment_grenade_crate
EHILeftDeployableItem._EQUIPMENT.e166f63494083d58 = deep_clone(EHILeftDeployableItem._EQUIPMENT.f6001ca4eb64a74c)
EHILeftDeployableItem._EQUIPMENT.e166f63494083d58.name = "Ordnance Bag"
EHILeftDeployableItem._EQUIPMENT.e166f63494083d58.aggregate_name = "Grenades"
EHILeftDeployableItem._EQUIPMENT.e166f63494083d58.max = 4 -- Hardcoded in the class
function EHILeftDeployableItem:RegisterListeners(params)
    self._format = params.format
    self._deployables = {} ---@type table<userdata, EHILeftDeployableItem.Deployable>
    self._unit_blocked = {} ---@type table<userdata, boolean>
    self._deployable_group = {} ---@type table<string, EHILeftDeployableItem.Group?>
    self._n_of_hooks = 0
    ---@param unit UnitAmmoDeployable|UnitGrenadeDeployable|UnitFAKDeployable
    local function init_equipment(_, unit)
        local key = unit:key()
        if not (self._deployables[key] or self._unit_blocked[key]) then
            self:AddDeployable(key, unit)
        end
    end
    ---@param equipment AmmoBagBase|GrenadeCrateBase|FirstAidKitBase
    ---@param peer_id integer?
    local function server_update_peer_information(equipment, peer_id, ...)
        local deployable = self._deployables[equipment._unit:key()]
        if deployable and deployable.item then
            local id = peer_id or 0
            deployable.peer_id = id
            deployable.item.panel:child("icon"):set_color(tweak_data.chat_colors[id] or Color.white) ---@diagnostic disable-line
        end
    end
    ---@param equipment AmmoBagBase|GrenadeCrateBase|FirstAidKitBase
    ---@param peer_id integer?
    local function client_update_peer_information(equipment, _, peer_id, ...)
        server_update_peer_information(equipment, peer_id)
    end
    ---@param peer_id integer?
    local function from_spawn_update_peer_information(_, _, _, peer_id, ...)
        local unit = Hooks:GetReturn()
        if unit then
            server_update_peer_information(unit:base(), peer_id)
        end
    end
    ---@param equipment AmmoBagBase|GrenadeCrateBase|FirstAidKitBase
    local function set_visual_stage_equipment(equipment, ...)
        self:UpdateDeployableAmount(equipment)
    end
    ---@param equipment AmmoBagInteractionExt|GrenadeCrateInteractionExt
    local function set_alpha(equipment, ...)
        self:UpdateItemVisible(equipment._unit:key(), equipment._unit, equipment._active)
    end
    ---@param equipment AmmoBagBase|GrenadeCrateBase|FirstAidKitBase
    local function destroy_equipment(equipment, ...)
        local key = equipment._unit:key()
        self:RemoveDeployable(key)
    end
    if params.show_ammo then
        Hooks:PostHook(AmmoBagBase, "spawn", "EHI_AmmoBagBase_EHILeftDeployableItem_spawn", from_spawn_update_peer_information)
        Hooks:PreHook(AmmoBagBase, "init", "EHI_AmmoBagBase_EHILeftDeployableItem_init", init_equipment)
        Hooks:PostHook(AmmoBagBase, "set_server_information", "EHI_AmmoBagBase_EHILeftDeployableItem_set_server_information", server_update_peer_information)
        Hooks:PostHook(AmmoBagBase, "sync_setup", "EHI_AmmoBagBase_EHILeftDeployableItem_sync_setup", client_update_peer_information)
        Hooks:PostHook(AmmoBagBase, "setup", "EHI_AmmoBagBase_EHILeftDeployableItem_setup", function(ammo, ...)
            self:UpdateDeployableMaxAmount(ammo._unit:key(), ammo._ammo_amount)
        end)
        Hooks:PostHook(AmmoBagBase, "_set_visual_stage", "EHI_AmmoBagBase_EHILeftDeployableItem__set_visual_stage", set_visual_stage_equipment)
        Hooks:PreHook(AmmoBagBase, "_set_empty", "EHI_AmmoBagBase_EHILeftDeployableItem__set_empty", destroy_equipment)
        Hooks:PostHook(AmmoBagBase, "load", "EHI_AmmoBagBase_EHILeftDeployableItem_load", function(ammo, ...)
            self:UpdateDeployableMaxAmount(ammo._unit:key(), ammo._ammo_amount)
        end)
        Hooks:PostHook(AmmoBagBase, "destroy", "EHI_AmmoBagBase_EHILeftDeployableItem_destroy", destroy_equipment)
        Hooks:PostHook(CustomAmmoBagBase, "_set_empty", "EHI_CustomAmmoBagBase_EHILeftDeployableItem__set_empty", destroy_equipment)
        Hooks:PostHook(AmmoBagInteractionExt, "set_active", "EHI_AmmoBagInteractionExt_EHILeftDeployableItem_set_active", set_alpha)
        self._n_of_hooks = self._n_of_hooks + 1
    end
    if params.show_bodybags then
        self._bodybags_hooked = true
        Hooks:PostHook(BodyBagsBagBase, "spawn", "EHI_BodyBagsBagBase_EHILeftDeployableItem_spawn", from_spawn_update_peer_information)
        Hooks:PostHook(BodyBagsBagBase, "init", "EHI_BodyBagsBagBase_EHILeftDeployableItem_init", init_equipment)
        Hooks:PostHook(BodyBagsBagBase, "set_server_information", "EHI_BodyBagsBagBase_EHILeftDeployableItem_set_server_information", server_update_peer_information)
        Hooks:PostHook(BodyBagsBagBase, "sync_setup", "EHI_BodyBagsBagBase_EHILeftDeployableItem_sync_setup", client_update_peer_information)
        Hooks:PostHook(BodyBagsBagBase, "_set_visual_stage", "EHI_BodyBagsBagBase_EHILeftDeployableItem__set_visual_stage", set_visual_stage_equipment)
        Hooks:PreHook(BodyBagsBagBase, "_set_empty", "EHI_BodyBagsBagBase_EHILeftDeployableItem__set_empty", destroy_equipment)
        Hooks:PostHook(BodyBagsBagBase, "destroy", "EHI_BodyBagsBagBase_EHILeftDeployableItem_destroy", destroy_equipment)
        Hooks:PostHook(BodyBagsBagInteractionExt, "set_active", "EHI_BodyBagsBagInteractionExt_EHILeftDeployableItem_set_active", set_alpha)
        self._n_of_hooks = self._n_of_hooks + 1
    end
    if params.show_doctor then
        Hooks:PostHook(DoctorBagBase, "spawn", "EHI_DoctorBagBase_EHILeftDeployableItem_spawn", from_spawn_update_peer_information)
        Hooks:PreHook(DoctorBagBase, "init", "EHI_DoctorBagBase_EHILeftDeployableItem_init", init_equipment)
        Hooks:PostHook(DoctorBagBase, "set_server_information", "EHI_DoctorBagBase_EHILeftDeployableItem_set_server_information", server_update_peer_information)
        Hooks:PostHook(DoctorBagBase, "sync_setup", "EHI_DoctorBagBase_EHILeftDeployableItem_sync_setup", client_update_peer_information)
        Hooks:PostHook(DoctorBagBase, "setup", "EHI_DoctorBagBase_EHILeftDeployableItem_setup", function(doctor, ...)
            self:UpdateDeployableMaxAmount(doctor._unit:key(), doctor._amount)
        end)
        Hooks:PostHook(DoctorBagBase, "_set_visual_stage", "EHI_DoctorBagBase_EHILeftDeployableItem__set_visual_stage", set_visual_stage_equipment)
        Hooks:PreHook(DoctorBagBase, "_set_empty", "EHI_DoctorBagBase_EHILeftDeployableItem__set_empty", destroy_equipment)
        Hooks:PostHook(DoctorBagBase, "load", "EHI_DoctorBagBase_EHILeftDeployableItem_load", function(doctor, ...)
            self:UpdateDeployableMaxAmount(doctor._unit:key(), doctor._amount)
        end)
        Hooks:PostHook(DoctorBagBase, "destroy", "EHI_DoctorBagBase_EHILeftDeployableItem_destroy", destroy_equipment)
        Hooks:PostHook(CustomDoctorBagBase, "_set_empty", "EHI_CustomDoctorBagBase_EHILeftDeployableItem__set_empty", destroy_equipment)
        Hooks:PostHook(DoctorBagBaseInteractionExt, "set_active", "EHI_DoctorBagBaseInteractionExt_EHILeftDeployableItem_set_active", set_alpha)
        self._n_of_hooks = self._n_of_hooks + 1
    end
    if params.show_fak then
        Hooks:PostHook(FirstAidKitBase, "spawn", "EHI_FirstAidKitBase_EHILeftDeployableItem_spawn", from_spawn_update_peer_information)
        Hooks:PostHook(FirstAidKitBase, "init", "EHI_FirstAidKitBase_EHILeftDeployableItem_init", init_equipment)
        Hooks:PostHook(FirstAidKitBase, "set_server_information", "EHI_FirstAidKitBase_EHILeftDeployableItem_set_server_information", server_update_peer_information)
        Hooks:PostHook(FirstAidKitBase, "sync_setup", "EHI_FirstAidKitBase_EHILeftDeployableItem_sync_setup", client_update_peer_information)
        Hooks:PostHook(FirstAidKitBase, "setup", "EHI_FirstAidKitBase_EHILeftDeployableItem_setup", set_visual_stage_equipment)
        Hooks:PreHook(FirstAidKitBase, "_set_empty", "EHI_FirstAidKitBase_EHILeftDeployableItem__set_empty", destroy_equipment)
        Hooks:PostHook(FirstAidKitBase, "destroy", "EHI_FirstAidKitBase_EHILeftDeployableItem_destroy", destroy_equipment)
        Hooks:PostHook(DoctorBagBaseInteractionExt, "set_active", "EHI_DoctorBagBaseInteractionExt_EHILeftDeployableItem_set_active", set_alpha)
        self._n_of_hooks = self._n_of_hooks + 1
    end
    if params.show_grenades then
        -- init calls _set_visual_stage, needs to be prehooked to work correctly
        Hooks:PreHook(GrenadeCrateBase, "init", "EHI_GrenadeCrateBase_EHILeftDeployableItem_init", init_equipment)
        Hooks:PostHook(GrenadeCrateBase, "_set_visual_stage", "EHI_GrenadeCrateBase_EHILeftDeployableItem__set_visual_stage", set_visual_stage_equipment)
        Hooks:PreHook(GrenadeCrateBase, "_set_empty", "EHI_GrenadeCrateBase_EHILeftDeployableItem__set_empty", destroy_equipment)
        Hooks:PostHook(GrenadeCrateBase, "destroy", "EHI_GrenadeCrateBase_EHILeftDeployableItem_destroy", destroy_equipment)
        Hooks:PreHook(CustomGrenadeCrateBase, "init", "EHI_CustomGrenadeCrateBase_EHILeftDeployableItem_init", init_equipment)
        Hooks:PostHook(CustomGrenadeCrateBase, "_set_empty", "EHI_CustomGrenadeCrateBase_EHILeftDeployableItem__set_empty", destroy_equipment)
        Hooks:PostHook(GrenadeCrateDeployableBase, "set_server_information", "EHI_GrenadeCrateDeployableBase_EHILeftDeployableItem_set_server_information", server_update_peer_information)
        Hooks:PreHook(GrenadeCrateDeployableBase, "_set_empty", "EHI_CustomGrenadeCrateDeployableBase_EHILeftDeployableItem__set_empty", destroy_equipment)
        if params.block_grenades then
            EHI.PlayerUtils:AddGrenadeDoesNotAllowPickupsCallback(function()
                Hooks:RemovePreHook("EHI_GrenadeCrateBase_EHILeftDeployableItem_init")
                Hooks:RemovePostHook("EHI_GrenadeCrateBase_EHILeftDeployableItem__set_visual_stage")
                Hooks:RemovePreHook("EHI_GrenadeCrateBase_EHILeftDeployableItem__set_empty")
                Hooks:RemovePostHook("EHI_GrenadeCrateBase_EHILeftDeployableItem_destroy")
                Hooks:RemovePreHook("EHI_CustomGrenadeCrateBase_EHILeftDeployableItem_init")
                Hooks:RemovePostHook("EHI_CustomGrenadeCrateBase_EHILeftDeployableItem__set_empty")
                Hooks:RemovePostHook("EHI_GrenadeCrateDeployableBase_EHILeftDeployableItem_set_server_information")
                Hooks:RemovePreHook("EHI_CustomGrenadeCrateDeployableBase_EHILeftDeployableItem__set_empty")
                self:RemoveDeployableGroup("grenades", "grenade")
                self._n_of_hooks = self._n_of_hooks - 1
                if self._n_of_hooks <= 0 then
                    self:delete()
                end
            end)
        end
        self._n_of_hooks = self._n_of_hooks + 1
    end
    EHI.TrackerUtils.Deployables:AddIgnoreListener(self._id, function(key, unit)
        self._unit_blocked[key] = true
        self:RemoveDeployable(key)
    end)
    if not self._AGGREGATE_DEPLOYABLES then
        EHI.ModUtils:AddCustomNameColorSyncCallback(self._id, function(peer_id, color)
            for key, deployable in pairs(self._deployables) do
                if deployable.peer_id == peer_id then
                    self:UpdateDeployableColor(key, peer_id, color)
                end
            end
        end)
    end
end

function EHILeftDeployableItem:UnregisterListeners()
    EHI.TrackerUtils.Deployables:RemoveIgnoreListener(self._id)
    EHI.ModUtils:RemoveCustomNameColorSyncCallback(self._id)
end

function EHILeftDeployableItem:OnAlarm()
    if self._bodybags_hooked then
        Hooks:RemovePostHook("EHI_BodyBagsBagBase_EHILeftDeployableItem_spawn")
        Hooks:RemovePostHook("EHI_BodyBagsBagBase_EHILeftDeployableItem_init")
        Hooks:RemovePostHook("EHI_BodyBagsBagBase_EHILeftDeployableItem_set_server_information")
        Hooks:RemovePostHook("EHI_BodyBagsBagBase_EHILeftDeployableItem_sync_setup")
        Hooks:RemovePostHook("EHI_BodyBagsBagBase_EHILeftDeployableItem__set_visual_stage")
        Hooks:RemovePreHook("EHI_BodyBagsBagBase_EHILeftDeployableItem__set_empty")
        Hooks:RemovePostHook("EHI_BodyBagsBagBase_EHILeftDeployableItem_destroy")
        Hooks:RemovePostHook("EHI_BodyBagsBagInteractionExt_EHILeftDeployableItem_set_active")
        self:RemoveDeployableGroup("bodybags")
        self._n_of_hooks = self._n_of_hooks - 1
        if self._n_of_hooks <= 0 then
            self:delete()
        end
        self._bodybags_hooked = nil
    end
end

---@param key userdata
---@param unit UnitAmmoDeployable|UnitGrenadeDeployable|UnitFAKDeployable
function EHILeftDeployableItem:AddDeployable(key, unit)
    local name_key = unit:name():key()
    local eq_data = self._EQUIPMENT[name_key] or self._EQUIPMENT.default
    if eq_data.force_console_report or self._unit_blocked[key] then
        return
    end
    local tbl = ---@type EHILeftDeployableItem.Deployable
    {
        eq_data = eq_data,
        name_key = name_key,
        peer_id = 0,
        ignored = false,
        max_amount = eq_data.max,
        pos = self:_get_amount_of_deployables_in_group(eq_data.group) + 1
    }
    self._deployables[key] = tbl
    if self._AGGREGATE_DEPLOYABLES then
        local group = self:_get_deployable_group(eq_data)
        if not group then
            group = {}
            group.deployables = {}
            group.item = self:AddItem(eq_data, true)
            group.eq_data = eq_data
            group.max = 0
            self._deployable_group[self:_get_group_name(eq_data)] = group
        end
        group.deployables[key] = {
            ignored = false,
            max_amount = eq_data.no_amount and 1 or eq_data.max or 0,
            amount = eq_data.no_amount and 1 or eq_data.max or 0
        }
        if eq_data.no_amount then
            group.max = group.max + 1
            self:_update_group_amount(group)
        elseif eq_data.max then
            group.max = group.max + eq_data.max
            self:_update_group_amount(group)
        end
    else
        tbl.item = self:AddItem(eq_data)
    end
    if self._AGGREGATE_DEPLOYABLES then
        self:_update_group_item_visibility()
    else
        self:set_visible()
        self:SortItems()
    end
end

---@param eq_data table
---@param force_amount boolean?
function EHILeftDeployableItem:_AddItem(panel, y, text, eq_data, force_amount)
    local w = self._sizes.w
    local h = self._sizes.h
    local icon_offset = self._sizes.icon_offset
    local icon_size = self._sizes.icon_size
    panel:bitmap({
        name = "icon",
        x = icon_offset,
        y = y + icon_offset,
        w = icon_size,
        h = icon_size,
        texture = eq_data.texture,
        texture_rect = eq_data.texture_rect,
        color = self._PROGRESS_COLOR
    })
    self:FitTheText(panel:text({
        w = w,
        h = h,
        text = self._AGGREGATE_DEPLOYABLES and eq_data.aggregate_name or eq_data.name or "?",
        font = tweak_data.menu.pd2_large_font,
        font_size = h,
        align = "center",
        vertical = "center",
        visible = self._show_top_text,
        color = self._PROGRESS_COLOR
    }))
    if force_amount or not eq_data.no_amount then
        self:FitTheText(panel:text({
            name = "amount",
            y = y + w,
            w = w,
            h = h,
            text = "420%",
            font = tweak_data.menu.pd2_large_font,
            font_size = h,
            align = "center",
            vertical = "center",
            color = self._PROGRESS_COLOR
        }))
    end
end

---@param base AmmoBagBase|GrenadeCrateBase|FirstAidKitBase
function EHILeftDeployableItem:UpdateDeployableAmount(base)
    local key = base._unit:key()
    local data = self._deployables[key]
    if data and not data.eq_data.no_amount then
        local amount = base:GetRealAmount()
        local item = data.item and data.item.panel:child("amount") --[[@as Text?]]
        if item then
            if self._format == 1 then
                item:set_text(string.format(data.eq_data.multiplier_format or "%dx", amount))
            else
                item:set_text(string.format(self._PERCENT_FORMAT, amount * 100))
            end
            self:FitTheText(item)
            if data.max_amount and amount > 0 then
                data.item.progress:stop()
                data.item.progress:animate(self._animate_item_progress, amount / data.max_amount, data.item.progress_bar)
            end
        end
        local group = self:_get_deployable_group(data.eq_data)
        local deployable = group and group.deployables[key]
        if deployable then
            deployable.amount = amount
            self:_update_group_amount(group)
        end
    end
end

---@param key userdata
---@param max number
function EHILeftDeployableItem:UpdateDeployableMaxAmount(key, max)
    local data = self._deployables[key]
    if data and not data.eq_data.no_amount then
        data.max_amount = max
        if self._AGGREGATE_DEPLOYABLES then
            local group = self:_get_deployable_group(data.eq_data)
            local deployable = group and group.deployables[key]
            if deployable then
                deployable.max_amount = max
                local new_max = 0
                for _, eq_max in pairs(group.deployables) do
                    new_max = new_max + eq_max.amount
                end
                group.max = math.max(group.max, new_max)
                self:_update_group_amount(group)
            end
        end
    end
end

---@param key userdata
---@param peer_id integer
---@param color Color?
function EHILeftDeployableItem:UpdateDeployableColor(key, peer_id, color)
    local data = self._deployables[key]
    if data and data.item then
        data.item.panel:child("icon"):set_color(color or tweak_data.chat_colors[peer_id or 0] or self._PROGRESS_COLOR) ---@diagnostic disable-line
    end
end

---@param key userdata
---@param unit UnitAmmoDeployable|UnitFAKDeployable|UnitGrenadeDeployable
---@param visibility boolean
function EHILeftDeployableItem:UpdateItemVisible(key, unit, visibility)
    local data = self._deployables[key]
    if data and data.ignored == visibility then
        data.ignored = not visibility
        if data.item then
            data.item.panel:set_visible(visibility)
        end
        if self._AGGREGATE_DEPLOYABLES then
            local group = self:_get_deployable_group(data.eq_data)
            local deployable = group and group.deployables[key]
            if deployable then
                deployable.ignored = not visibility
                if visibility then
                    self:UpdateDeployableAmount(unit:base())
                else
                    group.max = math.max(group.max - deployable.amount, 0)
                    self:_update_group_amount(group)
                end
                self:_update_group_item_visibility()
            end
        elseif table.count(self._deployables, self._count_of_visible_deployables) > 0 then
            self:set_visible()
            self:SortItems()
        else
            self:set_hidden()
        end
    end
end

---@param key userdata
function EHILeftDeployableItem:RemoveDeployable(key)
    local data = table.remove_key(self._deployables, key)
    if data then
        if data.item then
            self:RemoveItem(data.item.panel)
        end
        for _, deployable in pairs(self._deployables) do
            if deployable.eq_data.group == data.eq_data.group and deployable.pos > data.pos then
                deployable.pos = deployable.pos - 1
            end
        end
        if self._AGGREGATE_DEPLOYABLES then
            local group = self:_get_deployable_group(data.eq_data)
            if group then
                group.deployables[key] = nil
                if next(group.deployables) then
                    self:_update_group_amount(group)
                else
                    self:RemoveItem(group.item.panel)
                    self._deployable_group[self:_get_group_name(data.eq_data)] = nil
                end
                self:_update_group_item_visibility()
            end
        elseif table.count(self._deployables, self._count_of_visible_deployables) > 0 then
            self:SortItems()
        else
            self:set_hidden()
        end
    end
end

---Removes all deployables in the group with one call
---@param ... string
function EHILeftDeployableItem:RemoveDeployableGroup(...)
    local removed = 0
    for _, group in ipairs({ ... }) do
        for key, deployable in pairs(self._deployables) do
            if deployable.eq_data.group == group then
                if deployable.item then
                    self:RemoveItem(deployable.item.panel)
                    removed = removed + 1
                end
                self._deployables[key] = nil
                self._unit_blocked[key] = true
            end
        end
        local group_data = self._deployable_group[group]
        if group_data then
            self:RemoveItem(group_data.item.panel)
            removed = removed + 1
            self._deployable_group[group] = nil
        end
    end
    if removed > 0 then -- Run only if actually some of the deployables were removed
        if self._AGGREGATE_DEPLOYABLES then
            self:_update_group_item_visibility()
        elseif table.count(self._deployables, self._count_of_visible_deployables) > 0 then
            self:SortItems()
        else
            self:set_hidden()
        end
    end
end

function EHILeftDeployableItem:_update_group_item_visibility()
    local visible = false
    for _, group in ipairs(self._SORTED_GROUPS) do
        local list = self._deployable_group[group]
        if list then
            if table.count(list.deployables, self._count_of_visible_deployables) > 0 then
                list.item.panel:show()
                visible = true
            else
                list.item.panel:hide()
            end
        end
    end
    if visible then
        self:set_visible()
        self:SortGroupItems()
    else
        self:set_hidden()
    end
end

---@param eq_data { group: string, secondary_group: string? }
function EHILeftDeployableItem:_get_deployable_group(eq_data)
    return self._deployable_group[self:_get_group_name(eq_data)]
end

---@param eq_data { group: string, secondary_group: string? }
function EHILeftDeployableItem:_get_group_name(eq_data)
    return self._AGGREGATE_DEPLOYABLE_GRENADES and eq_data.secondary_group or eq_data.group
end

---@param group EHILeftDeployableItem.Group
function EHILeftDeployableItem:_update_group_amount(group)
    local amount = 0
    for _, data in pairs(group.deployables) do
        if data.ignored == false and data.amount > 0 and data.max_amount > 0 then
            amount = amount + data.amount
        end
    end
    local item = group.item.panel:child("amount") --[[@as Text]]
    if self._format == 1 then
        item:set_text(string.format(group.eq_data.multiplier_format or "%dx", amount))
    else
        item:set_text(string.format(self._PERCENT_FORMAT, amount * 100))
    end
    self:FitTheText(item)
    if group.max > 0 then
        group.item.progress:stop()
        group.item.progress:animate(self._animate_item_progress, amount / group.max, group.item.progress_bar)
    end
end

function EHILeftDeployableItem:SortItems()
    local list = {} ---@type table<string, EHILeftDeployableItem.Deployable[]>
    for _, group in ipairs(self._SORTED_GROUPS) do
        list[group] = {}
        for _, deployable in pairs(self._deployables) do
            if deployable.eq_data.group == group then
                list[group][deployable.pos] = deployable
            end
        end
    end
    local start_x = self:GetFirstItemStartX()
    for _, group in ipairs(self._SORTED_GROUPS) do
        for _, eq in ipairs(list[group]) do
            if not eq.ignored then
                eq.item.panel:stop()
                eq.item.panel:animate(self._move_item, start_x)
                start_x = start_x + eq.item.panel:w() + self._sizes.panel_offset
            end
        end
    end
end

function EHILeftDeployableItem:SortGroupItems()
    local start_x = self:GetFirstItemStartX()
    for _, group in ipairs(self._SORTED_GROUPS) do
        local list = self._deployable_group[group]
        if list and table.count(list.deployables, self._count_of_visible_deployables) > 0 then
            list.item.panel:stop()
            list.item.panel:animate(self._move_item, start_x)
            start_x = start_x + list.item.panel:w() + self._sizes.panel_offset
        end
    end
end

---@param group string
function EHILeftDeployableItem:_get_amount_of_deployables_in_group(group)
    local count = 0
    for _, deployable in pairs(self._deployables) do
        if deployable.eq_data.group == group then
            count = count + 1
        end
    end
    return count
end

---@class EHILeftPagerItem : EHILeftItemBase
---@field super EHILeftItemBase
EHILeftPagerItem = class(EHILeftItemBase)
EHILeftPagerItem._update_id = "EHILeftPagerItem"
EHILeftPagerItem._PAGER_T = 12
EHILeftPagerItem._PAGER_T_HALF = 6
EHILeftPagerItem._PAGER_HALF_COLOR_INDEX = EHI:GetHudlistListOption("left_list", "enemy_pager_warning_color")
function EHILeftPagerItem:RegisterListeners(params)
    self._pagers = {} ---@type table<string, { running: boolean, item: EHILeftItemBase.Item, t: number, warning: boolean }>
    self._warning_color, self._warning_color_string = tweak_data.ehi:GetBuffColorFromIndex(self._PAGER_HALF_COLOR_INDEX)
    self._update_callback = callback(self, self, "update")
end

function EHILeftPagerItem:update(_, dt)
    for _, pager in pairs(self._pagers) do
        if pager.running then
            local t = pager.t - dt
            if t <= 0 then
                pager.running = false -- Whole item will get nuked later
            else
                local item = pager.item
                item.progress_bar.red = t / self._PAGER_T
                item.progress:set_color(item.progress_bar)
                item.text:set_text(self:FormatTime(t))
                pager.t = t
                if t <= self._PAGER_T_HALF and not pager.warning then
                    self:SetColorTexture(item, self._warning_color_string)
                    item.text:set_color(self._warning_color)
                    item.panel:child("icon"):set_color(self._warning_color) ---@diagnostic disable-line
                    pager.warning = true
                end
            end
        end
    end
end

---@param id string
function EHILeftPagerItem:AddPager(id)
    self._pagers[id] =
    {
        running = true,
        item = self:AddItem(),
        t = self._PAGER_T
    }
    self:set_visible()
    self:AddToUpdate()
end

function EHILeftPagerItem:_AddItem(panel, y, text)
    local icon_offset = self._sizes.icon_offset
    local icon_size = self._sizes.icon_size
    local texture, texture_rect = tweak_data.hud_icons:get_icon_data("pagers_used")
    panel:bitmap({
        name = "icon",
        x = icon_offset,
        y = y + icon_offset,
        w = icon_size,
        h = icon_size,
        texture = texture,
        texture_rect = texture_rect,
        color = self._warning_color
    })
    text:set_text(self:FormatTime(self._PAGER_T))
    self:FitTheText(text)
end

function EHILeftPagerItem:SortItems()
    local x = self:GetFirstItemStartX()
    for _, pager in pairs(self._pagers) do
        local panel = pager.item.panel
        panel:stop()
        panel:animate(self._move_item, x + (panel:w() + self._sizes.panel_offset) * (pager.item.pos - 1))
    end
end

---@param id string
function EHILeftPagerItem:SetAnswered(id)
    local pager = self._pagers[id]
    if pager then
        pager.running = false
        self:SetColorTexture(pager.item, "green")
        pager.item.text:set_color(Color.green)
        pager.item.panel:child("icon"):set_color(Color.green) ---@diagnostic disable-line
    end
end

---@param id string
function EHILeftPagerItem:RemovePager(id)
    local pager = table.remove_key(self._pagers, id)
    if pager then
        self:RemoveItem(pager.item.panel)
        if next(self._pagers) then
            self:SortItems()
        else
            self:set_hidden()
            self:RemoveFromUpdate()
        end
    end
end

---@class EHILeftJammerItem : EHILeftItemBase
---@field super EHILeftItemBase
EHILeftJammerItem = class(EHILeftItemBase)
EHILeftJammerItem._ICON = { skills = { 1, 4 } }
EHILeftJammerItem._AFFECTS_PAGER_COLOR = EHI:GetHudlistListOption("left_list", "jammer_affects_pager")
EHILeftJammerItem._update_id = "EHILeftJammerItem"
function EHILeftJammerItem:RegisterListeners(params)
    self._jammers = {} ---@type table<string, { t_max: number, t: number, item: EHILeftItemBase.Item, peer_id: integer }>
    self._update_callback = callback(self, self, "update")
    EHI.ModUtils:AddCustomNameColorSyncCallback(self._update_id, function(peer_id, color)
        for _, jammer in pairs(self._jammers) do
            if jammer.peer_id == peer_id then
                jammer.item.panel:child("icon"):set_color(color or Color.white) ---@diagnostic disable-line
            end
        end
    end)
end

function EHILeftJammerItem:UnregisterListeners()
    EHI.ModUtils:RemoveCustomNameColorSyncCallback(self._update_id)
end

function EHILeftJammerItem:update(_, dt)
    for key, jammer in pairs(self._jammers) do
        local t = jammer.t - dt
        if t <= 0 then
            self:RemoveJammer(key)
        else
            local item = jammer.item
            item.progress_bar.red = t / jammer.t_max
            item.progress:set_color(item.progress_bar)
            item.text:set_text(self:FormatTime(t))
            jammer.t = t
        end
    end
end

---@param key string
---@param t number
---@param peer_id integer
---@param pagers_affected boolean
function EHILeftJammerItem:AddJammer(key, t, peer_id, pagers_affected)
    local item = self:AddItem(t, peer_id)
    self._jammers[key] = {
        item = item,
        t_max = t,
        t = t,
        peer_id = peer_id
    }
    if pagers_affected then
        local color, texture = tweak_data.ehi:GetBuffColorFromIndex(self._AFFECTS_PAGER_COLOR)
        self:SetColorTexture(item, texture)
        if not self._PROGRESS_VISIBILITY then
            item.text:set_color(color)
        end
    end
    self:set_visible()
    self:AddToUpdate()
end

---@param t number
---@param peer_id integer
function EHILeftJammerItem:_AddItem(panel, y, text, t, peer_id)
    local icon_offset = self._sizes.icon_offset
    local icon_size = self._sizes.icon_size
    local texture, texture_rect = tweak_data.ehi.default.hudlist.get_icon(self._ICON)
    panel:bitmap({
        name = "icon",
        x = icon_offset,
        y = y + icon_offset,
        w = icon_size,
        h = icon_size,
        texture = texture,
        texture_rect = texture_rect,
        color = peer_id and tweak_data.chat_colors[peer_id] or self._PROGRESS_COLOR
    })
    text:set_text(self:FormatTime(t))
    self:FitTheText(text)
end

---@param key string
function EHILeftJammerItem:RemoveJammer(key)
    local jammer = table.remove_key(self._jammers, key)
    if jammer then
        self:RemoveItem(jammer.item.panel)
        if next(self._jammers) then
            self:SortItems()
        else
            self:set_hidden()
            self:RemoveFromUpdate()
        end
    end
end

function EHILeftJammerItem:SortItems()
    local x = self:GetFirstItemStartX()
    for _, jammer in pairs(self._jammers) do
        local panel = jammer.item.panel
        panel:stop()
        panel:animate(self._move_item, x + (panel:w() + self._sizes.panel_offset) * (jammer.item.pos - 1))
    end
end

---@class EHILeftJammerRetriggerItem : EHILeftItemBase
---@field super EHILeftItemBase
EHILeftJammerRetriggerItem = class(EHILeftItemBase)
EHILeftJammerRetriggerItem._ICON = { skills = { 6, 2 } }
EHILeftJammerRetriggerItem._update_id = "EHILeftJammerRetriggerItem"
function EHILeftJammerRetriggerItem:RegisterListeners(params)
    self._jammers = {} ---@type table<string, { t_max: number, t: number, item: EHILeftItemBase.Item, peer_id: integer }>
    self._update_callback = callback(self, self, "update")
    EHI.ModUtils:AddCustomNameColorSyncCallback(self._update_id, function(peer_id, color)
        for _, jammer in pairs(self._jammers) do
            if jammer.peer_id == peer_id then
                jammer.item.panel:child("icon"):set_color(color or self._PROGRESS_COLOR) ---@diagnostic disable-line
            end
        end
    end)
end

function EHILeftJammerRetriggerItem:update(_, dt)
    for key, jammer in pairs(self._jammers) do
        local t = jammer.t - dt
        if t <= 0 then
            self:RemoveJammer(key)
        else
            local item = jammer.item
            item.progress_bar.red = t / jammer.t_max
            item.progress:set_color(item.progress_bar)
            item.text:set_text(self:FormatTime(t))
            jammer.t = t
        end
    end
end

---@param key string
---@param t number
---@param peer_id integer
function EHILeftJammerRetriggerItem:AddJammer(key, t, peer_id)
    self._jammers[key] = {
        item = self:AddItem(t, peer_id),
        t_max = t,
        t = t,
        peer_id = peer_id
    }
    self:set_visible()
    self:AddToUpdate()
end

---@param t number
---@param peer_id integer
function EHILeftJammerRetriggerItem:_AddItem(panel, y, text, t, peer_id)
    local icon_offset = self._sizes.icon_offset
    local icon_size = self._sizes.icon_size
    local texture, texture_rect = tweak_data.ehi.default.hudlist.get_icon(self._ICON)
    panel:bitmap({
        name = "icon",
        x = icon_offset,
        y = y + icon_offset,
        w = icon_size,
        h = icon_size,
        texture = texture,
        texture_rect = texture_rect,
        color = peer_id and tweak_data.chat_colors[peer_id] or self._PROGRESS_COLOR
    })
    text:set_text(self:FormatTime(t))
    self:FitTheText(text)
end

---@param key string
function EHILeftJammerRetriggerItem:RemoveJammer(key)
    local jammer = table.remove_key(self._jammers, key)
    if jammer then
        self:RemoveItem(jammer.item.panel)
        if next(self._jammers) then
            self:SortItems()
        else
            self:set_hidden()
            self:RemoveFromUpdate()
        end
    end
end

function EHILeftJammerRetriggerItem:SortItems()
    local x = self:GetFirstItemStartX()
    for _, jammer in pairs(self._jammers) do
        local panel = jammer.item.panel
        panel:stop()
        panel:animate(self._move_item, x + (panel:w() + self._sizes.panel_offset) * (jammer.item.pos - 1))
    end
end

---@class EHILeftCameraLoopItem : EHILeftItemBase
---@field super EHILeftItemBase
EHILeftCameraLoopItem = class(EHILeftItemBase)
EHILeftCameraLoopItem._update_id = "EHILeftCameraLoopItem"
EHILeftCameraLoopItem._ICON = { ehi = "camera_loop" }
EHILeftCameraLoopItem._CAMERA_HALF_COLOR_INDEX = EHI:GetHudlistListOption("left_list", "camera_loop_warning_color")
function EHILeftCameraLoopItem:RegisterListeners(params)
    self._cameras = {} ---@type table<string, EHILeftCameraLoopItem.Camera>
    self._warning_color, self._warning_color_string = tweak_data.ehi:GetBuffColorFromIndex(self._CAMERA_HALF_COLOR_INDEX)
    self._update_callback = callback(self, self, "update")
end

function EHILeftCameraLoopItem:update(_, dt)
    for id, cam in pairs(self._cameras) do
        local t = cam.t - dt
        local item = cam.item
        if t <= 0 then
            self:RemoveCameraLoop(id)
        else
            item.progress_bar.red = t / cam.t_max
            item.progress:set_color(item.progress_bar)
            item.text:set_text(self:FormatTime(t))
            cam.t = t
            if t <= cam.t_max_half and not cam.warning then
                self:SetColorTexture(item, self._warning_color_string)
                item.text:set_color(self._warning_color)
                item.panel:child("icon"):set_color(self._warning_color) ---@diagnostic disable-line
                cam.warning = true
            end
        end
    end
end

---@param id string
---@param t number
function EHILeftCameraLoopItem:AddCameraLoop(id, t)
    local cam = self._cameras[id] or {}
    cam.t_max = t
    cam.t_max_half = t / 2
    cam.t = t
    cam.item = cam.item or self:AddItem(t)
    self._cameras[id] = cam
    self:AddToUpdate()
    self:set_visible()
end

---@param id string
function EHILeftCameraLoopItem:RemoveCameraLoop(id)
    local cam = table.remove_key(self._cameras, id)
    if cam then
        self:RemoveItem(cam.item.panel)
        if next(self._cameras) then
            self:SortItems()
        else
            self:RemoveFromUpdate()
            self:set_hidden()
        end
    end
end

---@param t number
function EHILeftCameraLoopItem:_AddItem(panel, y, text, t)
    local icon_offset = self._sizes.icon_offset
    local icon_size = self._sizes.icon_size
    local texture, texture_rect = tweak_data.ehi.default.hudlist.get_icon(self._ICON)
    panel:bitmap({
        name = "icon",
        x = icon_offset,
        y = y + icon_offset,
        w = icon_size,
        h = icon_size,
        texture = texture,
        texture_rect = texture_rect,
        color = self._PROGRESS_COLOR
    })
    text:set_text(self:FormatTime(t))
    self:FitTheText(text)
end

function EHILeftCameraLoopItem:SortItems()
    local x = self:GetFirstItemStartX()
    for _, cam in pairs(self._cameras) do
        local panel = cam.item.panel
        panel:stop()
        panel:animate(self._move_item, x + (panel:w() + self._sizes.panel_offset) * (cam.item.pos - 1))
    end
end

EHI:AddOnLocalizationLoaded(function(loc, lang_name)
    if EHILeftDeployableItem then
        EHILeftDeployableItem._PERCENT_FORMAT = "%d" .. tweak_data.ehi:GetLanguageFormat(lang_name).percent_format()
    end
end)