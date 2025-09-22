local EHI = EHI
EHI:ShowLootCounter({ max = 18 }, { element = { EHI:GetInstanceElementID(100010, 1500), EHI:GetInstanceElementID(100010, 1750) } })
local door = {}
for i = 0, 1250, 250 do
    door[EHI:GetInstanceUnitID(100001, i)] = EHI:GetInstanceElementID(100006, i)
end
EHI:SetMissionDoorData(door)