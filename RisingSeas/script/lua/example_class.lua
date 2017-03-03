Project.ExampleClass = Appkit.class(Project.ExampleClass)
local ExampleClass = Project.ExampleClass

----------------------------- Component functions ------------------------------------

function ExampleClass:init()
	Project.example_class = self
end

function ExampleClass:update(dt)
	
end

function ExampleClass:shutdown()
	
end

----------------------------------------------------------------------------------------

return ExampleClass
