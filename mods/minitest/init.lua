-- The minitest mod overrides default textures and definitions to make them more minecraft-like.

minetest.register_node(":default:mese", {


})

--Item and Block Conversions

minetest.register_node(":default:stone_with_mese", {
	description = "Diamonds in Stone",
	tiles = {"default_stone.png^minitest_mineral_diamond.png"},
	is_ground_content = true,
	groups = {cracky=1},
	drop = "default:mese_crystal",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node(":default:mese", {
	description = "Diamond Block",
	tiles = {"minitest_diamond_block.png"},
	is_ground_content = true,
	groups = {cracky=1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craftitem(":default:mese_crystal", {
	description = "Diamond",
	inventory_image = "minitest_diamond.png",
})

minetest.register_craftitem(":default:mese_crystal_fragment", {
	description = "Diamond Fragment",
	inventory_image = "minitest_diamond_fragment.png",
})

minetest.register_alias("default:desert_stone", "default:sandstone")
minetest.register_alias("default:desert_sand", "default:sand")
minetest.register_alias("mapgen_desert_sand", "default:sand")
minetest.register_alias("mapgen_desert_stone", "default:sandstone")

--Tool Conversions

minetest.register_tool(":default:pick_mese", {
	description = "Diamond Pickaxe",
	inventory_image = "minitest_diamondpick.png",
	tool_capabilities = {
		full_punch_interval = 0.65,
		max_drop_level=3,
		groupcaps={
			cracky = {times={[1]=2.0, [2]=1.0, [3]=0.5}, uses=20, maxlevel=3},
			fleshy = {times={[2]=0.6, [3]=0.5}, uses=80, maxlevel=1}
		}
	},
})

minetest.register_tool("minitest:axe_diamond", {
	description = "Diamond Axe",
	inventory_image = "minitest_diamondaxe.png",
	tool_capabilities = {
		full_punch_interval = 0.65,
		max_drop_level=3,
		groupcaps={
			snappy = {times={[1]=2.0, [2]=1.0, [3]=0.5}, uses=20, maxlevel=3},
			fleshy = {times={[2]=0.6, [3]=0.5}, uses=80, maxlevel=1}
		}
	},
})

minetest.register_tool("minitest:shovel_diamond", {
	description = "Diamond Shovel",
	inventory_image = "minitest_diamondshovel.png",
	tool_capabilities = {
		full_punch_interval = 0.65,
		max_drop_level=3,
		groupcaps={
			crumbly = {times={[1]=2.0, [2]=1.0, [3]=0.5}, uses=20, maxlevel=3},
			fleshy = {times={[2]=0.6, [3]=0.5}, uses=80, maxlevel=1}
		}
	},
})

minetest.register_tool("minitest:sword_diamond", {
	description = "Diamond Sword",
	inventory_image = "minitest_diamondsword.png",
	tool_capabilities = {
		full_punch_interval = 0.65,
		max_drop_level=3,
		groupcaps={
			fleshy = {times={[2]=0.6, [3]=0.5}, uses=80, maxlevel=1}
		}
	},
})