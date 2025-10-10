local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local Status = EHI.Const.Trackers.Achievement.Status
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local element_sync_triggers =
{
    [102290] = { id = "VaultGas", icons = { Icon.Teargas }, hook_element = 102157, hint = Hints.Teargas }
}
---@type ParseTriggerTable
local triggers = {
    [102843] = { time = 28.05 + 418/30, id = "Suprise", icons = { "pd2_question" } },
    -- Suprise pull is in CoreWorldInstanceManager

    [101818] = { additional_time = 50 + 9.3, random_time = 30, id = "HeliDropLance", icons = Icon.HeliDropDrill, hint = Hints.DrillPartsDelivery },
    [101820] = { time = 9.3, id = "HeliDropLance", icons = Icon.HeliDropDrill, special_function = SF.SetTrackerAccurate, hint = Hints.DrillPartsDelivery },

    [103919] = { additional_time = 25 + 1 + 13, random_time = 5, id = "Van", icons = Icon.CarEscape, trigger_once = true, hint = Hints.LootEscape },
    [100840] = { time = 1 + 13, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTrackerAccurate, hint = Hints.LootEscape }

    -- levels/instances/unique/bex/bex_computer
    -- levels/instances/unique/bex/bex_server
    -- Handled in CoreWorldInstanceManager
}
if EHI.Mission._SHOW_MISSION_TRACKERS_TYPE.cheaty then
    EHI:LoadTracker("EHICorrectCablesTracker")
    triggers[102225] = EHI:AddCustomCode(function(self)
        local gate_box = managers.worlddefinition:get_unit(EHI:GetInstanceUnitID(100018, 3800))
        if not gate_box then -- Oh no, something happened and our required unit does not exist; skip
            return
        end
        self._trackers:AddTracker({
            id = "CorrectCables",
            remove_on_alarm = true,
            class = "EHICorrectCablesTracker"
        })
        local colors =
        {
            { color = "r", object = "g_light_01" },
            { color = "g", object = "g_light_02" },
            { color = "b", object = "g_light_03" },
            { color = "y", object = "g_light_04" }
        }
        for _, tbl in ipairs(colors) do
            if gate_box:get_object(Idstring(tbl.object)):visibility() then
                self._trackers:CallFunction("CorrectCables", "SetCode", tbl.color)
            end
        end
    end)
    -- 100076 = Wire cut
    triggers[EHI:GetInstanceElementID(100076, 4100)] = { id = "CorrectCables", special_function = SF.CallCustomFunction, f = "RemoveCode", arg = { "b" } }
    triggers[EHI:GetInstanceElementID(100076, 4250)] = { id = "CorrectCables", special_function = SF.CallCustomFunction, f = "RemoveCode", arg = { "g" } }
    triggers[EHI:GetInstanceElementID(100076, 4400)] = { id = "CorrectCables", special_function = SF.CallCustomFunction, f = "RemoveCode", arg = { "r" } }
    triggers[EHI:GetInstanceElementID(100076, 4550)] = { id = "CorrectCables", special_function = SF.CallCustomFunction, f = "RemoveCode", arg = { "y" } }
end
if EHI.IsClient then
    triggers[102157] = { additional_time = 60, random_time = 15, id = "VaultGas", icons = { Icon.Teargas }, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.Teargas }
end

---@type ParseAchievementTable
local achievements =
{
    bex_10 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [103701] = { special_function = EHI.Trigger:RegisterCustomSF(function(self, trigger, element, enabled)
                if enabled then
                    self._unlockable:SetAchievementStatus(trigger.id, Status.Defend)
                    self:UnhookTrigger(103704)
                end
            end) },
            [103702] = { special_function = SF.SetAchievementFailed },
            [103704] = { special_function = SF.SetAchievementFailed },
            [102602] = { special_function = SF.SetAchievementComplete },
            [100107] = { status = Status.Loud, class = TT.Achievement.Status },
        }
    },
    bex_11 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100107] = { counter = {
                { max = 11, id = "bags" },
                { max = 240, id = "boxes" }
            }, call_done_function = true, status_is_overridable = true },
            [103677] = { special_function = EHI.Trigger:RegisterCustomSF(function(self, trigger, ...)
                self._trackers:CallFunction(trigger.id, "IncreaseProgress", 1, "boxes")
            end) },
            [103772] = { special_function = SF.SetAchievementFailed }
        },
        preparse_callback = function(data)
            ---@class bex_11 : EHIAchievementProgressGroupTracker
            ---@field super EHIAchievementProgressGroupTracker
            local bex_11 = class(EHIAchievementProgressGroupTracker)
            function bex_11:post_init(...)
                bex_11.super.post_init(self, ...)
                self:AddLootListener({
                    counter =
                    {
                        f = function(loot)
                            local progress = loot:GetSecuredBagsAmount()
                            self:SetProgress(progress, "bags")
                            if progress >= self._counters_table.bags.max then
                                managers.ehi_loot:RemoveListener(self._id)
                            end
                        end
                    }
                })
            end
            function bex_11:pre_destroy()
                managers.ehi_loot:RemoveListener(self._id)
            end
            function bex_11:CountersDone()
                self:AnimateBG()
                self:SetStatusText("finish", self._counters_table.bags.label)
                self:AnimateMovement(self._anim_params.PanelSizeDecrease)
                local boxes_label = self._counters_table.boxes.label
                boxes_label:parent():remove(boxes_label)
                self._counters_table.boxes = nil
            end
            data.elements[100107].class_table = bex_11
        end
    }
}

local tbl =
{
    [100000] = { remove_vanilla_waypoint = 100005 }
}
EHI.Unit:UpdateInstanceUnits(tbl, 22450)

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 60 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100358] = { id = "Snipers", class = TT.Sniper.Count, sniper_count = 2 }
    other[100359] = { id = "Snipers", class = TT.Sniper.Count, sniper_count = 3 }
    --[[other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%]]
    other[100366] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess" }
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI.Mission:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other,
    sync_triggers = { element = element_sync_triggers }
})
EHI:ShowLootCounter({ max = 11 }, { element = { 100233, 100008 } })
local xp_override =
{
    params =
    {
        min_max =
        {
            loot_all = { min = 4, max = 11 }
        }
    }
}
EHI:AddXPBreakdown({
    plan =
    {
        stealth =
        {
            objectives =
            {
                { amount = 3000, name = "mex2_found_managers_safe" },
                { amount = 1000, name = "mex2_picked_up_tape" },
                { amount = 1000, name = "mex2_used_tape" },
                { amount = 3000, name = "mex2_picked_up_keychain" },
                { amount = 2000, name = "mex2_found_manual" },
                { amount = 3000, name = "pc_hack" },
                { amount = 2000, name = "ggc_laser_disabled" },
                { escape = 2000 }
            },
            loot_all = 1000,
            total_xp_override = xp_override
        },
        loud =
        {
            objectives =
            {
                { amount = 8000, name = "vault_found" },
                { amount = 3000, name = "mex2_it_guy_escorted" },
                { amount = 3000, name = "pc_hack" },
                { amount = 3000, name = "mex2_beast_arrived" },
                { amount = 12000, name = "vault_open" },
                { escape = 3000 }
            },
            loot_all = 1000,
            total_xp_override = xp_override
        }
    }
})