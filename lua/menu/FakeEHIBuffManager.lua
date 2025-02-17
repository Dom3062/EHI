local EHI = EHI
---@class FakeEHIBuffsManager
FakeEHIBuffsManager = {}
---@param panel Panel
function FakeEHIBuffsManager:new(panel)
    self._tweak_data = tweak_data.ehi.default.buff
    dofile(EHI.LuaPath .. "menu/FakeEHIBuffTracker.lua")
    self._class_redirect =
    {
        EHIGaugeBuffTracker = "FakeEHIGaugeBuffTracker",
        EHIStaminaBuffTracker = "FakeEHIGaugeBuffTracker"
    }
	self._buffs = {} ---@type FakeEHIBuffTracker[]
    self._panel = panel:panel({
        layer = 0,
        alpha = 1
    })
    self:SetScale(EHI:GetOption("buffs_scale"))
    self._x = EHI:GetOption("buffs_x_offset") --[[@as number]]
    self._y = EHI:GetOption("buffs_y_offset") --[[@as number]]
    self._n_visible = 0
	self._buffs_alignment = EHI:GetOption("buffs_alignment") --[[@as number]]
    self:AddFakeBuffs()
    self:OrganizeBuffs()
    return self
end

---@param scale number
function FakeEHIBuffsManager:SetScale(scale)
    self._scale = scale
    self._buff_w = self._tweak_data.size_w * scale
    self._buff_h = self._tweak_data.size_h * scale
end

function FakeEHIBuffsManager:AddFakeBuffs()
    local visible = EHI:GetOption("show_buffs")
    local shape = EHI:GetOption("buffs_shape")
    local progress = EHI:GetOption("buffs_show_progress")
    local buffs = tweak_data.ehi.buff
    local max = math.random(3, 5)
    local max_buffs = table.size(buffs)
    local visible_buffs = {}
    local saferect_x, saferect_y = managers.gui_data:full_to_safe(self._panel:w(), self._panel:h())
    saferect_x = (self._panel:w() - saferect_x + 0.5) * 2
    saferect_y = (self._panel:h() - saferect_y + 0.5) * 2
    local invert_progress = EHI:GetOption("buffs_invert_progress")
    for _ = 1, max, 1 do
        local n = 0
        local m = math.random(1, max_buffs)
        for key, buff in pairs(buffs) do
            n = n + 1
            if m == n then
                if not visible_buffs[key] then
                    local params = {}
                    params.id = key
                    params.texture, params.texture_rect = self._tweak_data.get_icon(buff)
                    params.text = buff.text
                    params.w = self._buff_w
                    params.h = self._buff_h
                    params.x = self._x - saferect_x
                    params.y = self._y + saferect_y
                    params.visible = visible
                    params.shape = shape
                    params.scale = self._scale
                    params.show_progress = progress
                    params.good = not buff.bad
                    params.saferect_x = saferect_x
                    params.saferect_y = saferect_y
                    params.parent_class = self
                    params.invert = invert_progress
                    if buff.class then
                        params.class = self._class_redirect[buff.class]
                    end
                    self:AddFakeBuff(params)
                    visible_buffs[key] = true
                    break
                else
                    n = n - 1
                end
            end
        end
    end
end

---@param params table
function FakeEHIBuffsManager:AddFakeBuff(params)
    self._n_visible = self._n_visible + 1
    self._buffs[self._n_visible] = _G[params.class or "FakeEHIBuffTracker"]:new(self._panel, params)
end

function FakeEHIBuffsManager:OrganizeBuffs()
    if self._n_visible == 0 then
        return
    elseif self._buffs_alignment == 1 then -- Left
        for i, buff in ipairs(self._buffs) do
            buff:SetLeftPos(self._x, i - 1)
        end
    elseif self._buffs_alignment == 2 then -- Center
        local center_x = self._panel:center_x()
        if self._n_visible == 1 then
            self._buffs[1]:SetCenterPos(center_x, 0, 0, false)
        else
            local even = self._n_visible % 2 == 0
            local center_pos = even and math.ceil(self._n_visible / 2) or math.floor(self._n_visible / 2)
            for i, buff in ipairs(self._buffs) do
                buff:SetCenterPos(center_x, i - 1, center_pos, even)
            end
        end
    else -- Right
        for i, buff in ipairs(self._buffs) do
            buff:SetRightPos(self._x, i - 1)
        end
    end
end

---@param x number
function FakeEHIBuffsManager:UpdateXOffset(x)
	self._x = x
	if self._buffs_alignment == 2 then -- Center
		return
	end
	self:OrganizeBuffs()
end

---@param y number
function FakeEHIBuffsManager:UpdateYOffset(y)
	self._y = y
    self:UpdateBuffs("SetY", y)
end

---@param scale number
function FakeEHIBuffsManager:UpdateScale(scale)
    self:SetScale(scale)
    self:UpdateBuffs("destroy")
    self._buffs = {}
    self._n_visible = 0
    self:AddFakeBuffs()
    self:OrganizeBuffs()
end

---@param alignment number
function FakeEHIBuffsManager:UpdateAlignment(alignment)
	self._buffs_alignment = alignment
	self:OrganizeBuffs()
end

---@param f string
---@param ... unknown
function FakeEHIBuffsManager:UpdateBuffs(f, ...)
    for _, buff in ipairs(self._buffs) do
        buff[f](buff, ...)
    end
end