local EHI = EHI
EHIkosugi5Tracker = class(EHIAchievementProgressTracker)
function EHIkosugi5Tracker:init(panel, params)
    params.max = 16 -- Random loot
    self._armor_max = 4 -- Armor
    self._armor_counter = 0
    self._completion = {}
    EHIkosugi5Tracker.super.init(self, panel, params)
    self._remove_after_reaching_counter_target = false
    EHI:AddAchievementToCounter({
        achievement = "kosugi_5",
        counter =
        {
            check_type = EHI.LootCounter.CheckType.CustomCheck,
            f = function(self, tracker_id, loot_type)
                local armor_count = self:GetSecuredBagsTypeAmount("samurai_suit")
                local total_count = self:GetSecuredBagsAmount()
                managers.ehi:CallFunction(tracker_id, "SetProgressArmor", armor_count)
                managers.ehi:SetTrackerProgress(tracker_id, total_count - armor_count)
            end
        }
    })
end

function EHIkosugi5Tracker:OverridePanel(params)
    self._panel:set_w(self._panel:w() * 2)
    self._time_bg_box:set_w(self._time_bg_box:w() * 2)
    self._armor_progress_text = self._time_bg_box:text({
        name = "text2",
        text = self:FormatArmorProgress(),
        align = "center",
        vertical = "center",
        w = self._time_bg_box:w() / 2,
        h = self._time_bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h() * self._text_scale,
        color = params.text_color or Color.white
    })
    self:FitTheText(self._armor_progress_text)
    self._armor_progress_text:set_left(self._text:right())
    if self._icon1 then
        self._icon1:set_x(self._icon1:x() * 2)
    end
end

function EHIkosugi5Tracker:FormatArmorProgress()
    return self._armor_counter .. "/" .. self._armor_max
end

function EHIkosugi5Tracker:SetCompleted(force)
    EHIkosugi5Tracker.super.SetCompleted(self, force)
    if self._status then
        self._text:set_text(self:Format())
        self:FitTheText()
        self:CheckCompletion("loot")
    end
end

function EHIkosugi5Tracker:SetProgressArmor(progress)
    if self._armor_counter ~= progress and not self._armor_counting_disabled then
        self._armor_counter = progress
        self._armor_progress_text:set_text(self:FormatArmorProgress())
        self:FitTheText(self._armor_progress_text)
        if self._armor_counter == self._armor_max then
            self._armor_progress_text:set_color(Color.green)
            self._armor_counting_disabled = true
            self:CheckCompletion("armor")
        end
        self:AnimateBG()
    end
end

function EHIkosugi5Tracker:CheckCompletion(type)
    self._completion[type] = true
    if self._completion.loot and self._completion.armor and not self._completion.final then
        self._completion.final = true
        self._parent_class:AddTrackerToUpdate(self._id, self)
    end
end

local function CheckForBrokenWeapons()
    local world = managers.worlddefinition
    for i = 100863, 100867, 1 do
        local weapon = world:get_unit(i)
        if weapon and weapon:damage() and weapon:damage()._state and weapon:damage()._state.graphic_group and weapon:damage()._state.graphic_group.grp_wpn then
            local state = weapon:damage()._state.graphic_group.grp_wpn
            if state[1] == "set_visibility" and state[2] then
                --EHI:Log("Found broken unit weapon with ID: " .. tostring(i))
                managers.ehi:IncreaseTrackerProgressMax("LootCounter", 1)
            end
        end
    end
end

local function CheckForBrokenCocaine() -- Not working for drop-ins
    local world = managers.worlddefinition
    for i = 100686, 100692, 1 do -- 2 - 8
        local unit = world:get_unit(i)
        if unit and unit:damage() and unit:damage()._variables and unit:damage()._variables.var_hidden == 0 then
            --EHI:Log("Found broken unit cocaine with ID: " .. tostring(unit:editor_id()))
            managers.ehi:IncreaseTrackerProgressMax("LootCounter", 1)
        end
    end
end

for _, unit_id in pairs({100098, 102897, 102899, 102900}) do
    managers.mission:add_runned_unit_sequence_trigger(unit_id, "interact", function(unit)
        managers.ehi:AddTracker({
            id = tostring(unit_id),
            time = 10,
            icons = { "pd2_fire" }
        })
    end)
end

EHI.AchievementTrackers.EHIkosugi5Tracker = true
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local DisableTriggerAndExecute = EHI:GetFreeCustomSpecialFunctionID()
local trigger = { special_function = SF.Trigger, data = { 1, 2 } }
local kosugi_3 = { id = "kosugi_3", special_function = SF.IncreaseProgress }
local triggers = {
    [1] = { time = 300, id = "Blackhawk", icons = { Icon.Heli, "pd2_goto" } },
    [2] = { special_function = SF.RemoveTriggers, data = { 101131, 100900 } },
    [101131] = trigger,
    [100900] = trigger,

    [100955] = { time = 10, id = "KeycardLeft", icons = { Icon.Keycard }, class = TT.Warning, special_function = DisableTriggerAndExecute, data = { id = 100957 } },
    [100957] = { time = 10, id = "KeycardRight", icons = { Icon.Keycard }, class = TT.Warning, special_function = DisableTriggerAndExecute, data = { id = 100955 } },
    [100967] = { special_function = SF.RemoveTrackers, data = { "KeycardLeft", "KeycardRight" } }
}

local achievements =
{
    [102700] = { special_function = SF.Trigger, data = { 1027001, 1027002, 1027003, 1027004 } },
    [1027001] = { max = 6, id = "kosugi_2", class = TT.AchievementProgress, remove_after_reaching_target = false },
    [1027002] = { max = 7, id = "kosugi_3", class = TT.AchievementProgress },
    [1027003] = { id = "kosugi_5", class = "EHIkosugi5Tracker" },
    [1027004] = { special_function = SF.CustomCode, f = function()
        CheckForBrokenWeapons()
        CheckForBrokenCocaine()
    end},

    [102796] = { id = "kosugi_2", special_function = SF.SetAchievementFailed },
    [100311] = { id = "kosugi_2", special_function = SF.IncreaseProgress },
    [104040] = kosugi_3, -- Artifact
    [104041] = kosugi_3, -- Money
    [104042] = kosugi_3, -- Coke
    [104044] = kosugi_3, -- Server
    [104047] = kosugi_3, -- Gold
    [104048] = kosugi_3, -- Weapon
    [104049] = kosugi_3, -- Painting
}

EHI:ParseTriggers(triggers)
EHI:RegisterCustomSpecialFunction(DisableTriggerAndExecute, function(id, t, ...)
    EHI:UnhookTrigger(t.data.id)
    EHI:CheckCondition(id)
end)
EHI:AddLoadSyncFunction(function(self)
    self:SetTrackerProgress("kosugi_1", managers.loot:GetSecuredBagsAmount())
    local kosugi_3_counter = 0
    local kosugi_5_counter_loot = 0
    local kosugi_5_counter_armor = managers.loot:GetSecuredBagsTypeAmount("samurai_suit")
    for _, loot_type in ipairs({ "artifact_statue", "money", "coke", "gold", "circuit", "weapon", "painting" }) do
        local amount = managers.loot:GetSecuredBagsTypeAmount(loot_type)
        kosugi_3_counter = kosugi_3_counter + math.min(amount, 1)
        kosugi_5_counter_loot = kosugi_5_counter_loot + amount
    end
    if kosugi_3_counter < 7 then
        EHI:Trigger(1027002)
        self:SetTrackerProgress("kosugi_3", kosugi_3_counter)
    end
    if kosugi_5_counter_loot < 16 or kosugi_5_counter_armor < 4 then
        EHI:Trigger(1027003)
        self:SetTrackerProgress("kosugi_5", math.min(kosugi_5_counter_loot, 16))
        self:CallFunction("kosugi_5", "SetProgressArmor", math.min(kosugi_5_counter_armor, 4))
    end
    CheckForBrokenWeapons()
    if not managers.game_play_central._mission_disabled_units[103995] then
        self:IncreaseTrackerProgressMax("LootCounter")
    end
end)

-- Loot Counter
-- 2 cocaine
-- 1 server
-- 2 random money bundles inside the warehouse
-- 4 random loot outside
-- 4 pieces of armor
local base_amount = 2 + 1 + 2 + 4 + 4
local random_weapons = 2
local random_paintings = 2
local crates = 4 -- (Normal + Hard)
if EHI:IsBetweenDifficulties(EHI.Difficulties.VeryHard, EHI.Difficulties.OVERKILL) then
    crates = 5
elseif EHI:IsDifficultyOrAbove(EHI.Difficulties.Mayhem) then
    crates = 6
    random_weapons = 1
    random_paintings = 1
end
local total = base_amount + crates + random_weapons + random_paintings
EHI:ShowLootCounter({
    max = total,
    triggers =
    {
        [103396] = { special_function = SF.IncreaseProgressMax }
    }
})
-- Not included bugged loot, this is checked after spawn -> 1027003
-- Reported here:
-- https://steamcommunity.com/app/218620/discussions/14/5710018482972011532/

-- daily_secret_identity -> Destroy 9 cameras

EHI:ShowAchievementLootCounter({
    achievement = "kosugi_1",
    max = 4,
    exclude_from_sync = true,
})
EHI:ShowAchievementLootCounter({
    achievement = "kosugi_4",
    max = 4,
    exclude_from_sync = true,
    counter =
    {
        check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
        loot_type = "samurai_suit"
    }
})