local EHI = EHI
if EHI:CheckLoadHook("ElementDifficulty") then
    return
end

if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

if tweak_data.levels:IsLevelSkirmish() then
    return
end

local original =
{
    client_on_executed = ElementDifficulty.client_on_executed,
    on_executed = ElementDifficulty.on_executed
}

local Trigger
if EHI:GetOption("show_difficulty_tracker") then
    local id = "Difficulty"
    Trigger = function(diff)
        if managers.ehi_tracker:CallFunction3(id, "SetChance", diff, EHITrackerManager.Rounding.Chance) then
            managers.ehi_tracker:AddTracker({
                id = id,
                icons = { "enemy" },
                chance = managers.ehi_tracker:RoundChanceNumber(diff),
                hint = "diff",
                class = EHI.Trackers.Chance
            })
        end
    end
else
    Trigger = function(value) end
end

local function Run(value)
    Trigger(value)
    managers.ehi_assault:SetDiff(value)
end

function ElementDifficulty:client_on_executed(...)
    original.client_on_executed(self, ...)
    Run(self._values.difficulty)
end

function ElementDifficulty:on_executed(...)
    if not self._values.enabled then
        return
    end
    Run(self._values.difficulty)
    original.on_executed(self, ...)
end