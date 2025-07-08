---@class PlayerManager
---@field _coroutine_mgr CoroutineManager
---@field _local_player_body_bags number
---@field _throw_regen_kills number?
---@field _temporary_upgrades table
---@field _timers table
---@field _melee_dmg_mul number
---@field _on_headshot_dealt_t number
---@field _damage_dealt_to_cops number
---@field _damage_dealt_to_cops_t number
---@field _damage_dealt_to_cops_decay_t number
---@field _dodge_shot_gain_value number
---@field _next_allowed_doh_t number
---@field _cached_detection_risk number?
---@field body_armor_value fun(self: self, category: string, override_value: number?, default: any?): number|any
---@field has_category_upgrade fun(self: self, category: string, upgrade: string): boolean
---@field get_damage_health_ratio fun(self: self, health_ratio: number, category: string?): number
---@field _get_damage_health_ratio_threshold fun(self: self, category: string?): number
---@field has_activate_temporary_upgrade fun(self: self, category: string, upgrade: string): boolean
---@field register_message fun(self: self, message: number|string, uid: string|number, func: function)
---@field unregister_message fun(self: self, message: number|string, uid: string|number)
---@field player_unit fun(self: self): UnitPlayer
---@field add_listener fun(self: self, key: string, events: string|string[], clbk: function)
---@field remove_listener fun(self: self, key: string)
---@field player_timer fun(self: self): TimerManager
---@field add_coroutine fun(self: self, name: number|string, func: {Priority: number, Function: function}, ...: any)
---@field local_player fun(self: self): UnitPlayer
---@field get_skill_exp_multiplier fun(self: self, stealth: boolean?): number
---@field upgrade_value_by_level fun(self: self, category: string, upgrade: string, level: number, default: any?): any|number
---@field equiptment_upgrade_value fun(self: self, category: string, upgrade: string, default: any?): any|number
---@field has_deployable_been_used fun(self: self): boolean
---@field skill_dodge_chance fun(self: self, running: boolean, crouching: boolean, on_zipline:boolean, override_armor: boolean?, detection_risk: number?): number
---@field critical_hit_chance fun(self: self, detection_risk: number?): number
---@field health_regen fun(self: self): number
---@field num_local_minions fun(self: self): number
---@field get_infamy_exp_multiplier fun(self: self): number
---@field damage_absorption fun(self: self): number
---@field damage_reduction_skill_multiplier fun(self: self, damage_type: string): number
---@field _wild_kill_triggers number[]
---@field _peer_used_deployable boolean
---@field count_up_player_minions fun(self: self)
---@field count_down_player_minions fun(self: self)
---@field current_state fun(self: self): string
---@field is_damage_health_ratio_active fun(self: self, health_ratio: number): boolean
---@field _smoke_screen_effects SmokeScreenEffect[]
---@field _carry_blocked_cooldown_t number

local EHI = EHI
if EHI:CheckLoadHook("PlayerManager") then
    return
end

local original = {}

if EHI:GetTrackerOption("show_bodybags_counter") then
    original._set_body_bags_amount = PlayerManager._set_body_bags_amount
    function PlayerManager:_set_body_bags_amount(...)
        original._set_body_bags_amount(self, ...)
        managers.ehi_tracker:SetCount("BodybagsCounter", self._local_player_body_bags)
    end
end

if not EHI:GetOption("show_buffs") then
    return
end

original.init = PlayerManager.init
function PlayerManager:init(...)
    original.init(self, ...)
    if EHI:GetBuffOption("regen_throwable_ai") then
        local value = tweak_data.upgrades.values.team.crew_throwable_regen
        local max = (value and value[1] or 35) + 1
        local progress = 0
        local function IncreaseProgress(...)
            progress = progress + 1
            if progress == max then
                progress = 0
            end
            managers.ehi_buff:AddGauge("crew_throwable_regen", progress / max, progress)
        end
        EHI:AddCallback(EHI.CallbackMessage.TeamAISkillChange, function(skill, operation)
            if skill == "crew_generous" then
                if operation == "add" then
                    progress = self._throw_regen_kills or 0
                    managers.ehi_buff:AddGauge("crew_throwable_regen", progress / max, progress)
                    self:register_message(Message.OnEnemyKilled, "EHI_crew_throwable_regen", IncreaseProgress)
                else
                    managers.ehi_buff:RemoveBuff("crew_throwable_regen")
                    self:unregister_message(Message.OnEnemyKilled, "EHI_crew_throwable_regen")
                end
            end
        end)
    end
end

if EHI:GetBuffOption("forced_friendship") then
    local hostage_limit = tweak_data.upgrades.values.team.damage.hostage_absorption_limit
    local absorption_gain = tweak_data.upgrades.values.team.damage.hostage_absorption[1]
    local max_absorption = hostage_limit * absorption_gain
    original.set_damage_absorption = PlayerManager.set_damage_absorption
    function PlayerManager:set_damage_absorption(key, value, ...)
        if key == "hostage_absorption" then
            if value and value > 0 then
                local ratio = value / max_absorption
                managers.ehi_buff:AddGauge("hostage_absorption", ratio, value * 10)
            else
                managers.ehi_buff:RemoveAndResetBuff("hostage_absorption")
            end
        end
        original.set_damage_absorption(self, key, value, ...)
    end
end

if EHI:GetBuffOption("unseen_strike_initial") then
    EHI:AddOnSpawnedCallback(function()
        local self = managers.player
        if self:has_category_upgrade("player", "unseen_increased_crit_chance") then
            local data = self:upgrade_value("player", "unseen_increased_crit_chance", 0) --[[@as table|number]]
            if data == 0 then
                return
            end
            local min_time = data.min_time or 4
            self:register_message(Message.OnPlayerDamage, "EHI_UnseenStrike_Initial", function()
                if not self:has_activate_temporary_upgrade("temporary", "unseen_strike") then
                    managers.ehi_buff:AddBuff("unseen_strike_initial", min_time)
                end
            end)
        end
    end)
end

if EHI:GetBuffOption("crit") then
    original.update_cached_detection_risk = PlayerManager.update_cached_detection_risk
    function PlayerManager:update_cached_detection_risk(...)
        original.update_cached_detection_risk(self, ...)
        managers.ehi_buff:CallFunction("CritChance", "UpdateDetectionRisk", self._cached_detection_risk)
    end
end

local AbilityKey, AbilitySpeedUp
EHI:AddOnSpawnedCallback(function()
    local self = managers.player
    local grenade = managers.blackmarket:equipped_grenade()
    if grenade == "chico_injector" then -- Kingpin
        AbilityKey = "chico_injector"
        AbilitySpeedUp = "speed_up_chico_injector"
    elseif grenade == "smoke_screen_grenade" then -- Sicario
        AbilityKey = "smoke_screen_grenade"
    elseif grenade == "damage_control" then -- Stoic
        AbilityKey = "damage_control"
        if self:has_category_upgrade("player", "damage_control_auto_shrug") then
            tweak_data.ehi.buff.damage_control.x = 2 -- 128px
            managers.ehi_buff:UpdateBuffIcon("damage_control")
            managers.ehi_buff:CallFunction("damage_control", "SetAutoShrug", self:upgrade_value("player", "damage_control_auto_shrug"))
        end
        self:register_message("ability_activated", "EHI_Stoic_Ability_Activated", function(ability_name)
            if ability_name == "damage_control" then
                managers.ehi_buff:RemoveBuff("damage_control")
            end
        end)
    elseif grenade == "tag_team" then -- Tag Team
        AbilityKey = "tag_team"
    elseif grenade == "pocket_ecm_jammer" then -- Hacker
        AbilityKey = "pocket_ecm_jammer"
        AbilitySpeedUp = "speed_up_pocket_ecm_jammer"
    elseif grenade == "copr_ability" then -- Leech
        AbilityKey = "copr_ability"
        AbilitySpeedUp = "speed_up_copr_ability"
    end
    if AbilityKey then
        AbilityKey = AbilityKey .. "_cooldown"
        Hooks:PreHook(self, "add_grenade_amount", "EHI_Replenish_Throwable", function(pm, amount, ...)
            if amount > 0 then
                managers.ehi_buff:CallFunction(AbilityKey, "Replenished")
            elseif amount < 0 then
                managers.ehi_buff:CallFunction(AbilityKey, "AddToReplenish")
            end
        end)
    end
end)

original.activate_temporary_upgrade = PlayerManager.activate_temporary_upgrade
function PlayerManager:activate_temporary_upgrade(category, upgrade, ...)
    original.activate_temporary_upgrade(self, category, upgrade, ...)
    local end_time = self._temporary_upgrades[category] and self._temporary_upgrades[category][upgrade] and self._temporary_upgrades[category][upgrade].expire_time
    if end_time then
        managers.ehi_buff:AddBuff(upgrade, end_time - Application:time())
    end
end

original.start_timer = PlayerManager.start_timer
function PlayerManager:start_timer(key, duration, ...)
    if key == "replenish_grenades" and AbilityKey then
        managers.ehi_buff:AddBuff(AbilityKey, duration)
    elseif key == "team_crew_inspire" then
        managers.ehi_buff:SyncAndAddBuff(key, duration)
    end
    original.start_timer(self, key, duration, ...)
end

original.speed_up_grenade_cooldown = PlayerManager.speed_up_grenade_cooldown
function PlayerManager:speed_up_grenade_cooldown(time, ...)
    if not self._timers.replenish_grenades then
        return
    end
    if not AbilityKey then
        return original.speed_up_grenade_cooldown(self, time, ...)
    end
    managers.ehi_buff:ShortBuffTime(AbilityKey, time)
    original.speed_up_grenade_cooldown(self, time, ...)
end

if EHI:GetBuffOption("bloodthirst") then
    local meele_boost_tweak = tweak_data.upgrades.values.player.melee_damage_stacking[1] or {}
    local bloodthirst_reload = EHI:GetBuffOption("bloodthirst_reload")
    local bloodthirst_ratio = EHI:GetBuffOption("bloodthirst_ratio") / 100
    local max_multiplier = meele_boost_tweak.max_multiplier or 16
    local bloodthirst_max = false
    if bloodthirst_ratio == 0 then
        EHI:AddOnSpawnedCallback(function()
            if managers.player:has_category_upgrade("player", "melee_damage_stacking") then
                managers.ehi_buff:AddGauge("melee_damage_stacking", 1 / max_multiplier, 1)
            end
        end)
    end
    original.set_melee_dmg_multiplier = PlayerManager.set_melee_dmg_multiplier
    function PlayerManager:set_melee_dmg_multiplier(multiplier, ...)
        original.set_melee_dmg_multiplier(self, multiplier, ...)
        if bloodthirst_max then
            return
        end
        local ratio = multiplier / max_multiplier
        if ratio >= bloodthirst_ratio then
            bloodthirst_max = ratio >= 1
            managers.ehi_buff:AddGauge("melee_damage_stacking", ratio, multiplier)
        end
    end
    original.reset_melee_dmg_multiplier = PlayerManager.reset_melee_dmg_multiplier
    function PlayerManager:reset_melee_dmg_multiplier(...)
        original.reset_melee_dmg_multiplier(self, ...)
        if bloodthirst_ratio > 0 then
            managers.ehi_buff:RemoveBuff("melee_damage_stacking")
        else
            managers.ehi_buff:AddGauge("melee_damage_stacking", self._melee_dmg_mul / max_multiplier, self._melee_dmg_mul)
        end
        bloodthirst_max = false -- Reset the lock
        if bloodthirst_reload then
            local data = self:upgrade_value("player", "melee_kill_increase_reload_speed", 0)
            if data ~= 0 then
                managers.ehi_buff:AddBuff("melee_kill_increase_reload_speed", data[2])
            end
        end
    end
elseif EHI:GetBuffOption("bloodthirst_reload") then
    original.reset_melee_dmg_multiplier = PlayerManager.reset_melee_dmg_multiplier
    function PlayerManager:reset_melee_dmg_multiplier(...)
        original.reset_melee_dmg_multiplier(self, ...)
        local data = self:upgrade_value("player", "melee_kill_increase_reload_speed", 0)
        if data ~= 0 then
            managers.ehi_buff:AddBuff("melee_kill_increase_reload_speed", data[2])
        end
    end
end

if EHI:GetBuffOption("painkillers") or EHI:GetBuffDeckOption("copycat", "grace_period_cooldown") then
    original.activate_temporary_property = PlayerManager.activate_temporary_property
    function PlayerManager:activate_temporary_property(name, time, ...)
        original.activate_temporary_property(self, name, time, ...)
        if name == "revived_damage_reduction" then -- "Painkillers"
            managers.ehi_buff:AddBuff("fast_learner", time)
        elseif name == "mrwi_health_invulnerable" then -- "Grace Period" (Copycat)
            managers.ehi_buff:AddBuff("mrwi_health_invulnerable_cooldown", time)
        end
    end
end

if EHI:GetBuffOption("second_wind") then
    original.activate_synced_temporary_team_upgrade = PlayerManager.activate_synced_temporary_team_upgrade
    function PlayerManager:activate_synced_temporary_team_upgrade(peer_id, category, upgrade, ...)
        original.activate_synced_temporary_team_upgrade(self, peer_id, category, upgrade, ...)
        if category ~= "temporary" or upgrade ~= "team_damage_speed_multiplier_received" then
            return
        end
        local upgrade_value = self:upgrade_value(category, upgrade)
        if upgrade_value == 0 then
            return
        end
        managers.ehi_buff:AddBuff("damage_speed_multiplier", upgrade_value[2])
    end
end

if EHI:GetBuffOption("inspire_ace") then
    original.disable_cooldown_upgrade = PlayerManager.disable_cooldown_upgrade
    function PlayerManager:disable_cooldown_upgrade(category, upgrade, ...)
        local upgrade_value = self:upgrade_value(category, upgrade)
        if upgrade_value == 0 then
            return
        end
        original.disable_cooldown_upgrade(self, category, upgrade, ...)
        if category ~= "cooldown" or upgrade ~= "long_dis_revive" then
            return
        end
        managers.ehi_buff:AddBuff("long_dis_revive", upgrade_value[2])
    end
end

if EHI:GetBuffOption("carry_interaction_cooldown") then
    original.drop_carry = PlayerManager.drop_carry
    function PlayerManager:drop_carry(...)
        original.drop_carry(self, ...)
        if self._carry_blocked_cooldown_t ~= self._ehi_carry_blocked_cooldown_t then
            self._ehi_carry_blocked_cooldown_t = self._carry_blocked_cooldown_t
            managers.ehi_buff:AddBuff("CarryInteractionCooldown", self._carry_blocked_cooldown_t - Application:time())
        end
    end
end

--////////////////--
--//  Tag Team  //--
--////////////////--
if EHI:GetBuffDeckSelectedOptions("tag_team", "effect", "absorption") then
    local Effect =
    {
        Priority = 1,
        Function = function(tagged, owner)
            local base_values = managers.player:upgrade_value("player", "tag_team_base")
            local absorption_bonus = managers.player:has_category_upgrade("player", "tag_team_damage_absorption") and managers.player:upgrade_value("player", "tag_team_damage_absorption")
            local timer = TimerManager:game()
            local kill_extension = base_values.kill_extension
            local duration = base_values.duration
            local absorption = 0
            local end_time = timer:time() + base_values.duration
            local function on_damage(damage_info) ---@param damage_info CopDamage.AttackData
                local was_killed = damage_info.result.type == "death"
                local valid_player = damage_info.attacker_unit == owner or damage_info.attacker_unit == tagged
                if was_killed and valid_player then
                    end_time = math.min(end_time + kill_extension, timer:time() + duration)
                    managers.ehi_buff:CallFunction("TagTeamEffect", "AddTimeCeil", kill_extension, duration)
                    if absorption_bonus then
                        absorption = math.min(absorption + absorption_bonus.kill_gain, absorption_bonus.max)
                        managers.ehi_buff:AddGauge("TagTeamAbsorption", absorption / absorption_bonus.max, absorption)
                    end
                end
            end
            local on_damage_key = "TagTeam_EHI_on_damage"
            CopDamage.register_listener(on_damage_key, { "on_damage" }, on_damage)
            while alive(owner) and timer:time() < end_time do
                coroutine.yield()
            end
            CopDamage.unregister_listener(on_damage_key)
            while not managers.player:got_max_grenades() do
                coroutine.yield()
            end
            managers.ehi_buff:RemoveBuff("TagTeamAbsorption")
        end
    }
    original._attempt_tag_team = PlayerManager._attempt_tag_team
    function PlayerManager:_attempt_tag_team(...)
        local result = original._attempt_tag_team(self, ...)
        if result then
            local duration = self:upgrade_value("player", "tag_team_base", {}).duration --[[@as number?]]
            if not duration then -- No duration ? How ?
                return
            end
            managers.ehi_buff:AddBuff("TagTeamEffect", duration)
            local args = self._coroutine_mgr._buffer.tag_team.arg
            local tagged, owner = unpack(args)
            self:add_coroutine("tag_team_EHI", Effect, tagged, owner)
        end
        return result
    end
end
if EHI:GetBuffDeckOption("tag_team", "tagged") then
    local Tagged =
    {
        Priority = 1,
        Function = function(tagged, owner, BuffKey)
            local base_values = owner:base():upgrade_value("player", "tag_team_base")
            local timer = TimerManager:game()
            local kill_extension = base_values.kill_extension
            local duration = base_values.duration
            local end_time = timer:time() + duration
            local on_damage_key = "on_damage_" .. BuffKey .. "_EHI"
            local function on_damage(damage_info) ---@param damage_info CopDamage.AttackData
                local was_killed = damage_info.result.type == "death"
                local valid_player = damage_info.attacker_unit == owner or damage_info.attacker_unit == tagged
                if was_killed and valid_player then
                    end_time = math.min(end_time + kill_extension, timer:time() + duration)
                    managers.ehi_buff:CallFunction(BuffKey, "AddTimeCeil", kill_extension, duration)
                end
            end
            CopDamage.register_listener(on_damage_key, { "on_damage" }, on_damage)
            local ended_by_owner = false
            local on_end_key = "on_end_tag_" .. BuffKey .. "_EHI"
            local function on_action_end(end_tagged, end_owner)
                local tagged_match = tagged == end_tagged
                local owner_match = owner == end_owner
                ended_by_owner = tagged_match and owner_match
            end
            managers.player:add_listener(on_end_key, { "tag_team_end" }, on_action_end)
            while not ended_by_owner and alive(tagged) and (alive(owner) or timer:time() < end_time) do
                coroutine.yield()
            end
            managers.ehi_buff:RemoveBuff(BuffKey)
            CopDamage.unregister_listener(on_damage_key)
            managers.player:remove_listener(on_end_key)
        end
    }
    original.sync_tag_team = PlayerManager.sync_tag_team
    function PlayerManager:sync_tag_team(tagged, owner, ...)
        original.sync_tag_team(self, tagged, owner, ...)
        if tagged == self:local_player() then
            local base_values = owner:base():upgrade_value("player", "tag_team_base") or {}
            local duration = base_values.duration
            if not duration then -- No duration ? Is the owner running a rebalance or cheating ?
                -- Other possible explanation is that the local player is running a rebalance,
                -- making synced upgrades from client marked as invalid
                -- End the execution here because the vanilla coroutine will crash too (but silently)
                return
            end
            local session = managers.network:session()
            local tagged_id = session:peer_by_unit(tagged):id()
            local owner_id = session:peer_by_unit(owner):id()
            local coroutine_key = "TagTeamTagged_" .. owner_id .. tagged_id
            managers.ehi_buff:AddBuff(coroutine_key, duration)
            self:add_coroutine(coroutine_key, Tagged, tagged, owner, coroutine_key)
        end
    end
end

--/////////////--
--//  Leech  //--
--/////////////--
if EHI:GetBuffDeckOption("leech", "ampule") then
    original.force_end_copr_ability = PlayerManager.force_end_copr_ability
    function PlayerManager:force_end_copr_ability(...)
        original.force_end_copr_ability(self, ...)
        managers.ehi_buff:RemoveBuff("copr_ability")
    end
end

--//////////////////////////////////--
--//  Bullseye / Ammo Efficiency  //--
--//////////////////////////////////--
if EHI:GetBuffOption("bullseye") or EHI:GetBuffDeckOption("copycat", "head_games_cooldown") then
    original.on_headshot_dealt = PlayerManager.on_headshot_dealt
    function PlayerManager:on_headshot_dealt(...)
        local previouscooldown = self._on_headshot_dealt_t or 0

        original.on_headshot_dealt(self, ...)

        local t = Application:time()

        if self:has_category_upgrade("player", "headshot_regen_armor_bonus") then
            if t >= previouscooldown then
                managers.ehi_buff:AddBuff("headshot_regen_armor_bonus", self._on_headshot_dealt_t - t)
            end
        end

        if self:has_category_upgrade("player", "headshot_regen_health_bonus") then
            if t >= previouscooldown then
                managers.ehi_buff:AddBuff("headshot_regen_health_bonus", self._on_headshot_dealt_t - t)
            end
        end
    end
end

--///////////////////////--
--//  Ammo Efficiency  //--
--///////////////////////--
original.on_ammo_increase = PlayerManager.on_ammo_increase
function PlayerManager:on_ammo_increase(...)
    original.on_ammo_increase(self, ...)
    managers.ehi_buff:RemoveAndResetBuff("ammo_efficiency")
end

--///////////////////--
--//  Bulletstorm  //--
--///////////////////--
if EHI:GetBuffOption("bulletstorm") then
    original.add_to_temporary_property = PlayerManager.add_to_temporary_property
    function PlayerManager:add_to_temporary_property(name, time, ...)
        original.add_to_temporary_property(self, name, time, ...)
        if name == "bullet_storm" then
            managers.ehi_buff:AddBuff("no_ammo_cost", time)
        end
    end
end

--//////////////--
--//  Maniac  //--
--//////////////--
if EHI:GetBuffDeckSelectedOptions("maniac", "stack", "stack_decay", "stack_convert_rate") then
    local next_maniac_stack_poll = EHI:GetBuffDeckOption("maniac", "stack") and 0 or math.huge
    local ShowManiacStackTicks = EHI:GetBuffDeckOption("maniac", "stack_convert_rate")
    local ShowManiacDecayTicks = EHI:GetBuffDeckOption("maniac", "stack_decay")
    local NextStackPoll = EHI:GetBuffDeckOption("maniac", "stack_refresh")
    local maxstacks = tweak_data.upgrades.max_cocaine_stacks_per_tick or 20
    original._update_damage_dealt = PlayerManager._update_damage_dealt
    function PlayerManager:_update_damage_dealt(t, ...)
        local previousstack = self._damage_dealt_to_cops_t or 0
        local previousdecay = self._damage_dealt_to_cops_decay_t or 0

        original._update_damage_dealt(self, t, ...)

        if not self:has_category_upgrade("player", "cocaine_stacking") or self:local_player() == nil or self._damage_dealt_to_cops_t == nil or self._damage_dealt_to_cops_decay_t == nil then
            return
        end

        -- t here is identical to the timestamp returned by PlayerManager:player_timer():time() so do not bother calling the latter
        if t >= previousstack and ShowManiacStackTicks then
            managers.ehi_buff:AddBuff2("ManiacStackTicks", self._damage_dealt_to_cops_t - t)
        end

        if t >= previousdecay and ShowManiacDecayTicks then
            managers.ehi_buff:AddBuff2("ManiacDecayTicks", self._damage_dealt_to_cops_decay_t - t)
        end

        -- Poll accumulated hysteria stacks, but not every frame
        if t >= next_maniac_stack_poll then
            local newstacks = math.min((self._damage_dealt_to_cops or 0) * tweak_data.gui.stats_present_multiplier * self:upgrade_value("player", "cocaine_stacking", 0), maxstacks)
            local ratio = newstacks / maxstacks
            if ratio > 0 then
                managers.ehi_buff:AddGauge("ManiacAccumulatedStacks", math.ehi_round(ratio, 0.01))
            else
                managers.ehi_buff:RemoveBuff("ManiacAccumulatedStacks")
            end
            next_maniac_stack_poll = t + NextStackPoll
        end
    end
end

--///////////////--
--//  Grinder  //--
--///////////////--
if EHI:GetBuffDeckOption("grinder", "stack_cooldown") then
    original._check_damage_to_hot = PlayerManager._check_damage_to_hot
    function PlayerManager:_check_damage_to_hot(t, ...)
        local previouscooldown = self._next_allowed_doh_t or 0
        original._check_damage_to_hot(self, t, ...)
        if self._next_allowed_doh_t and self._next_allowed_doh_t > previouscooldown then
            managers.ehi_buff:AddBuff("GrinderStackCooldown", self._next_allowed_doh_t - t)
        end
    end
end

--///////////////--
--//  Sicario  //--
--///////////////--
if EHI:GetBuffDeckSelectedOptions("sicario", "twitch", "twitch_cooldown") then
    local twitch_gauge_previous = 0
    local cooldown = tweak_data.upgrades.values.player.dodge_shot_gain[1][2] or 4
    original._dodge_shot_gain = PlayerManager._dodge_shot_gain
    function PlayerManager:_dodge_shot_gain(gain_value, ...)
        local dodge_value = gain_value or self._dodge_shot_gain_value or 0
        if twitch_gauge_previous ~= dodge_value then
            twitch_gauge_previous = dodge_value
            if dodge_value > 0 then
                managers.ehi_buff:AddGauge("SicarioTwitchGauge", dodge_value)
            else
                managers.ehi_buff:RemoveAndResetBuff("SicarioTwitchGauge")
            end
        end
        if dodge_value > 0 and dodge_value ~= self._dodge_shot_gain_value then
            managers.ehi_buff:AddBuff("SicarioTwitchCooldown", cooldown)
        end
        return original._dodge_shot_gain(self, gain_value, ...)
    end
end