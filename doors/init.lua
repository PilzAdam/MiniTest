doors = {}

-- Registers a door
--  name: The name of the door
--  def: a table with the folowing fields:
--    description
--    inventory_image
--    groups
--    tiles_bottom: the tiles of the bottom part of the door {front, side}
--    tiles_top: the tiles of the bottom part of the door {front, side}
--    If the following fields are not defined the default values are used
--    node_box_bottom
--    node_box_top
--    selection_box_bottom
--    selection_box_top
--    only_placer_can_open: if true only the player who placed the door can
--                          open it

local function is_right(pos, clicker) 
	local r1 = minetest.env:get_node({x=pos.x+1, y=pos.y, z=pos.z})
	local r2 = minetest.env:get_node({x=pos.x, y=pos.y, z=pos.z+1})
	if string.find(r1.name, "door_") or string.find(r2.name, "door_") then
		return false
	else
		return true
	end
end

function doors:register_door(name, def)
	def.groups.not_in_creative_inventory = 1
	
	local box = {{-0.5, -0.5, -0.5,   0.5, 0.5, -0.5+1.5/16}}
	
	if not def.node_box_bottom then
		def.node_box_bottom = box
	end
	if not def.node_box_top then
		def.node_box_top = box
	end
	if not def.selection_box_bottom then
		def.selection_box_bottom= box
	end
	if not def.selection_box_top then
		def.selection_box_top = box
	end
	
	minetest.register_craftitem(name, {
		description = def.description,
		inventory_image = def.inventory_image,
		
		on_place = function(itemstack, placer, pointed_thing)
			if not pointed_thing.type == "node" then
				return itemstack
			end
			
			local ptu = pointed_thing.under
			local nu = minetest.env:get_node(ptu)
			if minetest.registered_nodes[nu.name].on_rightclick then
				return minetest.registered_nodes[nu.name].on_rightclick(ptu, nu, placer, itemstack)
			end
			
			local pt = pointed_thing.above
			local pt2 = {x=pt.x, y=pt.y, z=pt.z}
			pt2.y = pt2.y+1
			if
				not minetest.registered_nodes[minetest.env:get_node(pt).name].buildable_to or
				not minetest.registered_nodes[minetest.env:get_node(pt2).name].buildable_to or
				not placer or
				not placer:is_player()
			then
				return itemstack
			end
			
			local p2 = minetest.dir_to_facedir(placer:get_look_dir())
			local pt3 = {x=pt.x, y=pt.y, z=pt.z}
			if p2 == 0 then
				pt3.x = pt3.x-1
			elseif p2 == 1 then
				pt3.z = pt3.z+1
			elseif p2 == 2 then
				pt3.x = pt3.x+1
			elseif p2 == 3 then
				pt3.z = pt3.z-1
			end
			if not string.find(minetest.env:get_node(pt3).name, name.."_b_") then
				minetest.env:set_node(pt, {name=name.."_b_1", param2=p2})
				minetest.env:set_node(pt2, {name=name.."_t_1", param2=p2})
			else
				minetest.env:set_node(pt, {name=name.."_b_2", param2=p2})
				minetest.env:set_node(pt2, {name=name.."_t_2", param2=p2})
			end
			
			if def.only_placer_can_open then
				local pn = placer:get_player_name()
				local meta = minetest.env:get_meta(pt)
				meta:set_string("doors_owner", pn)
				meta:set_string("infotext", "Owned by "..pn)
				meta = minetest.env:get_meta(pt2)
				meta:set_string("doors_owner", pn)
				meta:set_string("infotext", "Owned by "..pn)
			end
			
			if not minetest.setting_getbool("creative_mode") then
				itemstack:take_item()
			end
			return itemstack
		end,
	})
	
	local tt = def.tiles_top
	local tb = def.tiles_bottom
	
	local function after_dig_node(pos, name)
		if minetest.env:get_node(pos).name == name then
			minetest.env:remove_node(pos)
		end
	end
	
	local function on_rightclick(pos, dir, check_name, replace, replace_dir, params)
		pos.y = pos.y+dir
		if not minetest.env:get_node(pos).name == check_name then
			return
		end
		local p2 = minetest.env:get_node(pos).param2
		p2 = params[p2+1]
		
		local meta = minetest.env:get_meta(pos):to_table()
		minetest.env:set_node(pos, {name=replace_dir, param2=p2})
		minetest.env:get_meta(pos):from_table(meta)
		
		pos.y = pos.y-dir
		meta = minetest.env:get_meta(pos):to_table()
		minetest.env:set_node(pos, {name=replace, param2=p2})
		minetest.env:get_meta(pos):from_table(meta)
	end
	
	local function check_player_priv(pos, player)
		if not def.only_placer_can_open then
			return true
		end
		local meta = minetest.env:get_meta(pos)
		local pn = player:get_player_name()
		return meta:get_string("doors_owner") == pn
	end
	
	minetest.register_node(name.."_b_1", {
		tiles = {tb[2], tb[2], tb[2], tb[2], tb[1], tb[1].."^[transformfx"},
		paramtype = "light",
		paramtype2 = "facedir",
		drop = name,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = def.node_box_bottom
		},
		selection_box = {
			type = "fixed",
			fixed = def.selection_box_bottom
		},
		groups = def.groups,
		
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			pos.y = pos.y+1
			after_dig_node(pos, name.."_t_1")
		end,
		
		on_rightclick = function(pos, node, clicker)
			if check_player_priv(pos, clicker) then
				on_rightclick(pos, 1, name.."_t_1", name.."_b_2", name.."_t_2", {1,2,3,0})
				if is_right(pos, clicker) then
					minetest.sound_play("door_close", {gain = 0.3, max_hear_distance = 10})					
				else
					minetest.sound_play("door_open", {gain = 0.3, max_hear_distance = 10})
				end
			end
		end,
		
		can_dig = check_player_priv,
	})
	
	minetest.register_node(name.."_t_1", {
		tiles = {tt[2], tt[2], tt[2], tt[2], tt[1], tt[1].."^[transformfx"},
		paramtype = "light",
		paramtype2 = "facedir",
		drop = name,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = def.node_box_top
		},
		selection_box = {
			type = "fixed",
			fixed = def.selection_box_top
		},
		groups = def.groups,
		
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			pos.y = pos.y-1
			after_dig_node(pos, name.."_b_1")
		end,
		
		on_rightclick = function(pos, node, clicker)
			if check_player_priv(pos, clicker) then
				on_rightclick(pos, -1, name.."_b_1", name.."_t_2", name.."_b_2", {1,2,3,0})
				if is_right(pos, clicker) then
					minetest.sound_play("door_close", {gain = 0.3, max_hear_distance = 10})					
				else
					minetest.sound_play("door_open", {gain = 0.3, max_hear_distance = 10})
				end
			end
		end,
		
		can_dig = check_player_priv,
	})
	
	minetest.register_node(name.."_b_2", {
		tiles = {tb[2], tb[2], tb[2], tb[2], tb[1].."^[transformfx", tb[1]},
		paramtype = "light",
		paramtype2 = "facedir",
		drop = name,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = def.node_box_bottom
		},
		selection_box = {
			type = "fixed",
			fixed = def.selection_box_bottom
		},
		groups = def.groups,
		
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			pos.y = pos.y+1
			after_dig_node(pos, name.."_t_2")
		end,
		
		on_rightclick = function(pos, node, clicker)
			if check_player_priv(pos, clicker) then
				on_rightclick(pos, 1, name.."_t_2", name.."_b_1", name.."_t_1", {3,0,1,2})
				if is_right(pos, clicker) then
					minetest.sound_play("door_open", {gain = 0.3, max_hear_distance = 10})					
				else
					minetest.sound_play("door_close", {gain = 0.3, max_hear_distance = 10})
				end
			end
		end,
		
		can_dig = check_player_priv,
	})
	
	minetest.register_node(name.."_t_2", {
		tiles = {tt[2], tt[2], tt[2], tt[2], tt[1].."^[transformfx", tt[1]},
		paramtype = "light",
		paramtype2 = "facedir",
		drop = name,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = def.node_box_top
		},
		selection_box = {
			type = "fixed",
			fixed = def.selection_box_top
		},
		groups = def.groups,
		
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			pos.y = pos.y-1
			after_dig_node(pos, name.."_b_2")
		end,
		
		on_rightclick = function(pos, node, clicker)
			if check_player_priv(pos, clicker) then
				on_rightclick(pos, -1, name.."_b_2", name.."_t_1", name.."_b_1", {3,0,1,2})
				if is_right(pos, clicker) then
					minetest.sound_play("door_open", {gain = 0.3, max_hear_distance = 10})					
				else
					minetest.sound_play("door_close", {gain = 0.3, max_hear_distance = 10})
				end
			end
		end,
		
		can_dig = check_player_priv,
	})
	
end

doors:register_door("doors:door_wood", {
	description = "Wooden Door",
	inventory_image = "door_wood.png",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,door=1},
	tiles_bottom = {"door_wood_b.png", "door_brown.png"},
	tiles_top = {"door_wood_a.png", "door_brown.png"},
})

minetest.register_craft({
	output = "doors:door_wood",
	recipe = {
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"}
	}
})

doors:register_door("doors:door_steel", {
	description = "Steel Door",
	inventory_image = "door_steel.png",
	groups = {snappy=1,bendy=2,cracky=1,melty=2,level=2,door=1},
	tiles_bottom = {"door_steel_b.png", "door_grey.png"},
	tiles_top = {"door_steel_a.png", "door_grey.png"},
	only_placer_can_open = true,
})

minetest.register_craft({
	output = "doors:door_steel",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot"}
	}
})

doors:register_door("doors:door_glass", {
	description = "Glass Door",
	inventory_image = "door_glass.png",
	groups = {snappy=1,cracky=1,oddly_breakable_by_hand=2,door=1},
	tiles_bottom = {"default_glass.png", "door_grey.png"},
	tiles_top = {"default_glass.png", "door_grey.png"},
})

minetest.register_craft({
	output = "doors:door_glass",
	recipe = {
		{"default:glass", "default:glass"},
		{"default:glass", "default:glass"},
		{"default:glass", "default:glass"}
	}
})

minetest.register_alias("doors:door_wood_a_c", "doors:door_wood_t_1")
minetest.register_alias("doors:door_wood_a_o", "doors:door_wood_t_1")
minetest.register_alias("doors:door_wood_b_c", "doors:door_wood_b_1")
minetest.register_alias("doors:door_wood_b_o", "doors:door_wood_b_1")


----trapdoor----

local me
local meta
local state = 0

local function update_door(pos, node) 
	minetest.env:set_node(pos, node)
end

local function punch(pos)
	meta = minetest.env:get_meta(pos)
	state = meta:get_int("state")
	me = minetest.env:get_node(pos)
	local tmp_node
	local tmp_node2
	oben = {x=pos.x, y=pos.y+1, z=pos.z}
		if state == 1 then
			state = 0
			minetest.sound_play("door_close", {to_player = puncher, gain = 0.3, max_hear_distance = 10})
			tmp_node = {name="doors:trapdoor", param1=me.param1, param2=me.param2}
		else
			state = 1
			minetest.sound_play("door_open", {to_player = puncher, gain = 0.3, max_hear_distance = 10})
			tmp_node = {name="doors:trapdoor_open", param1=me.param1, param2=me.param2}
		end
		update_door(pos, tmp_node)
		meta:set_int("state", state)
end


minetest.register_node("doors:trapdoor", {
	description = "Trapdoor",
	inventory_image = "door_trapdoor.png",
	drawtype = "nodebox",
	tiles = {"door_trapdoor.png", "door_trapdoor.png",  "default_wood.png",  "default_wood.png", "default_wood.png", "default_wood.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,door=1},
	sounds = default.node_sound_wood_defaults(),
	drop = "doors:trapdoor",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.4, 0.5}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.4, 0.5}
	},
	on_creation = function(pos)
		state = 0
	end,
	on_rightclick = function(pos, node, clicker)
		punch(pos)
	end,
})


minetest.register_node("doors:trapdoor_open", {
	drawtype = "nodebox",
	tiles = {"default_wood.png", "default_wood.png",  "default_wood.png",  "default_wood.png", "door_trapdoor.png", "door_trapdoor.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	pointable = true,
	stack_max = 0,
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,door=1},
	sounds = default.node_sound_wood_defaults(),
	drop = "doors:trapdoor",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 0.4, 0.5, 0.5, 0.5}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 0.4, 0.5, 0.5, 0.5}
	},
	on_rightclick = function(pos, node, clicker)
		punch(pos)
	end,
})




minetest.register_craft({
	output = 'doors:trapdoor 2',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'group:wood', 'group:wood', 'group:wood'},
		{'', '', ''},
	}
})