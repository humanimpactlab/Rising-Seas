Project.World = Appkit.class(Project.World)
local World = Project.World

require 'script/lua/math'
AppkitUtility = require 'script/lua/appkit_utility'

local EARTH_DIAMETER = 1
local PIN_SCALE = 0.25
local TRANSITION_TIME = 1.0
local INERTIA_MULTIPLIER = 0.2
local VERTICAL_INERTIA_MULTIPLIER = 3.0
local VERTICAL_ROTATION_LIMIT = 17

local inertia = stingray.Vector3Box(5.0,0.0,0.0) --initial inertia
local rx, ry, rz = -15,0,0 --initial world rotation, in euler degrees

----------------------------- Component functions ------------------------------------

function World:init()
	Project.world = self

	self._in_transition = false
	self._change_levels = false
	self._next_level_name = ""

	self._pins = {}

	-- We scale x by -1 because of the camera position
	-- NOTE: the world_gui coord system is weird... To be sorted out...
	local mat = stingray.Matrix4x4.identity()
	stingray.Matrix4x4.set_scale(mat,s3d.Vector3(-1,1,1))
	self.gui = stingray.World.create_world_gui(Appkit.managed_world.world, mat,1,1,"immediate")
	self.world = stingray.World.unit_by_name(Appkit.managed_world.world, "earth")
end

function World:start()
	for name, c in pairs(Project.city_loader.cities) do
		if c.location then
			self:spawn_pin(name, c.location, c.label)
		end
	end
end

function World:update(dt)
	-- Prevent update if we are loading a new level.
	-- This prevents us from accessing a deleted unit.
	-- TODO: Create a better implementation of this after resource management is done.
	if self._change_levels then
		SimpleProject.change_level(self._next_level_name)
		self._change_levels = false
	else
		self:update_spin(dt)
		self:update_input(dt)
		self:update_gui(dt)
	end
end

function World:exit()
	stingray.World.destroy_gui(Appkit.managed_world.world, self.gui)
	for _, pin in pairs(self._pins) do
		stingray.World.destroy_unit(Appkit.managed_world.world, pin)
	end
	self._pins = {}
end

function World:shutdown()
end

----------------------------------------------------------------------------------------

function World:spawn_pin(name, location, label)
	local pin = stingray.World.spawn_unit(Appkit.managed_world.world, "content/levels/World/location_pin/pin")
	table.insert(self._pins, pin)

	stingray.World.link_unit(Appkit.managed_world.world, pin, 1, self.world, 1)

	local theta = math.rad(location[1])
	local phi = math.rad(location[2])

	-- When theta == 0, the pin ends up being perpendicular to what we want.
	--     Add a tiny offset to theta to "fix" this.
	if math.abs(theta) < 0.001 then theta = theta + 0.001 end

	local x = EARTH_DIAMETER*0.5*math.cos(theta)*math.sin(phi)
	local y = EARTH_DIAMETER*0.5*math.cos(theta)*math.cos(phi)
	local z = EARTH_DIAMETER*0.5*math.sin(theta)

	--Position is scaled with parent
	stingray.Unit.set_local_position(pin, 1, stingray.Vector3(x,y,z))
	local forward =  stingray.Quaternion.forward(stingray.Unit.local_rotation(pin,1))
	local cross = stingray.Vector3.cross(stingray.Vector3(x,y,z), forward)
	local lookat = stingray.Quaternion.look(cross, stingray.Vector3.up())
	stingray.Unit.set_local_rotation(pin, 1, lookat)
	stingray.Unit.set_local_scale(pin, 1, stingray.Vector3(PIN_SCALE,PIN_SCALE,PIN_SCALE))

	stingray.Unit.set_data(pin, "name", name)
	stingray.Unit.set_data(pin, "label", label or name)
end

function World:update_input(dt)
	--Check for clicks on pins
	if Project.input:click() then
		local unit, collisionPos, distance, normal, actor = AppkitUtility.pick_unit(Appkit.managed_world.world, Appkit.managed_world:get_enabled_camera())
		if unit and stingray.Unit.has_data(unit, "name") then
			stingray.Level.trigger_event(SimpleProject.level, "PinClicked")
			self:transition_to(unit)
		end
	end

	--Check for dragging behavior
	inertia:store(inertia:unbox() + Project.input.drag:unbox()*INERTIA_MULTIPLIER)
	if Project.input.left_down then
		inertia:store(stingray.Vector3(0,0,0))
	end
end

function World:update_spin(dt)
	local inert = inertia:unbox()

	rz = rz + inert.x*dt
	rx = rx + inert.y*dt*VERTICAL_INERTIA_MULTIPLIER

	if rx > VERTICAL_ROTATION_LIMIT then rx = VERTICAL_ROTATION_LIMIT end
	if ry > VERTICAL_ROTATION_LIMIT then ry = VERTICAL_ROTATION_LIMIT end
	if rx < -VERTICAL_ROTATION_LIMIT then rx = -VERTICAL_ROTATION_LIMIT end
	if ry < -VERTICAL_ROTATION_LIMIT then ry = -VERTICAL_ROTATION_LIMIT end

	local new_rot = stingray.Quaternion.from_euler_angles_xyz(rx,ry,rz)

	stingray.Unit.set_local_rotation(self.world, 1, new_rot)
end

function World:update_gui()
	local text_offset = stingray.Vector3(0,0,1)

	local font = "core/editor_slave/resources/gui/arial"
	local mat = "core/editor_slave/resources/gui/arial"

	local m = stingray.Matrix4x4.identity()
	--TODO: This offset should be relative to the pin angle.
	local text_offset = stingray.Vector3(0.0,0.1,0.05)
	for _, p in pairs(self._pins) do
		local pos = stingray.Unit.world_position(p,1)
		local label = stingray.Unit.get_data(p,"label")

		--NOTE: Because the gui coord system is weird, we inverse x, and swap y and z
		stingray.Gui.text_3d(self.gui, label, font, 0.05, mat, m, stingray.Vector3(-pos.x,pos.z,pos.y)+text_offset, 1)
	end
end

function World:transition_to(pin)
	self._in_transition = true

	--TODO: START LOADING NEXT LEVEL HERE
	local pin_name = stingray.Unit.get_data(pin, "name")

	--Start fading
	Project.effects:fade(false, TRANSITION_TIME)

	local t = 0
	local cam_unit = Appkit.managed_world.enabled_cameras[Appkit.managed_world:get_enabled_camera()]
	local start_pos = stingray.Vector3Box(stingray.Unit.local_position(cam_unit,1))
	local end_pos = stingray.Vector3Box(stingray.Unit.world_position(pin, 1)) --Use pin world position, not local
	local start_rot = stingray.QuaternionBox(stingray.Unit.local_rotation(cam_unit,1))
	local end_rot = stingray.QuaternionBox(stingray.Unit.local_rotation(pin, 1))
	local co = Scheduler.Spawn(function (dt)
		while t < TRANSITION_TIME do
			coroutine.yield(co)
			t = t + dt

			local pos = stingray.Vector3.lerp(start_pos:unbox(), end_pos:unbox(), t/TRANSITION_TIME)
			stingray.Unit.set_local_position(cam_unit, 1, pos)

			--TODO: The pin rotation is offset 90deg, we need to fix this before lerping it
			--local rot = math.slerp(start_rot:unbox(), end_rot:unbox(), t/TRANSITION_TIME)
			--stingray.Unit.set_local_rotation(cam_unit, 1, rot)
		end
		self._in_transition = false

		--TODO: SWITCH LEVELS HERE
		self._change_levels = true
		self._next_level_name = "content/levels/"..pin_name.."/"..pin_name
	end)
end

return World
