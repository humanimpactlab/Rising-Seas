local LUAUtility = LUAUtility or {}

function LUAUtility.load_module(name)
	return require (name)
end

function LUAUtility.try_load_module(name)
	if not name then
		print("ERROR: Trying to load nil script")
		return nil
	end

	local success, loaded_module = pcall(LUAUtility.load_module, name)
	if success then
		return loaded_module
	else
		print("ERROR: Cannot load script "..name)
		return nil
	end
end

function LUAUtility.try_call(object, func, ...)
	if object then
		local f = getmetatable(object)[func]
		if f then
			return f(object, ...)
		else
			print("ERROR: Trying to call a nil function")
			return nil
		end
	else
		return nil
	end
end

return LUAUtility