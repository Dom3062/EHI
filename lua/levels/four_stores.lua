local function LootSafeIsVisible()
    local unit = managers.worlddefinition:get_unit(101153)
    if not unit then
        return false
    end
    if not unit:damage() then
        return false
    end
    if unit:damage()._state then
        local group = unit:damage()._state.graphic_group
        return not group.safe -- If the "safe" group does not exist, the safe is visible
    else
        return false
    end
end

local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local van_anim_delay = 320 / 30
local assault_delay = 0
local triggers = { -- Time before escape vehicle arrives
    [101890] = { special_function = SF.CustomCodeDelayed, t = 4, f = function()
        if LootSafeIsVisible() then
            EHI:ShowLootCounter({ max = 1 })
        end
    end},
    [102492] = { time = 40 + van_anim_delay },
    [102493] = { time = 30 + van_anim_delay },
    [102494] = { time = 20 + van_anim_delay },
    [102495] = { time = 50 + van_anim_delay },
    [102496] = { time = 60 + van_anim_delay },
    [102497] = { time = 70 + van_anim_delay },
    [102498] = { time = 100 + van_anim_delay },
    [102499] = { time = 90 + van_anim_delay },
    [102511] = { time = 80 + van_anim_delay },
    [102512] = { time = 110 + van_anim_delay },
    [102513] = { time = 120 + van_anim_delay },
    [102526] = { time = 130 + van_anim_delay },
    [103592] = { time = 160 + van_anim_delay },
    [103593] = { time = 180 + van_anim_delay },
    [103594] = { time = 200 + van_anim_delay },

    [102505] = { id = 101006, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 101006 } },
    [103200] = { id = 103234, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 103234 } }
}
if EHI:GetOption("show_escape_chance") then
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi:AddEscapeChanceTracker(dropin, 30)
    end)
end

local other =
{
    [103501] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
}

EHI:ParseTriggers({ mission = triggers, other = other }, "Escape", Icon.CarEscape)
EHI:AddLoadSyncFunction(function(self)
    if LootSafeIsVisible() then
        EHI:ShowLootCounter({ max = 1 })
        self:SetTrackerProgress("LootCounter", managers.loot:GetSecuredBagsAmount())
    end
end)