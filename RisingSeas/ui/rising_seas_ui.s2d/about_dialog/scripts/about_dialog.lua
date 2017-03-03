--This script is executed on object creation
local _this_actor = ...

local function _button_released(button_name)
	local event = {
		eventId = scaleform.EventTypes.Custom,
		name = "ButtonReleased",
		data = {
			target = button_name -- Name of the button in Scaleform
		}
	}
	scaleform.Stage.dispatch_event(event)
end

local _added_listener = scaleform.EventListener.create(_added_listener, function(e)
	scaleform.Actor.set_visible(_this_actor, false)
end);

local _custom_listener = scaleform.EventListener.create(_custom_listener, function(e)
	if e.name == "DisplayAbout" then
		scaleform.Actor.set_visible(_this_actor, true)
	elseif e.name == "ButtonClicked" then
		if e.data.msg == "CloseAboutDialog" then
			_button_released("DoneButton")
			scaleform.Actor.set_visible(_this_actor, false)
		end
	end
end);

scaleform.EventListener.connect(_added_listener, _this_actor, scaleform.EventTypes.AddedToStage)
scaleform.EventListener.connect(_custom_listener, _this_actor, scaleform.EventTypes.Custom)
