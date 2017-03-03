Project.CityLoader = Appkit.class(Project.CityLoader)
local CityLoader = Project.CityLoader

LUAUtility = require 'script/lua/lua_utility'

----------------------------- Component functions ------------------------------------

function CityLoader:init()
	Project.city_loader = self
	
	self.cities = stingray.Application.settings()["Cities"]
end

function CityLoader:update(dt)
	
end

function CityLoader:shutdown()
	
end

----------------------------------------------------------------------------------------

function CityLoader:find_city_from_level(level_name)
	for name, _ in pairs(self.cities) do
		if string.find(level_name, name) ~= nil then
			return name
		end
	end
	return nil
end

function CityLoader:start_city(name)
	if Project.components[name] == nil then
		Project.components[name] = {}
	end
	for _, path in pairs(self.cities[name].scripts) do
		local Component = LUAUtility.try_load_module(path)
		if Component and type(Component) == "table" then
			table.insert(Project.components[name], Component())
		end
	end
	Project.UIManager.add_scene(name)
end

function CityLoader:shutdown_city(name)
	Project.components[name] = nil
	Project.UIManager.remove_scene(name)
end

return CityLoader
