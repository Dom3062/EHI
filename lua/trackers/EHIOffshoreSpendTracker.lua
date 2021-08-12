EHIOffshoreSpendTracker = EHIOffshoreSpendTracker or class(EHIMoneyCounterTracker)
function EHIOffshoreSpendTracker:init(panel, params)
    params.icons = { "Other_H_None_SpendMoney" }
    self._max_offshore_limit = managers.money:offshore()
    EHIOffshoreSpendTracker.super.init(self, panel, params)
end

function EHIOffshoreSpendTracker:MoneyChanged()
    if self._money > self._max_offshore_limit then
        return
    end
    self._text:set_text(self:Format())
    self:FitTheText()
end