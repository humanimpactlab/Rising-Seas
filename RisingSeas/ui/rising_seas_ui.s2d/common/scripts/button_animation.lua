local thisActor = ...
local thisContainer = scaleform.Actor.container(thisActor)

local thisPos = scaleform.Actor.local_position(thisActor)
scaleform.Actor.set_mouse_enabled_for_children(thisActor, false)

mouseDownEventListener = scaleform.EventListener.create(mouseDownEventListener, 
	function(e)
		scaleform.AnimationComponent.play_label(thisContainer, "pressed")
	end 
)

mouseUpEventListener = scaleform.EventListener.create(mouseUpEventListener,
	function(e)
		if e.currentTarget == thisActor then
			-- Update this button status
			scaleform.AnimationComponent.goto_label(thisContainer, "selected")
			scaleform.Actor.set_property(thisActor, "Selected", true)
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
scaleform.EventListener.connect(mouseUpEventListener, thisActor, scaleform.EventTypes.MouseUp)
scaleform.EventListener.connect(mouseOverEventListener, thisActor, scaleform.EventTypes.MouseOver)
scaleform.EventListener.connect(mouseOutEventListener, thisActor, scaleform.EventTypes.MouseOut)
scaleform.EventListener.connect(mouseReleaseOutsideEventListener, thisActor, scaleform.EventTypes.MouseUpOutside)

return thisActor
