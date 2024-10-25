local EHI = EHI
local old = MenuNodeMainGui._setup_item_rows
function MenuNodeMainGui:_setup_item_rows(...)
    old(self, ...)
    if EHI._cache.SaveFileCorrupted then -- Should always show, because it is important
        QuickMenu:new(
            managers.localization:text("ehi_save_data_corrupted"),
            managers.localization:text("ehi_save_data_corrupted_desc"),
            {
                {
                    text = managers.localization:text("ehi_button_ok"),
                    is_cancel_button = true
                }
            },
            true
        )
        EHI._cache.SaveFileCorrupted = nil
    end
    if EHI._cache.GameVersionNotCompatible then
        QuickMenu:new(
            managers.localization:text("ehi_wrong_game_version"),
            managers.localization:text("ehi_wrong_game_version_desc"),
            {
                {
                    text = managers.localization:text("ehi_button_ok"),
                    is_cancel_button = true
                }
            },
            true
        )
        EHI._cache.GameVersionNotCompatible = nil
        if EHI.ModInstance then
            EHI.ModInstance:SetEnabled(false, true)
        end
    end
end