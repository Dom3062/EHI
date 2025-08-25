---@class EHIEnemyCountTracker : EHICountTracker
---@field super EHICountTracker
EHIEnemyCountTracker = class(EHICountTracker)
EHIEnemyCountTracker._forced_hint_text = "enemy_count"
if EHI:GetOption("show_enemy_count_show_pagers") then
    EHIEnemyCountTracker._forced_icons = { "pager_icon", "enemy" }
    function EHIEnemyCountTracker:Format()
        return string.format("%d|%d", self._alarm_count - self._alarm_count_answered, self._count)
    end
    EHIEnemyCountTracker.FormatCount = EHIEnemyCountTracker.Format
else
    EHIEnemyCountTracker._forced_icons = { "enemy" }
end
function EHIEnemyCountTracker:pre_init(params)
    EHIEnemyCountTracker.super.pre_init(self, params)
    self._alarm_count = 0
    self._alarm_count_answered = 0
    if params.alarm_sounded and self._forced_icons[1] == "pager_icon" then -- If alarm sounded and pager icon is enabled, remove the icon here so positioning of other features will work correctly and no offset is required
        self._forced_icons[1] = "enemy"
        self._forced_icons[2] = nil
        self.FormatCount = EHIEnemyCountTracker.super.FormatCount
    end
end

function EHIEnemyCountTracker:post_init(params)
    EHIEnemyCountTracker.super.post_init(self, params)
    if params.no_loud_update then -- Do nothing, will get removed once assault tracker is visible
    elseif params.alarm_sounded then
        self:OnAlarm()
    else
        self._update_on_alarm = true
    end
end

function EHIEnemyCountTracker:OnAlarm()
    self._alarm_sounded = true
    self._count = self._count + self._alarm_count
    if self._icons[2] then
        self:RemoveIconAndAnimateMovement(1, true)
        self.FormatCount = EHIEnemyCountTracker.super.FormatCount
    elseif self._forced_icons[1] ~= "enemy" then
        self:SetIcon("enemy")
    end
    self:SetAndFitTheText(self:FormatCount())
end

function EHIEnemyCountTracker:NormalEnemyRegistered()
    self._count = self._count + 1
    self._text:set_text(self:FormatCount())
end

function EHIEnemyCountTracker:NormalEnemyUnregistered()
    self._count = self._count - 1
    self._text:set_text(self:FormatCount())
end

function EHIEnemyCountTracker:AlarmEnemyRegistered()
    if self._alarm_sounded then
        self:NormalEnemyRegistered()
        return
    end
    self._alarm_count = self._alarm_count + 1
    self._text:set_text(self:FormatCount())
    self:FitTheText()
end

function EHIEnemyCountTracker:AlarmEnemyUnregistered()
    if self._alarm_sounded then
        self:NormalEnemyUnregistered()
        return
    end
    self._alarm_count = self._alarm_count - 1
    self._text:set_text(self:FormatCount())
    self:FitTheText()
end

function EHIEnemyCountTracker:AlarmEnemyPagerAnswered()
    self._alarm_count_answered = self._alarm_count_answered + 1
    self._text:set_text(self:FormatCount())
    self:FitTheText()
end

function EHIEnemyCountTracker:AlarmEnemyPagerKilled()
    self._alarm_count_answered = self._alarm_count_answered - 1
    self._text:set_text(self:FormatCount())
    self:FitTheText()
end