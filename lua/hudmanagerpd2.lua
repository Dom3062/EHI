local deployable_icon =
{
    ["DoctorBags"] = "doctor_bag",
    ["AmmoBags"] = "ammo_bag",
    ["GrenadeCases"] = "frag_grenade",
    ["BodyBagsBagBase"] = "bodybags_bag"
}
local original =
{
    _setup_player_info_hud_pd2 = HUDManager._setup_player_info_hud_pd2,
    sync_set_assault_mode = HUDManager.sync_set_assault_mode,
    destroy = HUDManager.destroy
}
local EHI = EHI
function HUDManager:_setup_player_info_hud_pd2(...)
    original._setup_player_info_hud_pd2(self, ...)
    self.ehi = EHIPanel:new()
    local level_id = Global.game_settings.level_id
    if EHI:GetOption("show_pager_tracker") and tweak_data.levels[level_id] and tweak_data.levels[level_id].ghost_bonus then
        local base = tweak_data.player.alarm_pager.bluff_success_chance_w_skill
        local max = 0
        for _, value in pairs(base) do
            if value > 0 then
                max = max + 1
            end
        end
        self:AddTracker({
            id = "pagers",
            max = max,
            icons = { "pagers_used" },
            set_color_bad_when_reached = true,
            class = "EHIProgressTracker"
        })
        if max == 0 then
            managers.hud.ehi:CallFunction("pagers", "SetBad")
        end
    end
    if EHI:GetOption("show_difficulty_tracker") and level_id ~= "chill" then
        local diff = EHI._cache.Difficulty
        if diff then
            diff = EHI:RoundNumber(diff, 0.01) * 100
        else
            diff = 0
        end
        self:AddTracker({
            id = "Difficulty",
            icons = { "enemy" },
            chance = diff,
            class = "EHIChanceTracker"
        })
    end
    if EHI:GetOption("show_gained_xp") and EHI:GetOption("xp_panel") == 2 and Global.game_settings.gamemode ~= "crime_spree" then
        self:AddTracker({
            id = "XPTotal",
            class = "EHITotalXPTracker"
        })
    end
    for deployable, tbl in pairs(EHI._cache.Deployables) do
        if table.size(tbl) ~= 0 then
            if deployable == "Health" then
                self:AddAggregatedHealthTracker()
                for id, tblh in pairs(EHI._cache.Deployables.Health) do
                    for key, amount in pairs(tblh) do
                        self.ehi:CallFunction(deployable, "UpdateAmount", id, key, amount)
                    end
                end
            else
                self:AddTracker({
                    id = deployable,
                    format = deployable == "AmmoBags" and "percent" or "charges",
                    icons = { (deployable_icon[deployable] or "doctor_bag") },
                    class = "EHIEquipmentTracker"
                })
                for key, amount in pairs(tbl) do
                    self.ehi:CallFunction(deployable, "UpdateAmount", key, amount)
                end
            end
            EHI._cache.Deployables[deployable] = {}
        end
    end
    if level_id == "pines" then
        if EHI:DifficultyToIndex(Global.game_settings.difficulty) >= 3 and EHI:GetOption("show_achievement") then
            self:AddTracker({
                id = "uno_9",
                max = 40,
                icons = { "C_Vlad_H_XMas_Whats" },
                class = "EHIAchievementProgressTracker"
            })
        end
    end
    if level_id == "cane" then
        if EHI:DifficultyToIndex(Global.game_settings.difficulty) >= 3 and EHI:GetOption("show_achievement") then
            self:AddTracker({
                id = "cane_3",
                max = 100,
                icons = { "C_Vlad_H_Santa_EuroBag" },
                remove_after_reaching_target = true,
                class = "EHIAchievementProgressTracker"
            })
        end
    end
end

function HUDManager:sync_set_assault_mode(mode)
    original.sync_set_assault_mode(self, mode)
    if mode == "phalanx" and EHI:GetOption("show_captain_damage_reduction") then
        self:AddTracker({
            id = "PhalanxDamageReduction",
            icons = { "buff_shield" },
            class = "EHIChanceTracker"
        })
    else
        self:RemoveTracker("PhalanxDamageReduction")
    end
end

function HUDManager:destroy()
    self.ehi:destroy()
    original.destroy(self)
end

function HUDManager:SyncHeistTime(time)
    self.ehi:SyncTime(time)
end

function HUDManager:AddAggregatedHealthTracker()
    self:AddTracker({
        id = "Health",
        ids = { "doctor_bag", "first_aid_kit" },
        icons = { { icon = "doctor_bag", visible = false }, { icon = "first_aid_kit", visible = false } },
        dont_show_placed = { first_aid_kit = true },
        class = "EHIAggregatedEquipmentTracker"
    })
end

function HUDManager:AddCustodyTimeTracker()
    self:AddTracker({
        id = "CustodyTime",
        icons = { "mugshot_in_custody" },
        class = "EHICiviliansKilledTracker"
    })
end

function HUDManager:AddCustodyTimeTrackerAndAddPeerCustodyTime(peer_id, time)
    self:AddCustodyTimeTracker()
    self.ehi:CallFunction("CustodyTime", "AddPeerCustodyTime", peer_id, time)
end

function HUDManager:AddTracker(params)
    self.ehi:AddTracker(params)
end

-- Called by host only. Clients with EHI call HUDManager:AddTracker() when synced
function HUDManager:AddTrackerAndSync(params, id, delay)
    self:AddTracker(params)
    EHI:Sync(EHI.SyncMessages.EHISyncAddTracker, LuaNetworking:TableToString({ id = id, delay = delay or 0 }))
end

function HUDManager:RemoveTracker(id)
    self.ehi:RemoveTracker(id)
end

function HUDManager:AddMoney(id, amount)
    self.ehi:AddMoneyToTracker(id, amount)
end

function HUDManager:AddXP(id, amount)
    self.ehi:AddXPToTracker(id, amount)
end

function HUDManager:SetUpgradeable(id, upgradeable)
    self.ehi:SetTrackerUpgradeable(id, upgradeable)
end

function HUDManager:SetTime(id, time)
    self.ehi:SetTrackerTime(id, time)
end

function HUDManager:SetTimeNoAnim(id, time)
    self.ehi:CallFunction(id, "SetTimeNoAnim", time)
end

function HUDManager:SetUpgrades(id, upgrades)
    self.ehi:SetTrackerUpgrades(id, upgrades)
end

function HUDManager:SetTimerJammed(id, jammed)
    self.ehi:SetTimerJammed(id, jammed)
end

function HUDManager:SetTimerPowered(id, powered)
    self.ehi:SetTimerPowered(id, powered)
end

function HUDManager:SetTrackerPaused(id, pause)
    self.ehi:SetTrackerPaused(id, pause)
end

function HUDManager:PauseTracker(id)
    self:SetTrackerPaused(id, true)
end

function HUDManager:UnpauseTracker(id)
    self:SetTrackerPaused(id, false)
end

function HUDManager:TrackerExists(id)
    return self.ehi:TrackerExists(id)
end

function HUDManager:ResetTrackerTime(id)
    self.ehi:ResetTrackerTime(id)
end

function HUDManager:ResetTrackerTimeAndUnpause(id)
    self:ResetTrackerTime(id)
    self:UnpauseTracker(id)
end

function HUDManager:AddDelay(id, delay)
    self.ehi:AddDelayToTracker(id, delay)
end

function HUDManager:AddDelayToTrackerAndUnpause(id, delay)
    self:AddDelay(id, delay)
    self:UnpauseTracker(id)
end

function HUDManager:AddToCache(id, data)
    self.ehi:AddToCache(id, data)
end

function HUDManager:GetAndRemoveFromCache(id)
    return self.ehi:GetAndRemoveFromCache(id)
end

function HUDManager:SetProgress(id, progress)
    self.ehi:SetTrackerProgress(id, progress)
end

function HUDManager:IncreaseProgress(id)
    self.ehi:SetTrackerIncreaseProgress(id)
end

function HUDManager:SetTrackerTextColor(id, color)
    self.ehi:SetTrackerTextColor(id, color)
end

function HUDManager:SetTrackerAccurate(id)
    self:SetTrackerTextColor(id, Color.white)
end

if Network:is_client() then
end

function HUDManager:Debug(id, element)
    managers.chat:_receive_message(1, "[EHI]", "ID: " .. tostring(id) .. "; Element: " .. tostring(element), Color.white)
end

Hooks:Add("NetworkReceivedData", "NetworkReceivedData_EHI", function(sender, id, data)
    if id == EHI.SyncMessages.EHISyncAddTracker then
        local tbl = LuaNetworking:StringToTable(data)
        EHI:AddTrackerSynced(tonumber(tbl.id), tonumber(tbl.delay))
    end
end)