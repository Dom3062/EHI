local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local AssetLootDropOff = EHI:GetOption("show_one_icon") and { Icon.LootDrop } or Icon.CarLootDrop
local preload =
{
    { hint = Hints.LootEscape } -- Escape
}
---@type ParseTriggerTable
local triggers = {
    -- Time before escape is available
    [102808] = { run = { time = 65 } },
    [102811] = { run = { time = 80 } },
    [103591] = { run = { time = 126 } },
    [102813] = { run = { time = 186 } },
    [100797] = { run = { time = 240 } },
    [100832] = { run = { time = 270 } },

    -- Fire
    [101412] = { time = 300, id = "Fire", timer_id = "Fire1", icons = { Icon.Fire }, class = TT.Group.Warning, waypoint = { position_from_unit = 101758 }, hint = Hints.Fire },
    [101453] = { time = 300, id = "Fire", timer_id = "Fire2", icons = { Icon.Fire }, class = TT.Group.Warning, waypoint = { position_from_unit = 101759 }, hint = Hints.Fire },

    -- Asset
    [103094] = { time = 20 + (40/3), id = "AssetLootDropOff", icons = AssetLootDropOff, waypoint = { data_from_element = 103152 }, hint = Hints.Loot }
    -- 20: Base Delay
    -- 40/3: Animation finish delay
    -- Total 33.33 s
}
local BaseAssaultDelay = 3.5 + 2.5 + 3 + 2
local other =
{
    [101159] = EHI:AddAssaultDelay({ control = 12 + BaseAssaultDelay }),
    [101166] = EHI:AddAssaultDelay({ control = 10 + BaseAssaultDelay }),
    [101167] = EHI:AddAssaultDelay({ control = 15 + BaseAssaultDelay })
}
if EHI:IsLootCounterVisible() then
    local random_coke = EHI:GetValueBasedOnDifficulty({
        normal = 4,
        hard = 5,
        veryhard = 7,
        overkill_or_above = 9
    })
    local random_money = EHI:IsDifficultyOrBelow(EHI.Difficulties.Hard) and 2 or 4
    other[100544] = EHI:AddLootCounter3(function(self)
        EHI:ShowLootCounterNoChecks({
            max = 0,
            max_random = random_money
        })
    end, { element = { 102827, 103866, 103839, 103152 } })
    other[103997] = EHI:AddCustomCode(function(self)
        self._cache.nightclub_management_office_hidden = true -- Management office (with asset loot drop)
        self._cache.nightclub_hidden_safes = (self._cache.nightclub_hidden_safes or 0) + 1
    end)
    other[103998] = EHI:AddCustomCode(function(self)
        self._cache.nightclub_office_hidden = true -- Office
        self._cache.nightclub_hidden_safes = (self._cache.nightclub_hidden_safes or 0) + 1
    end)
    other[103999] = EHI:AddCustomCode(function(self)
        self._cache.nightclub_cellar_hidden = true -- Cellar
        self._cache.nightclub_hidden_safes = (self._cache.nightclub_hidden_safes or 0) + 1
    end)
    other[103912] = EHI:AddCustomCode(function(self)
        if (self._cache.nightclub_hidden_safes or 0) >= 2 then
            return
        elseif managers.game_play_central:IsMissionUnitEnabled(300940) and not self._cache.nightclub_office_hidden then -- units/payday2/architecture/com_int_nightclub/com_int_nightclub_wall_2m/063 (nightclub_interior continent)
            return
        elseif managers.game_play_central:IsMissionUnitEnabled(300099) and not self._cache.nightclub_cellar_hidden then -- units/payday2/architecture/com_int_nightclub/com_int_nightclub_wall_2m/026 (nightclub_interior continent)
            return
        end
        self._loot:IncreaseLootCounterMaxRandom(random_coke)
    end)
    -- Money
    -- It is much easier to hook into ElementMandatoryBags and reuse the value from the element itself
    -- instead of to hook to every ElementUnitSequence with money in it and then calculate how much money spawned and sub the difference in random bags  
    -- This way I can use max_random for coke only  
    -- However, money still has to be included in the max_random as players may open coke first instead of money  
    local MoneySpawned = EHI.Manager:RegisterCustomSF(function(self, trigger, element, ...) ---@param element ElementMandatoryBags
        self._loot:RandomLootSpawnedAndDeclined(element._values.amount, random_money)
    end)
    other[101877] = { special_function = MoneySpawned }
    other[101878] = { special_function = MoneySpawned }
    other[101882] = { special_function = MoneySpawned }
    other[101883] = { special_function = MoneySpawned }
    -- Coke
    other[101641] = EHI:AddCustomCode(function(self)
        self._loot:RandomLootSpawnedAndDeclined(self._cache.nightclub_coke_spawned or 0, random_coke)
    end)
    local CokeSpawned = EHI:AddCustomCode(function(self)
        self._cache.nightclub_coke_spawned = (self._cache.nightclub_coke_spawned or 0) + 1
    end)
    -- Safe 1
    -- Bottom
    other[101065] = CokeSpawned
    other[101068] = CokeSpawned
    other[101071] = CokeSpawned
    other[101072] = CokeSpawned
    other[101074] = CokeSpawned
    other[101083] = CokeSpawned
    -- Top
    other[101106] = CokeSpawned
    other[101027] = CokeSpawned
    other[101112] = CokeSpawned
    other[101113] = CokeSpawned
    other[101114] = CokeSpawned
    other[101120] = CokeSpawned
    -- Safe 2
    -- Bottom
    other[101440] = CokeSpawned
    other[101441] = CokeSpawned
    other[101442] = CokeSpawned
    other[101461] = CokeSpawned
    other[101462] = CokeSpawned
    other[101468] = CokeSpawned
    -- Top
    other[101478] = CokeSpawned
    other[101481] = CokeSpawned
    other[101484] = CokeSpawned
    other[101516] = CokeSpawned
    other[101624] = CokeSpawned
    other[101625] = CokeSpawned
    -- Safe 3
    -- Bottom
    other[102666] = CokeSpawned
    other[102667] = CokeSpawned
    other[102668] = CokeSpawned
    other[102671] = CokeSpawned
    other[102672] = CokeSpawned
    other[102673] = CokeSpawned
    -- Top
    other[102674] = CokeSpawned
    for i = 102676, 102680, 1 do
        other[i] = CokeSpawned
    end
end
if EHI:IsEscapeChanceEnabled() then
    EHI:AddOnAlarmCallback(function(dropin)
        -- Civilian kills do not count towards escape chance
        -- Reported in: https://steamcommunity.com/app/218620/discussions/14/5487063042655462839/
        managers.ehi_escape:AddEscapeChanceTracker(false, 25, 0)
    end)
    other[104285] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
end
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    ---@class EHIMultipleSniperLoopsTracker : EHITracker, EHISniperBaseTracker
    EHIMultipleSniperLoopsTracker = ehi_sniper_class(EHITracker, { hint = "enemy_snipers_loop" })
    function EHIMultipleSniperLoopsTracker:OverridePanel()
        self._single_sniper = true
        self._loops_running = 0
        self:SetBGSize(self._bg_box:w() / 2)
        self._text:set_w(self._bg_box:w())
        self._text:set_visible(false)
        self:FitTheText()
        self._count_text = self:CreateText({
            text = "1",
            x = 0,
            color = self._sniper_text_color,
            FitTheText = true
        })
        self._loops = { { t = 0, text = self._text, count = self._count_text, running = false } }
        self:SniperLogicStarted()
        self:SniperSpawned()
    end
    function EHIMultipleSniperLoopsTracker:AddAnotherLoop()
        self._text:set_w(self._bg_box:w() / 2)
        self:FitTheText()
        self._count_text:set_w(self._text:w())
        self:FitTheText(self._count_text)
        self._text2 = self:CreateText({
            w = self._text:w(),
            left = self._text:right(),
            FitTheText = true,
            visible = false
        })
        self._count_text2 = self:CreateText({
            text = "1",
            left = self._text2:x(),
            color = self._sniper_text_color,
            w = self._text2:w(),
            FitTheText = true
        })
        self._loops[2] = { t = 0, text = self._text2, count = self._count_text2, running = false }
        self:SniperLogicStarted()
        self:SniperSpawned()
    end
    function EHIMultipleSniperLoopsTracker:update(dt)
        for _, data in ipairs(self._loops) do
            if data.running then
                data.t = data.t - dt
                if data.t <= 0 then
                    data.text:set_visible(false)
                    data.count:set_visible(true)
                    data.running = false
                    self:SniperSpawned()
                    self._loops_running = self._loops_running - 1
                    if self._loops_running <= 0 then
                        self:RemoveTrackerFromUpdate()
                    end
                    self:AnimateBG(1)
                else
                    data.text:set_text(self:FormatTime(data.t))
                end
            end
        end
    end
    ---@param t number
    ---@param id number
    function EHIMultipleSniperLoopsTracker:RestartLoop(t, id)
        local loop = self._loops[id]
        loop.t = t
        loop.count:set_visible(false)
        loop.text:set_visible(true)
        loop.running = true
        self:SetAndFitTheText(self:FormatTime(t), loop.text)
        self._loops_running = self._loops_running + 1
        if self._loops_running == 1 then
            self:AddTrackerToUpdate()
        end
        self:AnimateBG(1)
    end
    other[101832] = { id = "Snipers", class = "EHIMultipleSniperLoopsTracker" }
    other[101845] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "AddAnotherLoop" }
    local SniperLootRestart = EHI.Manager:RegisterCustomSF(function(self, trigger, ...)
        self._trackers:CallFunction(trigger.id, "RestartLoop", trigger.time, trigger.loop or 1)
    end)
    other[101775] = { id = "Snipers", time = 85, special_function = SniperLootRestart }
    other[101776] = { id = "Snipers", time = 75, special_function = SniperLootRestart }
    other[101777] = { id = "Snipers", time = 70, special_function = SniperLootRestart }
    other[101778] = { id = "Snipers", time = 60, special_function = SniperLootRestart }
    other[101785] = { id = "Snipers", time = 90, special_function = SniperLootRestart }
    other[101780] = { id = "Snipers", time = 65, loop = 2, special_function = SniperLootRestart }
    other[101781] = { id = "Snipers", time = 75, loop = 2, special_function = SniperLootRestart }
    other[101782] = { id = "Snipers", time = 67, loop = 2, special_function = SniperLootRestart }
    other[101783] = { id = "Snipers", time = 56, loop = 2, special_function = SniperLootRestart }
    other[101784] = { id = "Snipers", time = 55, loop = 2, special_function = SniperLootRestart }
end

EHI.Manager:ParseTriggers({
    mission = triggers,
    other = other,
    preload = preload
}, "Escape", Icon.CarEscape)
local min_money = EHI:GetValueBasedOnDifficulty({
    hard_or_below = 1,
    veryhard_or_above = 2
})
local max_money = min_money * 2
local max_bags = max_money + EHI:GetValueBasedOnDifficulty({
    normal = 4,
    hard = 5,
    veryhard = 7,
    overkill_or_above = 9
})
EHI:AddXPBreakdown({
    objective =
    {
        escape =
        {
            { amount = 10000, stealth = true },
            { amount = 8000, loud = true, escape_chance = { start_chance = 25 } },
            { amount = 4000, loud = true, c4_used = true, escape_chance = { start_chance = 25 } }
        }
    },
    loot_all = 1000,
    total_xp_override =
    {
        params =
        {
            escape =
            {
                loot_all = { min = min_money, max = max_bags }
            }
        }
    }
})