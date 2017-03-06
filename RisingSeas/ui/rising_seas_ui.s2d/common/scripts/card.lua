--This script is executed on object creation
local thisActor = ...

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

local custom_listener = scaleform.EventListener.create(custom_listener, function(e)
	if not string.starts(e.name, "Card") then
	    return
	end
	
	if e.name == scaleform.Actor.name(thisActor) then
	    scaleform.Actor.set_visible(thisActor, true)
		local container = scaleform.Actor.container(thisActor)
		local content_actor = scaleform.ContainerComponent.actor_by_name(container, "content")
		local text_component       = scaleform.Actor.component_by_name(content_actor, "Text")
		scaleform.TextComponent.set_text(text_component, e.data.card_text)
		
		local title_actor = scaleform.ContainerComponent.actor_by_name(container, "Text")
		local title_text_component = scaleform.Actor.component_by_name(title_actor, "Text")
		scaleform.TextComponent.set_text(title_text_component, e.data.card_title)
	else
	    scaleform.Actor.set_visible(thisActor, false)
	end
end);

local added_listener = scaleform.EventListener.create(added_listener, function(e)
	if scaleform.Actor.name(thisActor) ~= "Card1" then
	    scaleform.Actor.set_visible(thisActor, false)
	end
end);

scaleform.EventListener.connect(added_listener, thisActor, scaleform.EventTypes.AddedToStage)
scaleform.EventListener.connect(custom_listener, thisActor, scaleform.EventTypes.Custom)
