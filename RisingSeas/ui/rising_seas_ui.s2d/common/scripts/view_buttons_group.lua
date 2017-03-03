
local thisActor = ...
local thisContainer = scaleform.Actor.container(thisActor)

local nbButtons = scaleform.ContainerComponent.num_actors(thisContainer)

local initialPositions = nil
local initialButtonSelected = 'EarthViewButton'

local function change_selection( target )
	for i = 1, nbButtons do
		local child = scaleform.ContainerComponent.actor_by_index(thisContainer, i)
		local childContainer = scaleform.Actor.container(child)
		if child ~= target then
			-- Reset initial scale and local_position of not selected buttons
			scaleform.Actor.set_local_scale(child, {x = 1.0, y = 1.0})
			scaleform.Actor.set_local_position(child, initialPositions[child]) 
			-- Update this button status
			scaleform.Actor.set_property(child, "Selected", false)
			scaleform.AnimationComponent.goto_label(childContainer, "default")
		end
	end
end

local function emitEvent( evt_name, actor )
	local actor = actor or thisActor
	local evt = {
		eventId = scaleform.EventTypes.Custom,
		name = evt_name,
		data = {
			buttonActor = actor
		}
	}
	scaleform.Stage.dispatch_event(evt)
end

local added_listener = scaleform.EventListener.create(added_listener, 
	function(e)
		if not initialPositions then
			initialPositions = {}
			for i = 1, nbButtons do
				local child = scaleform.ContainerComponent.actor_by_index(thisContainer, i)
				local name = scaleform.Actor.name(child)
				initialPositions[child] = scaleform.Actor.local_position(child)
				if name == initialButtonSelected then
					emitEvent("HighlightButton", child)
				end
			end
		end
	end
)

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

scaleform.EventListener.connect(added_listener, thisActor, scaleform.EventTypes.Added)
scaleform.EventListener.connect(added_listener, thisActor, scaleform.EventTypes.AddedToStage)
scaleform.EventListener.connect(custom_listener, thisActor, scaleform.EventTypes.Custom)

return thisActor