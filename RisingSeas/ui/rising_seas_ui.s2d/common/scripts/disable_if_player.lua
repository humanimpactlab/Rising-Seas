--This script is executed on object creation
local thisActor = ...

-- TO DO: use a more robust way of differentiating between the Editor and Windows player app because Project.PackageManager may not exist at this point. 
if scaleform.build.platform() == "Windows" and Project.PackageManager.use_bundles then
	scaleform.Actor.set_visible(thisActor, false)
end
