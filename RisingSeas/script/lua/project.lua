-----------------------------------------------------------------------------------
-- This implementation uses the default SimpleProject and the Project extensions are 
-- used to extend the SimpleProject behavior.

-- This is the global table name used by Appkit Basic project to extend behavior
Project = Project or {}

require 'script/lua/flow_callbacks'
Scheduler = require 'script/lua/scheduler'
CityLoader = require 'script/lua/city_loader'
Input = require 'script/lua/input'
Effects = require 'script/lua/effects'
ExampleClass = require 'script/lua/example_class'
UIManager = require 'script/lua/ui_manager'

Project.components = {}
Project.components.common = {}

local first_load = true

Project.level_names = {
	world = "content/levels/World/World"
}

Project.ui = {
	s2dproj = "ui/rising_seas_ui.s2d/rising_seas_ui",
	default_scene = "ui/rising_seas_ui.s2d/Empty"
}

-- Can provide a config for the basic project, or it will use a default if not.
local SimpleProject = require 'core/appkit/lua/simple_project'
SimpleProject.config = {
	standalone_init_level_name = Project.level_names.world,
	camera_unit = "core/appkit/units/camera/camera",
	camera_index = 1,
	shading_environment = nil, -- Will override levels that have env set in editor.
	create_free_cam_player = true, -- Project will provide its own player.
	exit_standalone_with_esc_key = true
}

-- Optional function by SimpleProject after level, world and player is loaded 
-- but before lua trigger level loaded node is activated.
function Project.on_level_load_pre_flow()

	if stingray.Window then
		stingray.Window.set_show_cursor(true)
		stingray.Window.set_clip_cursor(false)
	end

	if first_load then
	    --Add components here
		table.insert(Project.components.common, Scheduler())
		table.insert(Project.components.common, CityLoader())
		table.insert(Project.components.common, Input())
		table.insert(Project.components.common, Effects())
		table.insert(Project.components.common, ExampleClass())		
		table.insert(Project.components.common, UIManager())

    	first_load = false
	end
	
	local name = Project.city_loader:find_city_from_level(SimpleProject.level_name)
	Project.city_loader:start_city(name)
	
	--Call start on all components
	for _, level_components in pairs(Project.components) do
		for _, c in pairs(level_components) do
			if c.start then
				c:start()
			end
		end
    end
end

function Project.on_level_shutdown_post_flow()
	for _, level_components in pairs(Project.components) do
		for _, c in pairs(level_components) do
			if c.exit then
				c:exit()
			end
		end
    end

	local name = Project.city_loader:find_city_from_level(SimpleProject.level_name)
	Project.city_loader:shutdown_city(name)
end

-- This is triggered after the level is initialized, after on_level_load_pre_flow. Only once.
function Project.on_init_complete()

end	

-- Optional function called by SimpleProject after world update (we will probably want to split to pre/post appkit calls)
function Project.update(dt)
	for _, level_components in pairs(Project.components) do
		for _, c in pairs(level_components) do
			if c.update then
				c:update(dt)
			end
		end
    end
end

-- Optional function called by SimpleProject *before* appkit/world render
function Project.render()
end

-- Optional function called by SimpleProject *before* appkit/level/player/world shutdown
function Project.shutdown()
	for _, level_components in pairs(Project.components) do
		for _, c in pairs(level_components) do
			if c.shutdown then
				c:shutdown()
			end
		end
    end
end

return Project
