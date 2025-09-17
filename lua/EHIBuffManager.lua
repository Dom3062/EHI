local EHI = EHI

---@class EHIBuffManager
local EHIBuffManager = {}
EHIBuffManager._sync_add_buff = "EHISyncAddBuff"
---@param hud HUDManager
---@param panel Panel
function EHIBuffManager:init_finalize(hud, panel)
    local tweak_data = tweak_data.ehi.default.buff
    self._buffs = {} ---@type table<string, EHIBuffTracker?>
    self._update_buffs = setmetatable({}, { __mode = "k" }) ---@type table<string, EHIBuffTracker?>
    self._visible_buffs = setmetatable({}, { __mode = "k" }) ---@type table<string, EHIBuffTracker?>
    self._n_visible = 0
    self._gap = tweak_data.gap
    self._x = EHI:GetOption(_G.IS_VR and "buffs_vr_x_offset" or "buffs_x_offset") --[[@as number]]
    local path = EHI.LuaPath .. "buffs/"
    dofile(path .. "EHIBuffTracker.lua")
    dofile(path .. "EHIGaugeBuffTracker.lua")
    dofile(path .. "EHIPermanentBuffTracker.lua")
    dofile(path .. "SimpleBuffEdits.lua")
    EHIBuffTracker._parent_class = self
    hud:AddEHIUpdator("EHI_Buff_Update", self)
    self._panel = panel
    local scale = EHI:GetOption("buffs_scale") --[[@as number]]
    local buff_y = EHI:GetOption(_G.IS_VR and "buffs_vr_y_offset" or "buffs_y_offset") --[[@as number]]
    local buff_w = tweak_data.size_w * scale
    local buff_h = tweak_data.size_h * scale
    self:_init_buffs(buff_y, buff_w, buff_h, scale)
    self:_init_tag_team_buffs(buff_y, buff_w, buff_h, scale)
    self:_cleanup_unused_buff_classes()
    table.sort(self._skill_check_after_spawn or {}, function(a, b)
        return a._id:lower() < b._id:lower()
    end)
    EHI:AddOnSpawnedCallback(function()
        self:ActivateUpdatingBuffs()
    end)
    EHI:AddEndGameCallback(function()
        self._update_buffs = {}
    end)
    EHI:AddOnCustodyCallback(function(custody_state)
        for _, buff in pairs(self._buffs) do
            buff:SetCustodyState(custody_state)
        end
    end)
    EHI:AddOnAlarmCallback(function(dropin)
        for _, buff in pairs(self._buffs) do
            buff:SwitchToLoudMode()
        end
    end)
    if EHI.IsClient then
        managers.ehi_sync:AddReceiveHook(self._sync_add_buff, function(data, sender)
            local tbl = json.decode(data)
            if tbl then -- Check if the synced data is valid
                self:AddBuff(tbl.id, tbl.t)
            end
        end)
    end
end

---@param buff_y number
---@param buff_w number
---@param buff_h number
---@param scale number
function EHIBuffManager:_init_buffs(buff_y, buff_w, buff_h, scale)
    local get_icon = tweak_data.ehi.default.buff.get_icon
    for id, buff in pairs(tweak_data.ehi.buff) do
        if buff.option and not EHI:GetBuffOption(buff.option) then
        elseif buff.deck_option and not EHI:GetBuffDeckOption(buff.deck_option.deck, buff.deck_option.option) then
        else
            local params = {}
            params.id = id
            params.x = self._x
            params.y = buff_y
            params.w = buff_w
            params.h = buff_h
            params.group = buff.group
            params.text = buff.text
            params.text_localize = buff.text_localize
            params.texture, params.texture_rect = get_icon(buff)
            params.format = buff.format
            params.no_progress = buff.no_progress
            params.max = buff.max
            params.scale = scale
            params.skill_check_after_spawn = buff.skill_check_after_spawn
            if buff.permanent then
                if buff.permanent.option and EHI:GetBuffOption(buff.permanent.option) then
                    params.class = buff.permanent.class or "EHIPermanentBuffTracker"
                    params.skill_check = buff.permanent.skill_check
                    params.team_skill_check = buff.permanent.team_skill_check
                    params.team_ai_skill_check = buff.permanent.team_ai_skill_check
                    params.always_show = buff.permanent.always_show
                    params.show_on_trigger = buff.permanent.show_on_trigger
                    params.show_on_trigger_when_synced = buff.permanent.show_on_trigger_when_synced
                    params.class_to_load = buff.permanent.class_to_load
                    params.skill_check_after_spawn = true
                    params.check_buff_on_spawn = true
                elseif buff.permanent.deck_option and EHI:GetBuffDeckOption(buff.permanent.deck_option.deck, buff.permanent.deck_option.option) then
                    params.class = buff.permanent.class or "EHIPermanentBuffTracker"
                    params.skill_check = buff.permanent.skill_check
                    params.team_skill_check = buff.permanent.team_skill_check
                    params.always_show = buff.permanent.always_show
                    params.show_on_trigger = buff.permanent.show_on_trigger
                    params.skill_check_after_spawn = true
                    params.check_buff_on_spawn = true
                else
                    params.class = buff.class
                    params.class_to_load = buff.class_to_load
                end
            else
                params.class = buff.class
                params.class_to_load = buff.class_to_load
            end
            self:_create_buff(params, buff.persistent, buff.deck_option)
        end
    end
end

---@param buff_y number
---@param buff_w number
---@param buff_h number
---@param scale number
function EHIBuffManager:_init_tag_team_buffs(buff_y, buff_w, buff_h, scale)
    if not EHI:GetBuffDeckOption("tag_team", "tagged") then
        if EHI:GetBuffDeckOption("tag_team", "effect") then
            return
        end
        _G.EHITagTeamBuffTracker = nil
        return
    end
    local local_peer_id = EHI.IsHost and 1 or EHI._cache.LocalPeerID
    if Global.game_settings.single_player or not local_peer_id then
        return
    end
    local texture, texture_rect = tweak_data.ehi.default.buff.get_icon(tweak_data.ehi.buff.TagTeamEffect)
    for i = 1, HUDManager.PLAYER_PANEL, 1 do
        if i ~= local_peer_id then -- You cannot tag yourself...
            local params = {}
            params.id = "TagTeamTagged_" .. i .. local_peer_id
            params.x = self._x
            params.y = buff_y
            params.w = buff_w
            params.h = buff_h
            params.texture = texture
            params.texture_rect = texture_rect
            params.icon_color = tweak_data.chat_colors[i] or Color.white
            params.scale = scale
            params.class = "EHITagTeamBuffTracker"
            self:_create_buff(params)
        end
    end
    if CustomNameColor and CustomNameColor.ModID and not Global.game_settings.single_player then
        managers.ehi_sync:AddReceiveHook(CustomNameColor.ModID, function(data, sender)
            if data and data ~= "" then
                local buff = self._buffs["TagTeamTagged_" .. sender .. local_peer_id]
                if buff then
                    local col = NetworkHelper:StringToColour(data) ---@cast col -?
                    buff._icon:set_color(col)
                end
            end
        end)
    end
end

---@param params table
---@param persistent string?
---@param deck_option table?
function EHIBuffManager:_create_buff(params, persistent, deck_option)
    local buff
    if params.class_to_load then
        if params.class_to_load.prerequisite and not _G[params.class_to_load.prerequisite] then
            EHI:LoadBuff(params.class_to_load.prerequisite)
        end
        if params.class_to_load.load_class then
            EHI:LoadBuff(params.class_to_load.load_class)
        end
        buff = _G[params.class_to_load.class]:new(self._panel, params) --[[@as EHIBuffTracker]]
    else
        buff = _G[params.class or "EHIBuffTracker"]:new(self._panel, params) --[[@as EHIBuffTracker]]
    end
    self._buffs[params.id] = buff
    if params.skill_check_after_spawn then
        self._skill_check_after_spawn = self._skill_check_after_spawn or {} ---@type EHIBuffTracker[]
        table.insert(self._skill_check_after_spawn, buff)
    end
    if params.check_buff_on_spawn then -- queued
    elseif persistent and EHI:GetBuffOption(persistent) then
        buff:SetPersistent()
    elseif deck_option and EHI:GetBuffDeckOption(deck_option.deck, deck_option.persistent) then
        buff:SetPersistent()
    end
end

function EHIBuffManager:_cleanup_unused_buff_classes()
    for id, buff in pairs(tweak_data.ehi.buff) do
        if buff.class and buff.class ~= "EHIGaugeBuffTracker" then
            local class = buff.class
            if _G[class] and not self._buffs[id] then -- Tracker class exists, but the tracker is not created because it is disabled; remove the class
                _G[class] = nil
            end
        elseif buff.class_to_load and buff.class_to_load.prerequisite then
            local class = buff.class_to_load.class
            if _G[class] and not self._buffs[id] then -- Tracker class exists, but the tracker is not created because it is disabled; remove the class
                _G[class] = nil
            end
        end
    end
end

---@param id string
function EHIBuffManager:UpdateBuffIcon(id)
    local tweak = tweak_data.ehi.buff[id]
    local buff = self._buffs[id]
    if buff and tweak then
        local texture, texture_rect = tweak_data.ehi.default.buff.get_icon(tweak) ---@cast texture -?
        buff:UpdateIcon(texture, texture_rect)
    end
end

---@param id string
---@param f string
function EHIBuffManager:CallFunction(id, f, ...)
    local buff = self._buffs[id]
    if buff and buff[f] then
        buff[f](buff, ...)
    end
end

---@param id string
---@param t number
function EHIBuffManager:SyncAndAddBuff(id, t)
    managers.ehi_sync:SyncTable(self._sync_add_buff, { id = id, t = t })
    self:AddBuff(id, t)
end

function EHIBuffManager:ActivateUpdatingBuffs()
    if table.ehi_empty(self._skill_check_after_spawn) then
        return
    end
    for _, buff in ipairs(self._skill_check_after_spawn) do
        if buff:SkillCheck() then
            buff:PreUpdate()
        elseif buff:CanDeleteOnFalseSkillCheck() then
            if buff._DELETE_BUFF_ON_FALSE_SKILL_CHECK then
                buff:delete()
            else
                buff:delete_with_class()
            end
        end
    end
    self._skill_check_after_spawn = nil
end

---@param id string
---@param t number
function EHIBuffManager:AddBuff(id, t)
    local buff = self._buffs[id]
    if buff then
        if buff:IsActive() then
            buff:Extend(t)
        else
            buff:Activate(t, self._n_visible)
            self._visible_buffs[id] = buff
            self._n_visible = self._n_visible + 1
            self:ReorganizeFast(self._n_visible, buff)
        end
    end
end

---To stop moving buffs left and right on the screen
---@param id string
---@param t number
function EHIBuffManager:AddBuff2(id, t)
    self:AddBuff(id, t + 0.2)
end

---@param id string
function EHIBuffManager:AddBuffNoUpdate(id)
    local buff = self._buffs[id]
    if buff and not buff:IsActive() then
        buff:ActivateNoUpdate(self._n_visible)
        self._visible_buffs[id] = buff
        self._n_visible = self._n_visible + 1
        self:ReorganizeFast(self._n_visible, buff)
    end
end

---@param id string
---@param ratio number
---@param custom_value number?
function EHIBuffManager:AddGauge(id, ratio, custom_value)
    local buff = self._buffs[id] --[[@as EHIGaugeBuffTracker?]]
    if buff then
        if buff:IsActive() then
            buff:SetRatio(ratio, custom_value)
        else
            buff:Activate(ratio, custom_value, self._n_visible)
            self._visible_buffs[id] = buff
            self._n_visible = self._n_visible + 1
            self:ReorganizeFast(self._n_visible, buff)
        end
    end
end

---@param id string
function EHIBuffManager:RemoveBuff(id)
    local buff = self._buffs[id]
    if buff and buff:IsActive() then
        buff:Deactivate()
    end
end

---@param id string
function EHIBuffManager:RemoveAndResetBuff(id)
    local buff = self._buffs[id]
    if buff and buff:IsActive() then
        buff:DeactivateAndReset()
    end
end

---@param id string
function EHIBuffManager:DeleteBuff(id)
    local buff = self._buffs[id]
    if buff then
        buff:Remove()
    end
end

---@param id string
---@param t number
function EHIBuffManager:ShortBuffTime(id, t)
    local buff = self._buffs[id]
    if buff then
        buff:Shorten(t)
    end
end

---@param buff EHIBuffTracker
function EHIBuffManager:_add_visible_buff(buff)
    self._visible_buffs[buff._id] = buff
    buff._pos = self._n_visible
    self._n_visible = self._n_visible + 1
    self:ReorganizeFast(self._n_visible, buff)
end

---@param buff EHIBuffTracker
function EHIBuffManager:_remove_visible_buff(buff)
    self._visible_buffs[buff._id] = nil
    self._n_visible = self._n_visible - 1
    self:Reorganize(buff._pos, buff, true)
end

---@param buff EHIBuffTracker
function EHIBuffManager:_add_buff_to_update(buff)
    self._update_buffs[buff._id] = buff
end

---@param id string
function EHIBuffManager:_remove_buff_from_update(id)
    self._update_buffs[id] = nil
end

---@param dt number
function EHIBuffManager:update(t, dt)
    for _, buff in pairs(self._update_buffs) do
        buff:update(dt)
    end
end

if EHI:GetOption("buffs_alignment") == 1 then -- Left
    ---@param pos number?
    ---@param buff EHIBuffTracker
    ---@param removal boolean?
    function EHIBuffManager:Reorganize(pos, buff, removal)
        if self._n_visible == 0 then
            return
        end
        pos = pos or self._n_visible
        for _, v_buff in pairs(self._visible_buffs) do
            v_buff:SetLeftXByPos(self._x, pos)
        end
    end

    ---@param pos number
    ---@param buff EHIBuffTracker
    function EHIBuffManager:ReorganizeFast(pos, buff)
        buff:SetLeftXByPos(self._x, pos)
    end
elseif EHI:GetOption("buffs_alignment") == 2 then -- Center
    ---@param pos number?
    ---@param buff EHIBuffTracker
    ---@param removal boolean?
    function EHIBuffManager:Reorganize(pos, buff, removal)
        if self._n_visible == 0 then
            return
        elseif self._n_visible == 1 then
            local center_x = self._panel:center_x()
            if removal then
                local _, v_buff = next(self._visible_buffs) ---@cast v_buff -?
                v_buff:SetCenterDefaultX(center_x)
            else
                buff:SetCenterDefaultX(center_x)
            end
        else
            local even = self._n_visible % 2 == 0
            local center_pos = even and math.ceil(self._n_visible / 2) or math.floor(self._n_visible / 2)
            local center_x = self._panel:center_x()
            pos = pos or self._n_visible
            for _, v_buff in pairs(self._visible_buffs) do
                v_buff:SetCenterXByPos(center_x, pos, center_pos, even)
            end
        end
    end
    EHIBuffManager.ReorganizeFast = EHIBuffManager.Reorganize
else -- Right
    ---@param pos number?
    ---@param buff EHIBuffTracker
    ---@param removal boolean?
    function EHIBuffManager:Reorganize(pos, buff, removal)
        if self._n_visible == 0 then
            return
        end
        pos = pos or self._n_visible
        for _, v_buff in pairs(self._visible_buffs) do
            v_buff:SetRightXByPos(self._x, pos)
        end
    end

    ---@param pos number
    ---@param buff EHIBuffTracker
    function EHIBuffManager:ReorganizeFast(pos, buff)
        buff:SetRightXByPos(self._x, pos)
    end
end

return EHIBuffManager