---@alias EHITextFloatManager.Float { class: EHITextFloat, state: "onscreen"|"offscreen", position: Vector3, name_key: string, peer_id: integer }

local EHI = EHI
if EHI:CheckLoadHook("EHITextFloatManager") then
    return
end

---@class EHITextFloatManager
EHITextFloatManager = {}
function EHITextFloatManager:new()
    self._floats = {} ---@type table<userdata, EHITextFloatManager.Float?>
    self._deferred_floats = {} ---@type table<userdata, { unit: UnitAmmoDeployable|UnitGrenadeDeployable|UnitFAKDeployable, peer_id: integer }>
    self._unit_blocked = {} ---@type table<userdata, boolean>
    self._n_of_equipment = 0
    self._distance = EHI:GetOption("show_floating_text_distance") * 100
    self._angle = EHI:GetOption("show_floating_text_angle")
    Hooks:PreHook(PlayerMovement, "pre_destroy", "EHI_PlayerMovement_EHITextFloatManager_pre_destroy", function(...)
        self:_remove_update_loop(true)
        self._player_camera = nil
        for _, float in pairs(self._floats) do
            float.class:Hide()
            float.state = "offscreen"
        end
    end)
    Hooks:PostHook(PlayerCamera, "init", "EHI_PlayerCamera_EHITextFloatManager_init", function(base, ...)
        self._player_camera = base._camera_object
        self:_add_update_loop()
    end)
    ---@param unit UnitAmmoDeployable|UnitGrenadeDeployable|UnitFAKDeployable
    local function init_equipment(_, unit)
        local key = unit:key()
        if not (self._floats[key] or self._unit_blocked[key]) then
            if not self._panel then
                self._deferred_floats[key] = { unit = unit, peer_id = 0 }
                return
            end
            self:_add_float(key, unit)
        end
    end
    ---@param equipment AmmoBagBase|GrenadeCrateBase|FirstAidKitBase
    ---@param peer_id integer?
    local function server_update_peer_information(equipment, peer_id, ...)
        local key = equipment._unit:key()
        local id = peer_id or 0
        if self._deferred_floats[key] then
            self._deferred_floats[key].peer_id = id
        elseif self._floats[key] then
            self._floats[key].class:UpdatePeerColor(tweak_data.chat_colors[id] or Color.white)
        end
    end
    ---@param equipment AmmoBagBase|GrenadeCrateBase|FirstAidKitBase
    ---@param peer_id integer?
    local function client_update_peer_information(equipment, _, peer_id, ...)
        server_update_peer_information(equipment, peer_id)
    end
    ---@param peer_id integer?
    local function from_spawn_update_peer_information(_, _, _, peer_id, ...)
        local unit = Hooks:GetReturn()
        if unit then
            server_update_peer_information(unit:base(), peer_id)
        end
    end
    ---@param equipment AmmoBagBase|GrenadeCrateBase|FirstAidKitBase
    local function set_visual_stage_equipment(equipment, ...)
        local float = self._floats[equipment._unit:key()]
        if float then
            float.class:UpdateAmount(equipment)
        end
    end
    ---@param equipment AmmoBagInteractionExt|GrenadeCrateInteractionExt
    local function set_alpha(equipment, ...)
        local float = self._floats[equipment._unit:key()]
        if float then
            if equipment._active then
                float.class:SetUnitActive()
            else
                float.class:SetUnitNotActive()
            end
        end
    end
    ---@param equipment AmmoBagBase|GrenadeCrateBase|FirstAidKitBase
    local function destroy_equipment(equipment, ...)
        local float = table.remove_key(self._floats, equipment._unit:key())
        if float then
            self:_remove_float(float)
            self:_remove_update_loop()
        end
    end
    if EHI:GetOption("show_floating_text_ammo_bag") then
        Hooks:PostHook(AmmoBagBase, "spawn", "EHI_AmmoBagBase_EHITextFloatManager_spawn", from_spawn_update_peer_information)
        Hooks:PreHook(AmmoBagBase, "init", "EHI_AmmoBagBase_EHITextFloatManager_init", init_equipment)
        Hooks:PostHook(AmmoBagBase, "set_server_information", "EHI_AmmoBagBase_EHITextFloatManager_set_server_information", server_update_peer_information)
        Hooks:PostHook(AmmoBagBase, "sync_setup", "EHI_AmmoBagBase_EHITextFloatManager_sync_setup", client_update_peer_information)
        Hooks:PostHook(AmmoBagBase, "_set_visual_stage", "EHI_AmmoBagBase_EHITextFloatManager__set_visual_stage", set_visual_stage_equipment)
        Hooks:PreHook(AmmoBagBase, "_set_empty", "EHI_AmmoBagBase_EHITextFloatManager__set_empty", destroy_equipment)
        Hooks:PostHook(AmmoBagBase, "destroy", "EHI_AmmoBagBase_EHITextFloatManager_destroy", destroy_equipment)
        Hooks:PostHook(CustomAmmoBagBase, "_set_empty", "EHI_CustomAmmoBagBase_EHITextFloatManager__set_empty", destroy_equipment)
        Hooks:PostHook(AmmoBagInteractionExt, "set_active", "EHI_AmmoBagInteractionExt_EHITextFloatManager_set_active", set_alpha)
    end
    if EHI:GetOption("show_floating_text_bodybags_bag") and tweak_data.levels:IsStealthAvailable() then
        Hooks:PostHook(BodyBagsBagBase, "spawn", "EHI_BodyBagsBagBase_EHITextFloatManager_spawn", from_spawn_update_peer_information)
        Hooks:PostHook(BodyBagsBagBase, "init", "EHI_BodyBagsBagBase_EHITextFloatManager_init", init_equipment)
        Hooks:PostHook(BodyBagsBagBase, "set_server_information", "EHI_BodyBagsBagBase_EHITextFloatManager_set_server_information", server_update_peer_information)
        Hooks:PostHook(BodyBagsBagBase, "sync_setup", "EHI_BodyBagsBagBase_EHITextFloatManager_sync_setup", client_update_peer_information)
        Hooks:PostHook(BodyBagsBagBase, "_set_visual_stage", "EHI_BodyBagsBagBase_EHITextFloatManager__set_visual_stage", set_visual_stage_equipment)
        Hooks:PreHook(BodyBagsBagBase, "_set_empty", "EHI_BodyBagsBagBase_EHITextFloatManager__set_empty", destroy_equipment)
        Hooks:PostHook(BodyBagsBagBase, "destroy", "EHI_BodyBagsBagBase_EHITextFloatManager_destroy", destroy_equipment)
        Hooks:PostHook(BodyBagsBagInteractionExt, "set_active", "EHI_BodyBagsBagInteractionExt_EHITextFloatManager_set_active", set_alpha)
        EHI:AddOnAlarmCallback(function(dropin)
            Hooks:RemovePostHook("EHI_BodyBagsBagBase_EHITextFloatManager_spawn")
            Hooks:RemovePostHook("EHI_BodyBagsBagBase_EHITextFloatManager_init")
            Hooks:RemovePostHook("EHI_BodyBagsBagBase_EHITextFloatManager_set_server_information")
            Hooks:RemovePostHook("EHI_BodyBagsBagBase_EHITextFloatManager_sync_setup")
            Hooks:RemovePostHook("EHI_BodyBagsBagBase_EHITextFloatManager__set_visual_stage")
            Hooks:RemovePreHook("EHI_BodyBagsBagBase_EHITextFloatManager__set_empty")
            Hooks:RemovePostHook("EHI_BodyBagsBagBase_EHITextFloatManager_destroy")
            Hooks:RemovePostHook("EHI_BodyBagsBagInteractionExt_EHITextFloatManager_set_active")
            for key, data in pairs(self._floats) do
                if data.name_key == "a163786a6ddb0291" then
                    self:_remove_float(data)
                    self._floats[key] = nil
                end
            end
            self:_remove_update_loop()
        end)
    end
    if EHI:GetOption("show_floating_text_doctor_bag") then
        Hooks:PostHook(DoctorBagBase, "spawn", "EHI_DoctorBagBase_EHITextFloatManager_spawn", from_spawn_update_peer_information)
        Hooks:PreHook(DoctorBagBase, "init", "EHI_DoctorBagBase_EHITextFloatManager_init", init_equipment)
        Hooks:PostHook(DoctorBagBase, "set_server_information", "EHI_DoctorBagBase_EHITextFloatManager_set_server_information", server_update_peer_information)
        Hooks:PostHook(DoctorBagBase, "sync_setup", "EHI_DoctorBagBase_EHITextFloatManager_sync_setup", client_update_peer_information)
        Hooks:PostHook(DoctorBagBase, "_set_visual_stage", "EHI_DoctorBagBase_EHITextFloatManager__set_visual_stage", set_visual_stage_equipment)
        Hooks:PreHook(DoctorBagBase, "_set_empty", "EHI_DoctorBagBase_EHITextFloatManager__set_empty", destroy_equipment)
        Hooks:PostHook(DoctorBagBase, "destroy", "EHI_DoctorBagBase_EHITextFloatManager_destroy", destroy_equipment)
        Hooks:PostHook(CustomDoctorBagBase, "_set_empty", "EHI_CustomDoctorBagBase_EHITextFloatManager__set_empty", destroy_equipment)
        Hooks:PostHook(DoctorBagBaseInteractionExt, "set_active", "EHI_DoctorBagBaseInteractionExt_EHITextFloatManager_set_active", set_alpha)
    end
    if EHI:GetOption("show_floating_text_first_aid_kit") then
        Hooks:PostHook(FirstAidKitBase, "spawn", "EHI_FirstAidKitBase_EHITextFloatManager_spawn", from_spawn_update_peer_information)
        Hooks:PostHook(FirstAidKitBase, "init", "EHI_FirstAidKitBase_EHITextFloatManager_init", init_equipment)
        Hooks:PostHook(FirstAidKitBase, "set_server_information", "EHI_FirstAidKitBase_EHITextFloatManager_set_server_information", server_update_peer_information)
        Hooks:PostHook(FirstAidKitBase, "sync_setup", "EHI_FirstAidKitBase_EHITextFloatManager_sync_setup", client_update_peer_information)
        Hooks:PostHook(FirstAidKitBase, "setup", "EHI_FirstAidKitBase_EHITextFloatManager_setup", set_visual_stage_equipment)
        Hooks:PreHook(FirstAidKitBase, "_set_empty", "EHI_FirstAidKitBase_EHITextFloatManager__set_empty", destroy_equipment)
        Hooks:PostHook(FirstAidKitBase, "destroy", "EHI_FirstAidKitBase_EHITextFloatManager_destroy", destroy_equipment)
        Hooks:PostHook(DoctorBagBaseInteractionExt, "set_active", "EHI_DoctorBagBaseInteractionExt_EHITextFloatManager_set_active", set_alpha)
    end
    if EHI:GetOption("show_floating_text_throwables") then
        -- init calls _set_visual_stage, needs to be prehooked to work correctly
        Hooks:PreHook(GrenadeCrateBase, "init", "EHI_GrenadeCrateBase_EHITextFloatManager_init", init_equipment)
        Hooks:PostHook(GrenadeCrateBase, "_set_visual_stage", "EHI_GrenadeCrateBase_EHITextFloatManager__set_visual_stage", set_visual_stage_equipment)
        Hooks:PreHook(GrenadeCrateBase, "_set_empty", "EHI_GrenadeCrateBase_EHITextFloatManager__set_empty", destroy_equipment)
        Hooks:PostHook(GrenadeCrateBase, "destroy", "EHI_GrenadeCrateBase_EHITextFloatManager_destroy", destroy_equipment)
        Hooks:PreHook(CustomGrenadeCrateBase, "init", "EHI_CustomGrenadeCrateBase_EHITextFloatManager_init", init_equipment)
        Hooks:PostHook(CustomGrenadeCrateBase, "_set_empty", "EHI_CustomGrenadeCrateBase_EHITextFloatManager__set_empty", destroy_equipment)
        Hooks:PostHook(GrenadeCrateDeployableBase, "set_server_information", "EHI_GrenadeCrateDeployableBase_EHITextFloatManager_set_server_information", server_update_peer_information)
        Hooks:PreHook(GrenadeCrateDeployableBase, "_set_empty", "EHI_CustomGrenadeCrateDeployableBase_EHITextFloatManager__set_empty", destroy_equipment)
        if EHI:GetOption("show_floating_text_throwables_block_on_abilities_or_no_throwable") then
            EHI.PlayerUtils:AddGrenadeDoesNotAllowPickupsCallback(function()
                Hooks:RemovePreHook("EHI_GrenadeCrateBase_EHITextFloatManager_init")
                Hooks:RemovePostHook("EHI_GrenadeCrateBase_EHITextFloatManager__set_visual_stage")
                Hooks:RemovePreHook("EHI_GrenadeCrateBase_EHITextFloatManager__set_empty")
                Hooks:RemovePostHook("EHI_GrenadeCrateBase_EHITextFloatManager_destroy")
                Hooks:RemovePreHook("EHI_CustomGrenadeCrateBase_EHITextFloatManager_init")
                Hooks:RemovePostHook("EHI_CustomGrenadeCrateBase_EHITextFloatManager__set_empty")
                Hooks:RemovePostHook("EHI_GrenadeCrateDeployableBase_EHITextFloatManager_set_server_information")
                Hooks:RemovePreHook("EHI_CustomGrenadeCrateDeployableBase_EHITextFloatManager__set_empty")
                for key, data in pairs(self._floats) do
                    if data.name_key == "f6001ca4eb64a74c" or data.name_key == "e166f63494083d58" or data.name_key == "02a3ade37a633a71" or data.name_key == "fc520601b50186e4" then
                        self:_remove_float(data)
                        self._floats[key] = nil
                    end
                end
                self:_remove_update_loop()
            end)
        end
    end
    EHI.ModUtils:AddCustomNameColorSyncCallback(function(peer_id, color)
        for _, float in pairs(self._floats) do
            if float.peer_id == peer_id then
                float.class:UpdatePeerColor(color)
            end
        end
    end)
end

---@param panel Panel
---@param saferect Workspace
function EHITextFloatManager:init_hud(panel, saferect)
    self._panel = panel
    self._saferect = saferect
    EHITextFloat._panel = panel
    for key, def in pairs(self._deferred_floats) do
        self:_add_float(key, def.unit, true, def.peer_id)
    end
    self._deferred_floats = {}
end

---@param unit Unit
function EHITextFloatManager:IgnoreDeployable(unit)
    local key = unit:key()
    self._unit_blocked[key] = true
    self._deferred_floats[key] = nil
    if self._floats[key] then
        self:_remove_float(self._floats[key])
        self._floats[key] = nil
    end
    self:_remove_update_loop()
end

function EHITextFloatManager:_add_update_loop()
    if self._player_camera and self._n_of_equipment > 0 and not self._update_added then
        self._update_added = true
        managers.hud:AddEHIUpdator("EHI_FloatText_Update", self)
    end
end

---@param force_remove boolean?
function EHITextFloatManager:_remove_update_loop(force_remove)
    if force_remove or (self._n_of_equipment <= 0 and self._update_added) then
        self._update_added = nil
        managers.hud:RemoveEHIUpdator("EHI_FloatText_Update")
    end
end

---@param key userdata
---@param unit UnitAmmoDeployable|UnitGrenadeDeployable|UnitFAKDeployable
---@param from_defer boolean?
---@param peer_id integer?
function EHITextFloatManager:_add_float(key, unit, from_defer, peer_id)
    self._floats[key] = {
        class = EHITextFloat:new(unit, from_defer, peer_id),
        state = "offscreen",
        position = unit:position(),
        name_key = unit:name():key(),
        peer_id = peer_id or 0
    }
    self._n_of_equipment = self._n_of_equipment + 1
    self:_add_update_loop()
end

---@param float EHITextFloatManager.Float
function EHITextFloatManager:_remove_float(float)
    float.class:destroy()
    self._n_of_equipment = self._n_of_equipment - 1
end

local cam_pos = Vector3()
local wp_pos = Vector3()
local wp_dir = Vector3()
local nl_dir = Vector3()
---@param t number
---@param dt number
function EHITextFloatManager:update(t, dt)
    self._player_camera:m_position(cam_pos)
    local nl_cam_forward = self._player_camera:rotation():y()

    local panel = self._panel

    for _, data in pairs(self._floats) do
        mvector3.set(wp_pos, self._saferect:world_to_screen(self._player_camera, data.position))
        mvector3.set(wp_dir, data.position)
        mvector3.subtract(wp_dir, cam_pos)
        mvector3.set(nl_dir, wp_dir)
        mvector3.normalize(nl_dir)

        local dot = mvector3.dot(nl_cam_forward, nl_dir)
        local angle = math.acos(dot)
        local x, y = mvector3.x(wp_pos), mvector3.y(wp_pos)
        if angle > self._angle or panel:outside(x, y) or wp_dir:length() > self._distance then
            if data.state ~= "offscreen" then
                data.state = "offscreen"
                data.class:Offscreen()
            end
        else
            if data.state == "offscreen" then
                data.state = "onscreen"
                data.class:Onscreen()
            end
            data.class:SetCenter(x, y)
        end
    end
end

---@class EHITextFloat
---@field new fun(self: self, unit: UnitAmmoDeployable|UnitGrenadeDeployable|UnitFAKDeployable, from_defer: boolean?, peer_id: integer?): self
EHITextFloat = class()
EHITextFloat._SETTINGS =
{
    icon_alpha = EHI:GetOption("show_floating_text_icon") and 1 or 0,
    -- 1 = multiplier; 2 = percent
    format = EHI:GetOption("show_floating_text_format") --[[@as 1|2]],
    compact_mode = EHI:GetOption("show_floating_text_compact_mode"),
    color_peer_equipment = EHI:GetOption("show_floating_text_color_peer_equipment"),
    percent_format = "",
    short_percent_format = ""
}
EHITextFloat._EQUIPMENT =
{
    ["8f59e19e1e45a05e"] =
    {
        name = "Ammo Bag",
        texture = "guis/textures/pd2/skilltree/icons_atlas",
        texture_rect = { 64, 0, 64, 64 },
        multiplier_format = "%.2fx",
        check_upgrades_f = function(base) ---@param base AmmoBagBase
            if base._bullet_storm_level then
                if base._bullet_storm_level == 1 then
                    return "Bullet+"
                elseif base._bullet_storm_level == 2 then
                    return "Bullet++"
                end
            end
            return ""
        end
    },
    ["43ed278b1faf89b3"] =
    {
        name = "Doctor Bag",
        texture = "guis/textures/pd2/skilltree/icons_atlas",
        texture_rect = { 128, 448, 64, 64 },
        check_upgrades_f = function(base) ---@param base DoctorBagBase
            if base._damage_reduction_upgrade then
                return "Dmg-"
            end
            return ""
        end
    },
    a163786a6ddb0291 =
    {
        name = "Bodybags Bag",
        texture = "guis/textures/pd2/skilltree/icons_atlas",
        texture_rect = { 320, 704, 64, 64 }
    },
    e1474cdfd02aa274 =
    {
        name = "First Aid Kit",
        texture = "guis/textures/pd2/skilltree/icons_atlas",
        texture_rect = { 192, 640, 64, 64 },
        check_upgrades_f = function(base) ---@param base FirstAidKitBase
            local str = ""
            if base._damage_reduction_upgrade then
                str = "Dmg-"
            end
            if base._min_distance then
                if str == "" then
                    str = "Up^"
                else
                    str = str .. " Up^"
                end
            end
            return str
        end,
        no_amount = true
    },
    f6001ca4eb64a74c =
    {
        name = "Grenade Case",
        texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/preplan_icon_types",
        texture_rect = { 48, 0, 48, 48 }
    },
    default =
    {
        name = "?",
        force_console_report = true
    }
}
---units/payday2/props/stn_prop_medic_firstaid_box/stn_prop_medic_firstaid_box
EHITextFloat._EQUIPMENT["269c288629a7ebc7"] = deep_clone(EHITextFloat._EQUIPMENT["43ed278b1faf89b3"])
EHITextFloat._EQUIPMENT["269c288629a7ebc7"].name = "First Aid Kit Box"
EHITextFloat._EQUIPMENT["269c288629a7ebc7"].check_upgrades_f = nil
---units/payday2/props/stn_prop_armory_shelf_ammo/stn_prop_armory_shelf_ammo
EHITextFloat._EQUIPMENT.dad3d39f10a58fbd = deep_clone(EHITextFloat._EQUIPMENT["8f59e19e1e45a05e"])
EHITextFloat._EQUIPMENT.dad3d39f10a58fbd.name = "Ammo Shelf"
EHITextFloat._EQUIPMENT.dad3d39f10a58fbd.check_upgrades_f = nil
---units/pd2_dlc_spa/props/spa_prop_armory_shelf_ammo/spa_prop_armory_shelf_ammo
EHITextFloat._EQUIPMENT["150ebbf1166515e9"] = EHITextFloat._EQUIPMENT.dad3d39f10a58fbd
---units/pd2_dlc_hvh/props/hvh_prop_armory_shelf_ammo/hvh_prop_armory_shelf_ammo
EHITextFloat._EQUIPMENT["4f480c9809095026"] = EHITextFloat._EQUIPMENT.dad3d39f10a58fbd
---units/payday2/equipment/gen_equipment_grenade_crate/gen_equipment_explosives_case_single
EHITextFloat._EQUIPMENT["02a3ade37a633a71"] = deep_clone(EHITextFloat._EQUIPMENT.f6001ca4eb64a74c)
EHITextFloat._EQUIPMENT["02a3ade37a633a71"].name = "Grenade Crate"
EHITextFloat._EQUIPMENT["02a3ade37a633a71"].no_amount = true
---units/pd2_dlc_spa/equipment/spa_equipment_grenade_crate/spa_equipment_grenade_crate
EHITextFloat._EQUIPMENT.fc520601b50186e4 = EHITextFloat._EQUIPMENT.f6001ca4eb64a74c
---units/pd2_dlc_mxm/equipment/gen_equipment_grenade_crate/gen_equipment_grenade_crate
EHITextFloat._EQUIPMENT.e166f63494083d58 = deep_clone(EHITextFloat._EQUIPMENT.f6001ca4eb64a74c)
EHITextFloat._EQUIPMENT.e166f63494083d58.name = "Ordnance Bag"
---@param unit UnitAmmoDeployable|UnitGrenadeDeployable|UnitFAKDeployable
---@param from_defer boolean?
---@param peer_id integer?
function EHITextFloat:init(unit, from_defer, peer_id)
    local name_key = unit:name():key()
    local eq_data = self._EQUIPMENT[name_key] or self._EQUIPMENT.default
    local text
    if eq_data.force_console_report then
        local editor_id = unit:editor_id()
        if editor_id <= 0 then
            call_on_next_update(function()
                self:_report_in_console(unit:editor_id(), name_key)
            end)
        else
            self:_report_in_console(editor_id, name_key)
        end
    end
    if self._SETTINGS.compact_mode then
        if self._SETTINGS.format == 1 then
            text = "?x"
        else
            text = "?" .. self._SETTINGS.short_percent_format
        end
    elseif eq_data.no_amount then
        text = eq_data.name
    elseif self._SETTINGS.format == 1 then
        text = string.format("%s ?x", eq_data.name)
    else
        text = string.format("%s ?" .. self._SETTINGS.short_percent_format, eq_data.name)
    end
    self._amount = self._panel:text({
        text = text,
        vertical = "center",
        h = 16,
        w = 128,
        align = "center",
        rotation = 360,
        layer = 0,
        color = Color.white,
        font = tweak_data.menu.pd2_large_font,
        font_size = tweak_data.hud.default_font_size / 2.5,
        blend_mode = "normal",
        visible = false
    })
    local texture, texture_rect
    if eq_data.texture then
        texture = eq_data.texture
        texture_rect = eq_data.texture_rect
    else
        local default_icon = tweak_data.ehi.icons.default
        texture, texture_rect = tweak_data.hud_icons:get_icon_or(eq_data.icon or "pd2_question", default_icon.texture, default_icon.texture_rect)
    end
    self._icon = self._panel:bitmap({
        layer = 0,
        rotation = 360,
        texture = texture,
        texture_rect = texture_rect,
        w = 16,
        h = 16,
        blend_mode = "normal",
        alpha = self._SETTINGS.icon_alpha,
        visible = false
    })
    if self._SETTINGS.color_peer_equipment then
        self._icon:set_color(tweak_data.chat_colors[peer_id or 0] or Color.white)
    end
    self._eq_data = eq_data
    if from_defer then
        self:UpdateAmount(unit:base())
        if not unit:interaction():active() then
            self:SetUnitNotActive()
        end
    end
end

---@param editor_id integer
---@param name_key string
function EHITextFloat:_report_in_console(editor_id, name_key)
    EHI:Log("[EHIFloatText] Missing equipment data! name_key: " .. tostring(name_key))
    EHI:Log("[EHIFloatText] editor_id: " .. tostring(editor_id))
    if editor_id < 100000 then
        EHI:Log("[EHIFloatText] editor_id is still 0")
        EHI:Log("[EHIFloatText] level_id: " .. tostring(Global.game_settings.level_id))
        EHI:Log("[EHIFloatText] ----------separator----------")
        return
    end
    if editor_id >= 130000 then
        for _, data in ipairs(managers.world_instance:instance_data()) do
            local start_index = EHI:GetInstanceElementID(100000, data.start_index)
            local end_index = start_index + data.index_size - 1
            if math.within(editor_id, start_index, end_index) then
                EHI:Log("[EHIFloatText] instance: " .. tostring(data.name))
                EHI:Log("[EHIFloatText] folder: " .. tostring(data.folder))
                EHI:Log("[EHIFloatText] start_index: " .. tostring(data.start_index))
                EHI:Log("[EHIFloatText] base editor id: " .. tostring(editor_id - 30000 - data.start_index))
                break
            end
        end
    else
        EHI:Log("[EHIFloatText] level_id: " .. tostring(Global.game_settings.level_id))
    end
    EHI:Log("[EHIFloatText] ----------separator----------")
end

---@param equipment AmmoBagBase|GrenadeCrateBase|FirstAidKitBase
function EHITextFloat:UpdateAmount(equipment)
    local eq_data = self._eq_data
    if not eq_data.no_amount then
        local amount = equipment:GetRealAmount()
        local text
        if self._SETTINGS.compact_mode then
            if self._SETTINGS.format == 1 then
                text = string.format("%s", string.format(eq_data.multiplier_format or "%dx", amount))
            else
                text = string.format("%s", string.format(self._SETTINGS.percent_format, amount * 100))
            end
        elseif self._SETTINGS.format == 1 then
            text = string.format("%s: %s", eq_data.name, string.format(eq_data.multiplier_format or "%dx", amount))
        else
            text = string.format("%s: %s", eq_data.name, string.format(self._SETTINGS.percent_format, amount * 100))
        end
        if eq_data.check_upgrades_f then ---@cast equipment -GrenadeCrateBase
            local upgrades = eq_data.check_upgrades_f(equipment)
            if upgrades ~= "" then
                text = string.format("%s %s", text, upgrades)
            end
        end
        self._amount:set_text(text)
    elseif eq_data.check_upgrades_f then ---@cast equipment -GrenadeCrateBase
        local upgrades = eq_data.check_upgrades_f(equipment)
        if upgrades ~= "" then
            if self._SETTINGS.compact_mode then
                self._amount:set_text(string.format("%s", upgrades))
            else
                self._amount:set_text(string.format("%s: %s", eq_data.name, upgrades))
            end
        elseif self._SETTINGS.compact_mode then
            if self._SETTINGS.format == 1 then
                self._amount:set_text("1x")
            else
                self._amount:set_text(string.format(self._SETTINGS.percent_format, 100))
            end
        elseif self._SETTINGS.format == 1 then
            self._amount:set_text(string.format("%s: %s", eq_data.name, string.format(eq_data.multiplier_format or "%dx", 1)))
        else
            self._amount:set_text(string.format("%s: %s", eq_data.name, string.format(self._SETTINGS.percent_format, 100)))
        end
    elseif self._SETTINGS.compact_mode then
        if self._SETTINGS.format == 1 then
            self._amount:set_text("1x")
        else
            self._amount:set_text(string.format(self._SETTINGS.percent_format, 100))
        end
    elseif self._SETTINGS.format == 1 then
        self._amount:set_text(string.format("%s: %s", eq_data.name, string.format(eq_data.multiplier_format or "%dx", 1)))
    else
        self._amount:set_text(string.format("%s: %s", eq_data.name, string.format(self._SETTINGS.percent_format, 100)))
    end
end

function EHITextFloat:SetUnitNotActive()
    self._amount:set_alpha(0)
    self._icon:set_alpha(0)
end

function EHITextFloat:SetUnitActive()
    self._amount:set_alpha(1)
    self._icon:set_alpha(self._SETTINGS.icon_alpha)
end

function EHITextFloat:Hide()
    if alive(self._amount) then
        self._amount:hide()
    end
    if alive(self._icon) then
        self._icon:hide()
    end
end

function EHITextFloat:Offscreen()
    self._amount:hide()
    self._icon:hide()
end

function EHITextFloat:Onscreen()
    self._amount:show()
    self._icon:show()
end

if EHITextFloat._SETTINGS.compact_mode then
    if EHITextFloat._SETTINGS.icon_alpha == 0 then -- Icon is not visible
        ---@param x number
        ---@param y number
        function EHITextFloat:SetCenter(x, y)
            self._amount:set_center(x, y)
        end
    else
        ---@param x number
        ---@param y number
        function EHITextFloat:SetCenter(x, y)
            self._icon:set_center(x - 16, y)
            self._amount:set_center(self._icon:x() + 28, y)
        end
    end
else
    ---@param x number
    ---@param y number
    function EHITextFloat:SetCenter(x, y)
        self._amount:set_center(x, y)
        self._icon:set_center(x, y - 16)
    end
end

if EHITextFloat._SETTINGS.color_peer_equipment then
    ---@param color Color
    function EHITextFloat:UpdatePeerColor(color)
        self._icon:set_color(color)
    end
else
    ---@param color Color
    function EHITextFloat:UpdatePeerColor(color)
    end
end

function EHITextFloat:destroy()
    if alive(self._amount) then
        self._panel:remove(self._amount)
    end
    if alive(self._icon) then
        self._panel:remove(self._icon)
    end
end

EHI:AddOnLocalizationLoaded(function(loc, lang_name)
    local percent_format = tweak_data.ehi:GetLanguageFormat(lang_name).percent_format()
    EHITextFloat._SETTINGS.short_percent_format = percent_format
    EHITextFloat._SETTINGS.percent_format = "%d" .. percent_format
end)