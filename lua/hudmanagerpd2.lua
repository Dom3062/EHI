local EHI = EHI
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

function HUDManager:_setup_player_info_hud_pd2(...)
    original._setup_player_info_hud_pd2(self, ...)
    self.ehi = managers.ehi
    self:add_updator("EHI_Update", callback(self.ehi, self.ehi, "update"))
    local level_id = Global.game_settings.level_id
    local difficulty = Global.game_settings.difficulty
    if level_id ~= "chill" then
        if false then
            self:AddTracker({
                id = "Drama",
                icons = { "enemy" },
                dont_flash = true,
                class = "EHIChanceTracker"
            })
        end
        if EHI:GetOption("show_enemy_count_tracker") then
            self:AddTracker({
                id = "EnemyCount",
                class = "EHICountTracker"
            })
        end
        if EHI:GetOption("show_pager_tracker") then
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
    end
    if EHI:GetOption("show_gained_xp") and EHI:GetOption("xp_panel") == 2 and Global.game_settings.gamemode ~= "crime_spree" then
        self:AddTracker({
            id = "XPTotal",
            class = "EHITotalXPTracker"
        })
    end
    if EHI:GetOption("show_achievement") then
        self:ShowAchievements(level_id, difficulty)
    end
    self:ShowLootCounter(level_id, difficulty)
end

function HUDManager:ShowAchievements(level_id, difficulty)
    if level_id == "pines" then
        if EHI:IsOVKOrAbove(difficulty) then
            self.ehi:AddAchievementProgressTracker("uno_9", 40, "C_Vlad_H_XMas_Whats")
        end
    end
    if level_id == "cane" then
        if EHI:IsOVKOrAbove(difficulty) then
            self.ehi:AddAchievementProgressTracker("cane_3", 100, "C_Vlad_H_Santa_EuroBag")
        end
    end
    if level_id == "mex_cooking" then
        if EHI:IsOVKOrAbove(difficulty) then
            self.ehi:AddAchievementProgressTracker("mex2_9", 25, "C_Locke_H_BorderCrystals_HeisterCocinero")
        end
    end
    if level_id == "crojob2" then
        self.ehi:AddAchievementProgressTracker("voff_2", 2, "C_Butcher_H_BombDock_HighTimes")
    end
    if level_id == "pal" then
        local value_max = tweak_data.achievement.loot_cash_achievements.pal_2.secured.value
        local loot_value = managers.money:get_secured_bonus_bag_value("counterfeit_money", 1)
        local max = math.ceil(value_max / loot_value)
        self.ehi:AddAchievementProgressTracker("pal_2", max, "C_Classics_H_Counterfeit_DrEvil")
    end
    if level_id == "pbr" then
        self.ehi:AddAchievementProgressTracker("berry_2", 10, "C_Locke_H_Beneath_Clean")
    end
    if level_id == "pbr2" then
        self.ehi:AddAchievementProgressTracker("voff_4", 9, "C_Locke_H_BirthOfSky_Mellon")
    end
    if level_id == "pex" then
        self.ehi:AddAchievementProgressTracker("pex_10", 6, "C_Locke_H_BreakfastInTijuana_PaidInFull")
        --self.ehi:AddAchievementProgressTracker("pex_11", 7, "C_Locke_H_BreakfastInTijuana_StolenValor")
    end
    if level_id == "dah" then
        if EHI:IsOVKOrAbove(difficulty) then
            self.ehi:AddAchievementProgressTracker("dah_8", 12, "C_Classics_H_DiamondHesit_TheHuntfor")
        end
    end
    if level_id == "alex_1" then
        if EHI:IsOVKOrAbove(difficulty) then
            self.ehi:AddAchievementProgressTracker("halloween_2", 7, "C_Hector_H_Rats_FullMeasure")
        end
    end
    if level_id == "chas" then
        if EHI:IsOVKOrAbove(difficulty) then
            self.ehi:AddAchievementProgressTracker("chas_10", 15, "C_JiuFeng_H_DragonHeist_AllTheGold")
        end
    end
    if level_id == "run" then
        self.ehi:AddAchievementProgressTracker("run_8", 8, "C_Classics_H_HeatStreet_Zookeeper")
    end
    if level_id == "brb" and EHI:DifficultyToIndex(difficulty) >= 2 then
        self.ehi:AddAchievementProgressTracker("brb_8", 12, "C_Locke_H_BrooklynBank_AlltheGold") -- Removed when you drop-in
    end
    if level_id == "rvd2" then
        self.ehi:AddAchievementProgressTracker("rvd_11", 19, "C_Bain_H_ReservoirDogs_WasteNot")
    end
end

function HUDManager:ShowLootCounter(level_id, difficulty)
    local max = 0
    if level_id == "spa" then
        max = 4
    elseif level_id == "friend" then
        max = 16
    --[[elseif level_id == "rvd1" then
        max = 6]]
    end
    if max == 0 then
        return
    end
    self:AddTracker({
        id = "LootCounter",
        max = max,
        icons = { "pd2_loot" },
        class = "EHIProgressTracker"
    })
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

function HUDManager:AddDelay(id, delay)
    self.ehi:AddDelayToTracker(id, delay)
end

function HUDManager:AddDelayToTrackerAndUnpause(id, delay)
    self:AddDelay(id, delay)
    self:UnpauseTracker(id)
end

if Network:is_client() then
end

function HUDManager:Debug(id)
    local dt = 0
    if self._ehi_debug_time then
        local new_time = TimerManager:game():time()
        dt = new_time - self._ehi_debug_time
        self._ehi_debug_time = new_time
    else
        self._ehi_debug_time = TimerManager:game():time()
    end
    managers.chat:_receive_message(1, "[EHI]", "ID: " .. tostring(id) .. "; dt: " .. dt, Color.white)
end