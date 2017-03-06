BayOrgFlowCallbacks = BayOrgFlowCallbacks or {}

-- Water levels controlled by the slider.
local MIN = 0
local MAX = 6

local GENERAL_TEXT = {
"- Population: 9.440 \n- Property value: $3.5 billion\n- Homes: 3.095\n- 14 hazardous waste sites",
"- 4.896 people \n- $2.1 billion property value\n- 1.825 homes \n- 13 hazardous waste sites\n- 26 miles of roads",
"- 6.612 people \n- $2.7 billion property value\n- 2.343 homes \n- 31 miles of roads\n- 3 Rail stations",
"- 8.177 people \n- $3.4 billion property value\n- 3.012 homes \n- 14 hazardous waste sites"
}

local GENERAL_TITLES = {
"Data for this region",
"On land below 3 feet",
"On land below 4 feet",
"On land below 6 feet"	
}

local ALEX_TEXT = {
	"Jamal is a nurse at a health clinic. It’s a good job, and he hopes to get a management position. When he gets to see his daughter, they enjoy hanging out at the park across from his apartment.",
	"When the water starts to rise, Jamal wears tall boots so he can cross the washed-out streets. When his daughter can’t get home from school due to the floodwaters, he wears the boots and carries her home on his shoulders.",
	"The clinic asks Jamal to wear his big boots to work because the water now comes to the door. When he gets there, he’s told to move medication to the fridges on the second floor. He starts working 18-hour shifts and wonders if he still wants that management position….",
	"The clinic is empty only because ambulances can’t reach the victims. Jamal sleeps there because he can’t get home. The clinic runs on limited power. Jamal treats a boy the same age as his daughter who had stepped in water where there were live wires. His daughter and ex-wife have left town."	
}

local YINYIN_TEXT = {
	"Amy has just landed her dream job at a large software company. She loves the neighborhood and has bought her first home to raise a family. Amy spends her free time tending her vegetable garden.",
	"Amy learns that her new home is in an area is expected to be affected by rising sea levels; suddenly water-saving irrigation techniques are the least of her problems! Now, she does everything she can to shrink her carbon footprint, consuming less, recycling, and riding her bike to work. Flooded streets mean she has to take a lot of detours.",
	"When the flooding worsens, rumors fly that her new company will relocate. Amy’s garden washes out, and she now buys the vegetables she used to grow. She can’t bike to work because of road closures, and power outages mean that she can’t work from home.",
	"Amy’s company, affected by the rising seas, moves to another city. Heartbroken, she worries about abandoning her dreams of family life, and walking away from her new home, which is underwater in more ways than one."	
}

local LARON_TEXT = {
	"Gabriel is a fisherman and obsessed with the weather. His whole family has grown up in his mother’s home and he still worries about flooding, because they lost everything in the 1983 floods. But the next time the water comes, Gabriel is prepared.",
	"By the time the flooding reaches his street, Gabriel’s mother wants to move out, but Gabriel insists on sandbagging.  Every hour, the water gets closer. Gabriel tells his mother that he is prepared. He will not lose the family home.",
	"When the water reaches his driveway, Gabriel knows to stock up on his mother’s medications. But he can’t get to the pharmacy; the police have cut off access to the store because of the flooding.",
	"Gabriel runs out of gas for his generator. Water enters the house and warps the doors so they don’t shut. It smells of sewage and Gabriel’s mother needs to see a doctor. They can’t stay and so they pack photographs and valuables into plastic bins. This time, when the firefighters come with their boat, they go with them, and abandon his home."	
}

local BAYORG = {
	PARK_VIEW = "BayOrg.ParkView",
	CITY_VIEW = "BayOrg.CityView",
	ALEX_VIEW = "BayOrg.AlexView",
	LARON_VIEW = "BayOrg.LaronView",
	YINYIN_VIEW = "BayOrg.YinyinView"
}

local DETAILED_VIEW_NEAR_RANGE = 1
local GLOBAL_VIEW_NEAR_RANGE = 100

-- First view is the city view
local current_view_state = BAYORG.CITY_VIEW
local card_state = 1

local _slider_position = 0

-- We don't use the same near range values in detailed and global views to avoid z-fighting issues.
-- Quick fix, might be better ways to deal with this...
local function _configure_camera(detail)
	local active_camera = Appkit.managed_world:get_enabled_camera()
	local near_range = detail and DETAILED_VIEW_NEAR_RANGE or GLOBAL_VIEW_NEAR_RANGE	
	stingray.Camera.set_near_range(camera, near_range)
end

local function _update_card(force)
	local last_card_state = card_state
	if _slider_position < 11 then
		card_state = 1
	elseif _slider_position < 51 then
		card_state = 2
	elseif _slider_position < 71 then
		card_state = 3
	else
		card_state = 4
	end

	if force or card_state ~= last_card_state then
		local evt_name = "Card"..card_state
		
		--by default show the city level cards..
		local text_to_show = GENERAL_TEXT[card_state]
		local bubble_title = GENERAL_TITLES[card_state]
		
		if current_view_state == BAYORG.ALEX_VIEW then 
			text_to_show = ALEX_TEXT[card_state]			
			bubble_title = "Jamal’s story… "
		elseif current_view_state == BAYORG.YINYIN_VIEW then 
			text_to_show = YINYIN_TEXT[card_state]
			bubble_title = "Amy's story… "
		elseif current_view_state == BAYORG.LARON_VIEW then
			bubble_title = "Gabriel's story… "
			text_to_show = LARON_TEXT[card_state]
		end		
		scaleform.Stage.dispatch_event( { eventId = scaleform.EventTypes.Custom, name = evt_name, data = {card_text = text_to_show, card_title = bubble_title}} )
	end
end

function BayOrgFlowCallbacks.get_view_state(t)
	return {city = current_view_state == BAYORG.CITY_VIEW, 
			park = current_view_state == BAYORG.PARK_VIEW,
			alex = current_view_state == BAYORG.ALEX_VIEW,
			laron = current_view_state == BAYORG.LARON_VIEW,
			yinyin = current_view_state == BAYORG.YINYIN_VIEW}
end

function BayOrgFlowCallbacks.set_alex_view(t)
	current_view_state = BAYORG.ALEX_VIEW
	_configure_camera(true)
	_update_card(true)
end

function BayOrgFlowCallbacks.set_yinyin_view(t)
	current_view_state = BAYORG.YINYIN_VIEW
	_configure_camera(DETAILED_VIEW_NEAR_RANGE)
	_update_card(true)
end

function BayOrgFlowCallbacks.set_laron_view(t)
	current_view_state = BAYORG.LARON_VIEW
	_configure_camera(true)
	_update_card(true)
end

function BayOrgFlowCallbacks.set_city_view(t)
	current_view_state = BAYORG.CITY_VIEW
	_configure_camera(false)
	_update_card(true)
end
	
function BayOrgFlowCallbacks.set_park_view(t)
	current_view_state = BAYORG.PARK_VIEW
	_configure_camera(true)
	_update_card(true)
end

function BayOrgFlowCallbacks.adjust_water_level(t)
	local val = tonumber(t.value)
	local water_plane_z = MIN + (MAX-MIN)*val/100
	local water_plane_pos = stingray.Unit.local_position(t.water_plane,1)
	water_plane_pos.z = water_plane_z
	stingray.Unit.set_local_position(t.water_plane,1,water_plane_pos)
	_slider_position = val
	_update_card()
    local val = tonumber(t.value)
    if val > 90 then
        if scaleform then
    		scaleform.Stage.dispatch_event( { eventId = scaleform.EventTypes.Custom, name = "CallToAction", data = {}} )
    	end
    end
end