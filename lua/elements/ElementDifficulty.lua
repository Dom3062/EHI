local EHI = EHI
if EHI:CheckLoadHook("ElementDifficulty") then
    return
end

if tweak_data.levels:IsLevelSkirmish() then
    if EHI:GetTrackerOption("show_difficulty_tracker") and not ((EHI:CombineAssaultDelayAndAssaultTime() or EHI:GetTrackerOption("show_assault_time_tracker")) and EHI:GetOption("show_assault_diff_in_assault_trackers")) then
        ---@class EHIWaveDifficultyTracker : EHIProgressTracker
        ---@field super EHIProgressTracker
        EHIWaveDifficultyTracker = class(EHIProgressTracker)
        EHIWaveDifficultyTracker._forced_icons = { "crime_spree_assault_extender" }
        EHIWaveDifficultyTracker._forced_hint_text = "diff"
        EHIWaveDifficultyTracker._SKIRMISH_WAVE_DATA = tweak_data.skirmish:GetWaveData()
        function EHIWaveDifficultyTracker:post_init(params)
            EHIWaveDifficultyTracker.super.post_init(self, params)
            self._in_assault = params.in_assault
            managers.ehi_assault:AddAssaultStartCallback(function()
                if self._in_assault then
                    return
                end
                self:IncreaseProgress()
                self._in_assault = true
            end)
            managers.ehi_assault:AddAssaultEndCallback(function()
                self._in_assault = false
            end)
        end
        function EHIWaveDifficultyTracker:Format()
            local wave
            if self._progress <= 0 then
                wave = { damage = 1, health = 1 }
            else
                wave = self._SKIRMISH_WAVE_DATA[math.min(self._progress, managers.job:current_level_wave_count())]
            end
            if wave then
                if wave.damage and wave.health then
                    return string.format("%gx|%gx", wave.damage, wave.health)
                elseif wave.damage then
                    return string.format("%gx|?x", wave.damage)
                elseif wave.health then
                    return string.format("?x|%gx", wave.health)
                end
            end
            return "?x|?x"
        end
        function EHIWaveDifficultyTracker:SetProgress(progress)
            self._progress = progress
            self._progress_text:set_text(self:Format())
            self:FitTheText(self._progress_text)
            self:AnimateBG()
        end
        if EHI.IsHost then -- On host, create the tracker after spawn
            EHI:AddOnSpawnedCallback(function()
                managers.ehi_tracker:AddTracker({
                    id = "AssaultDiff",
                    class = "EHIWaveDifficultyTracker"
                })
            end)
        else -- On client, wait until HUDManager data is synced from host
            managers.ehi_sync:AddGameDataSyncFunction(function(data)
                local state = data.HUDManager
                managers.ehi_tracker:AddTracker({
                    id = "AssaultDiff",
                    progress = math.max(0, state.assault_number or 1),
                    in_assault = state.in_assault,
                    class = "EHIWaveDifficultyTracker"
                })
            end)
        end
    end
    return
end

local original =
{
    client_on_executed = ElementDifficulty.client_on_executed,
    on_executed = ElementDifficulty.on_executed
}

if EHI:GetTrackerOption("show_difficulty_tracker") and not ((EHI:CombineAssaultDelayAndAssaultTime() or EHI:GetTrackerOption("show_assault_time_tracker")) and EHI:GetOption("show_assault_diff_in_assault_trackers")) then
    managers.ehi_assault:AddAssaultDifficultyCallback(function(diff)
        local chance = math.ehi_round_chance(diff)
        if managers.ehi_tracker:CallFunction2("AssaultDiff", "SetChance", chance) then
            managers.ehi_tracker:AddTracker({
                id = "AssaultDiff",
                icons = { "crime_spree_assault_extender" },
                chance = chance,
                hint = "diff",
                class = EHI.Trackers.Chance
            })
        end
    end)
end

function ElementDifficulty:client_on_executed(...)
    original.client_on_executed(self, ...)
    managers.ehi_assault:CallAssaultDifficultyCallback(self._values.difficulty)
end

function ElementDifficulty:on_executed(...)
    if not self._values.enabled then
        return
    end
    managers.ehi_assault:CallAssaultDifficultyCallback(self._values.difficulty)
    original.on_executed(self, ...)
end