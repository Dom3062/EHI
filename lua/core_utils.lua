if EHI.Utils then
    return
end
EHI.Utils = {}

---@param chances number
---@return number[]
function EHI.Utils:GetTableChance(chances)
    local tbl = {}
    for i = 1, chances, 1 do
        tbl[i] = math.ceil(100 / (chances - (i - 1)))
    end
    return tbl
end