if not EHI:GetOption("show_difficulty_tracker") then
    return
end

if EHI._hooks.ElementDifficulty then -- Don't hook multiple times, pls
    return
else
    EHI._hooks.ElementDifficulty = true
end

if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

local level_tweak = tweak_data.levels[Global.game_settings.level_id]
if level_tweak and level_tweak.ai_group_type and level_tweak.ai_group_type == "skirmish" then
    return
end

local id = "Difficulty"

local function Trigger(value)
    local diff = EHI:RoundChanceNumber(value)
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
function ElementDifficulty:on_executed(...)
    _f_on_executed(self, ...)
    if not self._values.enabled then
        return
    end
    Trigger(self._values.difficulty)
end