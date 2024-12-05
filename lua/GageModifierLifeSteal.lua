if EHI:CheckLoadHook("GageModifierLifeSteal") or not EHI:GetBuffDeckOption("gage_boosts", "life_steal") then
    return
end

tweak_data.ehi.buff.GageModifierLifeSteal =
{
    bad = true,
    texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
    texture_rect = tweak_data.hud_icons.csb_lifesteal.texture_rect
}

local original = GageModifierLifeSteal.OnPlayerManagerKillshot
function GageModifierLifeSteal:OnPlayerManagerKillshot(...)
    original(self, ...)
    if not self._ehi_last_killshot_t or self._ehi_last_killshot_t ~= self._last_killshot_t then
        self._ehi_last_killshot_t = self._last_killshot_t
        managers.ehi_buff:AddBuff("GageModifierLifeSteal", self:value("cooldown"))
    end
end