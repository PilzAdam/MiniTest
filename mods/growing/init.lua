math.randomseed(os.time())

--[[
-- growname describes the node that is to grow
-- surfaces is a table of:
--   the name of the node that said node is allowed to grow on top of
--   the odds it has over 1000 to grow at each callback cycle
--]]

function add_grow_type(growname, surfaces)
	minetest.register_abm({
		nodenames = { growname },
		interval = 60,
		chance = 1,
		action = function(pos, node, active_object_count, active_object_count_wider)
			if minetest.env:get_meta(pos):get_string("new") == "true" then
				minetest.env:get_meta(pos):set_string("new", "false")
				return
			end
			-- First check if there is space above to grow
			p_top = {x = pos.x, y = pos.y + 1, z = pos.z}
			n_top = minetest.env:get_node(p_top)

			if n_top.name == "air" then
				-- Calc current height
				cur_height = 1
				p_next = {x = pos.x, y = pos.y - 1, z = pos.z}
				n_next  = minetest.env:get_node(p_next);
				while true do
					if n_next.name ~= node.name then
						break
					end
					cur_height = cur_height + 1
					p_next = {x = p_next.x, y = p_next.y - 1, z = p_next.z}
					n_next = minetest.env:get_node(p_next)
				end

				for _, s in ipairs(surfaces) do
					if n_next.name == s.name and (math.random(1, 1000) > (1000 - s.odds)) then
						if cur_height < s.max_height then
							minetest.env:add_node(p_top, {name = node.name})
							minetest.env:get_meta(p_top):set_string("new", "true")
						end
					end
				end
			end
		end
    })
end

add_grow_type("default:papyrus", {
{name = "default:dirt", odds = 500, max_height = 4},
{name = "default:dirt_with_grass", odds = 500, max_height = 4},
{name = "default:dirt_with_grass_footsteps", odds = 500, max_height = 4},
{name = "default:sand", odds = 500, max_height = 4}
})

add_grow_type("default:cactus", {
{name = "default:sand", odds = 500, max_height = 4},
{name = "default:desert_sand", odds = 500, max_height = 4}
})
