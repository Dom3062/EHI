local EHI = EHI

local tbl =
{
    [101807] = { icons = { EHI.Icons.Wait } }
}
EHI:UpdateUnits(tbl)

EHI:ShowLootCounter({ max = 18 }, { element = { EHI:GetInstanceElementID(100007, 3250), EHI:GetInstanceElementID(100007, 3500) } }) -- Loot objective + 17 paintings