if EHI:CheckLoadHook("GageModifierLifeSteal") or not EHI:GetBuffDeckAndOption("gage_boosts", "life_steal") then
    return
end

tweak_data.ehi.buff.GageModifierLifeSteal =
{
    group = "cooldown",
    texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
    texture_rect = tweak_data.hud_icons.csb_lifesteal.texture_rect,
    permanent =
    {
        deck_option =
        {
            deck = "gage_boosts",
            option = "life_steal_persistent"
        },
        show_on_trigger = true
    }
}

local original = GageModifierLifeSteal.OnPlayerManagerKillshot
function GageModifierLifeSteal:OnPlayerManagerKillshot(...)
    original(self, ...)
    if self._ehi_last_killshot_t ~= self._last_killshot_t then
        self._ehi_last_killshot_t = self._last_killshot_t
        managers.ehi_buff:AddBuff("GageModifierLifeSteal", self:value("cooldown"))
    end
end