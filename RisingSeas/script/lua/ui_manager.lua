Project.UIManager = Appkit.class(Project.UIManager)
local UIManager = Project.UIManager

----------------------------- Component functions ------------------------------------

function UIManager:init()
	Project.UIManager = self

	-- Load UI
	if scaleform then
    	scaleform.Stingray.load_project_and_scene(Project.ui.s2dproj, Project.ui.default_scene)
    else
    	print("ERROR: Could not load ui! Missing scaleform plugin.")
    end

    -- Create listener and connect to custom events
	self._custom_listener = scaleform.EventListener.create(self._custom_listener, self._on_custom_event)
	scaleform.EventListener.connect(self._custom_listener, scaleform.EventTypes.Custom) 
end

function UIManager:update(dt)
	
end

function UIManager:shutdown()
	if scaleform then
		-- Disconnect and delete listener to custom events
		scaleform.EventListener.disconnect(self._custom_listener)
		self._custom_listener = nil
		-- Unload UI
		scaleform.Stingray.unload_project()
	end
end

----------------------------------------------------------------------------------------

function UIManager._on_custom_event(evt)

end

function UIManager.add_scene(scene_to_add)
	local evt = {  	eventId = scaleform.EventTypes.Custom,
					name = "add_scene",
					data = {scene = scene_to_add} }
	scaleform.Stage.dispatch_event(evt)
end

function UIManager.remove_scene(scene_to_remove)
	local evt = {  	eventId = scaleform.EventTypes.Custom,
					name = "remove_scene",
					data = {scene = scene_to_remove} }
	scaleform.Stage.dispatch_event(evt)
end

return UIManager