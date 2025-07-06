local EHI = EHI
if EHI:CheckLoadHook("MutatorPiggyRevenge") or not EHI:GetTrackerOption("show_mission_trackers") then
    return
end
local original =
{
    on_game_started = MutatorPiggyRevenge.on_game_started,
    sync_feed_piggybank = MutatorPiggyRevenge.sync_feed_piggybank,
    sync_explode_piggybank = MutatorPiggyRevenge.sync_explode_piggybank
}
function MutatorPiggyRevenge:on_game_started(...)
    original.on_game_started(self, ...)
    EHI:LoadTracker("EHIPiggyBankMutatorTracker")
    if EHI.IsHost then -- Do not create the tracker on clients straight away, but wait instead for the sync function
        managers.ehi_tracker:AddTracker({
            id = "pda10_event",
            class = "EHIPiggyBankMutatorTracker"
        })
    end
end

if EHI.IsClient then
    original.sync_load = MutatorPiggyRevenge.sync_load
    function MutatorPiggyRevenge:sync_load(mutator_manager, load_data, ...)
        original.sync_load(self, mutator_manager, load_data, ...)
        local mutator_data = load_data.piggyrevenge_mutator
        if mutator_data.exploded_pig_level then
            return
        end
        managers.ehi_tracker:AddTracker({
            id = "pda10_event",
            class = "EHIPiggyBankMutatorTracker"
        })
        managers.ehi_tracker:CallFunction("pda10_event", "SyncLoad", mutator_data)
    end
end

function MutatorPiggyRevenge:sync_feed_piggybank(...)
    original.sync_feed_piggybank(self, ...)
    managers.ehi_tracker:SetProgress("pda10_event", self._pig_fed_count)
end

function MutatorPiggyRevenge:sync_explode_piggybank(...)
    if self._exploded_pig_level then
        return
    end
    original.sync_explode_piggybank(self, ...)
    managers.ehi_tracker:RemoveTracker("pda10_event")
end