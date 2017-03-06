Project.Scheduler = Appkit.class(Project.Scheduler)
local Scheduler = Project.Scheduler

Scheduler.coroutines = {}

function Scheduler:init()
	Project.Scheduler = self
end

function Scheduler:update(dt)
	local to_remove = {}
	for i, co in pairs(Scheduler.coroutines) do
		if coroutine.status(co) == "dead" then
			table.insert(to_remove,i)
		else
			coroutine.resume(co, dt)
		end
	end
	
	for _, i in ipairs(to_remove) do
		table.remove(Scheduler.coroutines,i)
	end
end

function Scheduler:shutdown()
	
end

function Scheduler.Spawn(func)
	local co = coroutine.create(func)
	table.insert(Scheduler.coroutines, co)
	return co
end

return Scheduler
