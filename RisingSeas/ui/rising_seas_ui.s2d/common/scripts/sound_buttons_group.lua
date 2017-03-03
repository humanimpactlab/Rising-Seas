
local thisActor = ...
local thisContainer = scaleform.Actor.container(thisActor)

local nbButtons = scaleform.ContainerComponent.num_actors(thisContainer)

local function change_selection( target )
	for i = 1, nbButtons do
		local child = scaleform.ContainerComponent.actor_by_index(thisContainer, i)
		local childContainer = scaleform.Actor.container(child)
		if child ~= target then
			scaleform.Actor.set_visible(child, true)
			scaleform.AnimationComponent.goto_label(childContainer, "default")
		end
	end
end

local custom_listener = scaleform.EventListener.create(custom_listener,
	function(e)
		-- Callback for button group handling
		if e.name == "ButtonSelected" and e.data then
			if e.data.buttonActor then
				if scaleform.Actor.parent(e.data.buttonActor) ~= thisActor then return end 
				change_selection(e.data.buttonActor) 
			end
		end
	end
)

scaleform.EventListener.connect(custom_listener, thisActor, scaleform.EventTypes.Custom)

return thisActor