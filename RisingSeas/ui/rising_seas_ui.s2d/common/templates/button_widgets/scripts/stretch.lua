--[[
	Attach this script to an Actor to allow it to stretch and compress itself to
	adapt to viewport size. Generally it should be used on panel backgrounds.

	The script requires the Actor to have any combination of these properties:
		* "Left" & "LeftEnd"
		* "Right" & "RightEnd"
		* "Up" & "UpEnd"
		* "Down" & "DownEnd"

	Each pair of property declares:
		* A boolean ([true;false]), enabling/disabling the stretching direction.
		* A number ([0;100]), indicating a percentage of the screen where the stretching should
		  end.

	For example:
		* "Right" checked and "RightEnd" set to "100" would mean that the given Actor should
		  stretch up to the width of the window.
		* "Right" checked and "RightEnd" set to "50" would mean that the given Actor should
		  stretch up to half of the window width.

	Property values should make sense, i.e. "LeftEnd" should never be greater than "RightEnd".
]]

local thisActor = ...
local size_changed = false

--- Actor Properties used to define stretching behavior:
local _right            = scaleform.Actor.property(thisActor, "Right")
local _right_end        = scaleform.Actor.property(thisActor, "RightEnd")
local _right_end_offset = scaleform.Actor.property(thisActor, "RightEndOffset")
local _left             = scaleform.Actor.property(thisActor, "Left")
local _left_end         = scaleform.Actor.property(thisActor, "LeftEnd")
local _left_end_offset  = scaleform.Actor.property(thisActor, "LeftEndOffset")
local _up               = scaleform.Actor.property(thisActor, "Up")
local _up_end           = scaleform.Actor.property(thisActor, "UpEnd")
local _up_end_offset    = scaleform.Actor.property(thisActor, "UpEndOffset")
local _down             = scaleform.Actor.property(thisActor, "Down")
local _down_end         = scaleform.Actor.property(thisActor, "DownEnd")
local _down_end_offset  = scaleform.Actor.property(thisActor, "DownEndOffset")


--- Send a "StretchComplete" Event, to notify potential listeners that the stretching computation
--- was applied.
--
-- Some parts of the UI might require updates after applying a stretch (scroll panels for example).
-- Registering to the "scaleform.EventTypes.ViewportResize" Event could trigger callbacks before
-- the stretching is applied (since the computation itself happens when that very event is fired),
-- thus is custom notification is required.
local function _notify_stretch_complete()
	local event = {
		eventId = scaleform.EventTypes.Custom,
		name = "GUI.Stretch.Complete",
		data = {
			target = scaleform.Actor.name(scaleform.Actor.scene(thisActor)),
			sender = scaleform.Actor.name(thisActor)
		}
	}
	scaleform.Stage.dispatch_event(event)
end

--- Stretch the Actor to the Right.
--
-- @param right_end Percentage of the right area to strech out to.
local function _stretch_right(right_end, end_offset)
	local rect = scaleform.Actor.world_bounds(thisActor)
	local scale = scaleform.Actor.local_scale(thisActor)
	local current_width = rect.x2 - rect.x1

	local start_point = rect.x1
	local end_point = scaleform.Stage.dimensions().width * right_end / 100
	local required_width = math.abs(end_point - start_point - end_offset)
	--scale
	local ratio = current_width / required_width
	local difference = required_width - current_width
	if (math.abs(difference) >= 1) then
		scale.x = scale.x / ratio
		scaleform.Actor.set_local_scale(thisActor, scale)
	end
	--The actor may be offset on account of pivot point. adapt position
	local offset = scaleform.Actor.world_bounds(thisActor).x1 - start_point
	if offset ~= 0 then
		local pos = scaleform.Actor.local_position(thisActor)
		pos.x = pos.x - offset
		scaleform.Actor.set_local_position(thisActor, pos)
	end
end

--- Stretch the Actor to the Left.
--
-- @param left_end Percentage of the left area to strech out to.
local function _stretch_left(left_end, end_offset)
	local rect = scaleform.Actor.world_bounds(thisActor)
	local scale = scaleform.Actor.local_scale(thisActor)
	local current_width = rect.x2 - rect.x1

	local start_point = rect.x2
	local end_point = scaleform.Stage.dimensions().width * left_end / 100
	local required_width = math.abs(end_point - start_point - end_offset)

	--scale
	local ratio = current_width / required_width
	local difference = required_width - current_width

	if (math.abs(difference) >= 1) then
		scale.x = scale.x / ratio
		scaleform.Actor.set_local_scale(thisActor, scale)
	end
	--The actor may be offset on account of pivot point. adapt position
	local offset = scaleform.Actor.world_bounds(thisActor).x2 - start_point
	if offset ~= 0 then
		local pos = scaleform.Actor.local_position(thisActor)
		pos.x = pos.x - offset
		scaleform.Actor.set_local_position(thisActor, pos)
	end
end

--- Stretch the Actor Up.
--
-- @param up_end Percentage of the up area to strech out to.
local function _stretch_up(up_end, end_offset)
	local rect = scaleform.Actor.world_bounds(thisActor)
	local scale = scaleform.Actor.local_scale(thisActor)
	local current_height = rect.y1 - rect.y2

	local start_point = rect.y2
	local end_point = scaleform.Stage.dimensions().height * up_end / 100
	local required_height = math.abs(end_point - start_point - end_offset)

	-- Scale:
	local ratio = current_height / required_height
	local difference = required_height - current_height
	if (math.abs(difference) >= 1) then
		scale.y = scale.y / ratio
		scaleform.Actor.set_local_scale(thisActor, scale)
	end
	-- The Actor may be offset on account of pivot point. Adapt position:
	local offset = scaleform.Actor.world_bounds(thisActor).y2 - start_point
	if offset ~= 0 then
		local pos = scaleform.Actor.local_position(thisActor)
		pos.y = pos.y - offset
		scaleform.Actor.set_local_position(thisActor, pos)
	end
end

--- Stretch the Actor Down.
--
-- @param down_end Percentage of the down area to strech out to.
local function _stretch_down(down_end, end_offset)
	local rect = scaleform.Actor.world_bounds(thisActor)
	local scale = scaleform.Actor.local_scale(thisActor)
	local current_height = rect.y2 - rect.y1

	local start_point = rect.y1
	local end_point = scaleform.Stage.dimensions().height * down_end / 100
	local required_height = math.abs(end_point - start_point - end_offset)

	-- Scale:
	local ratio = current_height / required_height
	local difference = required_height - current_height
	if (math.abs(difference) >= 1) then
		scale.y = scale.y / ratio
		scaleform.Actor.set_local_scale(thisActor, scale)
	end
	-- The Actor may be offset on account of pivot point. Adapt position:
	local offset = scaleform.Actor.world_bounds(thisActor).y1 - start_point
	if offset ~= 0 then
		local pos = scaleform.Actor.local_position(thisActor)
		pos.y = pos.y - offset
		scaleform.Actor.set_local_position(thisActor, pos)
	end
end

--- Handle the stretching of the Actor in any direction, according to its set Dynamic Properties.
local function _stretch()
	-- Handle the stretching to the Right:
	if (_right and _right ~= "Right" and _right_end and _right_end ~= "RightEnd") then
		local end_offset = 0
		if (_right_end_offset and _right_end_offset ~= "RightEndOffset") then
			end_offset = _right_end_offset
		end

		_stretch_right(_right_end, end_offset)
	end

	-- Handle the stretching to the Left:
	if (_left and _left ~= "Left" and _left_end and _left_end ~= "LeftEnd") then
		local end_offset = 0
		if (_left_end_offset and _left_end_offset ~= "LeftEndOffset") then
			end_offset = _left_end_offset
		end

		_stretch_left(_left_end, end_offset)
	end

	-- Handle the stretching up:
	if (_up and _up ~= "Up" and _up_end and _up_end ~= "UpEnd") then
		local end_offset = 0
		if (_up_end_offset and _up_end_offset ~= "UpEndOffset") then
			end_offset = _up_end_offset
		end

		_stretch_up(_up_end, end_offset)
	end

	-- Handle the stretching down:
	if (_down and _down ~= "Down" and _down_end and _down_end ~= "DownEnd") then
		local end_offset = 0
		if (_down_end_offset and _down_end_offset ~= "DownEndOffset") then
			end_offset = _down_end_offset
		end

		_stretch_down(_down_end, end_offset)
	end


	-- Notify potential listeners that the stretching computation is over:
	_notify_stretch_complete()
end

local added_listener = scaleform.EventListener.create(added_listener, function(e)
	_stretch()
end);

local viewport_resize_listener = scaleform.EventListener.create(viewport_resize_listener, function (e)
	size_changed = true
end);

local leave_frame_listener = scaleform.EventListener.create(leave_frame_listener, function (e)
	if size_changed then
		_stretch()
		size_changed = false
	end
end);


scaleform.EventListener.connect(added_listener, thisActor, scaleform.EventTypes.AddedToStage)
scaleform.EventListener.connect(viewport_resize_listener, thisActor, scaleform.EventTypes.ViewportResize)
scaleform.EventListener.connect(leave_frame_listener, thisActor, scaleform.EventTypes.LeaveFrame)
