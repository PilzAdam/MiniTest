-- Flint and Steel Functions
function get_nodedef_field(nodename, fieldname)
    if not minetest.registered_nodes[nodename] then
        return nil
    end
    return minetest.registered_nodes[nodename][fieldname]
end

function set_fire(pointed_thing)
		local n = minetest.env:get_node(pointed_thing.above)
		if n.name ~= ""  and n.name == "air" then
			minetest.env:set_node(pointed_thing.above, {name="fire:basic_flame"})
		end
end