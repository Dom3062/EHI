local EHI = EHI
if EHI._hooks.GroupAIStateBase then
	return
else
	EHI._hooks.GroupAIStateBase = true
end

local achievements_to_remove =
{
    "dah_8",
    "sah_9",
    "friend_6",
    "chas_10",
    "chca_10"
}

local trackers_to_remove =
{
    "BodyBags",
    "pagers", -- Removes pager tracker
    "pagers_chance" -- Removes pager chance tracker (if using mods)
}

local achievements_to_toggle =
{
    "uno_7"
}

local unhook =
{
    -- Pager stuff
    "PagerInit",
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

local dropin = false

local level_id = Global.game_settings.level_id
if level_id == "alex_2" then
    show_trackers[#show_trackers + 1] = { time = 75 + 15 + 30, id = "FirstAssaultDelay", icons = { { icon = "assaultbox", color = Color(1, 1, 0) } }, class = "EHIWarningTracker" }
end

local function Execute()
    if managers.trade.GetTradeCounterTick then
        managers.ehi:LoadFromTradeDelayCache()
        if not dropin then
            managers.ehi:SetTrade("normal", true, managers.trade:GetTradeCounterTick())
        end
    end
    for _, achievement in ipairs(achievements_to_remove) do
        managers.ehi:SetAchievementFailed(achievement)
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
    EHI:RunOnAlarmCallbacks(dropin)
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
    load = GroupAIStateBase.load
}

function GroupAIStateBase:init(...)
	original.init(self, ...)
    self:add_listener("EHI_EnemyWeaponsHot", { "enemy_weapons_hot" }, Execute)
end

function GroupAIStateBase:on_successful_alarm_pager_bluff(...) -- Called by host
    original.on_successful_alarm_pager_bluff(self, ...)
    managers.ehi:SetTrackerProgress("pagers", self._nr_successful_alarm_pager_bluffs)
    managers.ehi:SetChance("pagers_chance", (EHI:RoundChanceNumber(tweak_data.player.alarm_pager.bluff_success_chance_w_skill[self._nr_successful_alarm_pager_bluffs + 1] or 0)))
end

function GroupAIStateBase:sync_alarm_pager_bluff(...) -- Called by client
    original.sync_alarm_pager_bluff(self, ...)
    managers.ehi:SetTrackerProgress("pagers", self._nr_successful_alarm_pager_bluffs)
end

function GroupAIStateBase:load(...)
    dropin = managers.ehi:GetDropin()
    original.load(self, ...)
    if not self._enemy_weapons_hot then
        managers.ehi:SetTrackerProgress("pagers", self._nr_successful_alarm_pager_bluffs)
    else
        Execute()
	end
    local law1team = self._teams[tweak_data.levels:get_default_team_ID("combatant")]
    if law1team and law1team.damage_reduction then
        managers.ehi:SetChance("PhalanxDamageReduction", (EHI:RoundChanceNumber(law1team.damage_reduction or 0)))
    end
end

if EHI:ShowDramaTracker() then
    show_trackers[#show_trackers + 1] = { id = "Drama", icons = { "C_Escape_H_Street_Bullet" }, class = "EHIChanceTracker", dont_flash = true, pos = 0 }
    original._add_drama = GroupAIStateBase._add_drama
    function GroupAIStateBase:_add_drama(...)
        original._add_drama(self, ...)
        managers.ehi:SetChance("Drama", (EHI:RoundChanceNumber(self._drama_data.amount)))
    end
end

if EHI:GetOption("show_minion_tracker") then
    local function UpdateTracker(unit, key, amount)
        if managers.ehi:TrackerDoesNotExist("Converts") then
            managers.ehi:AddTracker({
                id = "Converts",
                dont_show_placed = true,
                icons = { "minion" },
                exclude_from_sync = true,
                class = "EHIEquipmentTracker"
            })
        end
        managers.ehi:CallFunction("Converts", "UpdateAmount", unit, key, amount)
    end

    original._set_converted_police = GroupAIStateBase._set_converted_police
    function GroupAIStateBase:_set_converted_police(u_key, unit, ...)
        original._set_converted_police(self, u_key, unit, ...)
        UpdateTracker(unit, tostring(u_key), unit and 1 or 0)
    end
end