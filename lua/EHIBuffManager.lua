local function GetIcon(params)
    local texture = ""
    local texture_rect = {}
    local x = params.x or 0
    local y = params.y or 0
    if params.skills then
        texture = "guis/textures/pd2/skilltree/icons_atlas"
		texture_rect = { x * 64, y * 64, 64, 64 }
    elseif params.u100skill then
        texture = "guis/textures/pd2/skilltree_2/icons_atlas_2"
		texture_rect = { x * 80, y * 80, 80, 80 }
    elseif params.deck then
        texture = "guis/" .. (params.folder and ("dlcs/" .. params.folder .. "/") or "") .. "textures/pd2/specialization/icons_atlas"
		texture_rect = { x * 64, y * 64, 64, 64 }
    elseif params.texture then
        texture = params.texture
        texture_rect = params.texture_rect
    end
    return texture, texture_rect
end

local buff_w = 32
local buff_h = 64
EHIBuffManager = EHIBuffManager or class()
function EHIBuffManager:init()
    self._buffs = {}
    self._update_buffs = {}
    setmetatable(self._update_buffs, {__mode = "k"})
    self._x = EHI:GetOption("buffs_x_offset")
    self._y = EHI:GetOption("buffs_y_offset")
    self._scale = EHI:GetOption("buffs_scale")
    buff_w = buff_w * self._scale
    buff_h = buff_h * self._scale
    self._visible_buffs = {}
    self._n_visible = 0
    self._cache = {}
    self._gap = 6
end

function EHIBuffManager:init_finalize(hud)
    self._panel = hud.panel
    self:InitializeBuffs()
    self:InitializeTagTeamBuffs()
end

function EHIBuffManager:InitializeBuffs()
    local tweak = tweak_data.ehi.buff
    for id, buff in pairs(tweak) do
        local params = {}
        params.id = id
        params.x = self._x
        params.y = self._y
        params.w = buff_w
        params.h = buff_h
        params.text = buff.text
        params.texture, params.texture_rect = GetIcon(buff)
        params.format = buff.format
        params.good = not buff.bad
        params.max = buff.max
        params.class = buff.class
        params.scale = self._scale
        params.parent_class = self
        self:CreateBuff(params)
    end
end

function EHIBuffManager:InitializeTagTeamBuffs()
    local local_peer_id = managers.network:session():local_peer():id()
    local icon =
    {
        deck = true,
        folder = "ecp",
        x = 0,
        y = 1
    }
    for i = 1, HUDManager.PLAYER_PANEL, 1 do
        if i ~= local_peer_id then
            local params = {}
            params.id = "TagTeamTagged_" .. i .. local_peer_id
            params.x = self._x
            params.y = self._y
            params.w = buff_w
            params.h = buff_h
            params.texture, params.texture_rect = GetIcon(icon)
            params.icon_color = tweak_data.chat_colors[i] or Color.white
            params.scale = self._scale
            params.parent_class = self
            self:CreateBuff(params)
        end
    end
end

function EHIBuffManager:CreateBuff(params)
    local buff = _G[params.class or "EHIBuffTracker"]:new(self._panel, params)
    self._buffs[params.id] = buff
end

function EHIBuffManager:UpdateBuffIcon(id)
    local tweak = tweak_data.ehi.buff[id]
    local buff = self._buffs[id]
    if buff and tweak then
        local texture, texture_rect = GetIcon(tweak)
        buff:UpdateIcon(texture, texture_rect)
    end
end

function EHIBuffManager:CallBuffFunction(id, f, ...)
    local buff = self._buffs[id]
    if buff and buff[f] then
        buff[f](buff, ...)
    end
end

function EHIBuffManager:AddDebugBuffs()
    local c = { 6, 6, 100, 30, 120 }
    for i = 1, 5, 1 do
        local buff = self._buffs["debug_" .. i]
        if buff then
            EHI:DelayCall("Buff_Debug_" .. i, 1 * i, function()
                buff._time = c[i] or 6
                buff._text:set_text(buff:Format())
                buff._panel:set_visible(true)
                self._visible_buffs["debug_" .. i] = true
                self._n_visible = self._n_visible + 1
                self:Reorganize()
            end)
        end
    end
end

function EHIBuffManager:ActivateUpdatingBuffs()
    local tweak = tweak_data.ehi.buff
    for id, buff in pairs(tweak) do
        if buff.activate_after_spawn then
            local b = self._buffs[id]
            if b:PreUpdateCheck() then
                b:PreUpdate()
                self:AddBuffToUpdate(id, b)
            end
        elseif buff.check_after_spawn then
            local b = self._buffs[id]
            if b:PreUpdateCheck() then
                b:PreUpdate()
            end
        end
    end
end

function EHIBuffManager:AddBuff(id, t)
    local buff = self._buffs[id]
    if buff then
        if buff:IsActive() then
            buff:Extend(t)
        else
            buff:Activate(t, self._n_visible)
            self._visible_buffs[id] = true
            self._n_visible = self._n_visible + 1
            self:Reorganize()
        end
    end
end

function EHIBuffManager:AddBuff2(id, start_t, end_t)
    self:AddBuff(id, end_t - start_t)
end

function EHIBuffManager:AddGauge(id, ratio)
    local buff = self._buffs[id]
    if buff then
        if buff:IsActive() then
            buff:SetRatio(ratio)
        else
            buff:Activate(ratio, self._n_visible)
            self._visible_buffs[id] = true
            self._n_visible = self._n_visible + 1
            self:Reorganize()
        end
    end
end

function EHIBuffManager:RemoveBuff(id)
    local buff = self._buffs[id]
    if buff and buff:IsActive() then
        buff:Deactivate()
    end
end

function EHIBuffManager:AppendTime(id, t)
    local buff = self._buffs[id]
    if buff then
        buff:Append(t)
    end
end

function EHIBuffManager:AppendTimeCeil(id, t, max)
    local buff = self._buffs[id]
    if buff then
        buff:AppendCeil(t, max)
    end
end

function EHIBuffManager:ShortenBuffTime(id, t)
    local buff = self._buffs[id]
    if buff then
        buff:Shorten(t)
    end
end

function EHIBuffManager:AddVisibleBuff(id)
    self._visible_buffs[id] = true
    self._buffs[id]:SetPos(self._n_visible)
    self._n_visible = self._n_visible + 1
    self:Reorganize()
end

function EHIBuffManager:RemoveVisibleBuff(id, pos)
    self._visible_buffs[id] = nil
    self._n_visible = self._n_visible - 1
    self:Reorganize(pos)
end

do
    local alignment = EHI:GetOption("buffs_alignment")
    if alignment == 1 then -- Left
        function EHIBuffManager:Reorganize(pos)
            if self._n_visible == 0 then
                return
            end
            pos = pos or self._n_visible
            for key, _ in pairs(self._visible_buffs) do
                local buff = self._buffs[key]
                buff:SetLeftXByPos(self._x, pos)
            end
        end
    elseif alignment == 2 then -- Center
        local ceil = math.ceil
        local floor = math.floor
        function EHIBuffManager:Reorganize(pos)
            if self._n_visible == 0 then
                return
            elseif self._n_visible == 1 then
                local key, _ = next(self._visible_buffs)
                local buff = self._buffs[key]
                buff:SetCenterX(self._panel:center_x())
                buff:SetPos(0)
            else
                local even = self._n_visible % 2 == 0
                local center_pos = even and ceil(self._n_visible / 2) or floor(self._n_visible / 2)
                local center_x = self._panel:center_x()
                pos = pos or self._n_visible
                for key, _ in pairs(self._visible_buffs) do
                    local buff = self._buffs[key]
                    buff:SetCenterX(center_x)
                    buff:SetCenterXByPos(pos, center_pos, even)
                end
            end
        end
    else -- Right
        function EHIBuffManager:Reorganize(pos)
            if self._n_visible == 0 then
                return
            end
            pos = pos or self._n_visible
            for key, _ in pairs(self._visible_buffs) do
                local buff = self._buffs[key]
                buff:SetRightXByPos(self._x, pos)
            end
        end
    end
end

function EHIBuffManager:AddBuffToUpdate(id, buff)
    self._update_buffs[id] = buff
end

function EHIBuffManager:RemoveBuffFromUpdate(id)
    self._update_buffs[id] = nil
end

function EHIBuffManager:RemoveAbilityCooldown()
    local ability = self._cache.Ability
    if ability then
        self:RemoveBuff(ability)
    end
end

function EHIBuffManager:update(t, dt)
    for _, buff in pairs(self._update_buffs) do
        buff:update(t, dt)
    end
end