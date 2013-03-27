minetest.register_node(":default:gravel", {
	description = "Gravel",
	tiles = {"default_gravel.png"},
	is_ground_content = true,
	groups = {crumbly=2, falling_node=1},
	drop = {
		max_items = 1,
		items = {
			{
				items = {'flint:flintstone'},
				rarity = 10,
			},
			{
				items = {'default:gravel'},
			}
		}
	},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.45},
	}),
})

minetest.register_craftitem("flint:flintstone", {
	description = "Flintstone",
	inventory_image = "flint_flintstone.png",
})


minetest.register_craft({
	output = 'flint:lighter',
	recipe = {
		{'default:steel_ingot', ''},
		{'', 'flint:flintstone'},
	}
})

local function get_nodedef_field(nodename, fieldname)
    if not minetest.registered_nodes[nodename] then
        return nil
    end
    return minetest.registered_nodes[nodename][fieldname]
end

local function set_fire(pointed_thing)
		local n = minetest.env:get_node(pointed_thing.above)
		if n.name ~= ""  and n.name == "air" then
			minetest.env:set_node(pointed_thing.above, {name="fire:basic_flame"})
		end
end

minetest.register_tool("flint:lighter", {
	description = "Lighter",
	inventory_image = "flint_lighter.png",
	liquids_pointable = false,
	stack_max = 1,
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=0,
		groupcaps={
			flamable = {uses=65, maxlevel=1},
		}
	},
	--groups = {hot=3, igniter=1, not_in_creative_inventory=1},
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			set_fire(pointed_thing)
			itemstack:add_wear(65535/65)
			return itemstack
		end
	end,

})