---@class EHIHealthFloatRect
EHIHealthFloatRect = {}
EHIHealthFloatRect._unit_name =
{
    civilian = "Civilian",
    civilian_female = "Civilian",
    civilian_mariachi = "Mariachi",
    captain = "Captain",
    civilian_no_penalty = "Civilian",
    gangster = "Gangster",
    triad = "Triad",
    biker = "Biker",
    biker_escape = "Biker",
    bolivian_indoors = "Security",
    bolivian_indoors_mex = "Security",
    bolivian = "Thug",
    mobster = "Mobster",
    security = "Security",
    security_undominatable = "Security",
    mute_security_undominatable = "Security",
    security_mex = "Security",
    security_mex_no_pager = "Security",
    gensec = "GenSec",
    cop = "Cop",
    cop_female 	= "Cop",
    cop_scared 	= "Cop",
    fbi = "FBI",
    fbi_female = "FBI",
    swat = "SWAT",
    heavy_swat = "Heavy SWAT",
    fbi_swat = "FBI SWAT",
    fbi_heavy_swat 	= "FBI Heavy SWAT",
    heavy_swat_sniper = "Heavy SWAT Sniper",
    city_swat = "City SWAT",
    shield = "Shield",
    spooc = "Cloaker",
    shadow_spooc = "Ark Guardian",
    taser = "Taser",
    sniper = "Sniper",
    medic = "Medic",
    tank = "Bulldozer",
    tank_hw = "Headlessdozer",
    tank_medic = "Medicdozer",
    tank_mini = "Minigundozer",
    phalanx_minion = "Winters' Shield",
    phalanx_vip = "Captain Winters",
    swat_van_turret_module = "Turret",
    ceiling_turret_module = "Turret",
    ceiling_turret_module_no_idle = "Turret",
    ceiling_turret_module_longer_range = "Turret",
    aa_turret_module = "Turret",
    crate_turret_module = "Turret",
    sentry_gun = "Sentry Gun",
    mobster_boss = "Boss",
    chavez_boss = "Boss",
    drug_lord_boss = "Boss",
    drug_lord_boss_stealth = "Boss",
    biker_boss = "Boss",
    bank_manager = "Bank Manager",
    inside_man = "Inside Man",
    escort_undercover 	= "Escort",
    escort_chinese_prisoner = "Escort",
    escort_cfo 	= "Escort",
    drunk_pilot = "Drunk Pilot",
    boris = "Boris",
    spa_vip = "Charon",
    spa_vip_hurt = "Charon",
    escort_criminal = "Vlad",
    old_hoxton_mission 	= "Old Hoxton",
    hector_boss = "Hector",
    hector_boss_no_armor = "Hector",
    triad_boss = "Yufu Wang",
    triad_boss_no_armor = "Yufu Wang",
    ranchmanager = "Ranch Manager",
    marshal_marksman = "Marshal Sniper",
    marshal_shield 	= "Marshal Shield",
    marshal_shield_break = "Marshal",
    zeal_heavy_swat = "Heavy ZEAL SWAT",
    zeal_swat = "ZEAL SWAT",
    butler = "Butler",
    vlad = "Vlad"
}
if Global.game_settings.level_id == "pbr" then
    EHIHealthFloatRect._unit_name.old_hoxton_mission = "Locke"
elseif Global.game_settings.level_id == "dah" then
    EHIHealthFloatRect._unit_name.bank_manager = "Ralph"
elseif Global.game_settings.level_id == "rvd1" then
    EHIHealthFloatRect._unit_name.civilian = "Cop"
    EHIHealthFloatRect._unit_name.old_hoxton_mission = "Mr. Blonde"
    EHIHealthFloatRect._unit_name.escort = "Mr. Pink"
elseif Global.game_settings.level_id == "rvd2" then
    if EHI.IsHost then
        EHIHealthFloatRect._unit_name.civilian = "Cabot Crew" -- Applies to both Mr. Pink and Mr. Blonde as they use same ID
    else
        EHIHealthFloatRect._unit_name.civilian = "Mr. Blonde"
        EHIHealthFloatRect._unit_name.robbers_safehouse = "Mr. Pink" -- Husk unit
    end
    EHIHealthFloatRect._unit_name.old_hoxton_mission = "Mr. Blonde"
elseif Global.game_settings.level_id == "bph" then
    EHIHealthFloatRect._unit_name.drunk_pilot = "Escort"
    EHIHealthFloatRect._unit_name.robbers_safehouse = "Kento"
elseif Global.game_settings.level_id == "bex" then
    EHIHealthFloatRect._unit_name.drunk_pilot = "IT Guy"
end
EHIHealthFloatRect._converts_disabled = not EHI:GetOption("show_floating_health_bar_converts") -- Team AI shares the same slot mask (16) with converts, workaround
EHIHealthFloatRect._civilians_disabled = not EHI:GetOption("show_floating_health_bar_civilians") -- Tied civilians share the same slot mask (22) with tied cops, workaround
EHIHealthFloatRect._team_ai_disabled = not EHI:GetOption("show_floating_health_bar_team_ai") -- Converts share the same slot mask (16) with Team AI, workaround
EHIHealthFloatRect._regular_disabled = not EHI:GetOption("show_floating_health_bar_regular_enemies")
EHIHealthFloatRect._special_tank_disabled = not EHI:GetOption("show_floating_health_bar_special_enemies_tank")
EHIHealthFloatRect._special_shield_disabled = not EHI:GetOption("show_floating_health_bar_special_enemies_shield")
EHIHealthFloatRect._special_taser_disabled = not EHI:GetOption("show_floating_health_bar_special_enemies_taser")
EHIHealthFloatRect._special_cloaker_disabled = not EHI:GetOption("show_floating_health_bar_special_enemies_cloaker")
EHIHealthFloatRect._special_sniper_disabled = not EHI:GetOption("show_floating_health_bar_special_enemies_sniper")
EHIHealthFloatRect._special_medic_disabled = not EHI:GetOption("show_floating_health_bar_special_enemies_medic")
EHIHealthFloatRect._special_other_disabled = not EHI:GetOption("show_floating_health_bar_special_enemies_other")
EHIHealthFloatRect._special_turret_disabled = not EHI:GetOption("show_floating_health_bar_special_enemies_turret")
---@param hud_panel Panel
function EHIHealthFloatRect:new(hud_panel)
    self._current_health = 0
    self._health_text_rect = { 2 , 18 , 232 , 11 } --Green Bar
    --self._shield_text_rect = { 2 , 34 , 232 , 11 } --Blue Bar
    --self._bar_text_rect = self._health_text_rect
    self._shield = false

    local unit_health_main = hud_panel:panel({
        name = "unit_health_main",
        halign = "grow",
        valign = "grow"
    })

    self._unit_health_panel = unit_health_main:panel({
        name = "unit_health_panel",
        visible = false
    })

    self._unit_bar = self._unit_health_panel:bitmap({
        name = "unit_health",
        texture = "guis/textures/pd2/healthshield",
        texture_rect = self._health_text_rect,
        blend_mode = "normal"
    })

    self._unit_bar_bg = self._unit_health_panel:bitmap({
        name = "unit_shield",
        texture = "guis/textures/pd2/healthshield",
        texture_rect = { 1, 1, 234, 13 },
        blend_mode = "normal"
    })

    self._unit_health_text = self._unit_health_panel:text({
        name = "unit_health_text",
        text = "250000/250000",
        blend_mode = "normal",
        alpha = 1,
        halign = "right",
        font = tweak_data.hud.medium_font,
        font_size = 20,
        color = Color.white,
        align = "center",
        layer = 1
    })

    self._unit_health_enemy_text = self._unit_health_panel:text({
        name = "unit_health_enemy_text",
        text = "SWAT VAN TURRET",
        blend_mode = "normal",
        alpha = 1,
        halign = "left",
        font = tweak_data.hud.medium_font,
        font_size = 22,
        color = Color.white,
        align = "center",
        layer = 1
    })

    local _ ,_ , hw, hh = self._unit_health_text:text_rect()
    local _ ,_ , ew, eh = self._unit_health_enemy_text:text_rect()

    self._unit_health_text:set_size(hw, hh)
    self._unit_health_enemy_text:set_size(ew, eh)

    self._unit_bar:set_w(self._unit_bar:w() - 2)

    self._unit_bar:set_center(self._unit_health_panel:center_x(), self._unit_health_panel:center_y() - 190)
    self._unit_bar_bg:set_center(self._unit_health_panel:center_x(), self._unit_health_panel:center_y() - 190)

    self._unit_health_text:set_right(self._unit_bar_bg:right())
    self._unit_health_text:set_bottom(self._unit_bar_bg:top())

    self._unit_health_enemy_text:set_left(self._unit_bar_bg:left())
    self._unit_health_enemy_text:set_bottom(self._unit_bar_bg:top())
    for _, criminal in ipairs(tweak_data.criminals.character_names) do
        self._unit_name[criminal] = managers.localization:text(string.format("menu_%s", criminal))
    end
    return self
end

---@param unit UnitEnemy|UnitEnemyTurret
---@param t number
function EHIHealthFloatRect:SetUnit(unit, t)
    if self._unit == unit then
        self._t = t
        return
    end
    self._t = t
    self._unit = unit
    self._block_update = false
    self._current_health = 0
    local base = unit:base() ---@cast base -SentryGunBase
    if self._converts_disabled and (unit:brain() and unit:brain().converted and unit:brain():converted()) then
        self._block_update = true
        self:set_visible(false)
        return
    elseif self._civilians_disabled and managers.enemy:is_civilian(unit) then
        self._block_update = true
        self:set_visible(false)
        return
    elseif self._team_ai_disabled and managers.groupai:state():is_unit_team_AI(unit) then
        self._block_update = true
        self:set_visible(false)
        return
    elseif base then
        if base.has_tag then
            if base:has_tag("special") then
                if base:has_tag("tank") then
                    if self._special_tank_disabled then
                        self._block_update = true
                        self:set_visible(false)
                        return
                    end
                elseif base:has_tag("shield") then
                    if self._special_shield_disabled then
                        self._block_update = true
                        self:set_visible(false)
                        return
                    end
                elseif base:has_tag("taser") then
                    if self._special_taser_disabled then
                        self._block_update = true
                        self:set_visible(false)
                        return
                    end
                elseif base:has_tag("spook") then
                    if self._special_cloaker_disabled then
                        self._block_update = true
                        self:set_visible(false)
                        return
                    end
                elseif base:has_tag("sniper") then
                    if self._special_sniper_disabled then
                        self._block_update = true
                        self:set_visible(false)
                        return
                    end
                elseif base:has_tag("medic") then
                    if self._special_medic_disabled then
                        self._block_update = true
                        self:set_visible(false)
                        return
                    end
                elseif self._special_other_disabled then
                    if self._special_tank_disabled then
                        self._block_update = true
                        self:set_visible(false)
                        return
                    end
                end
            elseif self._regular_disabled then
                self._block_update = true
                self:set_visible(false)
                return
            end
        elseif base.get_type and base:get_type() == "swat_turret" and self._special_turret_disabled then ---@diagnostic disable-line
            self._block_update = true
            self:set_visible(false)
            return
        end
    end
    local name = base and base._tweak_table_id or base._tweak_table
    name = name and self._unit_name[name] or name or "Enemy"
    self._unit_health_enemy_text:set_text(name)
    local _ ,_ , ew, eh = self._unit_health_enemy_text:text_rect()
    self._unit_health_enemy_text:set_size(ew, eh)
    self._unit_health_enemy_text:set_left(self._unit_bar_bg:left())
    self._unit_health_enemy_text:set_bottom(self._unit_bar_bg:top())
end

---@param t number
function EHIHealthFloatRect:Update(t)
    if self._block_update or not self._unit then
        return
    elseif t - self._t > 0.5 or not alive(self._unit) then
        self._unit = nil
        self:set_visible(false)
        return
    end
    local unit = self._unit
    local current_health = math.max(unit:character_damage()._health * 10, 0)
    if self._current_health == current_health then
        return
    end
    self._current_health = current_health
    local ratio = unit:character_damage():health_ratio()
    local r = self._unit_bar:w()
    local rn = (self._unit_bar_bg:w() - 4) * ratio
    local total = (unit:character_damage()._HEALTH_INIT or 0) * 10

    if total > 0 then
        self._unit_health_text:set_text(string.format("%s/%s", managers.experience:experience_string(current_health), managers.experience:experience_string(total)))
    else
        self._unit_health_text:set_text(string.format("%s", managers.experience:experience_string(current_health)))
    end

    local _ ,_ , hw, hh = self._unit_health_text:text_rect()

    self._unit_health_text:set_size(hw, hh)

    self._unit_health_text:set_right(self._unit_bar_bg:right())
    self._unit_health_text:set_bottom(self._unit_bar_bg:top())

    self._unit_health_text:set_color(ratio <= 0.1 and Color.red or ratio <= 0.25 and Color.yellow or Color.white)

    self._unit_bar:stop()

    --self._bar_text_rect = self._shield and self._shield_text_rect or self._health_text_rect

    self:set_visible(ratio > 0)
    self._unit_bar:animate(self._anim_set_width, self._health_text_rect, ratio, rn, r)
end

function EHIHealthFloatRect:UpdateLast()
    self._unit = nil
    self:set_visible(false)
end

---@param visible boolean
function EHIHealthFloatRect:set_visible(visible)
    if visible and not self._unit_health_visible then
        self._unit_health_visible = true
        self._unit_health_panel:stop()
        self._unit_health_panel:animate(self._anim_visible)
    elseif visible == false and self._unit_health_visible then
        self._unit_health_visible = false
        self._unit_health_panel:stop()
        self._unit_health_panel:animate(self._anim_hidden)
    end
end

---@param o Panel
function EHIHealthFloatRect._anim_visible(o)
    o:set_visible(true)
    over(0.25, function(lerp, t)
        o:set_alpha(math.lerp(o:alpha(), 1, lerp))
    end)
end

---@param o Panel
function EHIHealthFloatRect._anim_hidden(o)
    if o:alpha() >= 0.9 then
        wait(0.5)
    end
    over(1.5, function(lerp, t)
        o:set_alpha(math.lerp(o:alpha(), 0, lerp))
    end)
    o:set_visible(false)
end

---@param o Bitmap
---@param bar_text_rect number[]
---@param ratio number
---@param rn number
---@param r number
function EHIHealthFloatRect._anim_set_width(o, bar_text_rect, ratio, rn, r)
    if rn < r then
        over(0.2, function(lerp, t)
            local new_lerp = math.lerp(r, rn, lerp)
            o:set_w(new_lerp)
            o:set_texture_rect(bar_text_rect[1], bar_text_rect[2], new_lerp, bar_text_rect[4])
        end)
    end
    o:set_w(ratio * (bar_text_rect[3] - 2))
    o:set_texture_rect(bar_text_rect[1], bar_text_rect[2], bar_text_rect[3] * ratio, bar_text_rect[4])
end

---@param custody_state boolean
function EHIHealthFloatRect:SetInCustody(custody_state)
    self._block_update = custody_state
    if custody_state then
        self:set_visible(false)
    end
end