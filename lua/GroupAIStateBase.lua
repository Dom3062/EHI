local EHI = EHI
if EHI._hooks.GroupAIStateBase then
	return
else
	EHI._hooks.GroupAIStateBase = true
end

local achievements_to_remove =
{
    "green_3",
    "dah_8",
    "cow_11",
    "sah_9",
    "friend_6",
    "chas_10",
}

local trackers_to_remove =
{
    "BodyBags",
    "pagers" -- Removes pager tracker
}

local achievements_to_toggle =
{
    "uno_7"
}

local unhook =
{
    -- Pager stuff
    "set_tweak_data",
    "sync_interacted",
    "interact",
    "_at_interact_start"
}

local set_ok_state =
{
    "ameno_7"
}

local show_trackers = {}
if EHI:ShowDramaTracker() then
    show_trackers[#show_trackers + 1] = { id = "Drama", icons = { "enemy" }, class = "EHIChanceTracker", dont_flash = true, pos = 0 }
end

local level_id = Global.game_settings.level_id
if level_id == "alex_2" then
    show_trackers[#show_trackers + 1] = { time = 75 + 15 + 30, id = "FirstAssaultDelay", icons = { "assaultbox" }, class = "EHIWarningTracker" }
end

local function Execute(dropin)
    for _, achievement in ipairs(achievements_to_remove) do
        managers.ehi:SetFailedAchievement(achievement)
    end
    for _, tracker in ipairs(trackers_to_remove) do
        managers.ehi:RemoveTracker(tracker)
    end
    for _, achievement in ipairs(achievements_to_toggle) do
        managers.ehi:CallFunction(achievement, "ToggleObtainable")
    end
    for _, achievement in ipairs(set_ok_state) do
        managers.ehi:CallFunction(achievement, "SetStatus", "ok")
    end
    managers.ehi:RemovePagerTrackers()
    managers.ehi:RemoveLaserTrackers()
    EHI:RunOnAlarmCallbacks()
    for _, hook in ipairs(unhook) do
        EHI:Unhook(hook)
    end
    if not dropin then
        for _, tracker in pairs(show_trackers) do
            managers.ehi:AddTracker({
                id = tracker.id,
                time = tracker.time,
                icons = tracker.icons,
                dont_flash = tracker.dont_flash,
                class = tracker.class
            }, tracker.pos)
        end
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
    managers.ehi:SetTrackerProgress("pagers", self._nr_successful_alarm_pager_bluffs)
end

function GroupAIStateBase:sync_alarm_pager_bluff()
    original.sync_alarm_pager_bluff(self)
    managers.ehi:SetTrackerProgress("pagers", self._nr_successful_alarm_pager_bluffs)
end

function GroupAIStateBase:load(load_data)
    original.load(self, load_data)
    if self._enemy_weapons_hot then
		Execute(true)
    else
        managers.ehi:SetTrackerProgress("pagers", self._nr_successful_alarm_pager_bluffs)
	end
    local law1team = self._teams[tweak_data.levels:get_default_team_ID("combatant")]
    if law1team and law1team.damage_reduction then
        managers.ehi:SetChance("PhalanxDamageReduction", (EHI:RoundNumber(law1team.damage_reduction or 0, 0.01) * 100))
    end
end

if EHI:ShowDramaTracker() then
    original._add_drama = GroupAIStateBase._add_drama
    function GroupAIStateBase:_add_drama(amount)
        original._add_drama(self, amount)
        managers.ehi:SetChance("Drama", (EHI:RoundNumber(self._drama_data.amount, 0.01) * 100))
    end
end

if EHI:GetOption("show_minion_tracker") then
    local function UpdateTracker(unit, key, amount)
        if managers.ehi:TrackerDoesNotExist("Converts") then
            managers.ehi:AddTracker({
                id = "Converts",
                dont_show_placed = true,
                icons = { "minion" },
                class = "EHIEquipmentTracker"
            })
        end
        managers.ehi:CallFunction("Converts", "UpdateAmount", unit, key, amount)
    end

    original._set_converted_police = GroupAIStateBase._set_converted_police
    function GroupAIStateBase:_set_converted_police(u_key, unit, owner_unit)
        original._set_converted_police(self, u_key, unit, owner_unit)
        UpdateTracker(unit, tostring(u_key), unit and 1 or 0)
    end
end