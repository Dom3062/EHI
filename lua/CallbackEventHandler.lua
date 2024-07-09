local EHI = EHI
if EHI:CheckHook("CallbackEventHandler") then
    return
end

---@class CallbackEventHandler
---@field new fun(self: self): self
---@field add fun(self: self, func: function)
---@field dispatch fun(self: self, ...)
---@field clear fun(self: self)

function CallbackEventHandler:dispatch_and_clear(...)
    self:dispatch(...)
    self:clear()
end