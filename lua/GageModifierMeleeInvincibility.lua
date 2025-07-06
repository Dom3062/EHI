if EHI:CheckLoadHook("GageModifierMeleeInvincibility") or not EHI:GetBuffDeckAndOption("gage_boosts", "melee_invulnerability") then
    return
end

tweak_data.ehi.buff.GageModifierMeleeInvincibility =
{
    texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
    texture_rect = tweak_data.hud_icons.csb_melee.texture_rect,
    permanent =
    {
        deck_option =
        {
            deck = "gage_boosts",
            option = "melee_invulnerability_persistent"
        },
        show_on_trigger = true
    }
}

local original = GageModifierMeleeInvincibility.OnPlayerManagerKillshot
function GageModifierMeleeInvincibility:OnPlayerManagerKillshot(player_unit, unit_tweak, variant, ...)
    original(self, player_unit, unit_tweak, variant, ...)
    if variant == "melee" and table.contains(StatisticsManager.special_unit_ids, unit_tweak) then
        managers.ehi_buff:AddBuff("GageModifierMeleeInvincibility", self:value())
    end
end