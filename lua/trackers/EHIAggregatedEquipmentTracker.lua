local color =
{
    doctor_bag = EHI:GetEquipmentOption("doctor_bag"),
    ammo_bag = EHI:GetEquipmentOption("ammo_bag"),
    grenade_crate = EHI:GetEquipmentOption("grenade_crate"),
    first_aid_kit = EHI:GetEquipmentOption("first_aid_kit"),
    bodybags_bag = EHI:GetEquipmentOption("bodybags_bag")
}

local text_i =
{
    [1] = "doctor_bag",
    [2] = "ammo_bag",
    [3] = "grenade_crate",
    [4] = "first_aid_kit",
    [5] = "bodybags_bag"
}

EHIAggregatedEquipmentTracker = EHIAggregatedEquipmentTracker or class(EHITracker)
EHIAggregatedEquipmentTracker._update = false
function EHIAggregatedEquipmentTracker:init(panel, params)
    self._dont_show_placed = {}
    self._amount = {}
    self._placed = {}
    self._deployables = {}
    self._ignore = params.ignore or {}
    self._panel_size = 2
    self._format = {}
    self.text =
    {
        doctor_bag = false,
        ammo_bag = false,
        grenade_crate = false,
        first_aid_kit = false,
        bodybags_bag = false
    }
    for _, id in pairs(params.ids) do
        self._amount[id] = 0
        self._placed[id] = 0
        self._dont_show_placed[id] = params.dont_show_placed[id]
        self._deployables[id] = {}
        self._format[id] = params.format[id] or "charges"
    end
    EHIAggregatedEquipmentTracker.super.init(self, panel, params)
    self._time_bg_box:remove(self._text)
end

do
    local format = EHI:GetOption("equipment_format")
    if format == 1 then -- Uses (Bags placed)
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            if self._format[id] == "percent" then
                return EHI:RoundNumber(self._amount[id], 0.1) .. " (" .. self._placed[id] .. ")"
            else
                if self._dont_show_placed[id] then
                    return self._amount[id]
                else
                    return self._amount[id] .. " (" .. self._placed[id] .. ")"
                end
            end
        end
    elseif format == 2 then -- (Bags placed) Uses
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            if self._format[id] == "percent" then
                return "(" .. self._placed[id] .. ") " .. EHI:RoundNumber(self._amount[id], 0.1)
            else
                if self._dont_show_placed[id] then
                    return self._amount[id]
                else
                    return "(" .. self._placed[id] .. ") " .. self._amount[id]
                end
            end
        end
    elseif format == 3 then -- (Uses) Bags placed
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            if self._format[id] == "percent" then
                return "(" .. EHI:RoundNumber(self._amount[id], 0.1) .. ") " .. self._placed[id]
            else
                if self._dont_show_placed[id] then
                    return self._amount[id]
                else
                    return "(" .. self._amount[id] .. ") " .. self._placed[id]
                end
            end
        end
    elseif format == 4 then -- Bags placed (Uses)
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            if self._format[id] == "percent" then
                return self._placed[id] .. " (" .. EHI:RoundNumber(self._amount[id], 0.1) .. ")"
            else
                if self._dont_show_placed[id] then
                    return self._amount[id]
                else
                    return self._placed[id] .. " (" .. self._amount[id] .. ")"
                end
            end
        end
    elseif format == 5 then -- Uses
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            if self._format[id] == "percent" then
                return tostring(EHI:RoundNumber(self._amount[id], 0.01))
            else
                return tostring(self._amount[id])
            end
        end
    else -- Bags placed
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            if self._dont_show_placed[id] then
                if self._format[id] == "percent" then
                    return tostring(EHI:RoundNumber(self._amount[id], 0.01))
                end
                return tostring(self._amount[id])
            else
                return tostring(self._placed[id])
            end
        end
    end
end

function EHIAggregatedEquipmentTracker:GetTotalAmount()
    local amount = 0
    for _, count in pairs(self._amount) do
        amount = amount + count
    end
    return amount
end

function EHIAggregatedEquipmentTracker:GetNumberOfDeployables()
    local amount = 0
    for _, value in pairs(self.text) do
        amount = amount + (value and 1 or 0)
    end
    return amount
end

function EHIAggregatedEquipmentTracker:AddToIgnore(id)
    self._ignore[id] = true
    self._deployables[id] = {}
    self._amount[id] = 0
    self._placed[id] = 0
    self:CheckAmount(id)
end

function EHIAggregatedEquipmentTracker:UpdateAmount(id, unit, key, amount)
    if not key then
        EHI:DebugEquipment(self._id, unit, key, amount)
        return
    end
    if self._ignore[id] then
        return
    end
    self._deployables[id][key] = amount
    self._amount[id] = 0
    self._placed[id] = 0
    for _, value in pairs(self._deployables[id]) do
        if value > 0 then
            self._amount[id] = self._amount[id] + value
            self._placed[id] = self._placed[id] + 1
        end
    end
    self:CheckAmount(id)
end

function EHIAggregatedEquipmentTracker:CheckAmount(id)
    if self:GetTotalAmount() <= 0 then
        self:delete()
    else
        self:UpdateText(id)
    end
end

function EHIAggregatedEquipmentTracker:UpdateText(id)
    if self.text[id] then
        if self._amount[id] <= 0 then
            self:RemoveText(id)
        else
            self._time_bg_box:child(id):set_text(self:FormatDeployable(id))
            self:FitTheTextUnique(id)
        end
        self:AnimateBG()
    elseif not self._ignore[id] then
        if self._amount[id] > 0 then
            self:AddText(id)
            self:AnimateBG()
        end
    end
end

function EHIAggregatedEquipmentTracker:AddText(id)
    self._time_bg_box:text({
        name = id,
        text = "",
        align = "center",
        vertical = "center",
        w = self._time_bg_box:w(),
        h = self._time_bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
        font_size = self._panel:h() * self._text_scale,
        color = color[id] or Color.white
    })
    self.text[id] = true
    self:SetTextSize()
    self._time_bg_box:child(id):set_text(self:FormatDeployable(id))
    self:FitTheTextUnique(id)
    self:Reorganize()
end

function EHIAggregatedEquipmentTracker:RemoveText(id)
    self._time_bg_box:remove(self._time_bg_box:child(id))
    self.text[id] = false
    local n = self:GetNumberOfDeployables()
    if n == 1 then
        for ID, _ in pairs(self.text) do
            if self._time_bg_box:child(ID) then
                self._time_bg_box:child(ID):set_font_size(self._panel:h() * self._text_scale)
                self._time_bg_box:child(ID):set_x(0)
                self._time_bg_box:child(ID):set_w(self._time_bg_box:w())
                self:FitTheTextUnique(ID)
                break
            end
        end
    elseif n % 2 == 1 then
        for i = 5, 1, -1 do
            if self._time_bg_box:child(text_i[i]) then
                self._time_bg_box:child(text_i[i]):set_font_size(self._panel:h() * self._text_scale)
                self._time_bg_box:child(text_i[i]):set_w(32 * self._scale)
                self:FitTheTextUnique(text_i[i])
                break
            end
        end
    else
        self:SetTextSize(n)
    end
    self:Reorganize(n)
end

function EHIAggregatedEquipmentTracker:SetTextSize(n)
    n = n or self:GetNumberOfDeployables()
    if n == 1 then
        return
    end
    for id, _ in pairs(self.text) do
        if self._time_bg_box:child(id) then
            self._time_bg_box:child(id):set_w(32 * self._scale)
            self:FitTheTextUnique(id)
        end
    end
    if n % 2 == 0 then
        return
    end
    for i = 5, 1, -1 do
        if self._time_bg_box:child(text_i[i]) then
            self._time_bg_box:child(text_i[i]):set_font_size(self._panel:h() * self._text_scale)
            self._time_bg_box:child(text_i[i]):set_w(self._time_bg_box:w())
            self:FitTheTextUnique(text_i[i])
            break
        end
    end
end

function EHIAggregatedEquipmentTracker:Reorganize(n)
    n = n or self:GetNumberOfDeployables()
    if n == 1 then
        return
    end
    if n > self._panel_size then
        self._panel_size = self._panel_size * 2
        self._panel:set_w(self._panel:w() * 2)
        self._time_bg_box:set_w(self._time_bg_box:w() * 2)
    end
    if n < self._panel_size and n % 2 == 0 then
        self._panel_size = self._panel_size / 2
        self._panel:set_w(self._panel:w() / 2)
        self._time_bg_box:set_w(self._time_bg_box:w() / 2)
    end
    self._icon1:set_x(self._time_bg_box:w() + (5 * self._scale))
    local half = self._time_bg_box:w() / self._panel_size
    local pos = 1
    for id, _ in pairs(self.text) do
        if self._time_bg_box:child(id) then
            self._time_bg_box:child(id):set_x(half * (pos - 1))
            pos = pos + 1
        end
    end
end

function EHIAggregatedEquipmentTracker:ResetFontSizeUnique(id)
    self._time_bg_box:child(id):set_font_size(self._panel:h() * self._text_scale)
end

function EHIAggregatedEquipmentTracker:FitTheTextUnique(id)
    self:ResetFontSizeUnique(id)
    local txt = self._time_bg_box:child(id)
    local w = select(3, txt:text_rect())
    if w > txt:w() then
        txt:set_font_size(txt:font_size() * (txt:w() / w) * self._text_scale)
    end
end