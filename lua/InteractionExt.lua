local EHI = EHI
if EHI:CheckLoadHook("InteractionExt") then
    return
end

if EHI:GetTrackerOrWaypointOption("show_pager_callback", "show_waypoints_pager") then
    local answered_behavior = EHI:GetOption("show_pager_callback_answered_behavior") --[[@as 1|2]]
    local show_tracker, show_waypoint = EHI:GetShowTrackerAndWaypoint("show_pager_callback", "show_waypoints_pager")
    if show_tracker then
        ---@class EHIPagerTracker : EHIWarningTracker
        ---@field super EHIWarningTracker
        EHIPagerTracker = class(EHIWarningTracker)
        EHIPagerTracker._forced_icons = { "pager_icon" }
        EHIPagerTracker._forced_time = 12
        function EHIPagerTracker:SetAnswered()
            self:RemoveTrackerFromUpdate()
            self:StopAndSetTextColor(Color.green)
            self:AnimateBG()
        end
    end
    if show_waypoint then
        ---@class EHIPagerWaypoint : EHIWarningWaypoint
        ---@field super EHIWarningWaypoint
        EHIPagerWaypoint = class(EHIWarningWaypoint)
        EHIPagerWaypoint._forced_time = 12
        function EHIPagerWaypoint:SetAnswered()
            self:RemoveWaypointFromUpdate()
            self:StopAndSetColor(Color.green)
        end
    end

    Hooks:PostHook(IntimitateInteractionExt, "init", "EHI_pager_init", function(self, unit, ...)
        self._ehi_key = "pager_" .. tostring(unit:key())
    end)

    Hooks:PostHook(IntimitateInteractionExt, "set_tweak_data", "EHI_pager_set_tweak_data", function(self, id)
        if id == "corpse_alarm_pager" and not self.__ehi_pager_has_run then
            if show_tracker then
                managers.ehi_tracker:AddTracker({
                    id = self._ehi_key,
                    hint = "pager",
                    remove_on_alarm = true,
                    class = "EHIPagerTracker"
                })
            end
            if show_waypoint then
                managers.ehi_waypoint:AddWaypoint(self._ehi_key, {
                    texture = "guis/dlcs/cee/textures/pd2/crime_spree/modifiers_atlas",
                    texture_rect = { 0, 384, 128, 128 },
                    position = self._unit:position(),
                    remove_on_alarm = true,
                    class = "EHIPagerWaypoint"
                })
            end
            self.__ehi_pager_has_run = true
        end
    end)

    Hooks:PreHook(IntimitateInteractionExt, "interact", "EHI_pager_interact", function(self, ...)
        if self.tweak_data == "corpse_alarm_pager" then
            managers.ehi_tracking:Remove(self._ehi_key)
        end
    end)

    Hooks:PostHook(IntimitateInteractionExt, "_at_interact_start", "EHI_pager_at_interact_start", function(self, ...)
        if self.tweak_data == "corpse_alarm_pager" then
            if answered_behavior == 1 then
                managers.ehi_tracking:Call(self._ehi_key, "SetAnswered")
            else
                managers.ehi_tracking:Remove(self._ehi_key)
            end
        end
    end)

    Hooks:PreHook(IntimitateInteractionExt, "sync_interacted", "EHI_pager_sync_interacted", function(self, peer, player, status, ...) ---@param status string|number
        if self.tweak_data == "corpse_alarm_pager" then
            if status == "started" or status == 1 then
                if answered_behavior == 1 then
                    managers.ehi_tracking:Call(self._ehi_key, "SetAnswered")
                else
                    managers.ehi_tracking:Remove(self._ehi_key)
                end
            else -- complete or interrupted
                managers.ehi_tracking:Remove(self._ehi_key)
            end
        end
    end)

    EHI:AddOnAlarmCallback(function()
        EHI:Unhook("pager_init")
        EHI:Unhook("pager_set_tweak_data")
        EHI:Unhook("pager_interact")
        EHI:Unhook("pager_at_interact_start")
        EHI:Unhook("pager_sync_interacted")
    end)
end

if EHI:GetOption("show_enemy_count_tracker") and EHI:GetOption("show_enemy_count_show_pagers") then
    local Tracker = "EnemyCount"
    local CallbackKey = "EHI_" .. Tracker
    ---@param unit UnitEnemy
    local function PagerEnemyKilled(unit)
        managers.ehi_tracker:CallFunction(Tracker, "AlarmEnemyPagerKilled")
        unit:base():remove_destroy_listener(CallbackKey)
    end
    ---@param unit UnitEnemy
    local function PagerEnemyDestroyed(unit)
        managers.ehi_tracker:CallFunction(Tracker, "AlarmEnemyPagerKilled")
        unit:character_damage():remove_listener(CallbackKey)
    end
    Hooks:PostHook(IntimitateInteractionExt, "_at_interact_start", "EHI_EnemyCounter_pager_at_interact_start", function(self, ...)
        if self.tweak_data == "corpse_alarm_pager" and not self._unit:character_damage():dead() then
            managers.ehi_tracker:CallFunction(Tracker, "AlarmEnemyPagerAnswered")
            self._unit:base():add_destroy_listener(CallbackKey, PagerEnemyDestroyed)
            self._unit:character_damage():add_listener(CallbackKey, { "death" }, PagerEnemyKilled)
        end
    end)
    Hooks:PreHook(IntimitateInteractionExt, "sync_interacted", "EHI_EnemyCounter_pager_sync_interacted", function(self, peer, player, status, ...)
        if self.tweak_data == "corpse_alarm_pager" and (status == "started" or status == 1) and not self._unit:character_damage():dead() then
            managers.ehi_tracker:CallFunction(Tracker, "AlarmEnemyPagerAnswered")
            self._unit:base():add_destroy_listener(CallbackKey, PagerEnemyDestroyed)
            self._unit:character_damage():add_listener(CallbackKey, { "death" }, PagerEnemyKilled)
        end
    end)
    EHI:AddOnAlarmCallback(function()
        EHI:Unhook("EnemyCounter_pager_at_interact_start")
        EHI:Unhook("EnemyCounter_pager_sync_interacted")
    end)
end

do
    local equipment = {}
    local format_function
    if EHI:GetOption("show_use_left_ammo_bag") then
        equipment.ammo_bag = true
        Hooks:PostHook(AmmoBagInteractionExt, "_add_string_macros", "EHI_ammo_add_string_macros", function(self, macros, ...)
            local charges = math.ehi_round(self._unit:base():GetRealAmount(), 0.01)
            macros.EHI_USE_LEFT = format_function(charges)
        end)
    end
    if EHI:GetOption("show_use_left_doctor_bag") then
        equipment.doctor_bag = true
        Hooks:PostHook(DoctorBagBaseInteractionExt, "_add_string_macros", "EHI_doctor_add_string_macros", function(self, macros, ...)
            if self.tweak_data == "first_aid_kit" then
                macros.EHI_USE_LEFT = ""
            else
                local charges = self._unit:base():GetRealAmount()
                macros.EHI_USE_LEFT = format_function(charges)
            end
        end)
    end
    if EHI:GetOption("show_use_left_bodybags_bag") then
        equipment.bodybags_bag = true
        Hooks:PostHook(BodyBagsBagInteractionExt, "_add_string_macros", "EHI_bodybags_add_string_macros", function(self, macros, ...)
            local charges = self._unit:base():GetRealAmount()
            macros.EHI_USE_LEFT = format_function(charges)
        end)
    end
    if EHI:GetOption("show_use_left_grenades") then
        local grenade_case = Idstring("units/payday2/equipment/gen_equipment_grenade_crate/gen_equipment_explosives_case")
        local grenade_case_mcshay = Idstring("units/pd2_dlc_mxm/equipment/gen_equipment_grenade_crate/gen_equipment_grenade_crate")
        equipment.grenade_crate = true
        Hooks:PostHook(GrenadeCrateInteractionExt, "_add_string_macros", "EHI_grenades_add_string_macros", function(self, macros, ...)
            local name = self._unit:name()
            if name == grenade_case or name == grenade_case_mcshay then
                local charges = self._unit:base():GetRealAmount()
                macros.EHI_USE_LEFT = format_function(charges)
            else
                macros.EHI_USE_LEFT = ""
            end
        end)
    end
    if next(equipment) then
        EHI:AddOnLocalizationLoaded(function(loc, lang_name)
            for key, _ in pairs(equipment) do
                local tweak = tweak_data.interaction[key]
                if tweak and tweak.text_id then
                    local text = loc:text(tweak.text_id, { BTN_INTERACT = "$BTN_INTERACT" })
                    LocalizationManager._custom_localizations[tweak.text_id] = string.format("%s\n%s", text, "$EHI_USE_LEFT")
                end
            end
            equipment = nil
            format_function = tweak_data.ehi:GetLanguageFormat(lang_name).equipment()
        end)
    else
        equipment = nil
        format_function = nil
    end
end

if EHI:GetOption("show_colored_bag_contour") then
    -- Get maximum and minimum speed multiplier defined CarryTweakData for each defined type
    -- There won't be 0 multiplier as that means 0 move speed, basically stuck in the same spot
    -- Don't check 'being' type, it uses a different color
    local min_range, max_range, delta_range = math.huge, -math.huge, 0
    for key, data in pairs(tweak_data.carry.types) do
        if key ~= "being" then
            min_range = math.min(min_range, data.move_speed_modifier)
            max_range = math.max(max_range, data.move_speed_modifier)
        end
    end
    delta_range = max_range - min_range
    local bag_color = {} ---@type table<string, Vector3>
    local light = EHI:GetVectorFromOption("bag_contour", "light")
    local heavy = EHI:GetVectorFromOption("bag_contour", "heavy")
    for key, data in pairs(tweak_data.carry.types) do
        if key ~= "being" then
            bag_color[key] = math.lerp(light, heavy, (max_range - data.move_speed_modifier) / delta_range) -- Range is ratio
        end
    end
    bag_color.being = EHI:GetVectorFromOption("bag_contour", "body")
    bag_color.default = tweak_data.contour.interactable.standard_color or Vector3(1, 0.5, 0)
    local ids_contour_color = Idstring("contour_color")
    local ids_contour_opacity = Idstring("contour_opacity")
    ---@param opacity number?
    ---@param from_ehi boolean?
    function UseInteractionExt:set_contour(color, opacity, from_ehi)
        if self._tweak_data.no_contour or self._contour_override then
            return
        elseif from_ehi then
            for _, m in ipairs(self._materials) do
                m:set_variable(ids_contour_color, color and bag_color[color] or bag_color.default)
                m:set_variable(ids_contour_opacity, opacity or self._active and 1 or 0)
            end
        else
            UseInteractionExt.super.set_contour(self, color, opacity)
        end
    end
    function UseInteractionExt:set_active(...)
        UseInteractionExt.super.set_active(self, ...)
        if self:disabled() or not self._active or self._tweak_data.contour_preset or not self._unit:carry_data() then
            return
        end
        self._unit:carry_data():SetCustomContour()
    end
    local original = UseInteractionExt.unselect
    function UseInteractionExt:unselect(...)
        original(self, ...)
        if self._unit:carry_data() then
            self._unit:carry_data():SetCustomContour()
        end
    end
end

if not EHI:GetTrackerOption("show_equipment_tracker") then
    return
end

local all = EHI:GetOption("show_equipment_aggregate_all")

local function pre_set_active(self, ...)
    self.__ehi_active = self._active
end

local function post_set_active(self, ...)
    if self.__ehi_active ~= self._active then
        local amount_check = self._unit:base().GetRealAmount and self._unit:base():GetRealAmount() > 0
        if self._active then -- Active
            if amount_check and (not self._ehi_load_check or self._ehi_load_check()) then -- The unit is active now, load it from cache and show it on screen
                managers.ehi_deployable:LoadFromCache(self._ehi_tracker_id, self._ehi_key)
            end
        elseif amount_check then -- Not active; There is some amount left in the unit, let's cache it
            managers.ehi_deployable:AddToCache(self._ehi_tracker_id, self._ehi_key, self._unit, self._ehi_unit_check and self._ehi_unit)
        end
        self.__ehi_active = self._active
    end
end

local function destroy(self, ...)
    managers.ehi_deployable:RemoveFromCache(self._ehi_key)
end

if EHI:GetOption("show_equipment_ammobag") then
    AmmoBagInteractionExt._ehi_tracker_id = all and "Deployables" or "AmmoBags"
    AmmoBagInteractionExt._ehi_unit = "ammo_bag"
    AmmoBagInteractionExt._ehi_unit_check = all
    Hooks:PreHook(AmmoBagInteractionExt, "init", "EHI_AmmoBagInteractionExt_init", function(self, unit, ...)
        self._ehi_key = unit:base()._ehi_key
    end)
    EHI:PreHookAndHook(AmmoBagInteractionExt, "set_active", pre_set_active, post_set_active)
    Hooks:PostHook(AmmoBagInteractionExt, "destroy", "EHI_AmmoBagInteractionExt_destroy", destroy)
end

if EHI:GetOption("show_equipment_bodybags") then
    BodyBagsBagInteractionExt._ehi_tracker_id = all and "Deployables" or "BodyBags"
    BodyBagsBagInteractionExt._ehi_unit = "bodybags_bag"
    BodyBagsBagInteractionExt._ehi_load_check = function()
        return managers.groupai:state():whisper_mode()
    end
    BodyBagsBagInteractionExt._ehi_unit_check = all
    Hooks:PreHook(BodyBagsBagInteractionExt, "init", "EHI_BodyBagsBagInteractionExt_init", function(self, unit, ...)
        self._ehi_key = unit:base()._ehi_key
    end)
    EHI:PreHookAndHook(BodyBagsBagInteractionExt, "set_active", pre_set_active, post_set_active)
    Hooks:PostHook(BodyBagsBagInteractionExt, "destroy", "EHI_BodyBagsBagInteractionExt_destroy", destroy)
end

if EHI:GetOption("show_equipment_doctorbag") or EHI:GetOption("show_equipment_firstaidkit") then
    local aggregate = EHI:GetOption("show_equipment_aggregate_health")
    DoctorBagBaseInteractionExt._ehi_unit_check = aggregate or all
    Hooks:PreHook(DoctorBagBaseInteractionExt, "init", "EHI_DoctorBagBaseInteractionExt_init", function(self, unit, ...)
        self._ehi_key = unit:base()._ehi_key
        if all then
            self._ehi_tracker_id = "Deployables"
        elseif aggregate then
            self._ehi_tracker_id = "Health"
        elseif self.tweak_data == "first_aid_kit" then
            self._ehi_tracker_id = "FirstAidKits"
        else
            self._ehi_tracker_id = "DoctorBags"
        end
        self._ehi_unit = self.tweak_data == "first_aid_kit" and "first_aid_kit" or "doctor_bag"
    end)
    EHI:PreHookAndHook(DoctorBagBaseInteractionExt, "set_active", pre_set_active, post_set_active)
    Hooks:PostHook(DoctorBagBaseInteractionExt, "destroy", "EHI_DoctorBagBaseInteractionExt_destroy", destroy)
end