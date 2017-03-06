Project.Input = Appkit.class(Project.Input)
local Input = Project.Input

require "script/lua/math"

local Mouse = stingray.Mouse

local CLICK_TIME = 0.25

local mouse_down = false
local mouse_down_timer = 0.0

----------------------------- Component functions ------------------------------------

function Input:init()
	Project.input = self
	
	self.left_id = Mouse.button_id("left")
	self.last_mouse_position = stingray.Vector3Box()
	self.mouse_delta = stingray.Vector3Box()
	self.drag = stingray.Vector3Box()
	self.clicked = false
end

function Input:update(dt)
	
	--------------------- Drag ----------------------------
	local pos = stingray.Mouse.axis(stingray.Mouse.axis_id("cursor"), stingray.Mouse.RAW, 3)
	self.mouse_delta:store(pos - self.last_mouse_position:unbox())
	
	if Mouse.button(self.left_id) > math.EPSILON then
		self.drag:store(self.mouse_delta:unbox())
	else
		self.drag:store(stingray.Vector3(0,0,0))
	end
	
	self.last_mouse_position:store(pos)
	--------------------------------------------------------
	
	--------------- Click -----------------------
	self.left_down = false
	if Mouse.pressed(self.left_id) then
		mouse_down = true
		self.left_down = true
	end
	
	if mouse_down then
		mouse_down_timer = mouse_down_timer + dt
	else
		mouse_down_timer = 0.0
	end
	
	if Mouse.released(self.left_id) then
		mouse_down = false
		if mouse_down_timer <= CLICK_TIME then
			self.clicked = true
		end
	else
		self.clicked = false
	end
	-------------------------------------------
	
	
	
end

function Input:shutdown()
	
end

----------------------------------------------------------------------------------------

function Input:click()
	return self.clicked
end

return Input
