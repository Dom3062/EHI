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

if EHI:GetOption("show_difficulty_tracker") then
    ---@param diff number
    EHI:AddCallback(EHI.CallbackMessage.SyncAssaultDiff, function(diff)
        local chance = managers.ehi_tracker:RoundChanceNumber(diff)
        if managers.ehi_tracker:CallFunction2("AssaultDiff", "SetChance", chance) then
            managers.ehi_tracker:AddTracker({
                id = "AssaultDiff",
                icons = { "enemy" },
                chance = chance,
                hint = "diff",
                class = EHI.Trackers.Chance
            })
        end
    end)
end

function ElementDifficulty:client_on_executed(...)
    original.client_on_executed(self, ...)
    EHI:CallCallback(EHI.CallbackMessage.SyncAssaultDiff, self._values.difficulty)
end

function ElementDifficulty:on_executed(...)
    if not self._values.enabled then
        return
    end
    EHI:CallCallback(EHI.CallbackMessage.SyncAssaultDiff, self._values.difficulty)
    original.on_executed(self, ...)
end