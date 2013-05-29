
redstone = {}

local timer = {length = 0}

function redstone.after_redstone_tick(func, ...)
	timer[timer.length+1] = {f = func, args = {...}}
	timer.length = timer.length + 1
end

local tick = 0
TICKS = 10

minetest.register_globalstep(function(dtime)
	tick = tick + 1
	if tick >= TICKS then
		tick = 0
		local tm = timer
		timer = {length=0} -- Reset timer list before we apply changes
		for _, t in ipairs(tm) do
			t.f(unpack(t.args))
		end
	end
end)


dofile(minetest.get_modpath("redstone").."/crafting.lua")

local function add(v1, v2)
	return {x=v1.x+v2.x, y=v1.y+v2.y, z=v1.z+v2.z}
end

local function hacky_swap_node(pos,name, param2)
	local node = minetest.env:get_node(pos)
	local meta = minetest.env:get_meta(pos)
	if node.name == name then
		return
	end
	node.name = name
	node.param2 = param2 or node.param2
	local meta0 = meta:to_table()
	minetest.env:set_node(pos,node)
	meta = minetest.env:get_meta(pos)
	meta:from_table(meta0)
end

local function get_wallmounted_dir(pos, param2)
	local d = {x=0,y=0,z=0}
	if param2 == 0 then
		d.y = 1
	elseif param2 == 1 then
		d.y = -1
	elseif param2 == 2 then
		d.x = 1
	elseif param2 == 3 then
		d.x = -1
	elseif param2 == 4 then
		d.z = 1
	elseif param2 == 5 then
		d.z = -1
	end
	return d
end

local function get_wallmounted_node(pos, param2)
	return add(pos, get_wallmounted_dir(pos, param2))
end

local function get_facedir_node(pos, param2)
	local d = {x=0,y=0,z=0}
	if param2 == 0 then
		d.z = 1
	elseif param2 == 1 then
		d.x = 1
	elseif param2 == 2 then
		d.z = -1
	elseif param2 == 3 then
		d.x = -1
	end
	return add(pos, d)
end

redstone.default_rule = {
	{x= 1, y= 0, z=0},
	{x=-1, y= 0, z=0},
	{x= 1, y= 1, z=0},
	{x=-1, y= 1, z=0},
	{x= 1, y=-1, z=0},
	{x=-1, y=-1, z=0},
	
	{x=0, y= 0, z= 1},
	{x=0, y= 0, z=-1},
	{x=0, y= 1, z= 1},
	{x=0, y= 1, z=-1},
	{x=0, y=-1, z= 1},
	{x=0, y=-1, z=-1},
}

function redstone.level_at(pos, rule)
	rule  = rule or redstone.default_rule
	
	local level = 0
	for _,offset in ipairs(rule) do
		local p = add(pos, offset)
		local m = minetest.env:get_meta(p)
		local tmp = tonumber(m:get_string("redstone_level")) or 0
		if tmp > 0 then
			tmp = tmp-1
		end
		if tmp > level then
			level = tmp
		end
	end
	return level
end

function redstone.set_level(pos, level, force)
	local m = minetest.env:get_meta(pos)
	if force or (level ~= (tonumber(m:get_string("redstone_level")) or 0)) then
		m:set_string("redstone_level", tostring(level))
		for dx=-1,1 do
		for dy=-1,1 do
		for dz=-1,1 do
			if dx~=0 or dy~=0 or dz~=0 then
				local p = add(pos, {x=dx, y=dy, z=dz})
				local nn = minetest.env:get_node(p).name
				if
					minetest.registered_nodes[nn] and
					minetest.registered_nodes[nn].redstone_update and
					nn ~= "redstone:torch_off" and
					nn ~= "redstone:torch_on"
				then
					minetest.registered_nodes[nn].redstone_update(p)
				end
			end
		end
		end
		end
		for dx=-2,2 do
		for dy=-2,2 do
		for dz=-2,2 do
			if dx~=0 or dy~=0 or dz~=0 then
				local p = add(pos, {x=dx, y=dy, z=dz})
				local nn = minetest.env:get_node(p).name
				if nn == "redstone:torch_off" or nn == "redstone:torch_on" then
					redstone.after_redstone_tick(function(p)
						local nn = minetest.env:get_node(p).name
						if nn == "redstone:torch_off" or nn == "redstone:torch_on" then
							minetest.registered_nodes[nn].redstone_update(p)
						end
					end, p)
				end
			end
		end
		end
		end
	end
end

minetest.register_craftitem("redstone:redstone", {
	description = "Redstone",
	inventory_image = "redstone_redstone_item.png",
	stack_max = 64,
	sounds = default.node_sound_defaults(),
	
	on_place = function(itemstack, placer, pointed_thing)
		local tmpstack = ItemStack("redstone:redstone_off "..itemstack:get_count())
		tmpstack = minetest.item_place(tmpstack, placer, pointed_thing)
		return ItemStack("redstone:redstone "..tmpstack:get_count())
	end,
})

minetest.register_node("redstone:redstone_off", {
	tiles = {"redstone_redstone_off.png"},
	drawtype = "raillike",
	drop = "redstone:redstone",
	walkable = false,
	paramtype = "light",
	groups = {dig_immediate=3,attached_node=1,not_in_creative_inventory=1},
	sounds = default.node_sound_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.5+3/16, 0.5},
		},
	},
	after_place_node = function(pos)
		local level = redstone.level_at(pos)
		if level > 0 then
			minetest.env:set_node(pos, {name="redstone:redstone_on"})
		end
		redstone.set_level(pos, level)
	end,
	redstone_update = function(pos)
		local level = redstone.level_at(pos)
		if level > 0 then
			minetest.env:set_node(pos, {name="redstone:redstone_on"})
		end
		redstone.set_level(pos, level)
	end,
})

minetest.register_node("redstone:redstone_on", {
	tiles = {"redstone_redstone_on.png"},
	drawtype = "raillike",
	drop = "redstone:redstone",
	walkable = false,
	paramtype = "light",
	light_source = 7,
	groups = {dig_immediate=3,attached_node=1,not_in_creative_inventory=1},
	sounds = default.node_sound_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.5+3/16, 0.5},
		},
	},
	after_destruct = function(pos)
		redstone.set_level(pos, 0, true)
	end,
	redstone_update = function(pos)
		local level = redstone.level_at(pos)
		if level <= 0 then
			minetest.env:set_node(pos, {name="redstone:redstone_off"})
		end
		redstone.set_level(pos, level)
	end,
})

minetest.register_node("redstone:lever_off", {
	description = "Lever",
	drawtype = "torchlike",
	tiles = {"redstone_lever_bottom_off.png", "redstone_lever_wall_off.png"},
	inventory_image = "redstone_lever_bottom_off.png",
	wield_image = "redstone_lever_bottom_off.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	stack_max = 64,
	groups = {dig=default.dig.lever,attached_node=1},
	sounds = default.node_sound_defaults(),
	selection_box = {
		type = "wallmounted",
		wall_bottom = {-0.1, -0.5, -0.1, 0.1, -0.5+0.6, 0.1},
		wall_side = {-0.5, -0.3, -0.1, -0.5+0.3, 0.3, 0.1},
	},
	
	on_rightclick = function(pos, node)
		node.name = "redstone:lever_on"
		minetest.env:set_node(pos, node)
		redstone.set_level(pos, 16)
		local param2 = minetest.env:get_node(pos).param2
		redstone.set_level(get_wallmounted_node(pos, param2), 16)
	end,
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		local p0 = pointed_thing.under
		local p1 = pointed_thing.above
		if p0.y-1 == p1.y then
			return itemstack
		end

		return minetest.item_place(itemstack, placer, pointed_thing)
	end,
})

minetest.register_node("redstone:lever_on", {
	drawtype = "torchlike",
	tiles = {"redstone_lever_bottom_on.png", "redstone_lever_wall_on.png"},
	paramtype = "light",
	paramtype2 = "wallmounted",
	drop = "redstone:lever_off",
	walkable = false,
	groups = {dig=default.dig.lever,attached_node=1,not_in_creative_inventory=1},
	sounds = default.node_sound_defaults(),
	selection_box = {
		type = "wallmounted",
		wall_bottom = {-0.1, -0.5, -0.1, 0.1, -0.5+0.6, 0.1},
		wall_side = {-0.5, -0.3, -0.1, -0.5+0.3, 0.3, 0.1},
	},
	
	after_destruct = function(pos, oldnode)
		redstone.set_level(pos, 0, true)
		redstone.set_level(get_wallmounted_node(pos, oldnode.param2), 0)
	end,
	on_rightclick = function(pos, node)
		node.name = "redstone:lever_off"
		minetest.env:set_node(pos, node)
		redstone.set_level(pos, 0, true)
		redstone.set_level(get_wallmounted_node(pos, node.param2), 0)
	end,
})

minetest.register_node("redstone:torch_on", {
	description = "Redstone Torch",
	drawtype = "torchlike",
	tiles = {
		{name="default_torch_on_floor_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=3.0}},
		{name="default_torch_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=3.0}}
	},
	inventory_image = "default_torch_on_floor.png",
	wield_image = "default_torch_on_floor.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	light_source = 7,
	selection_box = {
		type = "wallmounted",
		wall_bottom = {-0.1, -0.5, -0.1, 0.1, -0.5+0.6, 0.1},
		wall_side = {-0.5, -0.3, -0.1, -0.5+0.3, 0.3, 0.1},
	},
	groups = {dig_immediate=3,attached_node=1},
	stack_max = 64,
	sounds = default.node_sound_defaults(),
	
	redstone_update = function(pos)
		local n = minetest.env:get_node(pos)
		local m = minetest.env:get_meta(pos)
		m:set_string("redstone_level", tostring(0))
		local level = redstone.level_at(get_wallmounted_node(pos, n.param2), {get_wallmounted_dir(pos, n.param2)})
		m:set_string("redstone_level", tostring(16))
		if level > 0 then
			n.name = "redstone:torch_off"
			minetest.env:set_node(pos, n)
			redstone.set_level(pos, 0)
		else
			redstone.set_level(pos, 16)
		end
	end,
	after_destruct = function(pos, oldnode)
		redstone.set_level(pos, 0, true)
	end,
	after_place_node = function(pos)
		local n = minetest.env:get_node(pos)
		local level = redstone.level_at(get_wallmounted_node(pos, n.param2), {get_wallmounted_dir(pos, n.param2)})
		if level > 0 then
			n.name = "redstone:torch_off"
			minetest.env:set_node(pos, n)
			redstone.set_level(pos, 0)
		else
			redstone.set_level(pos, 16)
		end
	end,
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		local p0 = pointed_thing.under
		local p1 = pointed_thing.above
		if p0.y-1 == p1.y then
			return itemstack
		end

		return minetest.item_place(itemstack, placer, pointed_thing)
	end,
})

minetest.register_node("redstone:torch_off", {
	drawtype = "torchlike",
	tiles = {
		{name="default_torch_on_floor_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=3.0}},
		{name="default_torch_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=3.0}}
	},
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	drop = "redstone:torch_on",
	selection_box = {
		type = "wallmounted",
		wall_bottom = {-0.1, -0.5, -0.1, 0.1, -0.5+0.6, 0.1},
		wall_side = {-0.5, -0.3, -0.1, -0.5+0.3, 0.3, 0.1},
	},
	groups = {dig_immediate=3,attached_node=1,not_in_creative_inventory=1},
	sounds = default.node_sound_defaults(),
	
	redstone_update = function(pos)
		local n = minetest.env:get_node(pos)
		local level = redstone.level_at(get_wallmounted_node(pos, n.param2), {get_wallmounted_dir(pos, n.param2)})
		if level <= 0 then
			n.name = "redstone:torch_on"
			minetest.env:set_node(pos, n)
			redstone.set_level(pos, 16)
		else
			redstone.set_level(pos, 0)
		end
	end,
})

minetest.register_node("redstone:stone_with_redstone", {
	description = "Redstone Ore",
	tiles = {"default_stone.png^redstone_mineral_redstone.png"},
	is_ground_content = true,
	groups = {cracky=default.dig.redstone_ore},
	drop = {
		items = {
			{items={"redstone:redstone 4"}},
			{items={"redstone:redstone"},rarity=4},
		},
	},
	stack_max = 64,
	sounds = default.node_sound_stone_defaults(),
	
	on_punch = function(pos, node, puncher)
		minetest.env:set_node(pos, {name="redstone:stone_with_redstone_activated"})
		redstone.set_level(pos, 16)
		minetest.after(math.random(10,20)/10, function(pos)
			if minetest.env:get_node(pos).name == "redstone:stone_with_redstone_activated" then
				minetest.env.set_node(pos, {name="redstone:stone_with_redstone"})
			end
		end, pos)
	end,
})

minetest.register_node("redstone:stone_with_redstone_activated", {
	tiles = {"default_stone.png^redstone_mineral_redstone.png"},
	is_ground_content = true,
	groups = {cracky=default.dig.redstone_ore,not_in_creative_inventory=1},
	light_source = 9,
	drop = {
		items = {
			{items={"redstone:redstone 4"}},
			{items={"redstone:redstone"},rarity=4},
		},
	},
	stack_max = 64,
	sounds = default.node_sound_stone_defaults(),
	
	on_destruct = function(pos)
		redstone.set_level(pos, 0)
	end,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "redstone:stone_with_redstone",
	wherein        = "default:stone",
	clust_scarcity = 600,
	clust_num_ores = 6,
	clust_size     = 3,
	height_min     = -59,
	height_max     = -52,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "redstone:stone_with_redstone",
	wherein        = "default:stone",
	clust_scarcity = 1200,
	clust_num_ores = 4,
	clust_size     = 3,
	height_min     = -55,
	height_max     = -53,
})

minetest.register_node("redstone:button", {
	description = "Button",
	tiles = {"default_stone.png"},
	inventory_image = "redstone_button_inventory.png",
	wield_image = "redstone_button_inventory.png",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {dig=default.dig.button},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.15, -0.1, 0.4,   0.15, 0.1, 0.5},
		},
	},
	
	on_rightclick = function(pos, node)
		redstone.set_level(pos, 16, true)
		redstone.set_level(get_facedir_node(pos, node.param2), 16, true)
		minetest.after(1, function(p1, p2)
			redstone.set_level(p1, 0, true)
			redstone.set_level(p2, 0, true)
		end, pos, get_facedir_node(pos, node.param2))
	end,
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		local pp = placer:getpos()
		local dir = {
			x = pointed_thing.above.x - pp.x,
			y = pointed_thing.above.y - pp.y,
			z = pointed_thing.above.z - pp.z
		}
		local nn = minetest.env:get_node(get_facedir_node(pointed_thing.above, minetest.dir_to_facedir(dir))).name
		if not minetest.registered_nodes[nn].walkable then
			return itemstack
		end

		return minetest.item_place(itemstack, placer, pointed_thing)
	end,
})

local function update_button_attachment(p)
	-- Round p to prevent falling entities to get stuck
	p.x = math.floor(p.x+0.5)
	p.y = math.floor(p.y+0.5)
	p.z = math.floor(p.z+0.5)
	
	for x = -1,1 do
	for y = -1,1 do
	for z = -1,1 do
		local n = minetest.env:get_node({x=p.x+x, y=p.y+y, z=p.z+z})
		if n.name == "redstone:button" then
			local nn = minetest.env:get_node(get_facedir_node({x=p.x+x, y=p.y+y, z=p.z+z}, n.param2)).name
			if not minetest.registered_nodes[nn].walkable then
				drop_attached_node({x=p.x+x, y=p.y+y, z=p.z+z})
			end
		end
	end
	end
	end
end
minetest.register_on_dignode(update_button_attachment)
minetest.register_on_placenode(update_button_attachment)

minetest.register_node("redstone:pressure_plate_stone", {
	description = "Stone Pressure Plate",
	tiles = {"default_stone.png"},
	drawtype = "nodebox",
	paramtype = "light",
	groups = {cracky=default.dig.pressure_plate_stone,attached_node=1},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.45, -0.5, -0.45, 0.45, -0.45, 0.45},
		},
	},
})

minetest.register_node("redstone:pressure_plate_wood", {
	description = "Wooden Pressure Plate",
	tiles = {"default_wood.png"},
	drawtype = "nodebox",
	paramtype = "light",
	groups = {choppy=default.dig.pressure_plate_wood,attached_node=1},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.45, -0.5, -0.45, 0.45, -0.45, 0.45},
		},
	},
})

minetest.register_abm({
	nodenames = {"redstone:pressure_plate_stone", "redstone:pressure_plate_wood"},
	interval = 1,
	chance = 1,
	action = function(pos)
		if #minetest.env:get_objects_inside_radius(pos, 1) ~= 0 then
			redstone.set_level(pos, 16)
			pos.y = pos.y-1
			redstone.set_level(pos, 16)
		else
			redstone.set_level(pos, 0)
			pos.y = pos.y-1
			redstone.set_level(pos, 0)
		end
	end,
})
