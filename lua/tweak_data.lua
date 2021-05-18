if EHI._hooks.tweak_data then
	return
else
	EHI._hooks.tweak_data = true
end

tweak_data.ehi =
{
    color =
    {
        InaccurateColor = Color(255, 255, 165, 0) / 255
    }
}