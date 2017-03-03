--This script is executed on object creation
local thisActor = ...

local children = scaleform.Actor.container(thisActor)
local animationActor = scaleform.ContainerComponent.actor_by_name(children, "animation")
local animationComponent = scaleform.Actor.container(animationActor)

local added_listener = scaleform.EventListener.create(added_listener, 
	function(e)
		scaleform.AnimationComponent.goto_label(animationComponent, "default")
	end
)
-----------------------------------------

local mouse_over_listener = scaleform.EventListener.create(mouse_over_listener, 
	function(e)
		local buttonClicked = scaleform.Actor.property(thisActor, "Selected")
		if e.currentTarget == thisActor and not buttonClicked then
			scaleform.AnimationComponent.goto_label(animationComponent, "hovered")
		end
	end
)

local mouse_out_listener = scaleform.EventListener.create(mouse_out_listener,
	function(e)
		local buttonClicked = scaleform.Actor.property(thisActor, "Selected") 
		if e.currentTarget == thisActor and not buttonClicked then
			scaleform.AnimationComponent.goto_label(animationComponent, "default")
		end
	end
)

local mouse_click_listener = scaleform.EventListener.create(mouse_click_listener, 
	function(e)
		if e.currentTarget == thisActor then
			scaleform.AnimationComponent.goto_label(animationComponent, "selected")
			scaleform.Actor.set_property(thisActor, "Selected", true)
		end
	end
)

local custom_listener = scaleform.EventListener.create(custom_listener, 
	function(e)
		-- Callback for button group handling
		if e.name == "ReleaseSelection" and e.data.target == scaleform.Actor.name(thisActor) then
			scaleform.AnimationComponent.goto_label(animationComponent, "default")
			scaleform.Actor.set_property(thisActor, "Selected", false)
		-- Callback from Expo on button send message processed
		elseif e.name == "ButtonReleased" and e.data.target == scaleform.Actor.name(thisActor) then
			scaleform.AnimationComponent.goto_label(animationComponent, "default")
			scaleform.Actor.set_property(thisActor, "Selected", false)
		end
	end
)

scaleform.EventListener.connect(added_listener, thisActor, scaleform.EventTypes.Added)
scaleform.EventListener.connect(added_listener, thisActor, scaleform.EventTypes.AddedToStage)
scaleform.EventListener.connect(mouse_over_listener, thisActor, scaleform.EventTypes.RollOver)
scaleform.EventListener.connect(mouse_out_listener, thisActor, scaleform.EventTypes.RollOut)
scaleform.EventListener.connect(mouse_click_listener, thisActor, scaleform.EventTypes.Click)
scaleform.EventListener.connect(custom_listener, thisActor, scaleform.EventTypes.Custom)
