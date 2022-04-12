local EHI = EHI
if EHI._hooks.GroupAIStateBase then
	return
else
	EHI._hooks.GroupAIStateBase = true
end

local dropin = false
local function Execute()
    EHI:RunOnAlarmCallbacks(dropin)
end

local original =
{
    init = GroupAIStateBase.init,
    on_successful_alarm_pager_bluff = GroupAIStateBase.on_successful_alarm_pager_bluff,
    sync_alarm_pager_bluff = GroupAIStateBase.sync_alarm_pager_bluff,
    load = GroupAIStateBase.load
}

function GroupAIStateBase:init(...)
	original.init(self, ...)
    self:add_listener("EHI_EnemyWeaponsHot", { "enemy_weapons_hot" }, Execute)
end

function GroupAIStateBase:on_successful_alarm_pager_bluff(...) -- Called by host
    original.on_successful_alarm_pager_bluff(self, ...)
    managers.ehi:SetTrackerProgress("pagers", self._nr_successful_alarm_pager_bluffs)
    managers.ehi:SetChance("pagers_chance", (EHI:RoundChanceNumber(tweak_data.player.alarm_pager.bluff_success_chance_w_skill[self._nr_successful_alarm_pager_bluffs + 1] or 0)))
end

function GroupAIStateBase:sync_alarm_pager_bluff(...) -- Called by client
    original.sync_alarm_pager_bluff(self, ...)
    managers.ehi:SetTrackerProgress("pagers", self._nr_successful_alarm_pager_bluffs)
end

function GroupAIStateBase:load(...)
    dropin = managers.ehi:GetDropin()
    original.load(self, ...)
    if self._enemy_weapons_hot then
        EHI:RunOnAlarmCallbacks(dropin)
    else
        managers.ehi:SetTrackerProgress("pagers", self._nr_successful_alarm_pager_bluffs)
	end
    local law1team = self._teams[tweak_data.levels:get_default_team_ID("combatant")]
    if law1team and law1team.damage_reduction then
        managers.ehi:SetChance("PhalanxDamageReduction", (EHI:RoundChanceNumber(law1team.damage_reduction or 0)))
    end
end

if EHI:ShowDramaTracker() then
    local level_id = Global.game_settings.level_id
    local level_data = tweak_data.levels[level_id]
    if not (level_data.ghost_required or level_data.ghost_required_visual) then
        original._add_drama = GroupAIStateBase._add_drama
        function GroupAIStateBase:_add_drama(...)
            original._add_drama(self, ...)
            managers.ehi:SetChance("Drama", EHI:RoundChanceNumber(self._drama_data.amount))
        end
        EHI:AddOnAlarmCallback(function()
            managers.ehi:AddTracker({
                id = "Drama",
                icons = { "C_Escape_H_Street_Bullet" },
                class = "EHIChanceTracker",
                dont_flash = true
            }, 0)
        end)
    end
end

if EHI:GetOption("show_minion_tracker") then
    local UpdateTracker
    if EHI:GetOption("show_minion_per_player") then
        UpdateTracker = function(unit, key, amount, peer_id)
            if managers.ehi:TrackerDoesNotExist("Converts") and amount ~= 0 then
                managers.ehi:AddTracker({
                    id = "Converts",
                    exclude_from_sync = true,
                    class = "EHIMinionTracker"
                })
            end
            if amount == 0 then -- Removal
                managers.ehi:CallFunction("Converts", "RemoveMinion", key)
            else
                managers.ehi:CallFunction("Converts", "AddMinion", unit, key, amount, peer_id)
            end
        end
    else
        UpdateTracker = function(unit, key, amount, peer_id)
            if managers.ehi:TrackerDoesNotExist("Converts") and amount ~= 0 then
                managers.ehi:AddTracker({
                    id = "Converts",
                    dont_show_placed = true,
                    icons = { "minion" },
                    exclude_from_sync = true,
                    class = "EHIEquipmentTracker"
                })
            end
            managers.ehi:CallFunction("Converts", "UpdateAmount", unit, key, amount)
        end
    end

    function GroupAIStateBase:EHIRemoveConvert(unit)
        UpdateTracker(nil, tostring(unit:key()), 0)
        local callback_key = "EHIConvert" .. tostring(unit:key())
        unit:character_damage():remove_listener(callback_key)
        unit:base():remove_destroy_listener(callback_key)
    end

    function GroupAIStateBase:EHIAddListener(unit)
        local callback_key = "EHIConvert" .. tostring(unit:key())
        local clbk = callback(self, self, "EHIRemoveConvert")
        unit:base():add_destroy_listener(callback_key, clbk)
        unit:character_damage():add_listener(callback_key, { "death" }, clbk)
    end

    original.convert_hostage_to_criminal = GroupAIStateBase.convert_hostage_to_criminal
    function GroupAIStateBase:convert_hostage_to_criminal(unit, peer_unit, ...)
		original.convert_hostage_to_criminal(self, unit, peer_unit, ...)
		if unit:brain()._logic_data.is_converted then
            self:EHIAddListener(unit)
			local peer_id = peer_unit and managers.network:session():peer_by_unit(peer_unit):id() or managers.network:session():local_peer():id()
            UpdateTracker(unit, tostring(unit:key()), 1, peer_id)
		end
	end

    original.sync_converted_enemy = GroupAIStateBase.sync_converted_enemy
	function GroupAIStateBase:sync_converted_enemy(converted_enemy, owner_peer_id, ...)
		if self._police[converted_enemy:key()] then
            self:EHIAddListener(converted_enemy)
            UpdateTracker(converted_enemy, tostring(converted_enemy:key()), 1, owner_peer_id or 0)
		end
		return original.sync_converted_enemy(self, converted_enemy, owner_peer_id, ...)
	end

    original.remove_minion = GroupAIStateBase.remove_minion
    function GroupAIStateBase:remove_minion(minion_key, ...)
        original.remove_minion(self, minion_key, ...)
        UpdateTracker(nil, tostring(minion_key), 0)
    end
end