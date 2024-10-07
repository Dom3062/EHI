local EHI = EHI
if EHI:CheckLoadHook("GroupAIStateBesiege") then
    return
end

local original =
{
    _begin_assault_task = GroupAIStateBesiege._begin_assault_task
}

if EHI:GetOptionAndLoadTracker("show_captain_damage_reduction") then
    original.set_phalanx_damage_reduction_buff = GroupAIStateBesiege.set_phalanx_damage_reduction_buff
    function GroupAIStateBesiege:set_phalanx_damage_reduction_buff(damage_reduction, ...)
        original.set_phalanx_damage_reduction_buff(self, damage_reduction, ...)
        managers.ehi_tracker:SetChancePercent("PhalanxDamageReduction", damage_reduction or 0)
    end
    EHI:AddCallback(EHI.CallbackMessage.AssaultModeChanged, function(mode)
        if mode == "phalanx" then
            managers.ehi_tracker:AddTracker({
                id = "PhalanxDamageReduction",
                class = "EHIPhalanxDamageReductionTracker",
            })
        else
            managers.ehi_tracker:ForceRemoveTracker("PhalanxDamageReduction")
        end
    end)
end

if EHI:GetOption("show_assault_delay_tracker") then
    function GroupAIStateBesiege:_begin_assault_task(...)
        original._begin_assault_task(self, ...)
        local end_t = self._task_data.assault.phase_end_t
        if end_t ~= 0 then
            local t = end_t - self._t
            managers.ehi_assault:AnticipationStartHost(t)
            managers.ehi_assault:SyncAnticipationStartHost(t)
        end
    end
else
    function GroupAIStateBesiege:_begin_assault_task(...)
        original._begin_assault_task(self, ...)
        local end_t = self._task_data.assault.phase_end_t
        if end_t ~= 0 then
            managers.ehi_assault:SyncAnticipationStartHost(end_t - self._t)
        end
    end
end