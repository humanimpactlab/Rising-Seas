AppkitUtility = require 'script/lua/appkit_utility'

ProjectFlowCallbacks = ProjectFlowCallbacks or {}

function ProjectFlowCallbacks.lerp_towards(t)
	local start_pos = stingray.Vector3Box(stingray.Unit.world_position(t.Unit, 1))
	local end_pos = stingray.Vector3Box(t.Position)

	local start_rot = stingray.QuaternionBox(stingray.Unit.local_rotation(t.Unit, 1))
	local end_rot = stingray.QuaternionBox(t.Rotation)

	local transition_time = t.Time
	local time = 0
	local co = Scheduler.Spawn(function (dt)
		while time < transition_time do
			coroutine.yield(co)
			time = time + dt

			local pos = stingray.Vector3.lerp(start_pos:unbox(), end_pos:unbox(), time/transition_time)
			stingray.Unit.set_local_position(t.Unit, 1, pos)

			local rot = stingray.Quaternion.lerp(start_rot:unbox(), end_rot:unbox(), time/transition_time)
			stingray.Unit.set_local_rotation(t.Unit, 1, rot)
		end
		stingray.Unit.set_local_position(t.Unit, 1, end_pos:unbox())
		stingray.Unit.set_local_rotation(t.Unit, 1, end_rot:unbox())
	end)
end

function ProjectFlowCallbacks.pick_unit(t)
	local ret = {Result = false}
	if stingray.Mouse.pressed(stingray.Mouse.button_id("left")) then
		local unit, collisionPos, distance, normal, actor = AppkitUtility.pick_unit(Appkit.managed_world.world, Appkit.managed_world:get_enabled_camera())
		if unit == t.Unit then
			ret.Result = true
		end
	end
	return ret
end

function ProjectFlowCallbacks.open_url_in_browser(t)
    stingray.Application.open_url_in_browser (t.URL)
end