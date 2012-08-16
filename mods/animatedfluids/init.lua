fluids = {'water', 'lava'}
for fluid=1,#fluids do
	name = fluids[fluid]
	fluid = minetest.registered_nodes['default:'..name..'_flowing']
	tile = {name='default_'..name..'_animated.png', animation={type='vertical_frames', aspect_w=16, aspect_h=16, length=fluid.viscosity}}
	fluid.tiles = {tile}
	tile1 = tile
	tile2 = tile
	tile1.backface_culling=false
	tile2.backface_culling=true
	fluid.special_tiles = {tile1,tile2}
	minetest.register_node(':default:'..name..'_flowing', fluid)
end
