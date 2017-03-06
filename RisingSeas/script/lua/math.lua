----------------------------------------------------------------
-- This script extends and overrides the global lua math library
----------------------------------------------------------------

-- Constants
math.EPSILON = 0.001
math.EPSILON_SQ = math.EPSILON*math.EPSILON -- Used by nearly_equal

math.DEG_TO_RAD = math.pi/180
math.RAD_TO_DEG = 180/math.pi

-- Reference Height and Diagonal of a full-frame 35mm digital SLR to do the conversion between focal length and FoV
local _REF_SENSOR_HEIGHT = 24 -- (in mm)
local _REF_SENSOR_DIAGONAL = 43.3 -- (in mm)

local _METER_TO_INCH_FACTOR = 0.0254

-- Reference Width of a full-frame 35mm digital SLR
math.REF_SENSOR_WIDTH = 36

-- Reference Height for a full-frame 35mm digital SLR
math.REF_SENSOR_HEIGHT = 24

-- Rotation needed to go from y-up to z-up
math.YUP_TO_ZUP_ROT = s3d.QuaternionBox(
	s3d.Quaternion.look(s3d.Vector3(0, 0, -1), s3d.Vector3(0, 1, 0))
)

-- Maximum value of an unsigned integer in C
local C_MAX_UNSIGNED_INT = 4294967295

-- override global randomseed function
local _math_randomseed = _G.math.randomseed
function math.randomseed(seed)
	Print("Warning: you should use push/pop functions to set/reset the value of the seed for random number generation")
end

--save seed
local _seed_stack_for_random = {}
local _current_seed = nil
local function _randomseed(seed)
	if not seed then -- you want to pop the stack to use a previous seed
		seed = table.remove(_seed_stack_for_random)
	else -- you want to push the current seed onto the stack and use the new one
		table.insert(_seed_stack_for_random, _current_seed)
	end

	if not seed then -- safe guard
		return
	end

	_current_seed = seed
	_math_randomseed(seed)
end

-- Functions

-- Sets a seed for the pseudo-random generator
--
-- @param seed The value of the seed.
function math.push_randomseed(seed)
	if seed < 0 or seed > C_MAX_UNSIGNED_INT then
		print("Warning: value of the seed is negative or too large")
		return
	end
	_randomseed(seed)
end

-- Revert the value of the seed to its previous state
function math.pop_randomseed()
	_randomseed()
end

-- set the initial seed
math.push_randomseed( os.time() )

--- Clamp the given value between [min;max].
--
-- @param val The value to clamp.
-- @param min The minimal bound of the value.
-- @param max The maximal bound of the value.
-- @return The given value, clamped to the [min;max] range.
function math.clamp(val, min, max)
	if min > max then
		min, max = max, min
	end
	return math.max(min, math.min(max, val))
end

function math.sign(val)
	if val > 0 then
		return 1
	elseif val < 0 then
		return -1
	else
		return 0
	end
end

-- Tests if two numbers are nearly equal, i.e. their difference isn't bigger than tol
-- @arg a number
-- @arg b number
-- @arg sq_tol square of the tolerance. Must be >0. By default it's math.EPSILON_SQ
function math.nearly_equal(a, b, sq_tol)
	sq_tol = sq_tol or math.EPSILON_SQ
	local diff = a - b
	return diff*diff < sq_tol
end

-- Tests if a number is nearly zero, i.e. it isn't bigger than tol
-- @arg a number
-- @arg sq_tol square of the tolerance. Must be >0. By default it's math.EPSILON_SQ
function math.nearly_zero(a, sq_tol)
	sq_tol = sq_tol or math.EPSILON_SQ
	return a*a < sq_tol
end

function math.lerp(a, b, t)
	return a*(1.0-t) + b*t
end

function math.rotate(q_original, yaw, pitch, min_angle, max_angle)
	local m_original = s3d.Matrix4x4.from_quaternion(q_original)

	local look_at = s3d.Quaternion.forward(q_original)
	local dot = s3d.Vector3.dot(s3d.Vector3(0,0,1), look_at)
	local next_pitch_degrees = (dot*90 + pitch*180/math.pi)
	if next_pitch_degrees > max_angle then
		pitch = math.pi*(max_angle-dot*90)/180
	elseif next_pitch_degrees < min_angle then
		pitch = math.pi*(min_angle-dot*90)/180
	end

	local q_yaw = s3d.Quaternion(s3d.Vector3(0,0,1), yaw)
	local q_pitch = s3d.Quaternion(s3d.Matrix4x4.x(m_original), pitch)

	local q_frame = s3d.Quaternion.multiply(q_yaw, q_pitch)
	local q_new = s3d.Quaternion.multiply(q_frame, q_original)

	return q_new
end

function math.to_spherical_coords(pos, center)
	local dir = pos - center
	local radius = s3d.Vector3.length(dir)

	-- If the point is at the origin, the angles can't be found
	if radius < math.EPSILON then
		return 0, 0, radius
	end

	local theta = math.atan2(dir.y, dir.x)
	local phi = -math.asin( dir.z/radius )
	return theta, phi, radius
end

function math.get_pose_from_angles(theta, phi, radius, center)
	local q1 = s3d.Quaternion(s3d.Vector3(0,0,1), theta)
	local q2 = s3d.Quaternion(s3d.Vector3(0,1,0), phi)
	local r = s3d.Quaternion.multiply(q1,q2)
	local dir = s3d.Quaternion.rotate(r, s3d.Vector3(1,0,0))

	local pos = dir*radius+center
	local rot = s3d.Quaternion.look(center - pos, s3d.Vector3(0,0,1))
	return pos, rot
end

function math.angle_between_vectors(v1, v2)
	return math.atan2(s3d.Vector3.length(s3d.Vector3.cross(v1, v2)), s3d.Vector3.dot(v1, v2))
end

function math.horizontal_angle_between_vectors(v1, v2)
	-- Create new vectors to avoid overriding the parameters
	local vec1 = s3d.Vector3(v1.x, v1.y, 0)
	local vec2 = s3d.Vector3(v2.x, v2.y, 0)
	return math.angle_between_vectors(vec1, vec2)
end

function math.vertical_angle_between_vectors(v1, v2)
	-- Create new vectors to avoid overriding the parameters
	-- Arbitrary direction of (1, 0) chosen for the xy plane
	local vec1 = s3d.Vector3(1, 0, v1.z)
	local vec2 = s3d.Vector3(1, 0, v2.z)
	return math.angle_between_vectors(vec1, vec2)
end

function math.distance_along_ray(ray_start, ray_dir, point_a, point_b)
	local at = s3d.Vector3.dot(point_a - ray_start, ray_dir)
	local bt = s3d.Vector3.dot(point_b - ray_start, ray_dir)
	return math.abs(bt - at)
end

-- Performs spherical interpolation of quaternions.  This is the smoothest rotation from one orientation to the other.
function math.slerp(quat0, quat1, u)
	local dot_prod = s3d.Quaternion.dot(quat0, quat1)
	local abs_dot_prod = math.abs(dot_prod)
	
	-- Avoid division by zero sine (when cosine == 1).  Near this value, spherical interpolation becomes equal to linear interpolation.
	if abs_dot_prod > 0.999 then
		return s3d.Quaternion.lerp(quat0, quat1, u)
	end

	local angle = math.acos(abs_dot_prod)
	local sin_angle = math.sin(angle)
	
	-- If the vectors are facing in opposite directions, flip the second quat to its closer equivalent.
	local sign = math.sign(dot_prod)

	local weight0 =        math.sin((1.0-u)*angle) / sin_angle
	local weight1 = sign * math.sin(     u *angle) / sin_angle
	
	local x0, y0, z0, w0 = s3d.Quaternion.to_elements(quat0)
	local x1, y1, z1, w1 = s3d.Quaternion.to_elements(quat1)

	local res = s3d.Quaternion.from_elements( weight0 * x0 + weight1 * x1,
	                                          weight0 * y0 + weight1 * y1,
	                                          weight0 * z0 + weight1 * z1,
	                                          weight0 * w0 + weight1 * w1 )

	return res
end

--- Linear easing method (no accelaration nor deceleration)
--
-- @param t                     The current time
-- @param d                     The duration (should be larger than t)
-- @return eased_in_progress    The eased time (between 0 and 1)

function math.linear_ease(t, d)
	return math.abs(t / d)
end

--- Easing method that accelerates over time
--
-- @param t                     The current time
-- @param d                     The duration (should be larger than t)
-- @param alpha                 The degree of acceleration curve, default is a quadratic
-- @return eased_in_progress    The eased time (between 0 and 1)

function math.poly_ease_in(t, d, alpha)
	if alpha == 1 then return math.linear_ease(t, d) end
	alpha = alpha or 2
	t = t / d
	local eased_in_progress = t^alpha
	if eased_in_progress < 0 then 
		return 0.0 
	elseif eased_in_progress > 1 
		then return 1.0 
	else 
		return eased_in_progress 
	end
end

--- Easing method that decelerates over time
--
-- @param t                     The current time
-- @param d                     The duration (should be larger than t)
-- @param alpha                 The degree of decelaration curve, default is a quadratic
-- @return eased_in_progress    The eased time (between 0 and 1)

function math.poly_ease_out(t, d, alpha)
	if alpha == 1 then return math.linear_ease(t, d) end
	alpha = alpha or 2
	t = t / d
	local eased_out_progress = 1 - (1-t)^alpha
	if eased_out_progress < 0 then 
		return 0.0 
	elseif eased_out_progress > 1 
		then return 1.0 
	else 
		return eased_out_progress 
	end
end

--- Easing method that accelerate until half-time then decelerates for the remaining time
--
-- @param t                     The current time
-- @param d                     The duration (should be larger than t)
-- @param alpha                 The degree of decelaration curve, default is a quadratic
-- @return eased_in_progress    The eased time (between 0 and 1)

function math.poly_ease_in_ease_out(t, d, alpha)
	alpha = alpha or 2
	t = t / d
	local eased_in_out_progress = (t^alpha)/((t^alpha)+((1-t)^alpha))
	if eased_in_out_progress < 0.0 then 
		return 0.0 
	elseif eased_in_out_progress > 1.0 
		then return 1.0 
	else 
		return eased_in_out_progress 
	end
end

--- Easing method that is the smoothest, a cubic that has zero speed at start and end
--
-- @param t                     The current time
-- @param d                     The duration (should be larger than t)
-- @return eased_in_progress    The eased time (between 0 and 1)

function math.cubic_ease_in_ease_out(t, d)
	t = t / d
	local eased_in_out_progress = t^2 * (3.0 - 2 * t)
	if eased_in_out_progress < 0.0 then 
		return 0.0 
	elseif eased_in_out_progress > 1.0 
		then return 1.0 
	else 
		return eased_in_out_progress 
	end
end

function math.rad_to_deg(value)
	return value*math.RAD_TO_DEG
end

function math.deg_to_rad(value)
	return value*math.DEG_TO_RAD
end

--- Find the size of the unscaled unit on the screen
--
-- @param cam The camera which is the point of view of the projection
-- @param unit The unit which size we want to compute
-- @return The size in pixels of the unit on the screen
function math.unscaled_size_on_screen(cam, unit)

	-- Get the bounding box of the unit
	local box_pose, box_extent = s3d.Unit.box(unit)
	local half_extent = s3d.Vector3.length(box_extent)

	-- Use half_extent as the radius of the circle on screen that represent the object
	local unit_pos = s3d.Unit.local_position(unit, 1)
	local cam_pos = s3d.Camera.world_position(cam)
	local lateral_vec = s3d.Vector3.normalize(s3d.Vector3.cross(s3d.Vector3(0,0,1), cam_pos - unit_pos))
	local lateral_dist = lateral_vec*half_extent

	-- Find the half extent of the screen plan in the 3d world
	local radius = s3d.Vector3.length(unit_pos - cam_pos)
	local cam_angle = s3d.Camera.vertical_fov(cam)*0.5
	local cam_half_extent = math.max(radius * math.tan(cam_angle), math.EPSILON)

	-- Use the ratio to determine the size in pixel
	local extent_ratio = half_extent/cam_half_extent
	local w, h = s3d.Application.back_buffer_size()

	return h*extent_ratio
end

-- Creates a rotation submatrix from a y an z axis
-- Use orthogonalize_rotation_submatrix if either y_axis or z_axis aren't normalized
function math.rotation_matrix_from_yz(y_axis, z_axis)
	return s3d.Matrix4x4.from_axes(
		s3d.Vector3.cross(y_axis, z_axis), y_axis, z_axis,
		s3d.Vector3.zero())
end

-- Makes the rotation submatrix of m orthoormal, or orthogonal, i.e.
-- each of its rows is normal and orthogonal
-- This is useful to avoid accumulation of error (e.g. from multiplication)
-- that could cause the rotation axes to go to zero or infinity.
-- If each element in the rotation diagonal is close to 1, calls the fast implementation
-- otherwise it calls the robust, yet slower implementation
-- @arg m a s3d.Matrix4x4 that represents a transformation
function math.orthogonalize_rotation_submatrix(m)
	local scale = s3d.Matrix4x4.scale(m)
	if math.nearly_equal(scale[1], 1) and
			math.nearly_equal(scale[2], 1) and
			math.nearly_equal(scale[3], 1) then
		return math.orthogonalize_rotation_submatrix_fast(m)
	else
		return math.orthogonalize_rotation_submatrix_robust(m)
	end
end

-- Makes the rotation submatrix of m orthonormal, or orthogonal
-- @see math.normalize_rotation_submatrix
function math.orthogonalize_rotation_submatrix_robust(m)
	local x_axis = s3d.Matrix4x4.x(m)
	local y_axis = s3d.Matrix4x4.y(m)
	local z_axis = s3d.Matrix4x4.z(m)
	z_axis = s3d.Vector3.normalize(z_axis)
	x_axis = s3d.Vector3.cross(y_axis, z_axis)
	y_axis = s3d.Vector3.cross(z_axis, x_axis)
	x_axis = s3d.Vector3.normalize(x_axis)
	y_axis = s3d.Vector3.normalize(y_axis)
	s3d.Matrix4x4.set_x(m, x_axis)
	s3d.Matrix4x4.set_y(m, y_axis)
	s3d.Matrix4x4.set_z(m, z_axis)
	return m
end

-- Makes the rotation submatrix of m orthonormal, or orthogonal
-- @see math.normalize_rotation_submatrix
-- Assumes that the norm of the rows of the rotation submatrix is close to 1
-- Implementation based on equations 18-21 of http://gentlenav.googlecode.com/files/DCMDraft2.pdf
function math.orthogonalize_rotation_submatrix_fast(m)
	local x_axis = s3d.Matrix4x4.x(m)
	local y_axis = s3d.Matrix4x4.y(m)

	-- The error is equally distributed between both axes
	local half_error = s3d.Vector3.dot(x_axis, y_axis)*.5
	local x_ort = x_axis - half_error*y_axis
	local y_ort = y_axis - half_error*x_axis
	-- z should simply be orthogonal to x and y
	local z_ort = s3d.Vector3.cross(x_ort, y_ort)

	-- Normalize and set using an approximation given by a Taylor expansion
	s3d.Matrix4x4.set_x(m, 0.5 * (3 - s3d.Vector3.dot(x_ort, x_ort)) * x_ort)
	s3d.Matrix4x4.set_y(m, 0.5 * (3 - s3d.Vector3.dot(y_ort, y_ort)) * y_ort)
	s3d.Matrix4x4.set_z(m, 0.5 * (3 - s3d.Vector3.dot(z_ort, z_ort)) * z_ort)
	return m
end

-- Sometimes we don't need the real length which may be more computationally expensive due to the sqrt
function math.length_squared(v)
	return s3d.Vector3.dot(v, v)
end

function math.focal_distance_from_fov(fov, screen_ratio)
	local lens_height =  math.REF_SENSOR_WIDTH / screen_ratio

	return lens_height / (math.tan(fov/(2*math.RAD_TO_DEG))*2)
end

function math.fov_from_focal_distance(focal_distance, screen_ratio)
	local lens_height =  math.REF_SENSOR_WIDTH / screen_ratio

	return 2*math.atan(lens_height/(2*focal_distance)) * math.RAD_TO_DEG
end

function math.meter_to_inch(meter)
	return meter / _METER_TO_INCH_FACTOR
end

function math.inch_to_meter(inch)
	return inch * _METER_TO_INCH_FACTOR
end

function math.focal_distance_from_diagonal_fov(diagonal_fov)
	return _REF_SENSOR_DIAGONAL / (math.tan(diagonal_fov/(2*math.RAD_TO_DEG))*2)
end

function math.focal_distance_from_vertical_fov(vertical_fov)
	return _REF_SENSOR_HEIGHT / (math.tan(vertical_fov/(2*math.RAD_TO_DEG))*2)
end

function math.diagonal_fov_from_focal_distance(focal_distance)
	return 2*math.atan(_REF_SENSOR_DIAGONAL/(2*focal_distance)) * math.RAD_TO_DEG
end

function math.vertical_fov_from_focal_distance(focal_distance)
	return 2*math.atan(_REF_SENSOR_HEIGHT/(2*focal_distance)) * math.RAD_TO_DEG
end

-- Rounds the number to the nearest specified decimals value
function math.round(number, nb_decimals)
    local multiplier = 10 ^ (nb_decimals or 0)
    return math.floor(number * multiplier + 0.5) / multiplier
end
