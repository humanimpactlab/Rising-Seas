local thisActor = ...

-- ============================================================================
-- Stage setup
-- ============================================================================
-- Since there are Vector Graphics in the scene, enable EdgeAA for the Stage and its children, unless disabled:
scaleform.Stage.set_edge_aa_mode(scaleform.EdgeAAModes.On);
scaleform.Stage.set_fps(30);
scaleform.Stage.set_view_scale_mode(scaleform.ViewScaleModes.NoScale);
-------------------------------------------------------------------------------

local scenes_by_name = {}
local num_scenes = 1

local function add_scene(scene_name)
	if scenes_by_name[scene_name] ~= nil then
		print(string.format("WARNING: Trying to add a Scene already added ('%s')", scene_name))
		return
	end

	local scene_to_add = scaleform.Actor.load(scene_name)
	scaleform.Stage.add_scene(scene_to_add)
	num_scenes = num_scenes + 1

	scenes_by_name[scene_name] = scene_to_add
	print(string.format("Adding Scene '%s'", scene_name))
end

local function remove_all_scenes()
	scaleform.Stage.remove_all_scenes()
	scenes_by_name = {}
	num_scenes = 0
end

local function remove_scene(scene_name)
	local scene = scenes_by_name[scene_name]
	if scene == nil then
		print(string.format("WARNING: Trying to remove a Scene that doesn't exist (%s)", scene_name))
		return
	end
	scaleform.Stage.remove_scene(scene)
	print(string.format("Removing Scene '%s'", scene_name))
	scenes_by_name[scene_name] = nil
	num_scenes = num_scenes - 1
end

local addedListener = scaleform.EventListener.create(addedListener, function(e)
	add_scene("Main")
end);

function toggle_visibility(scene_name, visible)
	local scene = scenes_by_name[scene_name]
	if scene == nil then
		print(string.format("WARNING: Trying to toggle visibility fora Scene that doesn't exist (%s)", scene_name))
		return
	end

	scaleform.Actor.set_visible(scene, visible)
	print(string.format("Toggling visibility for Scene '%s'", scene_name), visible)
end

local customListener = scaleform.EventListener.create(customListener, function(e)
	if e.name == "add_scene" then
		add_scene(e.data.scene..".s2dscene")
	elseif e.name == "remove_all_scenes" then
		remove_all_scenes()
	elseif e.name == "show_ui" then
		toggle_visibility(e.data.scene..".s2dscene", true)
	elseif e.name == "hide_ui" then
		toggle_visibility(e.data.scene..".s2dscene", false)
	elseif e.name == "remove_scene" then
		remove_scene(e.data.scene..".s2dscene")
	end
end);

scaleform.EventListener.connect(customListener, thisActor, scaleform.EventTypes.Custom)
scaleform.EventListener.connect(addedListener, thisActor, scaleform.EventTypes.Added)