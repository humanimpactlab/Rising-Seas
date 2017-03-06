--This script is executed on object creation
local thisActor = ...
local click_listener = scaleform.EventListener.create(click_listener, function(e)
	local evt = {
		eventId = scaleform.EventTypes.Custom,
		name = scaleform.Actor.property(thisActor, "Event"),
		data = {}
	}
	scaleform.Stage.dispatch_event(evt)
end);
scaleform.EventListener.connect(click_listener, thisActor, scaleform.EventTypes.Click)
