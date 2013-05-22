
local function update_workbench(pos)
	local meta = minetest.env:get_meta(pos)
	local inv = meta:get_inventory()
	local result = minetest.get_craft_result({
		type = "normal",
		width = 3,
		items = inv:get_list("craft")
	})
	inv:set_stack("result", 1, result.item)
end

minetest.register_node("workbench:workbench", {
	description = "Workbench",
	tiles = {"workbench_top.png", "workbench_side.png"},
	groups = {choppy=2,oddly_breakable_by_hand=2,flammable=3},
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.env:get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("craft", 9)
		inv:set_size("result", 1)
		meta:set_string("formspec", 
			"size[8,7.5;]"..
			"list[current_player;main;0,3.5;8,4;]"..
			"list[current_name;craft;3,0;3,3;]"..
			"list[current_name;result;6.5,1;1,1;]"
		)
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index,to_list, to_index, count, player)
		if to_list == "result" then
			print("Nope")
			return 0
		end
		return count
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "result" then
			print("Nope")
			return 0
		end
		return stack:get_count()
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		return stack:get_count()
	end,
	on_metadata_inventory_put = update_workbench,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local inv = minetest.env:get_meta(pos):get_inventory()
		if from_list == "result" then
			for i,stack in ipairs(inv:get_list("craft")) do
				stack:take_item()
				inv:set_stack("craft", i, stack)
			end
		end
		update_workbench(pos)
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local inv = minetest.env:get_meta(pos):get_inventory()
		if listname == "result" then
			for i,stack in ipairs(inv:get_list("craft")) do
				stack:take_item()
				inv:set_stack("craft", i, stack)
			end
		end
		update_workbench(pos)
	end,
	can_dig = function(pos)
		local inv = minetest.env:get_meta(pos):get_inventory()
		return inv:is_empty("craft") and inv:is_empty("result")
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
		player:get_inventory():set_width("craft", 2)
		player:get_inventory():set_size("craft", 4)
		player:set_inventory_formspec(
			"size[8,7.5;]"..
			"list[current_player;main;0,3.5;8,4;]"..
			"list[current_player;craft;4,0.5;2,2;]"..
			"list[current_player;craftpreview;6.5,1;1,1;]"
		)
	else
		player:get_inventory():set_width("craft", 3)
		player:get_inventory():set_size("craft", 9)
	end
end)