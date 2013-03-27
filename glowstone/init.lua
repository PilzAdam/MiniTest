minetest.register_node("glowstone:block", {
	description = "Glowstone",
	tiles = {"glowstone_block.png"},
	is_ground_content = true,
	groups = {cracky=3,oddly_breakable_by_hand=2},
	drop = 'glowstone:block',
	sounds = default.node_sound_glass_defaults(),
	light_source = LIGHT_MAX-0.5,
})

minetest.register_craft({
	output = 'glowstone:block 4',
	recipe = {
		{'group:stone', 'group:stone', 'group:stone'},
		{'group:stone', 'default:mese', 'group:stone'},
		{'group:stone', 'group:stone', 'group:stone'},
	}
})
