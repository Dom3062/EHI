local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove("overkill")
local fire_recharge = { time = 180, id = "FireRecharge", icons = { Icon.Fire, Icon.Loop } }
local fire_t = { time = 60, id = "Fire", icons = { Icon.Fire }, class = TT.Warning }
local triggers = {
    [100647] = { time = 240 + 60, id = "Chimney", icons = { Icon.Escape, Icon.LootDrop } },
    [EHI:GetInstanceElementID(100078, 10700)] = { time = 60, id = "Chimney", icons = { Icon.Escape, Icon.LootDrop }, special_function = SF.AddTrackerIfDoesNotExist },
    [EHI:GetInstanceElementID(100078, 11000)] = { time = 60, id = "Chimney", icons = { Icon.Escape, Icon.LootDrop }, special_function = SF.AddTrackerIfDoesNotExist },
    [EHI:GetInstanceElementID(100011, 10700)] = { time = 207 + 3, id = "ChimneyClose", icons = { Icon.Escape, Icon.LootDrop, Icon.Wait }, class = TT.Warning, special_function = SF.ReplaceTrackerWithTracker, data = { id = "Chimney" } },
    [EHI:GetInstanceElementID(100011, 11000)] = { time = 207 + 3, id = "ChimneyClose", icons = { Icon.Escape, Icon.LootDrop, Icon.Wait }, class = TT.Warning, special_function = SF.ReplaceTrackerWithTracker, data = { id = "Chimney" } },
    [EHI:GetInstanceElementID(100135, 11300)] = { time = 12, id = "SafeEvent", icons = { Icon.Heli, "pd2_goto" } },
    [101167] = { time = 1800, id = "cane_2", class = TT.AchievementUnlock, condition = show_achievement and ovk_and_up },
    [101176] = { id = "cane_2", special_function = SF.SetAchievementFailed }
}
for _, index in ipairs({0, 120, 240, 360, 480}) do
    local recharge = EHI:DeepClone(fire_recharge)
    recharge.id = recharge.id .. index
    triggers[EHI:GetInstanceElementID(100024, index)] = recharge
    local fire = EHI:DeepClone(fire_t)
    fire.id = fire.id .. index
    triggers[EHI:GetInstanceElementID(100022, index)] = fire
end

EHI:ParseTriggers(triggers)
if show_achievement and ovk_and_up then
    EHI:ShowAchievementLootCounter({
        achievement = "cane_3",
        max = 100,
        exclude_from_sync = true,
        remove_after_reaching_target = false
    })
end

local tbl =
{
    --cane_santa_event
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    [EHI:GetInstanceElementID(100014, 11300)] = { ignore = true },
    [EHI:GetInstanceElementID(100056, 11300)] = { ignore = true },
    [EHI:GetInstanceElementID(100226, 11300)] = { ignore = true },
    [EHI:GetInstanceElementID(100227, 11300)] = { icons = { Icon.Vault }, remove_on_pause = true, completion = true }
}
for _, index in ipairs({0, 120, 240, 360, 480}) do
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    -- OVK decided to use one timer for fire and fire recharge
	-- This ignores them and that timer is implemented in the for loop above
    tbl[EHI:GetInstanceElementID(100002, index)] = { ignore = true }
end
EHI:UpdateUnits(tbl)