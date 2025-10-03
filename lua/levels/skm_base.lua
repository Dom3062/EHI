local EHI = EHI
EHI:AddOnSpawnedCallback(function()
    if EHI:IsPlayingFromStart() then
        managers.ehi_assault:StartAssaultCountdown(15 + math.rand(5), true)
    end
end)