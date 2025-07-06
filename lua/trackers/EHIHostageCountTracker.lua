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
    local total_hostages = params.total_hostages
    -- Police hostages only exist on host, clients need to do some math gymnastics (and state saving) to get the same number
    -- Host will only calculate number of civilian hostages from provided total hostages and number of police hostages
    -- Client, on the other hand, needs to remember which civilian is tied and then subtract total number of tied civilians from total hostages to get number of police hostages
    -- If client will check which civilian is tied during sync of total hostages, the tracker will be off by 1 hostage because that info is send afterwards
    if params.police_hostages then
        self:SetHostageCountHost(total_hostages, params.police_hostages)
    else
        self._civilian_tied = {}
        for _, civ in pairs(managers.enemy:all_civilians()) do
            if alive(civ.unit) and civ.unit:brain():is_hostage() then
                self._civilian_tied[civ.unit:key()] = true
                self._civilian_hostages = self._civilian_hostages + 1
            end
        end
        self:SetHostageCountClient(total_hostages)
    end
end

---@param total_hostages number
---@param police_hostages number
function EHIHostageCountTracker:SetHostageCount(total_hostages, police_hostages)
    self._total_hostages = total_hostages
    self._police_hostages = police_hostages
    if self._count_text then
        self._count_text:set_text(self:Format())
        self:AnimateBG(1)
    end
end

---@param total_hostages number
---@param police_hostages number
function EHIHostageCountTracker:SetHostageCountHost(total_hostages, police_hostages)
    self._civilian_hostages = total_hostages - police_hostages
    self:SetHostageCount(total_hostages, police_hostages)
end

---@param total_hostages number
function EHIHostageCountTracker:SetHostageCountClient(total_hostages)
    self:SetHostageCount(total_hostages, total_hostages - self._civilian_hostages)
end

---@param unit_key userdata
function EHIHostageCountTracker:CivilianTied(unit_key)
    if self._civilian_tied[unit_key] then
        return
    end
    self._civilian_tied[unit_key] = true
    self._civilian_hostages = self._civilian_hostages + 1
    self:SetHostageCountClient(self._total_hostages)
end

---@param unit_key userdata
function EHIHostageCountTracker:CivilianUntied(unit_key)
    if table.remove_key(self._civilian_tied, unit_key) then
        self._civilian_hostages = self._civilian_hostages - 1
        self:SetHostageCountClient(self._total_hostages)
    end
end