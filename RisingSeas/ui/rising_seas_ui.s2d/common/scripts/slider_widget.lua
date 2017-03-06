--
-- IMPORTANT: This script resource may be attached to all slider widgets created by the Widget Creator panel.
--            If modifications are required, then first copy this file to a unique path and fix all necessary
--            script components' resource paths.
--

-- Local vars
local thisActor = ...
local thisContainer = scaleform.Actor.container(thisActor)

local GRIP_NORMAL_ACTOR_NAME = "grip_normal"
local GRIP_PRESS_ACTOR_NAME = "grip_press_mask"
local GRIP_OVER_ACTOR_NAME = "grip_over"

local BG_ACTOR_NAME = "background"
local FILLED_MASK_ACTOR_NAME = "filled_mask"
local GRIP_PRESS_BG_ACTOR_NAME = "grip_press_background"

local NORMAL_STATE = "normal"
local PRESS_STATE = "press"
local OVER_STATE = "over"

local gripNormal = scaleform.ContainerComponent.actor_by_name(thisContainer, GRIP_NORMAL_ACTOR_NAME)
local gripPress = scaleform.ContainerComponent.actor_by_name(thisContainer, GRIP_PRESS_ACTOR_NAME)
local gripOver = scaleform.ContainerComponent.actor_by_name(thisContainer, GRIP_OVER_ACTOR_NAME)

local background = scaleform.ContainerComponent.actor_by_name(thisContainer, BG_ACTOR_NAME)
local backgroundMask = scaleform.ContainerComponent.actor_by_name(thisContainer, FILLED_MASK_ACTOR_NAME)

local maskDim = scaleform.Actor.dimensions(backgroundMask)

-- init at first creation.
local mouseOver = false
local isPressed = false
local maxX = 0
local minX = 0
local lastSliderValue = 0

scaleform.Actor.set_visible(scaleform.ContainerComponent.actor_by_name(thisContainer, GRIP_PRESS_ACTOR_NAME), false)
scaleform.Actor.set_visible(scaleform.ContainerComponent.actor_by_name(thisContainer, GRIP_OVER_ACTOR_NAME), false)
-- Disable mouse for children
scaleform.Actor.set_mouse_enabled(scaleform.ContainerComponent.actor_by_name(thisContainer, BG_ACTOR_NAME), false)
scaleform.Actor.set_mouse_enabled(scaleform.ContainerComponent.actor_by_name(thisContainer, GRIP_NORMAL_ACTOR_NAME), false)
scaleform.Actor.set_mouse_enabled(scaleform.ContainerComponent.actor_by_name(thisContainer, GRIP_PRESS_ACTOR_NAME), false)
scaleform.Actor.set_mouse_enabled(scaleform.ContainerComponent.actor_by_name(thisContainer, GRIP_OVER_ACTOR_NAME), false)

local function emitEvent(func, param)
	local comp = scaleform.Actor.component_by_name(thisActor, "WidgetHandler")
	if comp ~= nil then
		local handlerObject = scaleform.ScriptComponent.script_results(comp)
		if handlerObject ~= nil then
			if handlerObject[func] ~= nil then
				if (param) then
					handlerObject[func](param)
				else
					handlerObject[func]()
				end
			end
		end
	end
end

-- local functions
local function setGrip(label)
	scaleform.Actor.set_visible(gripNormal, label==NORMAL_STATE)
	scaleform.Actor.set_visible(gripPress, label==PRESS_STATE)
	scaleform.Actor.set_visible(gripOver, label==OVER_STATE)
end

local function setGripPosition(ptPosition)
	scaleform.Actor.set_local_position(gripNormal, ptPosition)
	scaleform.Actor.set_local_position(gripPress, ptPosition)
	scaleform.Actor.set_local_position(gripOver, ptPosition)
end

local function setMaskWidth(ptPosition)
	maskDim.width = ptPosition
	scaleform.Actor.set_dimensions(backgroundMask, maskDim)
end

local function updateSliderPosition(ptXWorldPosition, ptYWorldPosition)
	local ptLocalPosition = scaleform.Actor.world_to_local(thisActor, {x = ptXWorldPosition, y = ptYWorldPosition})
	local xScale = scaleform.Actor.local_scale_3d(thisActor).x
	local pt = scaleform.Actor.local_position(gripNormal)
	local grip_half_width = scaleform.Actor.dimensions(gripNormal).width / 2
	local actor_bound = scaleform.Actor.local_position(thisActor).x + scaleform.Actor.dimensions(thisActor).width 
	pt.x = ptLocalPosition.x - grip_half_width
	if pt.x > maxX then
		pt.x = maxX
	end
	if pt.x < minX then
		pt.x = minX
	end
	
	setGripPosition(pt)
	setMaskWidth(ptLocalPosition.x)

	local newSliderValue = math.floor((pt.x - minX)/(maxX - minX)*100)
	if newSliderValue ~= lastSliderValue then
		lastSliderValue = newSliderValue
		emitEvent("valueChanged", newSliderValue)
	end
end

-- Helper function to set slider value (between 0 and 100).
--  setValue(40)
local function setValue(value)
	isPressed = false
	setGrip(NORMAL_STATE)
	local grip_half_width = scaleform.Actor.dimensions(gripNormal).width / 2
	local maxX = scaleform.Actor.dimensions(background).width - grip_half_width
	local minX = 0 - grip_half_width
	local pt = scaleform.Actor.local_position(gripNormal)
	pt.x = value / 100 * maxX
	if pt.x > maxX then
		pt.x = maxX
	end
	if pt.x < minX then
		pt.x = minX
	end
	setGripPosition(pt)
	lastSliderValue = value
end

-- Helper function to get slider value (between 0 and 100).
--  local sliderValue = getValue()
local function getValue()
	return lastSliderValue
end

-- Mouse event listeners
local mouseDownEventListener = scaleform.EventListener.create(mouseDownEventListener, 
	function(e)
	local clicked_grip = scaleform.Actor.perform_hit_test(gripNormal, {x = e.localX, y = e.localY}, false)
	local clicked_background = scaleform.Actor.perform_hit_test(thisActor, {x = e.stageX, y = e.stageY}, false)
	if clicked_background or clicked_grip then
		isPressed = true
		setGrip(PRESS_STATE)
		local dim_bg = scaleform.Actor.dimensions(background)
		local dim_grip = scaleform.Actor.dimensions(gripNormal)
		maxX = dim_bg.width - dim_grip.width / 2
		minX = 0 - dim_grip.width / 2
		if clicked_background then
			updateSliderPosition(e.stageX, e.stageY)
		end
	end
end )

local mouseUpEventListener = scaleform.EventListener.create(mouseUpEventListener, 
	function(e)
	isPressed = false
	if e.target == thisActor then
		setGrip(OVER_STATE)
	else
		setGrip(NORMAL_STATE)
	end
	 local evt = { eventId = scaleform.EventTypes.Custom, name = "slider_stop",
                      data = {}
                    }
        scaleform.Stage.dispatch_event(evt)
end )

local mouseOverEventListener = scaleform.EventListener.create(mouseOverEventListener, 
	function(e)
	mouseOver = true
	if not isPressed then
		setGrip(OVER_STATE)
	end
end )

local mouseOutEventListener = scaleform.EventListener.create(mouseOutEventListener, 
	function(e)
	--mouseOver = false
	--if not isPressed then
	--	setGrip(NORMAL_STATE)
	--end
end )

local mouseMoveEventListener = scaleform.EventListener.create(mouseMoveEventListener, 
	function(e)
	if isPressed and mouseOver then
		updateSliderPosition(e.stageX, e.stageY)
	end
end )

local removedFromStageListener = scaleform.EventListener.create(removedFromStageListener, 
	function(e)
	scaleform.EventListener.disconnect(mouseUpEventListener)
	scaleform.EventListener.disconnect(mouseMoveEventListener)
	scaleform.EventListener.disconnect(mouseDownEventListener)
	scaleform.EventListener.disconnect(mouseOverEventListener)
	scaleform.EventListener.disconnect(mouseOutEventListener)
end )

scaleform.EventListener.connect(removedFromStageListener, thisActor, scaleform.EventTypes.RemovedFromStage)
scaleform.EventListener.connect(mouseDownEventListener, thisActor, scaleform.EventTypes.MouseDown)
scaleform.EventListener.connect(mouseUpEventListener, scaleform.EventTypes.MouseUp)
scaleform.EventListener.connect(mouseOverEventListener, thisActor, scaleform.EventTypes.MouseOver)
scaleform.EventListener.connect(mouseOutEventListener, thisActor, scaleform.EventTypes.MouseOut)
scaleform.EventListener.connect(mouseMoveEventListener, scaleform.EventTypes.MouseMove)

return thisActor