local EHI = EHI
if EHI:CheckLoadHook("EHITextFloatManager") then
    return
end

---@class EHITextFloatManager
EHITextFloatManager = {}
EHITextFloatManager._SETTINGS =
{
    icon_alpha = EHI:GetOption("show_floating_text_icon") and 1 or 0
}
EHITextFloatManager._equipment =
{
    ["8f59e19e1e45a05e"] =
    {
        name = "Ammo Bag",
        texture = "guis/textures/pd2/skilltree/icons_atlas",
        texture_rect = { 64, 0, 64, 64 },
        format = "%.2fx",
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
    e166f63494083d58 =
    {
        name = "Ordnance Bag",
        texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/preplan_icon_types",
        texture_rect = { 48, 0, 48, 48 }
    },
    default =
    {
        name = "?"
    }
}
---@param panel Panel
---@param saferect Workspace
function EHITextFloatManager:new(panel, saferect)
    self._panel = panel
    self._saferect = saferect
    self._floats = {} ---@type table<userdata, { amount: Text, icon: Bitmap, state: string, position: Vector3, name_key: string }?>
    self._n_of_equipment = 0
    self._distance = EHI:GetOption("show_floating_text_distance") * 100
    Hooks:PreHook(PlayerMovement, "pre_destroy", "EHI_PlayerMovement_EHITextFloatManager_pre_destroy", function(...)
        self._spawned = nil
        self:RemoveUpdateLoop(true)
        for _, float in pairs(self._floats) do
            if alive(float.amount) then
                float.amount:hide()
            end
            if alive(float.icon) then
                float.icon:hide()
            end
            float.state = "offscreen"
        end
    end)
    Hooks:PostHook(PlayerMovement, "init", "EHI_PlayerMovement_EHITextFloatManager_init", function(...)
        self._spawned = true
        self:AddUpdateLoop()
    end)
    ---@param unit UnitAmmoDeployable|UnitGrenadeDeployable|UnitFAKDeployable
    local function init_equipment(_, unit)
        local key = unit:key()
        if not self._floats[key] then
            local name_key = unit:name():key()
            local eq_data = self._equipment[name_key] or self._equipment.default
            local text
            if eq_data.no_amount then
                text = eq_data.name
            else
                text = string.format("%s ?x", eq_data.name)
            end
            local amount = self._panel:text({
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
            local icon = self._panel:bitmap({
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
            self._floats[key] = {
                amount = amount,
                icon = icon,
                state = "offscreen",
                position = unit:position(),
                name_key = name_key
            }
            self._n_of_equipment = self._n_of_equipment + 1
            self:AddUpdateLoop()
        end
    end
    ---@param equipment AmmoBagBase|GrenadeCrateBase|FirstAidKitBase
    local function set_visual_stage_equipment(equipment, ...)
        local unit = equipment._unit
        local key = unit:key()
        local float = self._floats[key]
        if float then
            local eq_data = self._equipment[unit:name():key()] or self._equipment.default
            if not eq_data.no_amount then
                local amount = unit:base():GetRealAmount()
                local text = string.format("%s: %s", eq_data.name, string.format(eq_data.format or "%dx", amount))
                if eq_data.check_upgrades_f then ---@cast equipment -GrenadeCrateBase
                    local upgrades = eq_data.check_upgrades_f(equipment)
                    if upgrades ~= "" then
                        text = string.format("%s %s", text, upgrades)
                    end
                end
                float.amount:set_text(text)
            elseif eq_data.check_upgrades_f then ---@cast equipment -GrenadeCrateBase
                local upgrades = eq_data.check_upgrades_f(equipment)
                if upgrades ~= "" then
                    float.amount:set_text(string.format("%s: %s", eq_data.name, upgrades))
                end
            end
        end
    end
    ---@param equipment AmmoBagBase|GrenadeCrateBase|FirstAidKitBase
    local function destroy_equipment(equipment, ...)
        local key = equipment._unit:key()
        local float = table.remove_key(self._floats, key)
        if float then
            if alive(float.amount) then
                float.amount:parent():remove(float.amount)
            end
            if alive(float.icon) then
                float.icon:parent():remove(float.icon)
            end
            self._n_of_equipment = self._n_of_equipment - 1
            self:RemoveUpdateLoop()
        end
    end
    if EHI:GetOption("show_floating_text_ammo_bag") then
        Hooks:PostHook(AmmoBagBase, "init", "EHI_AmmoBagBase_EHITextFloatManager_init", init_equipment)
        Hooks:PostHook(AmmoBagBase, "_set_visual_stage", "EHI_AmmoBagBase_EHITextFloatManager__set_visual_stage", set_visual_stage_equipment)
        Hooks:PreHook(AmmoBagBase, "_set_empty", "EHI_AmmoBagBase_EHITextFloatManager__set_empty", destroy_equipment)
        Hooks:PostHook(AmmoBagBase, "destroy", "EHI_AmmoBagBase_EHITextFloatManager_destroy", destroy_equipment)
    end
    if EHI:GetOption("show_floating_text_bodybags_bag") then
        Hooks:PostHook(BodyBagsBagBase, "init", "EHI_BodyBagsBagBase_EHITextFloatManager_init", init_equipment)
        Hooks:PostHook(BodyBagsBagBase, "_set_visual_stage", "EHI_BodyBagsBagBase_EHITextFloatManager__set_visual_stage", set_visual_stage_equipment)
        Hooks:PreHook(BodyBagsBagBase, "_set_empty", "EHI_BodyBagsBagBase_EHITextFloatManager__set_empty", destroy_equipment)
        Hooks:PostHook(BodyBagsBagBase, "destroy", "EHI_BodyBagsBagBase_EHITextFloatManager_destroy", destroy_equipment)
    end
    if EHI:GetOption("show_floating_text_doctor_bag") then
        Hooks:PostHook(DoctorBagBase, "init", "EHI_DoctorBagBase_EHITextFloatManager_init", init_equipment)
        Hooks:PostHook(DoctorBagBase, "_set_visual_stage", "EHI_DoctorBagBase_EHITextFloatManager__set_visual_stage", set_visual_stage_equipment)
        Hooks:PreHook(DoctorBagBase, "_set_empty", "EHI_DoctorBagBase_EHITextFloatManager__set_empty", destroy_equipment)
        Hooks:PostHook(DoctorBagBase, "destroy", "EHI_DoctorBagBase_EHITextFloatManager_destroy", destroy_equipment)
    end
    if EHI:GetOption("show_floating_text_first_aid_kit") then
        Hooks:PostHook(FirstAidKitBase, "init", "EHI_FirstAidKitBase_EHITextFloatManager_init", init_equipment)
        Hooks:PostHook(FirstAidKitBase, "setup", "EHI_FirstAidKitBase_EHITextFloatManager_setup", set_visual_stage_equipment)
        Hooks:PreHook(FirstAidKitBase, "_set_empty", "EHI_FirstAidKitBase_EHITextFloatManager__set_empty", destroy_equipment)
        Hooks:PostHook(FirstAidKitBase, "destroy", "EHI_FirstAidKitBase_EHITextFloatManager_destroy", destroy_equipment)
    end
    if EHI:GetOption("show_floating_text_throwables") then
        -- init calls _set_visual_stage, needs to be prehooked to work correctly
        Hooks:PreHook(GrenadeCrateBase, "init", "EHI_GrenadeCrateBase_EHITextFloatManager_init", init_equipment)
        Hooks:PostHook(GrenadeCrateBase, "_set_visual_stage", "EHI_GrenadeCrateBase_EHITextFloatManager__set_visual_stage", set_visual_stage_equipment)
        Hooks:PreHook(GrenadeCrateBase, "_set_empty", "EHI_GrenadeCrateBase_EHITextFloatManager__set_empty", destroy_equipment)
        Hooks:PostHook(GrenadeCrateBase, "destroy", "EHI_GrenadeCrateBase_EHITextFloatManager_destroy", destroy_equipment)
        if EHI:GetOption("show_floating_text_throwables_block_on_abilities") then
            EHI.PlayerUtils:AddGrenadeDoesNotAllowPickupsCallback(function()
                Hooks:RemovePreHook("EHI_GrenadeCrateBase_EHITextFloatManager_init")
                Hooks:RemovePostHook("EHI_GrenadeCrateBase_EHITextFloatManager__set_visual_stage")
                Hooks:RemovePreHook("EHI_GrenadeCrateBase_EHITextFloatManager__set_empty")
                Hooks:RemovePostHook("EHI_GrenadeCrateBase_EHITextFloatManager_destroy")
                for key, data in pairs(self._floats) do
                    if data.name_key == "f6001ca4eb64a74c" or data.name_key == "e166f63494083d58" then
                        if alive(data.amount) then
                            data.amount:parent():remove(data.amount)
                        end
                        if alive(data.icon) then
                            data.icon:parent():remove(data.icon)
                        end
                        self._n_of_equipment = self._n_of_equipment - 1
                        self._floats[key] = nil
                    end
                end
                self:RemoveUpdateLoop()
            end)
        end
    end
end

function EHITextFloatManager:AddUpdateLoop()
    if self._spawned and self._n_of_equipment > 0 and not self._update_added then
        self._update_added = true
        managers.hud:AddEHIUpdator("EHI_FloatText_Update", self)
    end
end

---@param force_remove boolean?
function EHITextFloatManager:RemoveUpdateLoop(force_remove)
    if force_remove or (self._n_of_equipment <= 0 and self._update_added) then
        self._update_added = nil
        managers.hud:RemoveEHIUpdator("EHI_FloatText_Update")
    end
end

local wp_pos = Vector3()
local wp_dir = Vector3()
local wp_dir_normalized = Vector3()
local wp_cam_forward = Vector3()
---@param t number
---@param dt number
function EHITextFloatManager:update(t, dt)
    local cam = managers.viewport:get_current_camera()

    if not cam then
        return
    end

    local cam_pos = managers.viewport:get_current_camera_position()
    local cam_rot = managers.viewport:get_current_camera_rotation()

    mrotation.y(cam_rot, wp_cam_forward)

    local panel = self._panel

    for _, data in pairs(self._floats) do
        mvector3.set(wp_pos, self._saferect:world_to_screen(cam, data.position))
        mvector3.set(wp_dir, data.position)
        mvector3.subtract(wp_dir, cam_pos)
        mvector3.set(wp_dir_normalized, wp_dir)
        mvector3.normalize(wp_dir_normalized)

        local dot = mvector3.dot(wp_cam_forward, wp_dir_normalized)

        local x, y = mvector3.x(wp_pos), mvector3.y(wp_pos)
        if dot < 0 or panel:outside(x, y) or wp_dir:length() > self._distance then
            if data.state ~= "offscreen" then
                data.state = "offscreen"

                data.amount:hide()
                data.icon:hide()
            end
        else
            if data.state == "offscreen" then
                data.state = "onscreen"

                data.amount:show()
                data.icon:show()
            end

            data.amount:set_center(x, y)
            data.icon:set_center(x, y - 16)
        end
    end
end