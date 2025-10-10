local EHI = EHI
local Icon = EHI.Icons
---@class EHIHeliTracker : EHIWarningTracker
local EHIHeliTracker = class(EHIWarningTracker)
EHIHeliTracker._forced_icons = { Icon.Heli }
EHIHeliTracker._show_completion_color = true

local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local kills = EHI:GetValueBasedOnDifficulty({
    hard_or_below = 7,
    veryhard = 10,
    overkill = 10,
    mayhem_or_above = 15
})
---@type ParseTriggerTable
local triggers = {
    [100001] = { time = 30, id = "BileArrival", icons = { Icon.Heli, Icon.C4 }, hint = Hints.C4Delivery },

    [100068] = { max = kills, id = "SniperDeath", icons = { "sniper" }, class = TT.Progress, waypoint = { position_from_element_and_remove_vanilla_waypoint = 100294, restore_on_done = true }, hint = Hints.Kills },
    [104555] = { id = "SniperDeath", special_function = SF.IncreaseProgress },

    [103446] = { time = 20 + 6 + 4, id = "HeliDropsC4", icons = Icon.HeliDropC4, hint = Hints.C4Delivery },

    [102001] = { time = 5, id = "C4Explosion", icons = { Icon.C4 }, hint = Hints.Explosion },

    [100082] = { time = 30 + 10, id = "HeliComesWithMagnet", icons = { Icon.Heli, Icon.Winch }, hint = Hints.Winch },

    --- Add 0.2 delay here so the tracker does not hide first before this gets executed again; players won't notice 0.2 delay here
    [100147] = { time = 18.2 + 0.2, id = "HeliMagnetLoop", icons = { Icon.Heli, Icon.Winch, Icon.Loop }, special_function = EHI.Trigger:RegisterCustomSF(function(self, trigger, element, enabled)
        if enabled and self._trackers:CallFunction2(trigger.id, "SetTimeNoAnim", trigger.time) then
            self:CreateTracking()
        end
    end), hint = Hints.Wait },
    [102181] = { id = "HeliMagnetLoop", special_function = SF.RemoveTracker },

    [100206] = { time = 30, id = "LoweringTheMagnet", icons = Icon.HeliDropWinch, waypoint = { data_from_element = 101016 }, hint = Hints.Winch },

    [103869] = { time = 600, id = "PanicRoomTakeoff", class_table = EHIHeliTracker, hint = Hints.Defend },
    [100405] = { time = 15, id = "HeliTakeoff", icons = { Icon.Heli, Icon.Wait }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1004051 }, hint = Hints.Wait },
    [1004051] = { id = "PanicRoomTakeoff", special_function = SF.RemoveTracker }
}

---@type ParseAchievementTable
local achievements =
{
    flat_2 =
    {
        elements =
        {
            [100049] = { time = 20, class = TT.Achievement.Base },
            [104859] = { special_function = SF.SetAchievementComplete }
        }
    },
    cac_9 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100809] = { time = 60, class = TT.Achievement.Base, trigger_once = true, condition_function = EHI.ConditionFunctions.PlayingFromStart },
            [100805] = { special_function = SF.SetAchievementComplete },
        }
    }
}
if EHI:CanShowAchievement2("flat_5", "show_achievements_other") then
    ---@class flat_5 : EHIChanceTracker, EHIAchievementTracker
    ---@field super EHIChanceTracker
    local flat_5 = ehi_achievement_class(EHIChanceTracker)
    flat_5.CreateIcon = EHIUnlockableTracker.CreateIcon
    function flat_5:pre_init(params)
        self._peers = {} ---@type { hits: number, shots: number }[]
        self._n_of_peers = 0
        params.flash_bg = false
        params.disable_anim = true
        flat_5.super.pre_init(self, params)
    end
    function flat_5:post_init(params)
        flat_5.super.post_init(self, params)
        EHIAchievementTracker.post_init(self, params)
    end
    ---@param peer_id integer
    function flat_5:PlayerAdded(peer_id)
        self._n_of_peers = self._n_of_peers + 1
        self._peers[peer_id] = { hits = 0, shots = 0 }
    end
    ---@param peer_id integer
    function flat_5:PlayerDisconnected(peer_id)
        self._n_of_peers = self._n_of_peers - 1
        self._peers[peer_id] = nil
    end
    ---@param peer_id integer
    ---@param shot_made integer
    function flat_5:ShotMade(peer_id, shot_made)
        local peer = self._peers[peer_id]
        if peer then
            peer.shots = peer.shots + shot_made
            self:UpdateAllAccuracy()
        end
    end
    ---@param peer_id integer
    function flat_5:HitMade(peer_id)
        local peer = self._peers[peer_id]
        if peer then
            peer.hits = peer.hits + 1
            self:UpdateAllAccuracy()
        end
    end
    function flat_5:UpdateAllAccuracy()
        local accuracy = 0
        for _, peer in pairs(self._peers) do
            if peer.shots > 0 then
                accuracy = accuracy + math.floor(peer.hits / peer.shots * 100)
            end
        end
        self:SetChance(math.floor(accuracy / self._n_of_peers))
    end
    EHI:AddOnSpawnedExtendedCallback(function(self, job, level, from_beginning)
        if level == "flat" and from_beginning then
            managers.ehi_tracker:AddTracker({
                id = "flat_5",
                icons = EHI:GetAchievementIcon("flat_5"),
                class_table = flat_5
            })
            for id, _ in pairs(managers.network:session():all_peers()) do
                managers.ehi_tracker:CallFunction("flat_5", "PlayerAdded", id)
            end
            ---@param something UnitPlayer|UnitEnemy|UnitTeamAI
            local function _pid(something)
                local network = alive(something) and something:network()
                local peer = network and network:peer()
                return peer and peer:id() or 0
            end
            managers.ehi_hook:AddCopDamageListener("flat_5", function(c_dmg, damage_info, attacker_unit, damage)
                local pid = _pid(attacker_unit)
                if damage_info.variant == "bullet" or damage_info.variant == "fire" or damage_info.variant == "explosion" or damage_info.variant == "melee" then
                    managers.ehi_tracker:CallFunction("flat_5", "HitMade", pid)
                end
            end)
            managers.ehi_hook:AddShotWithAWeaponListener(function(peer_id, bullets_subtracted)
                managers.ehi_tracker:CallFunction("flat_5", "ShotMade", peer_id, bullets_subtracted)
            end)
            Hooks:PostHook(NetworkPeer, "init", "EHI_flat_5_NetworkPeer_init", function(peer, ...)
                managers.ehi_tracker:CallFunction("flat_5", "PlayerAdded", peer:id())
            end)
            Hooks:PostHook(NetworkPeer, "destroy", "EHI_flat_5_NetworkPeer_destroy", function(peer, ...)
                managers.ehi_tracker:CallFunction("flat_5", "PlayerDisconnected", peer:id())
            end)
        end
    end)
end

local other =
{
    [100290] = EHI:AddAssaultDelay({}) -- 30s
}
if EHI:IsLootCounterVisible() then
    other[102741] = EHI:AddLootCounter4(function(self, ...)
        local max = self._utils:CountInteractionAvailable("gen_pku_cocaine")
        EHI:ShowLootCounterNoChecks({ max = max + 1, client_from_start = true })
    end, { element = { 104303, 104306 }, present_timer = 0 })
end

--´drill defend waypoint001´ ElementWaypoint 101734
EHI.Waypoint:DisableTimerWaypoints({ [101734] = true })

EHI.Mission:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 2000, name = "panic_room_found" },
        { amount = 8000, name = "saws_done" },
        { amount = 3000, name = "panic_room_killed_all_snipers" },
        { amount = 2000, name = "c4_set_up" },
        { amount = 4000, name = "panic_room_roof_secured" },
        { amount = 1000, name = "panic_room_magnet_attached" },
        { amount = 3000, name = "panic_room_defended_heli" },
        { escape = 2000 }
    },
    loot =
    {
        coke = 500,
        toothbrush = 1000
    },
    total_xp_override =
    {
        params =
        {
            min =
            {
                objectives = true
            },
            max =
            {
                objectives = true,
                loot =
                {
                    coke = { times = 10 },
                    toothbrush = { times = 1 }
                }
            }
        }
    }
})