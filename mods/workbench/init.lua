minetest.register_node("workbench:workbench", {
	description = "Workbench",
	tiles = {"workbench_top.png", "workbench_side.png"},
	stack_max = 64,
	groups = {choppy=2,oddly_breakable_by_hand=2,flammable=3},
	sounds = default.node_sound_wood_defaults(),
	on_rightclick = function(pos, node, clicker, itemstack)
		minetest.show_formspec(clicker:get_player_name(), "workbench:workbench",
			"size[9,8;]"..
			"list[current_player;main;0,3.5;9,4;9]"..
			"list[current_player;main;0,7;9,1;]"..
			"list[current_player;craft;4,0;3,3;]"..
			"list[current_player;craftpreview;7.5,1;1,1;]"
		)
	end,
})

local players_viewdir = {}

minetest.register_globalstep(function(dtime)
	for _,player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local pitch = player:get_look_pitch()
		local yaw = player:get_look_yaw()
		local pos = player:getpos()
		local o = players_viewdir[name]
		if pitch ~= o.pitch or yaw ~= o.yaw or pos.x ~= o.pos.x or pos.y ~= o.pos.y or pos.z ~= o.pos.z then
			players_viewdir[name] = {pitch = pitch, yaw = yaw, pos = {x = pos.x, y = pos.y, z = pos.z}}
			local inv = player:get_inventory()
			pos.y = pos.y+1.5
			local ldir = player:get_look_dir()
			pos.x = pos.x + ldir.x
			pos.y = pos.y + ldir.y
			pos.z = pos.z + ldir.z
			for i,stack in ipairs(inv:get_list("craft")) do
				local obj = minetest.add_item(pos, stack)
				if obj then
					obj:setvelocity(ldir)
				end
				stack:clear()
				inv:set_stack("craft", i, stack)
			end
		end
	end
end)

minetest.register_craft({
	output = "workbench:workbench",
	recipe = {
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"},
	},
})

minetest.register_on_joinplayer(function(player)
	if not minetest.setting_getbool("creative_mode") then
		players_viewdir[player:get_player_name()] = {pitch = 0, yaw = 0, pos={x = 0, y = 0, z = 0}}
		player:get_inventory():set_width("craft", 3)
		player:get_inventory():set_size("craft", 9)
		player:get_inventory():set_size("main", 9*4)
		if player.hud_set_hotbar_itemcount then
			minetest.after(0, player.hud_set_hotbar_itemcount, player, 9)
		end
		player:set_inventory_formspec(
			"size[9,8;]"..
			
			"list[current_player;main;0,3.5;9,4;9]"..
			"list[current_player;main;0,7;9,1;]"..
			
			"list[current_player;craft;5,0.5;2,1;1]"..
			"list[current_player;craft;5,1.5;2,1;4]"..
			
			"list[current_player;craftpreview;7.5,1;1,1;]"
		)
	end
end)
