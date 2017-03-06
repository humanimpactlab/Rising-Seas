

local thisActor = ...
local thisContainer = scaleform.Actor.container(thisActor)

scaleform.Actor.set_mouse_enabled_for_children(thisActor, false)

local emitEvent = function( evt_name )
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
		scaleform.AnimationComponent.play_label(thisContainer, "pressed")
	end 
)



mouseClickEventListener = scaleform.EventListener.create(mouseClickEventListener,
	function(e)
		if e.currentTarget == thisActor then
			scaleform.AnimationComponent.goto_label(thisContainer, "selected")
			scaleform.Actor.set_visible(thisActor, false)
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
		scaleform.AnimationComponent.play_label(thisContainer, "default")
	end 
)



scaleform.EventListener.connect(mouseDownEventListener, thisActor, scaleform.EventTypes.MouseDown)
scaleform.EventListener.connect(mouseClickEventListener, thisActor, scaleform.EventTypes.MouseUp)
scaleform.EventListener.connect(mouseOverEventListener, thisActor, scaleform.EventTypes.MouseOver)
scaleform.EventListener.connect(mouseOutEventListener, thisActor, scaleform.EventTypes.MouseOut)
scaleform.EventListener.connect(mouseReleaseOutsideEventListener, thisActor, scaleform.EventTypes.MouseUpOutside)

return thisActor
