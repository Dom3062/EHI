---@class EHIPermanentBuffTracker : EHIBuffTracker
---@field super EHIBuffTracker
EHIPermanentBuffTracker = class(EHIBuffTracker)
EHIPermanentBuffTracker._DELETE_BUFF_ON_FALSE_SKILL_CHECK = true
function EHIPermanentBuffTracker:post_init(params)
    self._text:set_text("0")
    self._skill_check = params.skill_check
    self._always_show = params.always_show
    self._show_on_trigger = params.show_on_trigger
    self._show_on_trigger_when_synced = params.show_on_trigger_when_synced
    if params.team_ai_skill_check then
        self._always_show = true
        if params.team_ai_skill_check.category == "ability" then
            EHI:AddCallback(EHI.CallbackMessage.TeamAIAbilityChange, function(ability, operation)
                if ability == params.team_ai_skill_check.upgrade then
                    if operation == "add" then
                        self:AddVisibleBuff()
                    else
                        self:RemoveVisibleBuff()
                    end
                end
            end)
        end
    end
end

function EHIPermanentBuffTracker:Activate(...)
    EHIPermanentBuffTracker.super.Activate(self, ...)
    self._running = true
end

function EHIPermanentBuffTracker:Extend(...)
    EHIPermanentBuffTracker.super.Extend(self, ...)
    if not self._running then
        self._parent_class:_add_buff_to_update(self)
        self._running = true
    end
end

function EHIPermanentBuffTracker:ActivateSoft()
    self._visible = true
end

function EHIPermanentBuffTracker:Deactivate()
    self._parent_class:_remove_buff_from_update(self._id)
    self._running = false
end

function EHIPermanentBuffTracker:DeactivateAndReset()
    self:Deactivate()
    self._text:set_text("0")
    self._progress_bar.red = 0
    self._progress:set_color(self._progress_bar)
end

function EHIPermanentBuffTracker:DeactivateSoft()
    self._visible = false
end

function EHIPermanentBuffTracker:AddVisibleBuff()
end

function EHIPermanentBuffTracker:RemoveVisibleBuff()
end

function EHIPermanentBuffTracker:SkillCheck()
    if self._always_show or self._show_on_trigger then
        return true
    elseif self._skill_check then
        if self._skill_check.skills then
            local value = false
            for _, upgrade in ipairs(self._skill_check.skills) do
                value = value or managers.player:has_category_upgrade(upgrade.category, upgrade.upgrade)
            end
            if self._skill_check.negate then
                return not value
            end
            return value
        elseif self._skill_check.negate then
            return not managers.player:has_category_upgrade(self._skill_check.category, self._skill_check.upgrade)
        elseif self._show_on_trigger_when_synced then
            if not managers.player:has_category_upgrade(self._skill_check.category, self._skill_check.upgrade) then
                self._show_on_trigger = true
            end
            return true
        end
        return managers.player:has_category_upgrade(self._skill_check.category, self._skill_check.upgrade)
    end
    return false
end

function EHIPermanentBuffTracker:PreUpdate()
    self._always_show = nil
    self._skill_check = nil
    if not self._show_on_trigger then
        self._parent_class:AddBuffNoUpdate(self._id)
        self._active = true
    end
    self._show_on_trigger = nil
    self._show_on_trigger_when_synced = nil
    self._delete_on_false_check = nil
end

function EHIPermanentBuffTracker:delete()
    if self._pos then
        EHIPermanentBuffTracker.super.RemoveVisibleBuff(self)
        self._pos = nil
    end
    EHIPermanentBuffTracker.super.delete(self)
end

---@class EHIPermanentGaugeBuffTracker : EHIGaugeBuffTracker
---@field super EHIGaugeBuffTracker
EHIPermanentGaugeBuffTracker = class(EHIGaugeBuffTracker)
EHIPermanentGaugeBuffTracker._DELETE_BUFF_ON_FALSE_SKILL_CHECK = true
EHIPermanentGaugeBuffTracker.PreUpdate = EHIPermanentBuffTracker.PreUpdate
EHIPermanentGaugeBuffTracker.SkillCheck = EHIPermanentBuffTracker.SkillCheck
function EHIPermanentGaugeBuffTracker:post_init(params)
    EHIPermanentGaugeBuffTracker.super.post_init(self, params)
    self._skill_check = params.skill_check
    self._always_show = params.always_show
    self._show_on_trigger = params.show_on_trigger
    self._show_on_trigger_when_synced = params.show_on_trigger_when_synced
    if params.team_skill_check then
        self._always_show = true
        Hooks:PostHook(UpgradesManager, "_aquire_team", "EHI_Buff_" .. self._id .. "_aquire_team_skill", function(_, team, ...)
            if team.upgrade.category == params.team_skill_check.category and team.upgrade.upgrade == params.team_skill_check.upgrade then
                self:AddVisibleBuff()
                self:SetRatio(0)
            end
        end)
        Hooks:PostHook(UpgradesManager, "_unaquire_team", "EHI_Buff_" .. self._id .. "_unaquire_team_skill", function (_, team, ...)
            if team.category == params.team_skill_check.category then
                self:RemoveVisibleBuff()
            end
        end)
    end
end

function EHIPermanentGaugeBuffTracker:ActivateSoft()
    self._visible = true
end

function EHIPermanentGaugeBuffTracker:Deactivate()
    self:SetRatio(0)
end

function EHIPermanentGaugeBuffTracker:DeactivateAndReset()
    self:SetRatio(0)
end

function EHIPermanentGaugeBuffTracker:DeactivateSoft()
    self._visible = false
end

function EHIPermanentGaugeBuffTracker:AddVisibleBuff()
end

function EHIPermanentGaugeBuffTracker:RemoveVisibleBuff()
end

function EHIPermanentGaugeBuffTracker:delete()
    if self._pos then
        EHIPermanentGaugeBuffTracker.super.RemoveVisibleBuff(self)
        self._pos = nil
    end
    EHIPermanentGaugeBuffTracker.super.delete(self)
end