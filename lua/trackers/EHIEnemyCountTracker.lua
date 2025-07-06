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
function EHIEnemyCountTracker:init(panel, params)
    self._alarm_count = 0
    self._alarm_count_answered = 0
    EHIEnemyCountTracker.super.init(self, panel, params)
    if params.no_loud_update then -- Do nothing, will get removed once assault tracker is visible
    elseif params.alarm_sounded then
        self:OnAlarm(true)
    else
        self._update_on_alarm = true
    end
end

function EHIEnemyCountTracker:PosAndSetVisible(x, y)
    if self._alarm_sounded and self._icon_removed and self._ICON_LEFT_SIDE_START and not self._VERTICAL_ANIM_W_LEFT and not self._HORIZONTAL_ALINGMENT then
        x = x - self._icon_gap_size_scaled
    end
    EHIEnemyCountTracker.super.PosAndSetVisible(self, x, y)
    if self._alarm_sounded and self._icon_removed and self._ICON_LEFT_SIDE_START and not self._VERTICAL_ANIM_W_LEFT and not self._HORIZONTAL_ALINGMENT then
        self:AdjustHintX(self._icon_gap_size_scaled)
    end
end

---@param from_init boolean?
function EHIEnemyCountTracker:OnAlarm(from_init)
    self._alarm_sounded = true
    self._count = self._count + self._alarm_count
    if self._icons[2] then
        self:RemoveIcon(1)
        self._icons[1]:set_visible(true)
        self:AnimIconsX(self._default_bg_size + self._gap_scaled)
        self.FormatCount = EHIEnemyCountTracker.super.FormatCount
        if from_init then
            self._icon_removed = true
            self._panel_override_w = self._default_bg_size + self._icon_gap_size_scaled
        else
            self:ChangeTrackerWidth(self._default_bg_size + self._icon_gap_size_scaled, true)
            if self._ICON_LEFT_SIDE_START and not self._VERTICAL_ANIM_W_LEFT and not self._HORIZONTAL_ALINGMENT then
                self._panel:set_x(self._panel:x() - self._icon_gap_size_scaled)
                self:AnimateAdjustHintX(-self._icon_gap_size_scaled) -- TODO: Fix this inconsistency
            else
                self:AnimateAdjustHintX(-self._icon_gap_size_scaled, true)
            end
        end
    elseif self._forced_icons[1] ~= "enemy" then
        self:SetIcon("enemy")
    end
    self._text:set_text(self:FormatCount())
    self:FitTheText()
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

function EHIEnemyCountTracker:HintPositioned()
    if self._alarm_sounded and self._icon_removed and self._VERTICAL_ANIM_W_LEFT and self._ICON_LEFT_SIDE_START then
        self:AdjustHintX(self._icon_gap_size_scaled)
    end
end