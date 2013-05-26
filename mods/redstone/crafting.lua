
minetest.register_craft({
	output = "redstone:torch_on",
	recipe = {
		{"redstone:redstone"},
		{"default:stick"},
	},
})

minetest.register_craft({
	output = "redstone:lever_off",
	recipe = {
		{"default:stick"},
		{"default:cobble"},
	},
})
