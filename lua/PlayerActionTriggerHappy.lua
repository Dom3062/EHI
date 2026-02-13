if EHI:CheckLoadHook("PlayerActionTriggerHappy") or not EHI:GetBuffAndOption("trigger_happy") then
    return
end

local original = PlayerAction.TriggerHappy.Function
---@param player_manager PlayerManager
---@param damage_bonus number
---@param max_stacks integer
---@param max_time number
PlayerAction.TriggerHappy.Function = function(player_manager, damage_bonus, max_stacks, max_time, ...)
    player_manager._coroutine_mgr:add_and_run_coroutine("ehi_trigger_happy", PlayerAction.EHITriggerHappy, player_manager, max_time)
    original(player_manager, damage_bonus, max_stacks, max_time, ...)
    managers.ehi_buff:RemoveAndResetBuff("trigger_happy")
    player_manager:unregister_message(Message.OnEnemyShot, "ehi_trigger_happy") -- Just in case
    player_manager._coroutine_mgr:remove_coroutine("ehi_trigger_happy")
end

-- Trigger Happy was changed in Update 242.1 to extend end time each time a hit is made with a pistol (or akimbo pistol)
PlayerAction.EHITriggerHappy =
{
    Priority = 1,
    ---@param player_manager PlayerManager
    ---@param max_time number
    Function = function(player_manager, max_time)
        managers.ehi_buff:AddBuff("trigger_happy", max_time)
        local current_time = Application:time()
        local end_time = current_time + max_time

        local function on_hit(unit, attack_data)
            local attacker_unit = attack_data.attacker_unit
            local variant = attack_data.variant

            if attacker_unit == player_manager:player_unit() and variant == "bullet" then
                end_time = current_time + max_time
                managers.ehi_buff:AddBuff("trigger_happy", max_time)
            end
        end

        player_manager:register_message(Message.OnEnemyShot, "ehi_trigger_happy", on_hit)

        while current_time < end_time do
            current_time = Application:time()
            if not player_manager:is_current_weapon_of_category("pistol") then
                break
            end
            coroutine.yield()
        end

        player_manager:unregister_message(Message.OnEnemyShot, "ehi_trigger_happy")
    end
}