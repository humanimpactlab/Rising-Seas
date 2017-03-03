
----
--  Global helper functions for the various button templates found in the parent directory
----

local thisActor = ...

local click_listener = scaleform.EventListener.create(click_listener, 
	function(e)
		local evt = {
			eventId = scaleform.EventTypes.Custom,
			name = "ButtonClicked",
			data = {
				target = thisActor,
				actor_name = scaleform.Actor.name(thisActor),
				msg = scaleform.Actor.property(thisActor, "Message"),
				id = scaleform.Actor.property(thisActor, "ID")
			}
		}
		scaleform.Stage.dispatch_event(evt)
	end
)
 
local custom_listener = scaleform.EventListener.create(custom_listener, 
	function(e)
		-- Button ID property setter
		local thisName = scaleform.Actor.name(thisActor)
		if e.name == "SetMessage" and e.data.target == thisName then
			if e.data.value ~= nil and type(e.data.value) == "string" then
				scaleform.Actor.set_property(thisActor, "Message", e.data.value)
			end
		elseif e.name == "SetID" and e.data.target == thisName then
			if e.data.value ~= nil and type(e.data.value) == "string" then
				scaleform.Actor.set_property(thisActor, "ID", e.data.value)
			end
		end
	end
)

scaleform.EventListener.connect(click_listener, thisActor,scaleform.EventTypes.Click)
scaleform.EventListener.connect(custom_listener, thisActor, scaleform.EventTypes.Custom)

return thisActor
