-- mods/default/craftitems.lua

minetest.register_craftitem("default:stick", {
	description = "Stick",
	inventory_image = "default_stick.png",
	stack_max = 64,
})

minetest.register_craftitem("default:paper", {
	description = "Paper",
	inventory_image = "default_paper.png",
	stack_max = 64,
})

minetest.register_craftitem("default:book", {
	description = "Book",
	inventory_image = "default_book.png",
	stack_max = 64,
})

minetest.register_craftitem("default:coal", {
	description = "Coal",
	inventory_image = "default_coal.png",
	groups = {coal=1},
	stack_max = 64,
})

minetest.register_craftitem("default:charcoal", {
	description = "Charcoal",
	inventory_image = "default_coal.png",
	groups = {coal=1},
	stack_max = 64,
})

minetest.register_craftitem("default:diamond", {
	description = "Diamond",
	inventory_image = "default_diamond.png",
	stack_max = 64,
})

minetest.register_craftitem("default:clay_lump", {
	description = "Clay Lump",
	inventory_image = "default_clay_lump.png",
	stack_max = 64,
})

minetest.register_craftitem("default:iron_ingot", {
	description = "iron Ingot",
	inventory_image = "default_iron_ingot.png",
	stack_max = 64,
})

minetest.register_craftitem("default:gold_ingot", {
	description = "Gold Ingot",
	inventory_image = "default_gold_ingot.png",
	stack_max = 64,
})

minetest.register_craftitem("default:clay_brick", {
	description = "Clay Brick",
	inventory_image = "default_clay_brick.png",
	stack_max = 64,
})

minetest.register_craftitem("default:flint", {
	description = "Flint",
	inventory_image = "default_flint.png",
	stack_max = 64,
})

minetest.register_craftitem("default:apple", {
	description = "Apple",
	inventory_image = "default_apple.png",
	stack_max = 64,
	on_use = minetest.item_eat(1),
})

minetest.register_craftitem("default:torch", {
	description = "Torch",
	inventory_image = "default_torches_torch.png",
	stack_max = 64,
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end
		local above = pointed_thing.above
		local under = pointed_thing.under
		local wdir = minetest.dir_to_wallmounted({x = under.x - above.x, y = under.y - above.y, z = under.z - above.z})
		if wdir == 1 then
			local tmpstack = ItemStack("default:torch_floor "..itemstack:get_count())
			tmpstack = minetest.item_place(tmpstack, placer, pointed_thing)
			itemstack = ItemStack(itemstack:get_name().." "..tmpstack:get_count())
			--minetest.env:add_node(above, {name = "default:torch_floor"})
		else
			local tmpstack = ItemStack("default:torch_wall "..itemstack:get_count())
			tmpstack = minetest.item_place(tmpstack, placer, pointed_thing)
			itemstack = ItemStack(itemstack:get_name().." "..tmpstack:get_count())
			--minetest.env:add_node(above, {name = "default:torch_wall", param2 = default.is_wall(wdir)})
		end
		return itemstack
	end,
})
