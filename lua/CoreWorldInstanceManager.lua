if true then
    return
end

function CoreWorldInstanceManager:prepare_mission_data(instance)
	local start_index = instance.start_index
	local folder = instance.folder
	local path = folder .. "/" .. "world"
	local instance_data = self:_get_instance_mission_data(path)
	local continent_data = managers.worlddefinition._continents[instance.continent]
	local convert_list = {}

    log("[EHI] Instance Data before:")
    _G.PrintTable(instance)
    log("-------")
    for key, element in pairs(instance_data.default.elements) do
        log(tostring(key))
        _G.PrintTable(element)
        log("-------")
    end

	for script, script_data in pairs(instance_data) do
		for _, element in ipairs(script_data.elements) do
			element.values.instance_name = instance.name
			convert_list[element.id] = continent_data.base_id + self:_get_mod_id(element.id) + self._start_offset_index + start_index
			element.id = convert_list[element.id]

			if element.values.rotation then
				element.values.rotation = instance.rotation * element.values.rotation
			end

			if element.values.position then
				element.values.position = instance.position + element.values.position:rotate_with(instance.rotation)
			end

			if element.class == "ElementSpecialObjective" then
				element.values.search_position = instance.position + element.values.search_position:rotate_with(instance.rotation)
			elseif element.class == "ElementLootBag" then
				if element.values.spawn_dir then
					element.values.spawn_dir = element.values.spawn_dir:rotate_with(instance.rotation)
				end
			elseif element.class == "ElementSpawnGrenade" then
				element.values.spawn_dir = element.values.spawn_dir:rotate_with(instance.rotation)
			elseif element.class == "ElementSpawnUnit" then
				element.values.unit_spawn_dir = element.values.unit_spawn_dir:rotate_with(instance.rotation)
			elseif element.class == "ElementLaserTrigger" then
				for _, point in pairs(element.values.points) do
					point.rot = instance.rotation * point.rot
					point.pos = instance.position + point.pos:rotate_with(instance.rotation)
				end
			end
		end
	end

	for script, script_data in pairs(instance_data) do
		for _, element in ipairs(script_data.elements) do
			self:_convert_table(convert_list, element.values, continent_data, start_index)
		end
	end

    log("[EHI] Instance Data after:")
    _G.PrintTable(instance)
    log("-------")
    for key, element in pairs(instance_data.default.elements) do
        log(tostring(key))
        _G.PrintTable(element)
        log("-------")
    end

	return instance_data
end