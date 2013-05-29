-- Minetest 0.4 mod: farming
-- See README.txt for licensing and other information.

--
-- Soil
--
minetest.register_node("farming:soil", {
	description = "Soil",
	tiles = {"farming_soil.png", "default_dirt.png"},
	drop = "default:dirt",
	is_ground_content = true,
	groups = {crumbly=default.dig.dirt_with_grass, not_in_creative_inventory=1, soil=2},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("farming:soil_wet", {
	description = "Wet Soil",
	tiles = {"farming_soil_wet.png", "farming_soil_wet_side.png"},
	drop = "default:dirt",
	is_ground_content = true,
	groups = {crumbly=default.dig.dirt_with_grass, not_in_creative_inventory=1, soil=3},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_abm({
	nodenames = {"farming:soil", "farming:soil_wet"},
	interval = 15,
	chance = 4,
	action = function(pos, node)
		pos.y = pos.y+1
		local nn = minetest.env:get_node(pos).name
		pos.y = pos.y-1
		if minetest.registered_nodes[nn] and minetest.registered_nodes[nn].walkable then
			minetest.env:set_node(pos, {name="default:dirt"})
		end
		-- check if there is water nearby
		if minetest.env:find_node_near(pos, 4, {"group:water"}) then
			-- if it is dry soil turn it into wet soil
			if node.name == "farming:soil" then
				minetest.env:set_node(pos, {name="farming:soil_wet"})
			end
		else
			-- turn it back into dirt if it is already dry
			if node.name == "farming:soil" then
				-- only turn it back if there is no plant on top of it
				if minetest.get_item_group(nn, "plant") == 0 then
					minetest.env:set_node(pos, {name="default:dirt"})
				end
				
			-- if its wet turn it back into dry soil
			elseif node.name == "farming:soil_wet" then
				minetest.env:set_node(pos, {name="farming:soil"})
			end
		end
	end,
})

--
-- Hoes
--
-- turns nodes with group soil=1 into soil; drop seeds if plowing grass
local function hoe_on_use(itemstack, user, pointed_thing, uses)
	local pt = pointed_thing
	-- check if pointing at a node
	if not pt then
		return
	end
	if pt.type ~= "node" then
		return
	end
	
	local under = minetest.env:get_node(pt.under)
	local p = {x=pt.under.x, y=pt.under.y+1, z=pt.under.z}
	local above = minetest.env:get_node(p)
	
	-- return if any of the nodes is not registered
	if not minetest.registered_nodes[under.name] then
		return
	end
	if not minetest.registered_nodes[above.name] then
		return
	end
	
	if minetest.registered_nodes[under.name].on_rightclick then
		return minetest.registered_nodes[under.name].on_rightclick(pt.under, under, user, itemstack)
	end
	
	-- check if the node above the pointed thing is air
	if above.name ~= "air" then
		return
	end
	
	-- check if pointing at dirt
	if minetest.get_item_group(under.name, "soil") ~= 1 then
		return
	end
	
	-- turn the node into soil, wear out item and play sound
	minetest.env:set_node(pt.under, {name="farming:soil"})
	minetest.sound_play("default_dig_crumbly", {
		pos = pt.under,
		gain = 0.5,
	})
	itemstack:add_wear(65535/(uses-1))
	return itemstack
end

minetest.register_tool("farming:hoe_wood", {
	description = "Wooden Hoe",
	inventory_image = "farming_tool_woodhoe.png",
	
	on_place = function(itemstack, user, pointed_thing)
		return hoe_on_use(itemstack, user, pointed_thing, 60)
	end,
})

minetest.register_tool("farming:hoe_stone", {
	description = "Stone Hoe",
	inventory_image = "farming_tool_stonehoe.png",
	
	on_place = function(itemstack, user, pointed_thing)
		return hoe_on_use(itemstack, user, pointed_thing, 132)
	end,
})

minetest.register_tool("farming:hoe_iron", {
	description = "Iron Hoe",
	inventory_image = "farming_tool_ironhoe.png",
	
	on_place = function(itemstack, user, pointed_thing)
		return hoe_on_use(itemstack, user, pointed_thing, 251)
	end,
})

minetest.register_tool("farming:hoe_gold", {
	description = "Gold Hoe",
	inventory_image = "farming_tool_goldhoe.png",
	
	on_place = function(itemstack, user, pointed_thing)
		return hoe_on_use(itemstack, user, pointed_thing, 33)
	end,
})

minetest.register_tool("farming:hoe_diamond", {
	description = "Diamond Hoe",
	inventory_image = "farming_tool_diamondhoe.png",
	
	on_place = function(itemstack, user, pointed_thing)
		return hoe_on_use(itemstack, user, pointed_thing, 1562)
	end,
})

minetest.register_craft({
	output = "farming:hoe_wood",
	recipe = {
		{"group:wood", "group:wood"},
		{"", "default:stick"},
		{"", "default:stick"},
	}
})

minetest.register_craft({
	output = "farming:hoe_stone",
	recipe = {
		{"group:stone", "group:stone"},
		{"", "default:stick"},
		{"", "default:stick"},
	}
})

minetest.register_craft({
	output = "farming:hoe_iron",
	recipe = {
		{"default:iron_ingot", "default:iron_ingot"},
		{"", "default:stick"},
		{"", "default:stick"},
	}
})

minetest.register_craft({
	output = "farming:hoe_gold",
	recipe = {
		{"default:gold_ingot", "default:gold_ingot"},
		{"", "default:stick"},
		{"", "default:stick"},
	}
})

minetest.register_craft({
	output = "farming:hoe_diamond",
	recipe = {
		{"default:diamond", "default:diamond"},
		{"", "default:stick"},
		{"", "default:stick"},
	}
})

--
-- Override grass for drops
--
minetest.register_node(":default:grass_1", {
	description = "Grass",
	drawtype = "plantlike",
	tiles = {"default_grass_1.png"},
	-- use a bigger inventory image
	inventory_image = "default_grass_3.png",
	wield_image = "default_grass_3.png",
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	drop = {
		max_items = 1,
		items = {
			{items = {'farming:seed_wheat'},rarity = 20},
		}
	},
	groups = {dig_immediate=3,flammable=3,flora=1,attached_node=1},
	sounds = default.node_sound_leaves_defaults({
		dug = {name="default_dig_crumbly", gain=0.4}
	}),
	stack_max = 64,
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
	},
	on_place = function(itemstack, placer, pointed_thing)
		-- place a random grass node
		local stack = ItemStack("default:grass_"..math.random(1,5))
		local ret = minetest.item_place(stack, placer, pointed_thing)
		return ItemStack("default:grass_1 "..itemstack:get_count()-(1-ret:get_count()))
	end,
})

for i=2,5 do
	minetest.register_node(":default:grass_"..i, {
		description = "Grass",
		drawtype = "plantlike",
		tiles = {"default_grass_"..i..".png"},
		inventory_image = "default_grass_"..i..".png",
		wield_image = "default_grass_"..i..".png",
		paramtype = "light",
		walkable = false,
		buildable_to = true,
		is_ground_content = true,
		drop = {
			max_items = 1,
			items = {
				{items = {'farming:seed_wheat'},rarity = 20},
			}
		},
		groups = {dig_immediate=3,flammable=3,flora=1,attached_node=1,not_in_creative_inventory=1},
		sounds = default.node_sound_leaves_defaults({
			dug = {name="default_dig_crumbly", gain=0.4}
		}),
		stack_max = 64,
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
		},
	})
end

minetest.register_node(":default:junglegrass", {
	description = "Jungle Grass",
	drawtype = "plantlike",
	visual_scale = 1.3,
	tiles = {"default_junglegrass.png"},
	inventory_image = "default_junglegrass.png",
	wield_image = "default_junglegrass.png",
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	is_ground_content = true,
	drop = {
		max_items = 1,
		items = {
			{items = {'farming:seed_cotton'},rarity = 20},
		}
	},
	stack_max = 64,
	groups = {dig_immediate=3,flammable=2,flora=1,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
	},
})

--
-- Place seeds
--
local function place_seed(itemstack, placer, pointed_thing, plantname)
	local pt = pointed_thing
	-- check if pointing at a node
	if not pt then
		return
	end
	if pt.type ~= "node" then
		return
	end
	
	local under = minetest.env:get_node(pt.under)
	local above = minetest.env:get_node(pt.above)
	
	-- return if any of the nodes is not registered
	if not minetest.registered_nodes[under.name] then
		return
	end
	if not minetest.registered_nodes[above.name] then
		return
	end
	
	-- check if pointing at the top of the node
	if pt.above.y ~= pt.under.y+1 then
		return
	end
	
	-- check if you can replace the node above the pointed node
	if not minetest.registered_nodes[above.name].buildable_to then
		return
	end
	
	-- check if pointing at soil
	if minetest.get_item_group(under.name, "soil") <= 1 then
		return
	end
	
	-- add the node and remove 1 item from the itemstack
	minetest.env:add_node(pt.above, {name=plantname})
	if not minetest.setting_getbool("creative_mode") then
		itemstack:take_item()
	end
	return itemstack
end

--
-- Wheat
--
minetest.register_craftitem("farming:seed_wheat", {
	description = "Wheat Seed",
	inventory_image = "farming_wheat_seed.png",
	stack_max = 64,
	on_place = function(itemstack, placer, pointed_thing)
		return place_seed(itemstack, placer, pointed_thing, "farming:wheat_1")
	end,
})

minetest.register_craftitem("farming:wheat", {
	description = "Wheat",
	inventory_image = "farming_wheat.png",
	stack_max = 64,
})

minetest.register_craftitem("farming:bread", {
	description = "Bread",
	inventory_image = "farming_bread.png",
	stack_max = 1,
	on_use = minetest.item_eat(5),
})

minetest.register_craft({
	output = "farming:bread",
	recipe = {{"farming:wheat", "farming:wheat", "farming:wheat"}},
})

for i=1,8 do
	local drop = {
		items = {
			{items = {'farming:wheat'},rarity=9-i},
			{items = {'farming:wheat'},rarity=18-i*2},
			{items = {'farming:seed_wheat'},rarity=9-i},
			{items = {'farming:seed_wheat'},rarity=18-i*2},
		}
	}
	minetest.register_node("farming:wheat_"..i, {
		drawtype = "plantlike",
		tiles = {"farming_wheat_"..i..".png"},
		paramtype = "light",
		walkable = false,
		buildable_to = true,
		is_ground_content = true,
		drop = drop,
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
		},
		groups = {dig_immediate=3,flammable=2,plant=1,wheat=i,not_in_creative_inventory=1,attached_node=1},
		sounds = default.node_sound_leaves_defaults(),
	})
end

minetest.register_abm({
	nodenames = {"group:wheat"},
	neighbors = {"group:soil"},
	interval = 90,
	chance = 2,
	action = function(pos, node)
		-- return if already full grown
		if minetest.get_item_group(node.name, "wheat") == 8 then
			return
		end
		
		-- check if on wet soil
		pos.y = pos.y-1
		local n = minetest.env:get_node(pos)
		if minetest.get_item_group(n.name, "soil") < 3 then
			return
		end
		pos.y = pos.y+1
		
		-- check light
		if not minetest.env:get_node_light(pos) then
			return
		end
		if minetest.env:get_node_light(pos) < 13 then
			return
		end
		
		-- grow
		local height = minetest.get_item_group(node.name, "wheat") + 1
		minetest.env:set_node(pos, {name="farming:wheat_"..height})
	end
})

--
-- Cotton
--
minetest.register_craftitem("farming:seed_cotton", {
	description = "Cotton Seed",
	inventory_image = "farming_cotton_seed.png",
	stack_max = 64,
	on_place = function(itemstack, placer, pointed_thing)
		return place_seed(itemstack, placer, pointed_thing, "farming:cotton_1")
	end,
})

minetest.register_craftitem("farming:string", {
	description = "String",
	inventory_image = "farming_string.png",
	stack_max = 64,
})

minetest.register_craft({
	output = "wool:white",
	recipe = {
		{"farming:string", "farming:string"},
		{"farming:string", "farming:string"},
	}
})

for i=1,8 do
	local drop = {
		items = {
			{items = {'farming:string'},rarity=9-i},
			{items = {'farming:string'},rarity=18-i*2},
			{items = {'farming:string'},rarity=27-i*3},
			{items = {'farming:seed_cotton'},rarity=9-i},
			{items = {'farming:seed_cotton'},rarity=18-i*2},
			{items = {'farming:seed_cotton'},rarity=27-i*3},
		}
	}
	minetest.register_node("farming:cotton_"..i, {
		drawtype = "plantlike",
		tiles = {"farming_cotton_"..i..".png"},
		paramtype = "light",
		walkable = false,
		buildable_to = true,
		is_ground_content = true,
		drop = drop,
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
		},
		groups = {dig_immediate=3,flammable=2,plant=1,cotton=i,not_in_creative_inventory=1,attached_node=1},
		sounds = default.node_sound_leaves_defaults(),
	})
end

minetest.register_abm({
	nodenames = {"group:cotton"},
	neighbors = {"group:soil"},
	interval = 80,
	chance = 2,
	action = function(pos, node)
		-- return if already full grown
		if minetest.get_item_group(node.name, "cotton") == 8 then
			return
		end
		
		-- check if on wet soil
		pos.y = pos.y-1
		local n = minetest.env:get_node(pos)
		if minetest.get_item_group(n.name, "soil") < 3 then
			return
		end
		pos.y = pos.y+1
		
		-- check light
		if not minetest.env:get_node_light(pos) then
			return
		end
		if minetest.env:get_node_light(pos) < 13 then
			return
		end
		
		-- grow
		local height = minetest.get_item_group(node.name, "cotton") + 1
		minetest.env:set_node(pos, {name="farming:cotton_"..height})
	end
})
