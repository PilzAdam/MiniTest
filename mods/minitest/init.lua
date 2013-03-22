-- The minitest mod overrides default textures and definitions to make them more minecraft-like.

minetest.register_node(":default:mese", {


})

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