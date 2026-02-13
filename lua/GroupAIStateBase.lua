local EHI = EHI
if EHI:CheckLoadHook("GroupAIStateBase") then
    return
end

local dropin = false
managers.ehi_sync:AddDropInListener(function()
    dropin = true
end)
local original =
{
    init = GroupAIStateBase.init,
    on_successful_alarm_pager_bluff = GroupAIStateBase.on_successful_alarm_pager_bluff,
    sync_alarm_pager_bluff = GroupAIStateBase.sync_alarm_pager_bluff,
    load = GroupAIStateBase.load,
    convert_hostage_to_criminal = GroupAIStateBase.convert_hostage_to_criminal,
    sync_converted_enemy = GroupAIStateBase.sync_converted_enemy,
    remove_minion = GroupAIStateBase.remove_minion
}

function GroupAIStateBase:init(...)
    original.init(self, ...)
    self:add_listener("EHI_EnemyWeaponsHot", "enemy_weapons_hot", function()
        EHI:RunOnAlarmCallbacks(dropin)
        self:remove_listener("EHI_EnemyWeaponsHot")
    end)
    if EHI:GetOption("show_minion_health") then
        self.__ehi_minion_health_events = table.exclude(CopDamage._all_event_types, "death") -- "death" event is already handled in a different callback
    end
    self.__ehi_color_minions_to_owner = EHI:GetOption("show_minion_colored_to_owner")
end

function GroupAIStateBase:on_successful_alarm_pager_bluff(...) -- Called by host
    original.on_successful_alarm_pager_bluff(self, ...)
    managers.ehi_tracker:SetProgress("Pagers", self._nr_successful_alarm_pager_bluffs)
    managers.ehi_tracker:SetChancePercent("PagersChance", tweak_data.player.alarm_pager.bluff_success_chance_w_skill[self._nr_successful_alarm_pager_bluffs + 1] or 0)
end

function GroupAIStateBase:sync_alarm_pager_bluff(...) -- Called by client
    original.sync_alarm_pager_bluff(self, ...)
    managers.ehi_tracker:SetProgress("Pagers", self._nr_successful_alarm_pager_bluffs)
end

function GroupAIStateBase:load(...)
    original.load(self, ...)
    if self._enemy_weapons_hot then
        EHI:RunOnAlarmCallbacks(dropin)
        self:remove_listener("EHI_EnemyWeaponsHot")
        local law1team = self._teams[tweak_data.levels:get_default_team_ID("combatant")]
        if law1team and law1team.damage_reduction then -- PhalanxDamageReduction is created before this gets set; see GameSetup:load()
            managers.ehi_tracker:SetChancePercent("PhalanxDamageReduction", law1team.damage_reduction or 0)
        elseif self._hunt_mode then -- Assault and AssaultTime is created before this is checked; see GameSetup:load()
            managers.ehi_assault:CallAssaultTypeChangedCallback("endless", 0)
        end
    else
        managers.ehi_tracker:SetProgress("Pagers", self._nr_successful_alarm_pager_bluffs)
    end
end

if not tweak_data.levels:IsStealthRequired() then
    if EHI:ShowDramaTracker() then
        local assault_mode = "normal"
        local function Create()
            if managers.ehi_tracker:Exists("Drama") then
                return
            end
            managers.ehi_tracker:AddTracker({
                id = "Drama",
                chance = math.ehi_round_chance(managers.groupai:state()._drama_data.amount),
                icons = { "C_Escape_H_Street_Bullet" },
                disable_anim = true,
                flash_bg = false,
                hint = "drama",
                class = EHI.Trackers.Chance
            }, managers.ehi_assault:Exists() and 1 or 0)
        end
        original._add_drama = GroupAIStateBase._add_drama
        function GroupAIStateBase:_add_drama(...)
            original._add_drama(self, ...)
            managers.ehi_tracker:SetChance("Drama", self._drama_data.amount, 2)
        end
        EHI:AddOnAlarmCallback(Create)
        managers.ehi_assault:AddAssaultTypeChangedCallback(function(mode, element_id)
            if mode == "endless" then
                managers.ehi_tracker:RemoveTracker("Drama")
            elseif managers.ehi_tracker:DoesNotExist("Drama") then
                Create()
            end
            assault_mode = mode
        end)
        managers.ehi_assault:AddAssaultModeChangedCallback(function(mode)
            if mode == "normal" and assault_mode == "endless" then
                assault_mode = "normal"
                Create()
            end
        end)
    end
    if EHI:GetTrackerOption("show_minion_tracker") then
        local UpdateTracker
        if EHI:GetOption("show_minion_option") ~= 2 then
            EHI:LoadTracker("EHIMinionTracker")
            local minion_class = (EHI:GetOption("show_minion_option") == 1 and EHI:GetOption("show_minion_health")) and "EHIMinionHealthOnlyTracker" or "EHIMinionTracker"
            ---@param key userdata
            ---@param amount number
            ---@param peer_id integer
            ---@param local_peer boolean?
            UpdateTracker = function(key, amount, peer_id, local_peer)
                if managers.ehi_tracker:DoesNotExist("Converts") and amount > 0 then
                    managers.ehi_tracker:AddTracker({
                        id = "Converts",
                        class = minion_class
                    })
                end
                if amount == 0 then -- Removal
                    managers.ehi_tracker:CallFunction("Converts", "RemoveMinion", key)
                else
                    managers.ehi_tracker:CallFunction("Converts", "AddMinion", key, peer_id, local_peer)
                end
            end
        else
            local minion_class = EHI:GetOptionAndLoadTracker("show_minion_health") and "EHITotalMinionTracker" or "EHIEquipmentTracker"
            if minion_class == "EHIEquipmentTracker" and not EHIEquipmentTracker then
                EHI:LoadTracker("EHIEquipmentTracker")
            end
            ---@param key userdata
            ---@param amount number
            ---@param peer_id integer
            ---@param local_peer boolean?
            UpdateTracker = function(key, amount, peer_id, local_peer)
                if managers.ehi_tracker:DoesNotExist("Converts") and amount > 0 then
                    managers.ehi_tracker:AddTracker({
                        id = "Converts",
                        dont_show_placed = true,
                        icons = { "minion" },
                        hint = "converts",
                        class = minion_class
                    })
                end
                if minion_class == "EHITotalMinionTracker" then
                    if amount == 0 then -- Removal
                        managers.ehi_tracker:CallFunction("Converts", "RemoveMinion", key)
                    else
                        managers.ehi_tracker:CallFunction("Converts", "AddMinion", key, peer_id, local_peer)
                    end
                else
                    managers.ehi_tracker:CallFunction("Converts", "UpdateAmount", key, amount)
                end
            end
        end
        if EHI:GetOption("show_minion_option") == 1 then -- Only you
            EHI:AddCallback(EHI.CallbackMessage.OnMinionAdded, function(unit, local_peer, peer_id)
                if local_peer then
                    UpdateTracker(unit:key(), 1, peer_id, true)
                end
            end)
        else -- Everyone
            EHI:AddCallback(EHI.CallbackMessage.OnMinionAdded, function(unit, local_peer, peer_id)
                UpdateTracker(unit:key(), 1, peer_id, local_peer)
            end)
        end
        EHI:AddCallback(EHI.CallbackMessage.OnMinionKilled, function(key, local_peer, peer_id)
            UpdateTracker(key, 0, peer_id)
        end)
    end
    if not tweak_data.levels:IsLevelSafehouse() and EHI:GetOptionAndLoadTracker("show_hostage_count_tracker") then
        local format_total = EHI:GetOption("hostage_count_tracker_format") == 1
        if EHI.IsHost then
            original.on_hostage_state = GroupAIStateBase.on_hostage_state
            function GroupAIStateBase:on_hostage_state(...)
                local original_count = self._hostage_headcount
                original.on_hostage_state(self, ...)
                if original_count ~= self._hostage_headcount then
                    managers.ehi_tracker:CallFunction("HostageCount", "SetHostageCountHost", self._hostage_headcount, self._police_hostage_headcount)
                end
            end
        elseif format_total then
            original.sync_hostage_headcount = GroupAIStateBase.sync_hostage_headcount
            function GroupAIStateBase:sync_hostage_headcount(...)
                original.sync_hostage_headcount(self, ...)
                managers.ehi_tracker:CallFunction("HostageCount", "SetHostageCount", self._hostage_headcount, 0)
            end
        end
        EHI:AddOnSpawnedCallback(function()
            local ai_state = managers.groupai:state()
            managers.ehi_tracker:AddTracker({
                id = "HostageCount",
                format_total = format_total,
                total_hostages = ai_state:hostage_count(),
                police_hostages = EHI.IsHost and ai_state:police_hostage_count(),
                class = "EHIHostageCountTracker"
            })
        end)
    end
    if EHI:GetTrackerOption("show_marshal_initial_time") and EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) then
        local level_data = tweak_data.levels[Global.game_settings.level_id] or {}
        if not level_data.ai_marshal_spawns_disabled then
            EHI:AddOnAlarmCallback(function(drop)
                if drop or EHI._cache.PlayingDevMap then
                    return
                end
                local marshal_spawn_group = tweak_data.group_ai.enemy_spawn_groups and tweak_data.group_ai.enemy_spawn_groups.marshal_squad
                local t = marshal_spawn_group and (marshal_spawn_group.initial_spawn_delay or marshal_spawn_group.spawn_cooldown or 0) or 0
                if t > 0 then
                    managers.ehi_tracker:AddTracker({
                        id = "Marshals",
                        time = t,
                        icons = { "equipment_sheriff_star" },
                        hint = "marshal",
                        class = EHI.Trackers.Warning
                    })
                end
            end)
        end
    end
end

if EHI:GetOption("show_minion_killed_message") then
    local show_popup_type = EHI:GetOption("show_minion_killed_message_type")
    if show_popup_type == 1 then
        EHI:SetNotificationAlert("MINION", "ehi_popup_minion")
    end
    local game_is_running = true
    local function GameEnd()
        game_is_running = false
    end
    EHI:AddEndGameCallback(GameEnd)
    EHI:AddCallback(EHI.CallbackMessage.MissionEnd, GameEnd)
    EHI:AddCallback(EHI.CallbackMessage.OnMinionKilled, function(key, local_peer, peer_id)
        if game_is_running and local_peer then
            if show_popup_type == 1 then
                managers.hud:custom_ingame_popup_text("MINION", managers.localization:text("ehi_popup_minion_killed"), "EHI_Minion")
            else
                managers.hud:show_hint({ text = managers.localization:text("ehi_popup_minion_killed") })
            end
        end
    end)
end

---@param params table
---@param unit UnitEnemy
function GroupAIStateBase:EHIConvertDied(params, unit)
    params.killed_callback = nil
    self:EHIRemoveConvert(params, unit)
end

---@param params table
---@param unit UnitEnemy
function GroupAIStateBase:EHIConvertDestroyed(params, unit)
    params.destroyed_callback = nil
    self:EHIRemoveConvert(params, unit)
end

---@param params table
---@param unit UnitEnemy
function GroupAIStateBase:EHIRemoveConvert(params, unit)
    EHI:CallCallback(EHI.CallbackMessage.OnMinionKilled, params.key, params.local_peer, params.peer_id)
    unit:character_damage():remove_listener("EHIConvertDamage")
    if params.killed_callback then
        unit:character_damage():remove_listener("EHIConvert")
    end
    if params.destroyed_callback then
        unit:base():remove_destroy_listener("EHIConvert")
    end
end

---@param key string
---@param unit UnitEnemy
function GroupAIStateBase:EHIConvertDamaged(key, unit, damage_info)
    managers.ehi_tracker:CallFunction("Converts", "MinionDamaged", key, unit)
end

---@param unit UnitEnemy
---@param local_peer boolean
---@param peer_id integer
function GroupAIStateBase:EHIAddConvert(unit, local_peer, peer_id)
    if not unit.key then
        EHI:Log("Convert does not have a 'key()' function! Aborting to avoid crashing the game.")
        return
    end
    EHI:CallCallback(EHI.CallbackMessage.OnMinionAdded, unit, local_peer, peer_id)
    local key = unit:key()
    local data = { key = key, local_peer = local_peer, peer_id = peer_id, killed_callback = true, destroyed_callback = true }
    unit:base():add_destroy_listener("EHIConvert", callback(self, self, "EHIConvertDestroyed", data))
    unit:character_damage():add_listener("EHIConvert", { "death" }, callback(self, self, "EHIConvertDied", data))
    if local_peer and self.__ehi_minion_health_events then
        unit:character_damage():add_listener("EHIConvertDamage", self.__ehi_minion_health_events, callback(self, self, "EHIConvertDamaged", key))
    end
    if self.__ehi_color_minions_to_owner and unit:contour() then
        local colors = tweak_data.chat_colors
        unit:contour():change_color("friendly", colors[peer_id] or colors[#colors] or tweak_data.contour.character.friendly_minion_color)
    end
end

function GroupAIStateBase:convert_hostage_to_criminal(unit, peer_unit, ...)
    original.convert_hostage_to_criminal(self, unit, peer_unit, ...)
    if unit:brain()._logic_data.is_converted then
        local peer_id = peer_unit and managers.network:session():peer_by_unit(peer_unit):id() or managers.network:session():local_peer():id()
        local local_peer = not peer_unit
        self:EHIAddConvert(unit, local_peer, peer_id)
    end
end

function GroupAIStateBase:sync_converted_enemy(converted_enemy, owner_peer_id, ...)
    if self._police[converted_enemy:key()] then
        local peer_id = owner_peer_id or 0
        self:EHIAddConvert(converted_enemy, peer_id == managers.network:session():local_peer():id(), peer_id)
    end
    return original.sync_converted_enemy(self, converted_enemy, owner_peer_id, ...)
end

function GroupAIStateBase:remove_minion(minion_key, ...)
    if self._converted_police[minion_key] then
        EHI:CallCallback(EHI.CallbackMessage.OnMinionKilled, minion_key, false, 0)
    end
    original.remove_minion(self, minion_key, ...)
end

if EHI.IsHost and (EHI:CanShowCivilianCountTracker() and EHI:GetOption("civilian_count_tracker_format") >= 2) then
    original.on_civilian_tied = GroupAIStateBase.on_civilian_tied
    function GroupAIStateBase:on_civilian_tied(u_key, ...)
        original.on_civilian_tied(self, u_key, ...)
        managers.ehi_tracker:CallFunction("CivilianCount", "CivilianTied", u_key)
    end
end