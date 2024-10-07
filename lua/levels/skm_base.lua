local EHI = EHI
if EHI:IsClient() then
    return
end
EHI:AddOnSpawnedCallback(function()
    managers.ehi_assault:StartAssaultCountdown(15 + math.rand(5), true)
end)