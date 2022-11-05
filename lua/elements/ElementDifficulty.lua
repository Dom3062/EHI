local EHI = EHI
if EHI._hooks.ElementDifficulty then -- Don't hook multiple times, pls
    return
else
    EHI._hooks.ElementDifficulty = true
end

if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

if tweak_data.levels:get_group_ai_state() == "skirmish" then
    return
end

local function AssaultDelay(value)
    EHI._cache.diff = value
    managers.ehi:CallFunction("AssaultDelay", "UpdateDiff", value)
end

local Trigger
if EHI:GetOption("show_difficulty_tracker") then
    local id = "Difficulty"
    Trigger = function(value)
        local diff = EHI:RoundChanceNumber(value)
        if managers.ehi:TrackerExists(id) then
            managers.ehi:SetChance(id, diff)
        else
            managers.ehi:AddTracker({
                id = id,
                icons = { "enemy" },
                chance = diff,
                class = EHI.Trackers.Chance
            })
        end
    end
else
    Trigger = function(value) end
end

local _f_client_on_executed = ElementDifficulty.client_on_executed
function ElementDifficulty:client_on_executed(...)
    _f_client_on_executed(self, ...)
    Trigger(self._values.difficulty)
    AssaultDelay(self._values.difficulty)
end

local _f_on_executed = ElementDifficulty.on_executed
function ElementDifficulty:on_executed(...)
    _f_on_executed(self, ...)
    if not self._values.enabled then
        return
    end
    Trigger(self._values.difficulty)
    AssaultDelay(self._values.difficulty)
end