---@class EHIMoneyTracker : EHINeededValueTracker
---@field super EHINeededValueTracker
EHIMoneyTracker = class(EHINeededValueTracker)
EHIMoneyTracker._OFFSHORE_RATE = 1 - tweak_data:get_value("money_manager", "offshore_rate") -- 0.8
EHIMoneyTracker._SPENDING_RATE = 1 - EHIMoneyTracker._OFFSHORE_RATE -- 0.2
function EHIMoneyTracker:pre_init(params)
    EHIMoneyTracker.super.pre_init(self, params)
    self._assets_cost = params.spend_on_assets
    self._previous_total = 0
    self._send_to_offshore = 0
    self._send_to_spending = 0
    self._money_multiplier = params.alive_players_multiplier or 1
    self._secured_total = params.bags_value or 0
    self._small_secured_total = params.small_loot_value or 0
end

function EHIMoneyTracker:post_init(params)
    EHIMoneyTracker.super.post_init(self, params)
    self._job_payout = params.job_payout
    local total_money = self._assets_cost + self._job_payout + self._secured_total + self._small_secured_total
    if total_money > 0 then
        self:SetProgress(self._job_payout)
    end
end

if EHI:GetOption("money_tracker_format") == 1 then
    function EHIMoneyTracker:Format()
        return string.format("%s/%s", managers.experience:cash_string(self._send_to_offshore), managers.experience:cash_string(self._send_to_spending))
    end

    function EHIMoneyTracker:ShouldColorGreen()
        return self._send_to_offshore > 0 and self._send_to_spending > 0
    end

    function EHIMoneyTracker:ShouldColorRed()
        return self._send_to_spending < 0
    end
elseif EHI:GetOption("money_tracker_format") == 2 then
    function EHIMoneyTracker:Format()
        return string.format("%s/%s", managers.experience:cash_string(self._send_to_spending), managers.experience:cash_string(self._send_to_offshore))
    end

    function EHIMoneyTracker:ShouldColorGreen()
        return self._send_to_offshore > 0 and self._send_to_spending > 0
    end

    function EHIMoneyTracker:ShouldColorRed()
        return self._send_to_spending < 0
    end
elseif EHI:GetOption("money_tracker_format") == 3 then
    function EHIMoneyTracker:Format()
        return string.format("%s", managers.experience:cash_string(self._send_to_offshore))
    end

    function EHIMoneyTracker:ShouldColorGreen()
        return self._send_to_offshore > 0
    end

    function EHIMoneyTracker:ShouldColorRed()
        return false
    end
else
    function EHIMoneyTracker:Format()
        return string.format("%s", managers.experience:cash_string(self._send_to_spending))
    end

    function EHIMoneyTracker:ShouldColorGreen()
        return self._send_to_spending > 0
    end

    function EHIMoneyTracker:ShouldColorRed()
        return self._send_to_spending < 0
    end
end

---@param amount number
function EHIMoneyTracker:CivilianKilled(amount)
    self._civilian_deduction_total = (self._civilian_deduction_total or 0) + amount
    self:SetTotal(true)
end

---@param total_amount number
function EHIMoneyTracker:LootSecured(total_amount)
    if self._secured_total == total_amount then
        return
    end
    self._secured_total = total_amount
    self:SetTotal()
end

---@param total_amount number
function EHIMoneyTracker:SmallLootSecured(total_amount)
    if self._small_secured_total == total_amount then
        return
    end
    self._small_secured_total = total_amount
    self:SetTotal()
end

---@param force_refresh boolean?
function EHIMoneyTracker:SetTotal(force_refresh)
    local total = self._secured_total + self._job_payout + self._small_secured_total
    if total ~= self._previous_total or force_refresh then
        self._previous_total = total
        self:SetProgress(total)
    end
end

---@param new_multiplier number
function EHIMoneyTracker:MultiplierChanged(new_multiplier)
    self._money_multiplier = new_multiplier
    self:SetProgress(self._previous_total == 0 and self._job_payout or self._previous_total)
end

function EHIMoneyTracker:SetProgress(progress)
    progress = progress * self._money_multiplier
    self._send_to_offshore = math.round(progress * self._OFFSHORE_RATE)
    self._send_to_spending = math.round(progress * self._SPENDING_RATE) - (self._civilian_deduction_total or 0) - self._assets_cost
    self:SetAndFitTheText()
    self:AnimateBG(1)
    if self:ShouldColorGreen() then
        self:SetTextColor(Color.green)
    elseif self:ShouldColorRed() then
        self:SetTextColor(Color.red)
    else
        self:SetTextColor()
    end
end
EHIMoneyTracker.FormatProgress = EHIMoneyTracker.Format