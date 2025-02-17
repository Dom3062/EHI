local EHI = EHI
if EHI:CheckLoadHook("MutatorPiggyBank") or not EHI:GetTrackerOption("show_mission_trackers") then
    return
end
local original =
{
    on_game_started = MutatorPiggyBank.on_game_started,
    sync_feed_piggybank = MutatorPiggyBank.sync_feed_piggybank,
    sync_explode_piggybank = MutatorPiggyBank.sync_explode_piggybank
}
function MutatorPiggyBank:on_game_started(...)
    original.on_game_started(self, ...)
    EHI:LoadTracker("EHIPiggyBankMutatorTracker")
    if EHI.IsHost then -- Do not create the tracker on clients straight away, but wait instead for the sync function
        managers.ehi_tracker:AddTracker({
            id = "pda9_event",
            class = "EHIPiggyBankMutatorTracker"
        })
    end
end

if EHI.IsClient then
    original.sync_load = MutatorPiggyBank.sync_load
    function MutatorPiggyBank:sync_load(mutator_manager, load_data, ...)
        original.sync_load(self, mutator_manager, load_data, ...)
        local mutator_data = load_data.piggybank_mutator
        if mutator_data.exploded_pig_level then
            return
        end
        managers.ehi_tracker:AddTracker({
            id = "pda9_event",
            class = "EHIPiggyBankMutatorTracker"
        })
        managers.ehi_tracker:CallFunction("pda9_event", "SyncLoad", mutator_data)
    end
end

function MutatorPiggyBank:sync_feed_piggybank(...)
    original.sync_feed_piggybank(self, ...)
    managers.ehi_tracker:SetTrackerProgress("pda9_event", self._pig_fed_count)
end

function MutatorPiggyBank:sync_explode_piggybank(...)
    if self._exploded_pig_level then
        return
    end
    original.sync_explode_piggybank(self, ...)
    managers.ehi_tracker:RemoveTracker("pda9_event")
end