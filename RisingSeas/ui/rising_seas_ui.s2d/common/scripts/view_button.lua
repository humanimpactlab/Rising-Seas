

local thisActor = ...
local thisContainer = scaleform.Actor.container(thisActor)

local thisPos = scaleform.Actor.local_position(thisActor)

scaleform.Actor.set_mouse_enabled_for_children(thisActor, false)

local SCALE_FACTOR = 1.25

local function highlightButton()
	-- Increase size of buttons
	local iconActor = scaleform.ContainerComponent.actor_by_name(thisContainer, "icon")
	local iDim = scaleform.Actor.dimensions(thisActor)
	local iPos = scaleform.Actor.local_position(thisActor)
	local iIconPos = scaleform.Actor.local_position(iconActor)
	local iIconDim = scaleform.Actor.dimensions(iconActor)
	scaleform.Actor.set_local_scale(thisActor, {x = SCALE_FACTOR, y = SCALE_FACTOR})
	-- And center them to their original icon position			
	local fDim = scaleform.Actor.dimensions(thisActor)
	local fPos = scaleform.Actor.local_position(thisActor)
	local fIconPos = scaleform.Actor.local_position(iconActor)
	local fIconDim = scaleform.Actor.dimensions(iconActor)
	fPos.x = iPos.x + (iDim.width - fDim.width) + ((fIconPos.x + fIconDim.width * 0.5 * SCALE_FACTOR) - (iIconPos.x + iIconDim.width * 0.5))
	fPos.y = iPos.y + (iDim.height - fDim.height) * 0.5
	scaleform.Actor.set_local_position(thisActor, fPos)
end

local function emitEvent( evt_name )
	local evt = {
		eventId = scaleform.EventTypes.Custom,
		name = evt_name,
		data = {
			buttonActor = thisActor
		}
	}
	scaleform.Stage.dispatch_event(evt)
end

mouseDownEventListener = scaleform.EventListener.create(mouseDownEventListener, 
	function(e)
		if not scaleform.Actor.property(thisActor, "Selected") then
			scaleform.AnimationComponent.play_label(thisContainer, "pressed")
		end
	end 
)



mouseClickEventListener = scaleform.EventListener.create(mouseClickEventListener,
	function(e)
		if e.currentTarget == thisActor and not scaleform.Actor.property(thisActor, "Selected") then
			-- Update this button status
			scaleform.AnimationComponent.goto_label(thisContainer, "selected")
			scaleform.Actor.set_property(thisActor, "Selected", true)
			-- Highlight buttons
			highlightButton()
			-- Call for an update of the other buttons in this button's group
			emitEvent("ButtonSelected")
		end
	end
)



mouseOverEventListener = scaleform.EventListener.create(mouseOverEventListener, 
	function(e)
		if not scaleform.Actor.property(thisActor, "Selected") then
			scaleform.AnimationComponent.play_label(thisContainer, "hovered")
		end
	end 
)



mouseOutEventListener = scaleform.EventListener.create(mouseOutEventListener, 
	function(e)
		if not scaleform.Actor.property(thisActor, "Selected") then
			scaleform.AnimationComponent.play_label(thisContainer, "default")
		end
	end 
)



mouseReleaseOutsideEventListener = scaleform.EventListener.create(mouseReleaseOutsideEventListener, 
	function(e)
		if not scaleform.Actor.property(thisActor, "Selected") then
			scaleform.AnimationComponent.play_label(thisContainer, "default")
		end
	end 
)

local custom_listener = scaleform.EventListener.create(custom_listener,
	function(e)
		-- Callback for button group handling
		if e.name == "HighlightButton" and e.data then
			if e.data.buttonActor then
				if e.data.buttonActor == thisActor then  
					-- Update this button status
					scaleform.AnimationComponent.goto_label(thisContainer, "selected")
					scaleform.Actor.set_property(thisActor, "Selected", true)
					-- Highlight buttons
					highlightButton() 
				end
			end
		end
	end
)

scaleform.EventListener.connect(mouseDownEventListener, thisActor, scaleform.EventTypes.MouseDown)
scaleform.EventListener.connect(mouseClickEventListener, thisActor, scaleform.EventTypes.MouseUp)
scaleform.EventListener.connect(mouseOverEventListener, thisActor, scaleform.EventTypes.MouseOver)
scaleform.EventListener.connect(mouseOutEventListener, thisActor, scaleform.EventTypes.MouseOut)
scaleform.EventListener.connect(mouseReleaseOutsideEventListener, thisActor, scaleform.EventTypes.MouseUpOutside)
scaleform.EventListener.connect(custom_listener, thisActor, scaleform.EventTypes.Custom)

return thisActor
