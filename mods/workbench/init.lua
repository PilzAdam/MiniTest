-- init.lua
-- workbench minetest mod, by darkrose
-- Copyright (C) Lisa Milne 2012 <lisa@ltmnet.com>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as
-- published by the Free Software Foundation, either version 2.1 of the
-- License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
-- Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this program.  If not, see
-- <http://www.gnu.org/licenses/>

minetest.register_node("workbench:3x3", {
	description = "WorkBench",
	tile_images = {"workbench_3x3_top.png","workbench_3x3_bottom.png","workbench_3x3_side.png"},
	paramtype2 = "facedir",
	groups = {cracky=2},
	legacy_facedir_simple = true,
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("formspec",
			"size[8,9]"..
			"list[current_name;table;1,1;3,3;]"..
			"list[current_name;dst;6,2;1,1;]"..
			"list[current_player;main;0,5;8,4;]")
		meta:set_string("infotext", "3x3 WorkBench")
		local inv = meta:get_inventory()
		inv:set_size("table", 9)
		inv:set_size("dst", 1)
	end,
	can_dig = function(pos,player)
		local meta = minetest.env:get_meta(pos);
		local inv = meta:get_inventory()
		if inv:is_empty("table") and inv:is_empty("dst") then
			return true
		end
		return false
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if to_list == "dst" then
			return 0
		end
		return count
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "dst" then
			return 0
		end
		return stack:get_count()
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		return stack:get_count()
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index,
			to_list, to_index, count, player)
		minetest.node_metadata_inventory_move_allow_all(
				pos, from_list, from_index, to_list, to_index, count, player)
		if to_list == "table" or from_list == "table" then
			local meta = minetest.env:get_meta(pos)
			local inv = meta:get_inventory()
			local tablelist = inv:get_list("table")
			local crafted = nil

			if tablelist then
				crafted = minetest.get_craft_result({method = "normal", width = 3, items = tablelist})
			end

			if crafted then
				inv:set_stack("dst", 1, crafted.item)
			else
				inv:set_stack("dst", 1, nil)
			end
		end
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "table" then
			local meta = minetest.env:get_meta(pos)
			local inv = meta:get_inventory()
			local tablelist = inv:get_list("table")
			local crafted = nil

			if tablelist then
				crafted = minetest.get_craft_result({method = "normal", width = 3, items = tablelist})
			end

			if crafted then
				inv:set_stack("dst", 1, crafted.item)
			else
				inv:set_stack("dst", 1, nil)
			end
		end
	end,
	on_metadata_inventory_take = function(pos, listname, index, count, player)
		if listname == "table" then
			local meta = minetest.env:get_meta(pos)
			local inv = meta:get_inventory()
			local tablelist = inv:get_list("table")
			local crafted = nil

			if tablelist then
				crafted = minetest.get_craft_result({method = "normal", width = 3, items = tablelist})
			end

			if crafted then
				inv:set_stack("dst", 1, crafted.item)
			else
				inv:set_stack("dst", 1, nil)
			end
		elseif listname == "dst" then
			local meta = minetest.env:get_meta(pos)
			local inv = meta:get_inventory()
			local tablelist = inv:get_list("table")
			local crafted = nil
			local table_dec = nil

			if tablelist then
				crafted,table_dec = minetest.get_craft_result({method = "normal", width = 3, items = tablelist})
			end

			if table_dec then
				inv:set_list("table", table_dec.items)
			else
				inv:set_list("table", nil)
			end

			local tablelist = inv:get_list("table")

			if tablelist then
				crafted,table_dec = minetest.get_craft_result({method = "normal", width = 3, items = tablelist})
			end

			if crafted then
				inv:set_stack("dst", 1, crafted.item)
			else
				inv:set_stack("dst", 1, nil)
			end
		end
		return post
	end,
})

minetest.register_craft({
	output = '"workbench:3x3"',
	recipe = {
		{'"default:wood"','"default:wood"'},
		{'"default:wood"','"default:wood"'},
	}
})
