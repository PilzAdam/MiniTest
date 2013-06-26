local function getCraftResult(pos)
	local inv = minetest.get_meta(pos):get_inventory()
	inv:set_stack("craftpreview", 1, minetest.get_craft_result({method = "normal", width = 3, items = inv:get_list("craft")}).item)
end

minetest.register_node("workbench:workbench", {
	description = "Workbench",
	tiles = {"workbench_top.png", "workbench_side.png"},
	stack_max = 64,
	groups = {choppy=default.dig.workbench,flammable=3},
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", 
			"size[9,8;]"..
			"list[current_player;main;0,3.5;9,3;9]"..
			"list[current_player;main;0,7;9,1;]"..
			"list[context;craft;4,0;3,3;]"..
			"list[context;craftpreview;7.5,1;1,1;]"
		)
		meta:get_inventory():set_size("craft", 9)
		meta:get_inventory():set_size("craftpreview", 1)
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		getCraftResult(pos)
	end,
    	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		getCraftResult(pos)
	end,
   	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		getCraftResult(pos)
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "craftpreview" then return 0 end
		return stack:get_count()
	end,
	can_dig = function(pos,player)
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("craft") and inv:is_empty("craftpreview")
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
