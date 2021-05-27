if EHI._hooks.HUDManagerPD2 then
	return
else
	EHI._hooks.HUDManagerPD2 = true
end

local original =
{
    _setup_player_info_hud_pd2 = HUDManager._setup_player_info_hud_pd2,
    sync_set_assault_mode = HUDManager.sync_set_assault_mode,
    destroy = HUDManager.destroy,
    set_disabled = HUDManager.set_disabled,
    set_enabled = HUDManager.set_enabled
}
local EHI = EHI
function HUDManager:_setup_player_info_hud_pd2(...)
    original._setup_player_info_hud_pd2(self, ...)
    self.ehi = managers.ehi
    self:add_updator("EHI_Update", callback(self.ehi, self.ehi, "update"))
    local level_id = Global.game_settings.level_id
    if EHI:GetOption("show_enemy_count_tracker") and level_id ~= "chill" then
        self:AddTracker({
            id = "EnemyCount",
            class = "EHICountTracker"
        })
    end
    if EHI:GetOption("show_pager_tracker") and level_id ~= "chill" then
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
            self.ehi:CallFunction("pagers", "SetBad")
        end
    end
    if EHI:GetOption("show_gained_xp") and EHI:GetOption("xp_panel") == 2 and Global.game_settings.gamemode ~= "crime_spree" then
        self:AddTracker({
            id = "XPTotal",
            class = "EHITotalXPTracker"
        })
    end
    if EHI:GetOption("show_achievement") then
        if level_id == "pines" then
            if EHI:IsOVKOrAbove(Global.game_settings.difficulty) then
                self:AddTracker({
                    id = "uno_9",
                    max = 40,
                    icons = { "C_Vlad_H_XMas_Whats" },
                    class = "EHIAchievementProgressTracker"
                })
            end
        end
        if level_id == "cane" then
            if EHI:IsOVKOrAbove(Global.game_settings.difficulty) then
                self:AddTracker({
                    id = "cane_3",
                    max = 100,
                    icons = { "C_Vlad_H_Santa_EuroBag" },
                    class = "EHIAchievementProgressTracker"
                })
            end
        end
        if level_id == "mex_cooking" then
            if EHI:IsOVKOrAbove(Global.game_settings.difficulty) then
                self:AddTracker({
                    id = "mex2_9",
                    max = 25,
                    icons = { "C_Locke_H_BorderCrystals_HeisterCocinero" },
                    class = "EHIAchievementProgressTracker"
                })
            end
        end
        if level_id == "crojob2" then
            self:AddTracker({
                max = 2,
                id = "voff_2",
                icons = { "C_Butcher_H_BombDock_HighTimes" },
                class = "EHIAchievementProgressTracker"
            })
        end
        if level_id == "pal" then
            local value_max = 1000000
            local loot_value = managers.money:get_secured_bonus_bag_value("counterfeit_money", 1)
            local max = math.ceil(value_max / loot_value)
            self:AddTracker({
                max = max,
                id = "pal_2",
                icons = { "C_Classics_H_Counterfeit_DrEvil" },
                class = "EHIAchievementProgressTracker"
            })
        end
        if level_id == "pbr2" then
            self:AddTracker({
                max = 9,
                id = "voff_4",
                icons = { "C_Locke_H_BirthOfSky_Mellon" },
                class = "EHIAchievementProgressTracker"
            })
        end
        if level_id == "pex" then
            self:AddTracker({
                max = 6,
                id = "pex_10",
                icons = { "C_Locke_H_BreakfastInTijuana_PaidInFull" },
                class = "EHIAchievementProgressTracker"
            })
            --[[self:AddTracker({
                max = 7,
                id = "pex_11",
                icons = { "C_Locke_H_BreakfastInTijuana_StolenValor" },
                class = "EHIAchievementProgressTracker"
            })]]
        end
        if level_id == "dah" then
            if EHI:IsOVKOrAbove(Global.game_settings.difficulty) then
                self:AddTracker({
                    max = 12,
                    id = "dah_8",
                    icons = { "C_Classics_H_DiamondHesit_TheHuntfor" },
                    class = "EHIAchievementProgressTracker"
                })
            end
        end
        if level_id == "alex_1" then
            if EHI:IsOVKOrAbove(Global.game_settings.difficulty) then
                self:AddTracker({
                    max = 7,
                    id = "halloween_2",
                    icons = { "C_Hector_H_Rats_FullMeasure" },
                    class = "EHIAchievementProgressTracker"
                })
            end
        end
        if level_id == "chas" then
            if EHI:IsOVKOrAbove(Global.game_settings.difficulty) then
                self:AddTracker({
                    max = 15,
                    id = "chas_10",
                    icons = { "C_JiuFeng_H_DragonHeist_AllTheGold" },
                    class = "EHIAchievementProgressTracker"
                })
            end
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

function HUDManager:set_disabled()
    original.set_disabled(self)
    managers.ehi:HidePanel()
end

function HUDManager:set_enabled()
    original.set_enabled(self)
    managers.ehi:ShowPanel()
end

function HUDManager:destroy()
    self.ehi:destroy()
    original.destroy(self)
end

function HUDManager:SyncHeistTime(time)
    self.ehi:SyncTime(time)
end

function HUDManager:AddTracker(params)
    self.ehi:AddTracker(params)
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