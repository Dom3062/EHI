local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local c4 = { time = 5, id = "C4", icons = { Icon.C4 } }
local triggers = {
    [100915] = { time = 4640/30, id = "CraneMoveGas", icons = { Icon.Winch, Icon.Fire, "pd2_goto" }, waypoint = { position = Vector3(-17900, 7800, 56.6182) } },
    [100967] = { time = 3660/30, id = "CraneMoveGold", icons = { Icon.Escape } },
    -- C4 (Doors)
    [100985] = c4,
    -- C4 (GenSec Truck)
    [100830] = c4,
    [100961] = c4
}

local achievements =
{
    [100484] = { time = 300, id = "farm_2", class = TT.AchievementUnlock },
    [100485] = { time = 30, id = "farm_4", class = TT.Achievement },

    [100319] = { id = "farm_2", special_function = SF.SetAchievementFailed },
    [102841] = { id = "farm_4", special_function = SF.SetAchievementComplete },
    [101553] = { id = "farm_3", class = TT.AchievementStatus, difficulty_pass = ovk_and_up },
    [103394] = { id = "farm_3", special_function = SF.SetAchievementFailed },
    [102880] = { id = "farm_3", special_function = SF.SetAchievementComplete },
}

EHI:ParseTriggers(triggers, achievements)

if show_achievement then
    if ovk_and_up then
        EHI:ShowAchievementLootCounter({
            achievement = "farm_6",
            max = 1,
            exclude_from_sync = true,
            remove_after_reaching_target = false,
            counter =
            {
                check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
                loot_type = "din_pig"
            }
        })
        if managers.ehi:TrackerExists("farm_6") then
            EHI:ShowLootCounter({
                max = 10,
                no_counting = true
            })
            EHI:HookLootCounter(EHI.LootCounter.CheckType.OneTypeOfLoot, "gold")
        else
            EHI:ShowLootCounter({ max = 11 })
        end
        EHI:HookWithID(HUDManager, "sync_set_assault_mode", "EHI_farm_1_achievement", function(self, mode, ...)
            if mode == "phalanx" then
                self.ehi:AddTracker({
                    id = "farm_1",
                    status = "finish",
                    icons = EHI:GetAchievementIcon("farm_1"),
                    exclude_from_sync = true,
                    class = EHI.Trackers.AchievementStatus,
                })
            else
                self.ehi:SetAchievementFailed("farm_1")
            end
        end)
    else
        EHI:ShowLootCounter({ max = 10 })
    end
else
    local max = 10
    if ovk_and_up then
        max = 11
    end
    EHI:ShowLootCounter({ max = max })
end

local tbl =
{
    -- Drills
    [100035] = { remove_vanilla_waypoint = true, waypoint_id = 103175 },
    [100949] = { remove_vanilla_waypoint = true, waypoint_id = 103174 }
}
EHI:UpdateUnits(tbl)