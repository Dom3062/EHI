if not EHI:GetOption("show_difficulty_tracker") then
    return
end

local function Trigger(value)
    if managers.hud and managers.hud.ehi then
        managers.hud.ehi:SetChance("Difficulty", EHI:RoundNumber(value, 0.01) * 100)
    else
        EHI._cache.Difficulty = value
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
    Trigger(self._values.difficulty)
end