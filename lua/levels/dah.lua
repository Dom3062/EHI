local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local heli_delay = 26 + 6
local OVKorAbove = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local element_sync_triggers =
{
    [103569] = { time = 25, id = "CFOFall", icons = { Icon.Hostage, Icon.Goto }, hook_element = 100438, hint = Hints.Wait, --[[waypoint = { data_from_element_and_remove_vanilla_waypoint = 104393 }]] }
}
---@type ParseTriggerTable
local triggers = {
    [100276] = { time = 25 + 3 + 11, id = "CFOToChopper", icons = { Icon.Heli, Icon.Goto }, waypoint = { data_from_element_and_remove_vanilla_waypoint = 102822 }, hint = Hints.Wait },

    [104875] = { time = 45 + heli_delay, id = "HeliEscapeLoud", icons = Icon.HeliEscapeNoLoot, waypoint = { data_from_element = 100475, remove_vanilla_waypoint = 104882 }, hint = Hints.Escape },
    [103159] = { time = 30 + heli_delay, id = "HeliEscapeLoud", icons = Icon.HeliEscapeNoLoot, waypoint = { icon = Icon.Escape, position_from_element_and_remove_vanilla_waypoint = 103163 }, hint = Hints.Escape }
}
if EHI.Mission._SHOW_MISSION_TRIGGERS_TYPE.cheaty then
    ---@type EHI.ColorTable
    local dah_laptop_codes =
    {
        red = 1900,
        green = 2100,
        blue = 2300
    }
    triggers[103969] = { id = "ColorCodes", class = TT.ColoredCodes, remove_on_alarm = true, waypoint = { waypointless = true } }
    triggers[101652] = { id = "ColorCodes", special_function = SF.RemoveTracker } -- Vault opened
    EHI:HookColorCodes(dah_laptop_codes, { unit_id_all = 100052 })
    if EHI.IsClient then
        local codes = EHI.TrackerUtils:CacheColorCodesNumbers(dah_laptop_codes)
        local color_map = EHI.TrackerUtils:GetColorCodesMap()
        triggers[103969].load_sync = function(self) ---@param self EHIMissionElementTrigger
            if self.ConditionFunctions.IsStealth() then
                self:CreateTracking()
                local bg = Idstring("g_code_screen")
                for color, data in pairs(dah_laptop_codes) do
                    local unit_id = EHI:GetInstanceUnitID(100052, data)
                    local unit = managers.worlddefinition:get_unit(unit_id)
                    local code = EHI.TrackerUtils:CheckIfCodeIsVisible(codes, bg, unit, color)
                    if code then
                        self._tracking:SetColorCode(color, code, unit_id, color_map[color])
                    end
                end
            end
        end
    end
end

local other =
{
    [100479] = EHI:AddAssaultDelay({ control = 30 + 2 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[102694] = { chance = 20, recheck_t = 30, id = "SnipersBlackhawk", class = TT.Sniper.HeliTimedChance, trigger_once = true }
    other[102698] = { id = "SnipersBlackhawk", special_function = SF.IncreaseChanceFromElement } -- +10%
    other[102704] = { id = "SnipersBlackhawk", special_function = SF.SetChanceFromElement } -- 20%
    local SniperKilled = EHI.Trigger:RegisterCustomSF(function(self, trigger, ...)
        if self._trackers:CallFunction2(trigger.id, "SnipersKilled", 23 + 10) then
            self._trackers:AddTracker({
                id = trigger.id,
                time = 23 + 10,
                chance = 20,
                recheck_t = 30,
                no_logic_annoucement = true,
                class = TT.Sniper.HeliTimedChance
            })
        end
    end)
    for _, index in ipairs({ 6100, 7100, 17900, 18900 }) do
        other[EHI:GetInstanceElementID(100020, index)] = { id = "SnipersBlackhawk", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess", arg = { 25 } }
        other[EHI:GetInstanceElementID(100023, index)] = { id = "SnipersBlackhawk", special_function = SF.IncreaseCounter }
        other[EHI:GetInstanceElementID(100007, index)] = { id = "SnipersBlackhawk", special_function = SF.DecreaseCounter }
        other[EHI:GetInstanceElementID(100025, index)] = { id = "SnipersBlackhawk", special_function = SniperKilled }
    end
end

---@param progress number?
local function dah_8(progress)
    progress = progress or 0
    if progress >= 12 then
        return
    end
    EHI:ShowAchievementLootCounterNoCheck({
        achievement = "dah_8",
        progress = progress,
        max = 12,
        counter =
        {
            loot_type = "diamondheist_big_diamond"
        }
    })
end
---@type ParseAchievementTable
local achievements =
{
    dah_8 =
    {
        difficulty_pass = OVKorAbove,
        elements =
        {
            [103969] = { special_function = SF.CustomCode, f = dah_8 },
            [102259] = { special_function = SF.SetAchievementComplete },
            [102261] = { special_function = SF.IncreaseProgress }
        },
        failed_on_alarm = true,
        load_sync = function(self)
            if self.ConditionFunctions.IsStealth() then
                dah_8(managers.loot:GetSecuredBagsTypeAmount("diamondheist_big_diamond"))
            end
        end,
        cleanup_callback = function()
            dah_8 = nil ---@diagnostic disable-line
        end
    }
}

EHI.Mission:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other,
    sync_triggers = { element = element_sync_triggers }
})

EHI.Waypoint:DisableTimerWaypoints({
    [101368] = true -- Drill waypoint for vault with red diamond
})

EHI:ShowLootCounter({
    max = 8,
    triggers =
    {
        [101019] = EHI:AddCustomCode(function(self)
            self._loot:IncreaseLootCounterProgressMax()
        end) -- Red Diamond
    },
    load_sync = function(self)
        -- Red Diamond spawns on OVK or above only
        if OVKorAbove and managers.game_play_central:IsMissionUnitDisabled(100950) then -- Red Diamond
            self._loot:IncreaseLootCounterProgressMax()
        end
        self._loot:SyncSecuredLoot()
    end
}, { element = 102960 })
local loot, loot_all
if OVKorAbove then
    loot =
    {
        red_diamond = 2000,
        diamonds_dah = 400
    }
else
    loot_all = 400
end
local MinBags = EHI:GetValueBasedOnDifficulty({
    hard_or_below = 4,
    veryhard = 6,
    overkill_or_above = 8
})
local xp_override =
{
    params =
    {
        min_max =
        {
            loot =
            {
                red_diamond = { max = 1 },
                diamonds_dah = { min = MinBags, max = 8 }
            },
            loot_all = { min = MinBags, max = 8 }
        }
    }
}
EHI:AddXPBreakdown({
    plan =
    {
        stealth =
        {
            objectives =
            {
                { amount = 4000, name = "diamond_heist_boxes_hack" },
                { amount = 1000, name = "diamond_heist_found_color_codes" },
                { amount = 2000, name = "diamond_heist_found_keycard" },
                { escape = 2000 }
            },
            loot = loot,
            loot_all = loot_all,
            total_xp_override = xp_override
        },
        loud =
        {
            objectives =
            {
                { amount = 4000, name = "diamond_heist_boxes_hack" },
                { amount = 2000, name = "diamond_heist_found_keycard" },
                { amount = 4000, name = "diamond_heist_cfo_in_heli" },
                { amount = 4000, name = "vault_open" },
                { escape = 4000 }
            },
            loot = loot,
            loot_all = loot_all,
            total_xp_override = xp_override
        }
    }
})