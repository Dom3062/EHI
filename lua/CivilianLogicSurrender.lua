local EHI = EHI
if EHI:CheckLoadHook("CivilianLogicSurrender") or EHI:IsClient() or not EHI:CanShowCivilianCountTracker() or EHI:GetOption("civilian_count_tracker_format") == 1 then
    return
end

local original = CivilianLogicSurrender.exit
function CivilianLogicSurrender.exit(data, ...)
    if data.internal_data.is_hostage then
        managers.ehi_tracker:CallFunction("CivilianCount", "CivilianUntied", data.key)
    end
    original(data, ...)
end