function LevelsTweakData:get_group_ai_state()
	local level_data = Global.level_data and Global.level_data.level_id and self[Global.level_data.level_id]
	if level_data then
        return level_data.group_ai_state or "besiege"
	end
	return "besiege"
end