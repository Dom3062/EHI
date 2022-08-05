local EHI = EHI
local Icon = EHI.Icons
local TT = EHI.Trackers
local SF = EHI.SpecialFunctions
local truck_delay = 524/30
local boat_delay = 450/30
local triggers = {
    [104082] = { time = 30 + 24 + 3, id = "HeliThermalDrill", icons = Icon.HeliDropDrill },

    -- Boat
    [103273] = { time = boat_delay, id = "BoatSecureTurret", icons = { Icon.Boat, Icon.LootDrop } },
    [103041] = { time = 30 + boat_delay, id = "BoatSecureAmmo", icons = { Icon.Boat, Icon.LootDrop } },

    -- Truck
    [105055] = { time = 15 + truck_delay, id = "TruckSecureTurret", icons = { Icon.Car, Icon.LootDrop } },
    [105183] = { time = 30 + 524/30, id = "TruckSecureAmmo", icons = { Icon.Car, Icon.LootDrop } },

    -- Achievement bugged, can be achieved in stealth
    -- Reported in: https://steamcommunity.com/app/218620/discussions/14/3048357185566603324/
    [104716] = { id = "armored_6", class = TT.AchievementNotification },
    [103311] = { id = "armored_6", special_function = SF.SetAchievementFailed }
}

EHI:ParseTriggers(triggers)
if EHI:GetOption("show_achievement") then
    EHI:ShowAchievementLootCounter({
        achievement = "armored_1",
        max = 20,
        exclude_from_sync = true,
        counter =
        {
            check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
            loot_type = "ammo"
        }
    })
    EHI:AddLoadSyncFunction(function(self)
        if EHI.ConditionFunctions.IsStealth() then
            self:AddAchievementNotificationTracker("armored_6")
        end
    end)
end
EHI:ShowLootCounter({ max = 23 })

local tbl = {}
for i = 0, 500, 100 do
    --levels/instances/unique/train_cam_computer
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    tbl[EHI:GetInstanceElementID(100022, i)] = { icons = { Icon.Vault }, remove_on_alarm = true }
end
EHI:UpdateUnits(tbl)