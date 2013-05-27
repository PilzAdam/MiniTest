minetest.register_node("workbench:workbench", {
	description = "Workbench",
	tiles = {"workbench_top.png", "workbench_side.png"},
	stack_max = 64,
	groups = {choppy=default.dig.workbench,flammable=3},
	sounds = default.node_sound_wood_defaults(),
	on_rightclick = function(pos, node, clicker, itemstack)
		minetest.show_formspec(clicker:get_player_name(), "workbench:workbench",
			"size[9,8;]"..
			"list[current_player;main;0,3.5;9,3;9]"..
			"list[current_player;main;0,7;9,1;]"..
			"list[current_player;craft;4,0;3,3;]"..
			"list[current_player;craftpreview;7.5,1;1,1;]"
		)
	end,
})

minetest.register_craft({
	output = "workbench:workbench",
	recipe = {
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"},
	},
})

minetest.register_on_joinplayer(function(player)
	if not minetest.setting_getbool("creative_mode") then
		player:get_inventory():set_width("craft", 3)
		player:get_inventory():set_size("craft", 9)
		player:get_inventory():set_size("main", 9*4)
		if player.hud_set_hotbar_itemcount then
			minetest.after(0, player.hud_set_hotbar_itemcount, player, 9)
		end
		player:set_inventory_formspec(
			"size[9,8;]"..
			
			"list[current_player;main;0,3.5;9,3;9]"..
			"list[current_player;main;0,7;9,1;]"..
			
			"list[current_player;craft;5,0.5;2,1;1]"..
			"list[current_player;craft;5,1.5;2,1;4]"..
			
			"list[current_player;craftpreview;7.5,1;1,1;]"
		)
	end
end)
