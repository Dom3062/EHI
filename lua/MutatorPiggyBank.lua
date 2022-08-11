local original =
{
    on_game_started = MutatorPiggyBank.on_game_started,
    sync_load = MutatorPiggyBank.sync_load,
    sync_feed_piggybank = MutatorPiggyBank.sync_feed_piggybank,
    sync_explode_piggybank = MutatorPiggyBank.sync_explode_piggybank
}
function MutatorPiggyBank:on_game_started(mutator_manager, ...)
    original.on_game_started(self, mutator_manager, ...)
    managers.ehi:AddTracker({
        id = "pda9_event",
        class = "EHIPiggyBankMutatorTracker"
    })
end

function MutatorPiggyBank:sync_load(mutator_manager, load_data, ...)
    original.sync_load(mutator_manager, load_data, ...)
    managers.ehi:CallFunction("pda9_event", "SyncLoad", load_data.piggybank_mutator)
end

function MutatorPiggyBank:sync_feed_piggybank(bag_unit, reached_next_level, ...)
    original.sync_feed_piggybank(self, bag_unit, reached_next_level, ...)
    managers.ehi:SetTrackerProgress("pda9_event", self._pig_fed_count)
end

function MutatorPiggyBank:sync_explode_piggybank(...)
    original.sync_explode_piggybank(self, ...)
	if self._exploded_pig_level then
		return
	end
    if managers.experience.SetPiggyBankExplodedLevel then
        managers.experience:SetPiggyBankExplodedLevel(self._exploded_pig_level)
    end
end