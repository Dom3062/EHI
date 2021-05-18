if not EHI:GetOption("show_difficulty_tracker") then
    return
end

if EHI._hooks.ElementDifficulty then -- Don't hook multiple times, pls
    return
else
    EHI._hooks.ElementDifficulty = true
end

local id = "Difficulty"

--[[if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

if Global.game_settings.level_id == "chill" then
    return
end]]

local function Trigger(value)
    local diff = EHI:RoundNumber(value, 0.01) * 100
    if managers.ehi:TrackerExists(id) then
        managers.ehi:SetChance(id, diff)
    else
        managers.ehi:AddTracker({
            id = id,
            icons = { "enemy" },
            chance = diff,
            class = "EHIChanceTracker"
        })
    end
end

local _f_client_on_executed = ElementDifficulty.client_on_executed
function ElementDifficulty:client_on_executed(...)
    _f_client_on_executed(self, ...)
    Trigger(self._values.difficulty)
end

local _f_on_executed = ElementDifficulty.on_executed
function ElementDifficulty:on_executed(instigator)
    _f_on_executed(self, instigator)
    if not self._values.enabled then
        return
    end
    Trigger(self._values.difficulty)
end