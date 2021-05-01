local achievements_to_remove =
{
    "green_3",
    "dah_8",
    "cow_11",
    "sah_9",
    "friend_6",

    -- Not an achievement, but it removes body bags
    "BodyBags",
    "pagers" -- Removes pager tracker
}

local achievements_to_toggle =
{
    "uno_7"
}

local function Execute()
    for _, achievement in ipairs(achievements_to_remove) do
        managers.hud:RemoveTracker(achievement)
    end
    for _, achievement in ipairs(achievements_to_toggle) do
        managers.hud.ehi:CallFunction(achievement, "ToggleObtainable")
    end
end

local original =
{
    init = GroupAIStateBase.init,
    on_successful_alarm_pager_bluff = GroupAIStateBase.on_successful_alarm_pager_bluff,
    sync_alarm_pager_bluff = GroupAIStateBase.sync_alarm_pager_bluff,
    load = GroupAIStateBase.load,
    sync_cs_grenade = GroupAIStateBase.sync_cs_grenade
}

function GroupAIStateBase:init()
	original.init(self)
    self:add_listener("EHI_EnemyWeaponsHot", { "enemy_weapons_hot" }, Execute)
end

function GroupAIStateBase:on_successful_alarm_pager_bluff()
    original.on_successful_alarm_pager_bluff(self)
    managers.hud:SetProgress("pagers", self._nr_successful_alarm_pager_bluffs)
end

function GroupAIStateBase:sync_alarm_pager_bluff()
    original.sync_alarm_pager_bluff(self)
    managers.hud:SetProgress("pagers", self._nr_successful_alarm_pager_bluffs)
end

function GroupAIStateBase:load(load_data)
    original.load(self, load_data)
    if self._enemy_weapons_hot then
		managers.hud:RemoveTracker("pagers")
    else
        managers.hud:SetProgress("pagers", self._nr_successful_alarm_pager_bluffs)
	end
    local law1team = self._teams[tweak_data.levels:get_default_team_ID("combatant")]
    if law1team and law1team.damage_reduction then
        managers.hud.ehi:SetChance("PhalanxDamageReduction", (EHI:RoundNumber(law1team.damage_reduction or 0, 0.01) * 100))
    end
end

if EHI:GetOption("show_minion_tracker") then
    local function UpdateTracker(key, amount)
        if managers.hud.ehi then
            if not managers.hud:TrackerExists("Converts") then
                managers.hud:AddTracker({
                    id = "Converts",
                    dont_show_placed = true,
                    icons = { "minion" },
                    class = "EHIEquipmentTracker"
                })
            end
            managers.hud.ehi:CallFunction("Converts", "UpdateAmount", key, amount)
        end
    end

    original._set_converted_police = GroupAIStateBase._set_converted_police
    function GroupAIStateBase:_set_converted_police(u_key, unit, owner_unit)
        original._set_converted_police(self, u_key, unit, owner_unit)
        UpdateTracker(tostring(u_key), unit and 1 or 0)
    end
end