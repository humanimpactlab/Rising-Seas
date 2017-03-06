local thisActor = ...

local addedListener = scaleform.EventListener.create(addedListener, 
	function(e)
		scaleform.Actor.set_visible(thisActor, false)
	end
)

scaleform.EventListener.connect(addedListener, thisActor, scaleform.EventTypes.Added)
scaleform.EventListener.connect(addedListener, thisActor, scaleform.EventTypes.AddedToStage)
