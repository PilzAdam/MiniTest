-- Minetest 0.4 mod: stairs
-- See README.txt for licensing and other information.

stairs = {}

-- Node will be called stairs:stair_<subname>
function stairs.register_stair(subname, recipeitem, groups, images, description, sounds)
	minetest.register_node(":stairs:stair_" .. subname, {
		description = description,
		drawtype = "nodebox",
		tiles = images,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = true,
		groups = groups,
		sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
			},
		},
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return itemstack
			end
			
			local p0 = pointed_thing.under
			local p1 = pointed_thing.above
			if p0.y-1 == p1.y then
				local fakestack = ItemStack("stairs:stair_" .. subname.."upside_down")
				local ret = minetest.item_place(fakestack, placer, pointed_thing)
				if ret:is_empty() then
					itemstack:take_item()
					return itemstack
				end
			end
			
			-- Otherwise place regularly
			return minetest.item_place(itemstack, placer, pointed_thing)
		end,
	})
	
	minetest.register_node(":stairs:stair_" .. subname.."upside_down", {
		drop = "stairs:stair_" .. subname,
		drawtype = "nodebox",
		tiles = images,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = true,
		groups = groups,
		sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, 0, -0.5, 0.5, 0.5, 0.5},
				{-0.5, -0.5, 0, 0.5, 0, 0.5},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, 0, -0.5, 0.5, 0.5, 0.5},
				{-0.5, -0.5, 0, 0.5, 0, 0.5},
			},
		},
	})

	minetest.register_craft({
		output = 'stairs:stair_' .. subname .. ' 4',
		recipe = {
			{recipeitem, "", ""},
			{recipeitem, recipeitem, ""},
			{recipeitem, recipeitem, recipeitem},
		},
	})

	-- Flipped recipe for the silly minecrafters
	minetest.register_craft({
		output = 'stairs:stair_' .. subname .. ' 4',
		recipe = {
			{"", "", recipeitem},
			{"", recipeitem, recipeitem},
			{recipeitem, recipeitem, recipeitem},
		},
	})
end

-- Node will be called stairs:slab_<subname>
function stairs.register_slab(subname, recipeitem, groups, images, description, sounds)
	minetest.register_node(":stairs:slab_" .. subname, {
		description = description,
		drawtype = "nodebox",
		tiles = images,
		paramtype = "light",
		is_ground_content = true,
		groups = groups,
		sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
		},
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
		},
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return itemstack
			end

			-- If it's being placed on an another similar one, replace it with
			-- a full block
			local slabpos = nil
			local slabnode = nil
			local p0 = pointed_thing.under
			local p1 = pointed_thing.above
			local n0 = minetest.env:get_node(p0)
			if n0.name == "stairs:slab_" .. subname and
					p0.y+1 == p1.y then
				slabpos = p0
				slabnode = n0
			end
			if slabpos then
				-- Remove the slab at slabpos
				minetest.env:remove_node(slabpos)
				-- Make a fake stack of a single item and try to place it
				local fakestack = ItemStack(recipeitem)
				pointed_thing.above = slabpos
				fakestack = minetest.item_place(fakestack, placer, pointed_thing)
				-- If the item was taken from the fake stack, decrement original
				if not fakestack or fakestack:is_empty() then
					itemstack:take_item(1)
				-- Else put old node back
				else
					minetest.env:set_node(slabpos, slabnode)
				end
				return itemstack
			end
			
			-- Upside down slabs
			if p0.y-1 == p1.y then
				-- Turn into full block if pointing at a existing slab
				if n0.name == "stairs:slab_" .. subname.."upside_down" then
					-- Remove the slab at the position of the slab
					minetest.env:remove_node(p0)
					-- Make a fake stack of a single item and try to place it
					local fakestack = ItemStack(recipeitem)
					pointed_thing.above = p0
					fakestack = minetest.item_place(fakestack, placer, pointed_thing)
					-- If the item was taken from the fake stack, decrement original
					if not fakestack or fakestack:is_empty() then
						itemstack:take_item(1)
					-- Else put old node back
					else
						minetest.env:set_node(p0, n0)
					end
					return itemstack
				end
				
				-- Place upside down slab
				local fakestack = ItemStack("stairs:slab_" .. subname.."upside_down")
				local ret = minetest.item_place(fakestack, placer, pointed_thing)
				if ret:is_empty() then
					itemstack:take_item()
					return itemstack
				end
			end
			
			-- If pointing at the side of a upside down slab
			if n0.name == "stairs:slab_" .. subname.."upside_down" and
					p0.y+1 ~= p1.y then
				-- Place upside down slab
				local fakestack = ItemStack("stairs:slab_" .. subname.."upside_down")
				local ret = minetest.item_place(fakestack, placer, pointed_thing)
				if ret:is_empty() then
					itemstack:take_item()
					return itemstack
				end
			end
			
			-- Otherwise place regularly
			return minetest.item_place(itemstack, placer, pointed_thing)
		end,
	})
	
	minetest.register_node(":stairs:slab_" .. subname.."upside_down", {
		drop = "stairs:slab_"..subname,
		drawtype = "nodebox",
		tiles = images,
		paramtype = "light",
		is_ground_content = true,
		groups = groups,
		sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {-0.5, 0, -0.5, 0.5, 0.5, 0.5},
		},
		selection_box = {
			type = "fixed",
			fixed = {-0.5, 0, -0.5, 0.5, 0.5, 0.5},
		},
	})

	minetest.register_craft({
		output = 'stairs:slab_' .. subname .. ' 6',
		recipe = {
			{recipeitem, recipeitem, recipeitem},
		},
	})
end

-- Nodes will be called stairs:{stair,slab}_<subname>
function stairs.register_stair_and_slab(subname, recipeitem, groups, images, desc_stair, desc_slab, sounds)
	stairs.register_stair(subname, recipeitem, groups, images, desc_stair, sounds)
	stairs.register_slab(subname, recipeitem, groups, images, desc_slab, sounds)
end

stairs.register_stair_and_slab("wood", "minitest:wood",
	{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3},
	{"default_wood.png"},
	"Wooden Stair",
	"Wooden Slab"
)

stairs.register_stair_and_slab("stone", "minitest:stone",
	{cracky=3},
	{"default_stone.png"},
	"Stone Stair",
	"Stone Slab"
)

stairs.register_stair_and_slab("cobble", "minitest:cobble",
	{cracky=3},
	{"default_cobble.png"},
	"Cobble Stair",
	"Cobble Slab"
)

stairs.register_stair_and_slab("brick", "minitest:brick",
	{cracky=3},
	{"default_brick.png"},
	"Brick Stair",
	"Brick Slab"
)

stairs.register_stair_and_slab("sandstone", "minitest:sandstone",
	{crumbly=2,cracky=2},
	{"default_sandstone.png"},
	"Sandstone Stair",
	"Sandstone Slab"
)

stairs.register_stair_and_slab("junglewood", "minitest:junglewood",
	{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3},
	{"default_junglewood.png"},
	"Junglewood Stair",
	"Junglewood Slab"
)

stairs.register_stair_and_slab("stonebrick", "minitest:stonebrick",
	{cracky=3},
	{"default_stone_brick.png"},
	"Stone Brick Stair",
	"Stone Brick Slab"
)
