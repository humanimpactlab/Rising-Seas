-- Only supports vertical scrolling for now
local _this_actor = ...

local Util = require 'core/appkit/lua/util'

local _TEXT_ACTOR = "TextField"
local _SLIDER_ACTOR = "VerticalSlider"
local _ARROW_UP_ACTOR = "ArrowUp"
local _ARROW_DOWN_ACTOR = "ArrowDown"
local _SLIDER_BAR = "Bar"
local _CURSOR_ACTOR = "Cursor"
local _SCROLL_STEP = 1 -- might want to have this as an actor property
local _DRAG_STEP = 14
local _MIN_CUR_SIZE = 75

local _this_container
local _text_actor
local _text_component
local _slider_actor
local _slider_container
local _arrow_up
local _arrow_down
local _slider_bar
local _max_text_scroll
local _slider_cursor
local _slider_cursor_size
local _scroll_cursor_pos
local _slider_actor_x
local _sliding_upper_bound
local _sliding_lower_bound
local _sliding_area

local _up_held
local _down_held
local _dragging
local _drag_distance
local _cursor_dragging

local _last_touch_pos
local _last_touch_x_pos

local function _text_pos_to_cursor_pos(text_pos)
	return (text_pos/_max_text_scroll) * (_sliding_area)
end

local function _cursor_pos_to_text_pos(cur_pos)
	return _max_text_scroll * cur_pos/(_sliding_area)
end

local function _get_scroll_bar_length()
	return (scaleform.Actor.dimensions(_slider_bar)).height
end

local function _set_cursor_pos(position_y)
	-- position_y is recieved in terms of the cursor's local position relative to the scroll bounds
	-- Make sure that we are not over the bounds of the sliding area
	if position_y > _sliding_area then
		position_y = _sliding_area
	elseif position_y < 0 then
		position_y = 0
	end

	_scroll_cursor_pos = position_y
	position_y = math.floor(_scroll_cursor_pos + _sliding_upper_bound)

	local position =  scaleform.Point({x = _slider_actor_x, y =  position_y})
	scaleform.Actor.set_local_position(_slider_cursor, position)
end

local function _set_scroll_text(line)
	if line < 1 then
		line = 1
	elseif line > _max_text_scroll then
		line = _max_text_scroll
	end

	scaleform.TextComponent.set_scroll_line(_text_component, line)
end

local function _init_cursor()
	local text_height = scaleform.TextComponent.text_height(_text_component)

	local text_rect = scaleform.TextComponent.rect(_text_component)
	local text_vertical_bound = text_rect.y2 - text_rect.y1

	_sliding_upper_bound = (scaleform.Actor.visible(_arrow_up) and (scaleform.Actor.dimensions(_arrow_up)).height) or 0
	_sliding_lower_bound = _get_scroll_bar_length() - ((scaleform.Actor.visible(_arrow_up) and (scaleform.Actor.dimensions(_arrow_down)).height) or 0)
	_scroll_cursor_pos = 0

	_sliding_area = _sliding_lower_bound - _sliding_upper_bound

	_slider_cursor_size = (text_vertical_bound/text_height) * _sliding_area

	-- Make sure that cursor is smaller than the bounds
	if _slider_cursor_size > _sliding_area then
		_slider_cursor_size = _sliding_area
	elseif _slider_cursor_size < _MIN_CUR_SIZE then
		_slider_cursor_size = _MIN_CUR_SIZE
	end

	scaleform.Actor.set_local_scale(_slider_cursor, {x = 1, y = _slider_cursor_size})

	-- Update the lower bound and sliding area based on the new size of the cursor
	_sliding_lower_bound = _sliding_lower_bound - _slider_cursor_size
	_sliding_area = _sliding_lower_bound - _sliding_upper_bound

	_slider_actor_x = 0

	_set_cursor_pos(_scroll_cursor_pos)

	_up_held = false
	_down_held = false
end

local function _scroll(delta_value)
	local scroll_line = scaleform.TextComponent.scroll_line(_text_component)
	scroll_line = scroll_line - delta_value
	_set_scroll_text(scroll_line)
	-- Move the cursor
	_set_cursor_pos(_text_pos_to_cursor_pos(scroll_line))
end

local _mouse_wheel_listener = scaleform.EventListener.create(_mouse_wheel_up, function(e)
	_scroll(e.wheelDelta)
end)

local _scroll_up_listener = scaleform.EventListener.create(_scroll_up_listener, function(e)
	if _up_held == true then
		_scroll(_SCROLL_STEP)
	end
end)

local _up_arrow_held = scaleform.EventListener.create(_up_arrow_held, function(e)
	_up_held = true
end)

local _up_arrow_unheld = scaleform.EventListener.create(_up_arrow_unheld, function(e)
	_up_held = false
end)

local _scroll_down_listener = scaleform.EventListener.create(_scroll_down_listener, function(e)
	if _down_held == true then
		_scroll(-1 * _SCROLL_STEP)
	end
end)

local _down_arrow_held = scaleform.EventListener.create(_down_arrow_held, function(e)
	_down_held = true
end)

local _down_arrow_unheld = scaleform.EventListener.create(_down_arrow_unheld, function(e)
	_down_held = false
end)

local _slider_bar_listener = scaleform.EventListener.create(_slider_bar_listener, function(e)
	local cursor_pos = e.localY or 0 -- localY is in percentage
	cursor_pos = (cursor_pos * _get_scroll_bar_length()) - _sliding_upper_bound - (_slider_cursor_size/2)
	_set_cursor_pos(cursor_pos)
	_set_scroll_text(_cursor_pos_to_text_pos(cursor_pos))
end)

local _mouse_down_listener = scaleform.EventListener.create(_mouse_down_listener, function(e)
	_last_touch_pos = e.stageY
	_last_touch_x_pos = e.stageX
	_drag_distance = 0
	_dragging = true
end)

local _mouse_up_listener = scaleform.EventListener.create(_mouse_up_listener, function(e)
	_last_touch_pos = e.stageY
	_last_touch_x_pos = e.stageX
	_drag_distance = 0
	_dragging = false
end)

local _mouse_drag_listener = scaleform.EventListener.create(_mouse_drag_listener, function(e)
	if _dragging then
		local delta_touch = e.stageY - _last_touch_pos
		local delta_touch_x = e.stageX - _last_touch_x_pos

		_drag_distance = _drag_distance + delta_touch

		local angle = math.atan(delta_touch / delta_touch_x) * 360 / math.pi
		local abs_drag = math.abs(_drag_distance)
		if math.abs(angle) > 45 and abs_drag >= _DRAG_STEP then
			_scroll((abs_drag/_drag_distance) * _SCROLL_STEP)
			_drag_distance = abs_drag - _DRAG_STEP
		end
		_last_touch_pos = e.stageY
		_last_touch_x_pos = e.stageX
	end
end)

local _cursor_down_listener = scaleform.EventListener.create(_cursor_down_listener, function(e)
	_last_touch_pos = e.stageY
	_cursor_dragging = true
end)

local _cursor_up_listener = scaleform.EventListener.create(_cursor_up_listener, function(e)
	_last_touch_pos = e.stageY
	_cursor_dragging = false
end)

local _cursor_drag_listener = scaleform.EventListener.create(_cursor_drag_listener, function(e)
	if _cursor_dragging then
		local delta_touch = e.stageY - _last_touch_pos
		local cursor_pos = _scroll_cursor_pos + delta_touch
		_set_cursor_pos(cursor_pos)
		_set_scroll_text(_cursor_pos_to_text_pos(cursor_pos))
		_last_touch_pos = e.stageY
	end
end)

local function _connect()
	scaleform.EventListener.connect(_mouse_wheel_listener, _this_actor, scaleform.EventTypes.MouseWheel)

	scaleform.EventListener.connect(_scroll_up_listener, _arrow_up, scaleform.EventTypes.LeaveFrame)
	scaleform.EventListener.connect(_up_arrow_held, _arrow_up, scaleform.EventTypes.MouseDown)
	scaleform.EventListener.connect(_up_arrow_unheld, _arrow_up, scaleform.EventTypes.MouseUp)
	scaleform.EventListener.connect(_up_arrow_unheld, _arrow_up, scaleform.EventTypes.RollOut)

	scaleform.EventListener.connect(_scroll_down_listener, _arrow_down, scaleform.EventTypes.LeaveFrame)
	scaleform.EventListener.connect(_down_arrow_held, _arrow_down, scaleform.EventTypes.MouseDown)
	scaleform.EventListener.connect(_down_arrow_unheld, _arrow_down, scaleform.EventTypes.MouseUp)
	scaleform.EventListener.connect(_down_arrow_unheld, _arrow_down, scaleform.EventTypes.RollOut)

	scaleform.EventListener.connect(_mouse_down_listener, _text_actor, scaleform.EventTypes.MouseDown)
	scaleform.EventListener.connect(_mouse_up_listener, _text_actor, scaleform.EventTypes.MouseUp)
	scaleform.EventListener.connect(_mouse_up_listener, _text_actor, scaleform.EventTypes.MouseUpOutside)
	scaleform.EventListener.connect(_mouse_drag_listener, _text_actor, scaleform.EventTypes.MouseMove)

	scaleform.EventListener.connect(_cursor_down_listener, _slider_cursor, scaleform.EventTypes.MouseDown)
	scaleform.EventListener.connect(_cursor_up_listener, _slider_cursor, scaleform.EventTypes.MouseUp)
	scaleform.EventListener.connect(_cursor_up_listener, _slider_cursor, scaleform.EventTypes.MouseUpOutside)
	scaleform.EventListener.connect(_cursor_drag_listener, _this_actor, scaleform.EventTypes.MouseMove)

	scaleform.EventListener.connect(_slider_bar_listener, _slider_bar, scaleform.EventTypes.MouseDown)
end

local function _init()
	_this_container = scaleform.Actor.container(_this_actor)

	_slider_actor = scaleform.ContainerComponent.actor_by_name(_this_container, _SLIDER_ACTOR)

	_text_actor = scaleform.ContainerComponent.actor_by_name(_this_container, _TEXT_ACTOR)
	_text_component = scaleform.Actor.component_by_name(_text_actor, "TextComponent")
	_max_text_scroll = scaleform.TextComponent.max_scroll_line(_text_component)

	_slider_container = scaleform.Actor.container(_slider_actor)
	_arrow_up = scaleform.ContainerComponent.actor_by_name(_slider_container, _ARROW_UP_ACTOR)
	_arrow_down = scaleform.ContainerComponent.actor_by_name(_slider_container, _ARROW_DOWN_ACTOR)
	_slider_bar = scaleform.ContainerComponent.actor_by_name(_slider_container, _SLIDER_BAR)
	_slider_cursor = scaleform.ContainerComponent.actor_by_name(_slider_container, _CURSOR_ACTOR)

	local arrow_up_visibility = scaleform.Actor.property(_arrow_up, "Visible")
	local arrow_down_visibility = scaleform.Actor.property(_arrow_down, "Visible")
	scaleform.Actor.set_visible(_arrow_up, arrow_up_visibility)
	scaleform.Actor.set_visible(_arrow_down, arrow_down_visibility)

	_init_cursor()

	_connect()
end

local _added_listener = scaleform.EventListener.create(_added_listener, function(e)
	_init()
end)

scaleform.EventListener.connect(_added_listener, _this_actor, scaleform.EventTypes.AddedToStage)
