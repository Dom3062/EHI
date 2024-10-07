if EHI:CheckLoadHook("SkirmishTweakData") then
    return
end

function SkirmishTweakData:GetWaveData()
    for _, modifiers in pairs(self.wave_modifiers) do
        for _, modifier in ipairs(modifiers) do
            if modifier.data and modifier.data.waves then
                return modifier.data.waves
            end
        end
    end
    return {}
end