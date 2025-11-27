---@class EHIHostageCountTracker : EHICountTracker
---@field super EHICountTracker
EHIHostageCountTracker = class(EHICountTracker)
EHIHostageCountTracker._forced_hint_text = "hostage"
EHIHostageCountTracker._forced_icons = { "hostage" }
if EHI:GetOption("hostage_count_tracker_format") == 1 then -- Total only
    function EHIHostageCountTracker:Format()
        return tostring(self._total_hostages)
    end
elseif EHI:GetOption("hostage_count_tracker_format") == 2 then -- Total | Police
    EHIHostageCountTracker._forced_icons[2] = { icon = "hostage", color = Color(0, 1, 1) }
    function EHIHostageCountTracker:Format()
        return string.format("%d|%d", self._total_hostages, self._police_hostages)
    end
elseif EHI:GetOption("hostage_count_tracker_format") == 3 then -- Police | Total
    EHIHostageCountTracker._forced_icons[1] = { icon = "hostage", color = Color(0, 1, 1) }
    EHIHostageCountTracker._forced_icons[2] = "hostage"
    function EHIHostageCountTracker:Format()
        return string.format("%d|%d", self._police_hostages, self._total_hostages)
    end
elseif EHI:GetOption("hostage_count_tracker_format") == 4 then -- Civilians | Police
    EHIHostageCountTracker._forced_icons[2] = { icon = "hostage", color = Color(0, 1, 1) }
    function EHIHostageCountTracker:Format()
        return string.format("%d|%d", self._civilian_hostages, self._police_hostages)
    end
else -- Police | Civilians
    EHIHostageCountTracker._forced_icons[1] = { icon = "hostage", color = Color(0, 1, 1) }
    EHIHostageCountTracker._forced_icons[2] = "hostage"
    function EHIHostageCountTracker:Format()
        return string.format("%d|%d", self._police_hostages, self._civilian_hostages)
    end
end
EHIHostageCountTracker.FormatCount = EHIHostageCountTracker.Format
function EHIHostageCountTracker:pre_init(params)
    self._total_hostages = 0
    self._civilian_hostages = 0
    self._police_hostages = 0
end

function EHIHostageCountTracker:post_init(params)
    EHIHostageCountTracker.super.post_init(self, params)
    local total_hostages = params.total_hostages
    if params.police_hostages then
        self:SetHostageCountHost(total_hostages, params.police_hostages)
    elseif params.format_total then
        self:SetHostageCountHost(total_hostages, 0)
        self._block_civ_or_enemy_hostage_changes = true
    else
        self._unit_tied = {}
        for _, civ in pairs(managers.enemy:all_civilians()) do
            if alive(civ.unit) and civ.unit:brain():is_hostage() then
                self._unit_tied[civ.unit:key()] = true
                self._civilian_hostages = self._civilian_hostages + 1
            end
        end
        for _, enemy in pairs(managers.enemy:all_enemies()) do
            if alive(enemy.unit) and enemy.unit:brain():is_hostage() then
                self._unit_tied[enemy.unit:key()] = true
                self._police_hostages = self._police_hostages + 1
            end
        end
        self:SetHostageCount(self._civilian_hostages + self._police_hostages, self._police_hostages)
    end
end

---@param total_hostages integer
---@param police_hostages integer
function EHIHostageCountTracker:SetHostageCount(total_hostages, police_hostages)
    self._total_hostages = total_hostages
    self._police_hostages = police_hostages
    self._count_text:set_text(self:Format())
    self:AnimateBG(1)
end

---@param total_hostages integer
---@param police_hostages integer
function EHIHostageCountTracker:SetHostageCountHost(total_hostages, police_hostages)
    self._civilian_hostages = total_hostages - police_hostages
    self:SetHostageCount(total_hostages, police_hostages)
end

function EHIHostageCountTracker:SetHostageCountClient()
    self:SetHostageCount(self._civilian_hostages + self._police_hostages, self._police_hostages)
end

---@param unit_key userdata
function EHIHostageCountTracker:CivilianTied(unit_key)
    if self._block_civ_or_enemy_hostage_changes or self._unit_tied[unit_key] then
        return
    end
    self._unit_tied[unit_key] = true
    self._civilian_hostages = self._civilian_hostages + 1
    self:SetHostageCountClient()
end

---@param unit_key userdata
function EHIHostageCountTracker:CivilianUntied(unit_key)
    if self._block_civ_or_enemy_hostage_changes then
        return
    elseif table.remove_key(self._unit_tied, unit_key) then
        self._civilian_hostages = self._civilian_hostages - 1
        self:SetHostageCountClient()
    end
end

---@param unit_key userdata
function EHIHostageCountTracker:PoliceTied(unit_key)
    if self._block_civ_or_enemy_hostage_changes or self._unit_tied[unit_key] then
        return
    end
    self._unit_tied[unit_key] = true
    self._police_hostages = self._police_hostages + 1
    self:SetHostageCountClient()
end

---@param unit_key userdata
function EHIHostageCountTracker:PoliceUntied(unit_key)
    if self._block_civ_or_enemy_hostage_changes then
        return
    elseif table.remove_key(self._unit_tied, unit_key) then
        self._police_hostages = self._police_hostages - 1
        self:SetHostageCountClient()
    end
end