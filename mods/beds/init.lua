local player_in_bed = 0

minetest.register_node("beds:bed_bottom", {
	description = "Bed",
	inventory_image = "beds_bed.png",
	wield_image = "beds_bed.png",
	wield_scale = {x=0.8,y=2.5,z=1.3},
	drawtype = "nodebox",
	tiles = {"beds_bed_top_bottom.png^[transformR90", "default_wood.png",  "beds_bed_side_bottom_r.png",  "beds_bed_side_bottom_r.png^[transformfx", "beds_bed_empty.png", "beds_bed_side_bottom.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	stack_max = 1,
	groups = {dig=default.dig.bed,flammable=3},
	sounds = default.node_sound_wood_defaults(),
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.06, 0.5},
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.06, 1.5},
				
	},

	after_place_node = function(pos, placer, itemstack)
		local node = minetest.env:get_node(pos)
		local p = {x=pos.x, y=pos.y, z=pos.z}
		local param2 = node.param2
		node.name = "beds:bed_top"
		if param2 == 0 then
			pos.z = pos.z+1
		elseif param2 == 1 then
			pos.x = pos.x+1
		elseif param2 == 2 then
			pos.z = pos.z-1
		elseif param2 == 3 then
			pos.x = pos.x-1
		end
		if minetest.registered_nodes[minetest.env:get_node(pos).name].buildable_to  then
			minetest.env:set_node(pos, node)
		else
			minetest.env:remove_node(p)
			return true
		end
	end,
		
	on_destruct = function(pos)
		local node = minetest.env:get_node(pos)
		local param2 = node.param2
		if param2 == 0 then
			pos.z = pos.z+1
		elseif param2 == 1 then
			pos.x = pos.x+1
		elseif param2 == 2 then
			pos.z = pos.z-1
		elseif param2 == 3 then
			pos.x = pos.x-1
		end
		if( minetest.env:get_node({x=pos.x, y=pos.y, z=pos.z}).name == "beds:bed_top") then
			if( minetest.env:get_node({x=pos.x, y=pos.y, z=pos.z}).param2 == param2 ) then
				minetest.env:remove_node(pos)
			end	
		end
	end,
	
	on_rightclick = function(pos, node, clicker)
		if not clicker:is_player() then
			return
		end
		local meta = minetest.env:get_meta(pos)
		local param2 = node.param2
		if param2 == 0 then
			pos.z = pos.z+1
		elseif param2 == 1 then
			pos.x = pos.x+1
		elseif param2 == 2 then
			pos.z = pos.z-1
		elseif param2 == 3 then
			pos.x = pos.x-1
		end
		if clicker:get_player_name() == meta:get_string("player") then
			if param2 == 0 then
				pos.x = pos.x-1
			elseif param2 == 1 then
				pos.z = pos.z+1
			elseif param2 == 2 then
				pos.x = pos.x+1
			elseif param2 == 3 then
				pos.z = pos.z-1
			end
			pos.y = pos.y-0.5
			clicker:set_physics_override(1, 1, 1)
			clicker:setpos(pos)
			meta:set_string("player", "")
			player_in_bed = player_in_bed-1
		elseif meta:get_string("player") == "" then
			if minetest.env:get_timeofday() > 0.2 and minetest.env:get_timeofday() < 0.805 then
				minetest.chat_send_player(clicker:get_player_name(), "You can only sleep at night")
				return
			end
			pos.y = pos.y-0.5
			clicker:set_physics_override(0, 0, 0)
			clicker:setpos(pos)
			if param2 == 0 then
				clicker:set_look_yaw(math.pi)
			elseif param2 == 1 then
				clicker:set_look_yaw(0.5*math.pi)
			elseif param2 == 2 then
				clicker:set_look_yaw(0)
			elseif param2 == 3 then
				clicker:set_look_yaw(1.5*math.pi)
			end
			
			meta:set_string("player", clicker:get_player_name())
			player_in_bed = player_in_bed+1
		end
	end
})

minetest.register_node("beds:bed_top", {
	drawtype = "nodebox",
	tiles = {"beds_bed_top_top.png^[transformR90", "beds_bed_empty.png",  "beds_bed_side_top_r.png",  "beds_bed_side_top_r.png^[transformfx",  "beds_bed_side_top.png", "beds_bed_empty.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {dig=default.dig.bed,flammable=3},
	sounds = default.node_sound_wood_defaults(),
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.06, 0.5},
	},
	selection_box = {
		type = "fixed",
		fixed = {0, 0, 0, 0, 0, 0},
	},
})

minetest.register_alias("beds:bed", "beds:bed_bottom")

minetest.register_craft({
	output = "beds:bed",
	recipe = {
		{"group:wool", "group:wool", "group:wool"},
		{"group:wood", "group:wood", "group:wood"}
	}
})

beds_player_spawns = {}
local file = io.open(minetest.get_worldpath().."/beds_player_spawns", "r")
if file then
	beds_player_spawns = minetest.deserialize(file:read("*all"))
	file:close()
end

local timer = 0
minetest.register_globalstep(function(dtime)
	if timer<2 then
		timer = timer+dtime
		return
	end
	timer = 0
	
	local players = #minetest.get_connected_players()
	if players == player_in_bed and players ~= 0 then
		if minetest.env:get_timeofday() < 0.2 or minetest.env:get_timeofday() > 0.805 then
			minetest.chat_send_all("Good night!!!")
			minetest.env:set_timeofday(0.23)
			for _,player in ipairs(minetest.get_connected_players()) do
				beds_player_spawns[player:get_player_name()] = player:getpos()
			end
			local file = io.open(minetest.get_worldpath().."/beds_player_spawns", "w")
			if file then
				file:write(minetest.serialize(beds_player_spawns))
				file:close()
			end
		end
	end
end)

minetest.register_on_respawnplayer(function(player)
	local name = player:get_player_name()
	if beds_player_spawns[name] then
		player:setpos(beds_player_spawns[name])
		return true
	end
end)
