function EHI:PaintingCount()
    --[[local paintings = managers.ehi:GetUnits("units/payday2/architecture/com_int_gallery/com_int_gallery_wall_painting_bars", 1)
    local n_of_paintings = 0
    -- 3878622f45bc7dfe => Idstring("g_important") without ID and @ at the end
    for _, painting in pairs(paintings) do
        if painting:damage()._state and painting:damage()._state.object and painting:damage()._state.object["3878622f45bc7dfe"] then
            local state = painting:damage()._state.object["3878622f45bc7dfe"].set_visibility
            -- Object at index 1 is our Idstring "3878622f45bc7dfe", no need to check that again
            -- This check is a bit different than in function EHI:LordOfWar(), because objects are going through "self:set_cat_state2()" in CoreSequenceManager.lua
            if state and state[2] then
                n_of_paintings = n_of_paintings + 1
            end
        end
    end]]
    self:ShowLootCounter(9)
    self:ShowAchievementLootCounter({
        achievement = "pink_panther",
        max = 9
    })
end

--[[local SF = EHI.SpecialFunctions
local triggers = {
    [100789] = { special_function = SF.CustomCode, f = function()
        EHI:PaintingCount()
    end}
}

EHI:ParseTriggers(triggers)]]
EHI:ShowLootCounter(9)
EHI:ShowAchievementLootCounter({
    achievement = "pink_panther",
    max = 9,
    exclude_from_sync = true,
    remove_after_reaching_target = false
})
EHI:AddOnAlarmCallback(function()
    managers.ehi:SetAchievementFailed("pink_panther")
end)