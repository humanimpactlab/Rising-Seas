Project.Effects = Appkit.class(Project.Effects)
local Effects = Project.Effects

local FADE_TIME = 0.25

----------------------------- Component functions ------------------------------------

function Effects:init()
	Project.effects = self
	self._shading_env = nil
    self._fade = nil
end

function Effects:start()
	self._data_component_manager = s3d.EntityManager.data_component(SimpleProject.world)
	local all_entity_handles = s3d.World.entities(SimpleProject.world)

	for _, entity_handle in ipairs(all_entity_handles) do

        -- There is no way to identify the entity (no name/debug_name)
        -- The way we can identify if this is a shading_environment is by
        -- checking the components attached to it.
        local is_shading_environment = false

		local all_data_component_handles = {s3d.DataComponent.instances(self._data_component_manager, entity_handle)}
		for _, data_component_handle in ipairs(all_data_component_handles) do
			--If global lighting exists on the entity, we know it's the shading environment'
			local shading_environment_mapping_resource_name = s3d.DataComponent.get_property(self._data_component_manager, entity_handle, data_component_handle, {"shading_environment_mapping"})
			if shading_environment_mapping_resource_name == "core/stingray_renderer/shading_environment_components/global_lighting" then
				if (self._shading_env == nil) then
					is_shading_environment = true
					self._shading_env = entity_handle
				end
			end

			--Fade
			--TODO: Right now, we need to add the fade component to the shading environment to enable fading in/out
			-- In the future, Stingray will support adding rendering passes without having to modify the core.
			-- TODO FH: Fix fade component
			--[[
			if shading_environment_mapping_resource_name == "components/fade" then
				self._fade = data_component_handle;
				s3d.DataComponent.set_property(self._data_component_manager, self._shading_env, self._fade, {"fade_value"}, 1.0)
			end
			--]]
		end
end

    if self._fade ~= nil then
        self:fade(true)
    end
end

function Effects:update(dt)

end

function Effects:shutdown()

end

----------------------------------------------------------------------------------------

function Effects:fade(fade_in, time)
    if self._fade == nil then return end

	local transition_time = time
	if time == nil then
		transition_time = FADE_TIME
	end

    self._fading = true
	local t = 0
    local co = Scheduler.Spawn(function (dt)
		while t < transition_time do
			coroutine.yield(co)
			t = t + dt

			local fade_value = t/transition_time
			if fade_in then
				fade_value = 1.0-t/transition_time
			end
            s3d.DataComponent.set_property(self._data_component_manager, self._shading_env, self._fade, {"fade_value"}, fade_value)
		end
		self._fading = false
	end)
end

return Effects
