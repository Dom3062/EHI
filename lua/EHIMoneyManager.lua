---@class EHIMoneyManager
EHIMoneyManager = {}
EHIMoneyManager._enabled = EHI:GetOptionAndLoadTracker("show_money_tracker")
---@param manager EHIManager
function EHIMoneyManager:init_finalize(manager)
    if not self._enabled then
        return
    end
    local job = managers.job
    if tweak_data.levels:IsLevelSafehouse() or EHI._cache.PlayingDevMap then
        _G.EHIMoneyTracker = nil
        self._enabled = false
        return
    elseif job:_on_last_stage() then
        local payout, _, _ = managers.money:get_contract_money_by_stars(job:current_job_stars(), job:current_difficulty_stars(), nil, job:current_job_id(), job:current_level_id(), {})
        self._job_payout = payout
    else
        self._job_payout = 0
    end
    self._trackers = manager._trackers
    Hooks:PostHook(CivilianDamage, "_unregister_from_enemy_manager", "EHI_EHIMoneyManager_unregister_civilian", function(damage, damage_info, ...) ---@param damage_info CopDamage.AttackData
        local attacker_unit = damage_info and damage_info.attacker_unit
        if attacker_unit and attacker_unit == managers.player:player_unit() and not tweak_data.character[damage._unit:base()._tweak_table].no_civ_penalty then
            self._trackers:CallFunction("Money", "CivilianKilled", managers.money:get_civilian_deduction())
        end
    end)
    manager._loot:AddListener("EHIMoneyManager", function(loot)
        self._trackers:CallFunction("Money", "LootSecured", loot:GetSecuredBagsValueAmount())
        self._trackers:CallFunction("Money", "SmallLootSecured", loot:get_real_total_small_loot_value())
    end)
    manager._loot:AddSyncListener(function(loot)
        self._bags_secured_value = loot:GetSecuredBagsValueAmount()
        self._small_loot_secured_value = loot:get_real_total_small_loot_value()
    end)
    ---@param assets MissionAssetsManager
    local function UpdateMoneySpendOnAssets(assets)
        self._spend_on_assets = assets:get_money_spent()
    end
    Hooks:PostHook(MissionAssetsManager, "_on_asset_unlocked", "EHI_EHIMoneyManager_on_asset_unlocked", UpdateMoneySpendOnAssets)
    Hooks:PostHook(MissionAssetsManager, "sync_relock_assets", "EHI_EHIMoneyManager_sync_relock_assets", UpdateMoneySpendOnAssets)
    Hooks:PreHook(PrePlanningManager, "on_execute_preplanning", "EHI_EHIMoneyManager_on_execute_preplanning", function(preplan, ...)
        if preplan:has_current_level_preplanning() then
            self._spend_on_preplanning = managers.money:get_preplanning_total_cost()
        end
    end)
    EHI:AddCallback("ExperienceManager_RefreshPlayerCount", function(alive_players) ---@param alive_players number
        local multiplier = tweak_data:get_value("money_manager", "alive_humans_multiplier", alive_players or 1) or 1
        if self._trackers:CallFunction2("Money", "MultiplierChanged", multiplier) then
            self._alive_players_multiplier = multiplier
        end
    end)
end

function EHIMoneyManager:Spawned()
    if not self._enabled then
        return
    end
    Hooks:RemovePostHook("EHI_EHIMoneyManager_on_asset_unlocked")
    Hooks:RemovePostHook("EHI_EHIMoneyManager_sync_relock_assets")
    Hooks:RemovePreHook("EHI_EHIMoneyManager_on_execute_preplanning")
    self._trackers:AddTracker({
        id = "Money",
        job_payout = self._job_payout,
        spend_on_assets = (self._spend_on_assets or 0) + (self._spend_on_preplanning or 0),
        alive_players_multiplier = self._alive_players_multiplier,
        bags_value = self._bags_secured_value,
        small_loot_value = self._small_loot_secured_value,
        icons = { EHI.Icons.Money },
        hint = "payday",
        class = "EHIMoneyTracker"
    })
    self._alive_players_multiplier = nil
    self._bags_secured_value = nil
    self._small_loot_secured_value = nil
end