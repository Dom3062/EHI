if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

local EHI = rawget(_G, "EHI")
if EHI._hooks.CoreMissionScriptElement_BaseDelay then -- Don't hook multiple times, pls
    return
else
    EHI._hooks.CoreMissionScriptElement_BaseDelay = true
end

core:module("CoreMissionScriptElement")

local level_id = Global.game_settings.level_id
local triggers = {}
local trigger_id_all = "Trigger"
local trigger_icon_all = nil
local SF = EHI.SpecialFunctions
local Icon = EHI:GetIcons()
local TT =
{
    Warning = "EHIWarningTracker"
}
local _cache = {}
if level_id == "pal" then -- Counterfeit
    local heli = { id = "HeliCageDelay", icons = { Icon.Heli, Icon.LootDrop, "faster" }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "HeliCage" }, class = TT.Warning }
    triggers = {
        [EHI:GetInstanceElementID(100013, 4700)] = heli,
        [EHI:GetInstanceElementID(100013, 4750)] = heli,
        [EHI:GetInstanceElementID(100013, 4800)] = heli,
        [EHI:GetInstanceElementID(100013, 4850)] = heli
    }
else
    return
end

if Network:is_server() then
    EHI:AddHostTriggers(triggers)
else
    EHI:SetSyncTriggers(triggers)
end

-- chew
-- ´pilot_on_his_way´ MissionScriptElement 100558
-- BASE DELAY 5-10

local _f_calc_base_delay = MissionScriptElement._calc_base_delay
function MissionScriptElement:_calc_base_delay()
    local delay = _f_calc_base_delay(self)
    if triggers[self._id] then
        EHI:AddTrackerAndSync(self._id, delay)
    end
    return delay
end