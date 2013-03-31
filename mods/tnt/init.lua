local shared_autoban = minetest.get_modpath("shared_autoban")

experimental = {}

minetest.register_entity("tnt:smoke", {
    physical = true,
	visual_size = {x=0.05, y=0.05},
	collisionbox = {-0.05,-0.05,-0.05,0.05,0.05,0.05},
    visual = "sprite",
    textures = {"tnt_smoke.png"},
    shrink = false,
    on_step = function(self, dtime)
        self.object:setvelocity({x=0, y=0.5, z=0})
        self.object:setacceleration({x=0, y=9.8, z = 0})
        self.timer = self.timer + dtime
        self.visual_size.x = self.visual_size.x + 0.025
        self.visual_size.y = self.visual_size.x
        if self.timer > 1 then
           self.object:remove()
        end
    end,
    timer = 0,
})


minetest.register_entity("tnt:smoke2", {
    physical = true,
	visual_size = {x=1, y=1},
	collisionbox = {-0.05,-0.05,-0.05,0.05,0.05,0.05},
    visual = "sprite",
    textures = {"tnt_smokew.png"},
    ft = true,
    on_step = function(self, dtime)
        self.timer = self.timer + dtime
        if self.timer > 1.5 and self.ft==true then
           self.object:setvelocity({x=0, y=0, z = 0})	   
           self.object:setacceleration({x=0, y=2, z = 0})	   
           self.ft = false
        end
           if self.timer > 3 then
              self.object:remove()
           end		
    end,
    timer = 0,
})

minetest.register_entity("tnt:explosion", {
    physical = true,
	visual_size = {x=1, y=1},
	collisionbox = {-0.05,-0.05,-0.05,0.05,0.05,0.05},
    visual = "sprite",
	anim_step =0,
	timer = 0,
	animation_frames = 8,
    on_step = function(self, dtime)
        self.timer = self.timer + dtime
        if self.timer > 2 then
           self.object:remove()
        end		
		   local pos = self.object:getpos()
		   self.object:setpos({x=pos.x+math.random(-1,1),y=pos.y+math.random(-1,1),z=pos.z+math.random(-1,1)})
           self.visual_size.x = math.random(2)
           self.visual_size.y = self.visual_size.x	
		self.anim_step = (self.anim_step+1)%self.animation_frames
		self.object:setacceleration({x=math.random(-2,2), y=math.random(-2,2), z=math.random(-2,2)})
        self.object:set_properties({
		textures = {
	        "tnt_explosion.png^[verticalframe:"..self.animation_frames..":"..self.anim_step.."]"            
        },
    })		
    end,
    
})


--
-- TNT (not functional)
--

minetest.register_craft({
	output = "tnt:tnt",
	recipe = {
		{'minitest:sand','minitest:sulfer','minitest:sand'},
		{'minitest:sulfer','minitest:sand','minitest:sulfer'},
		{'minitest:sand','minitest:sulfer','minitest:sand'}
	}
})

minetest.register_node("tnt:tnt", {
	tile_images = {"tnt_tnt_top.png", "tnt_tnt_bottom.png",
			"tnt_tnt_side.png", "tnt_tnt_side.png",
			"tnt_tnt_side.png", "tnt_tnt_side.png"},
	inventory_image = minetest.inventorycube("tnt_tnt_top.png",
			"tnt_tnt_side.png", "tnt_tnt_side.png"),
	drop = 'tnt:tnt', -- Get nothing
	material = {
		diggability = "not",
	},
	after_place_node = function(pos, placer, itemstack)
	   meta = minetest.env:get_meta(pos) 
	   if meta then
	      meta:set_string("owner",placer:get_player_name())
	   end   
	end,
})

minetest.register_on_punchnode(function(p, node, puncher)
local ttt = minetest.env:get_meta(p):get_string("owner")
if ttt~="" then minetest.debug("At " .. minetest.pos_to_string(p).." was punched "..ttt) end
	if (shared_autoban and puncher and puncher~="mob" and check_ownership_once(p,puncher:get_player_name()))
	or (not shared_autoban)
	or puncher == "mob"
      then
	if node.name == "tnt:tnt" then
	    local meta = minetest.env:get_meta(p)
	    if meta then
           local ow = meta:get_string("owner")	       		   
           minetest.env:remove_node(p)
           local ent = minetest.env:add_entity(p, "tnt:tnt"):get_luaentity()
           ent.visual_size.x = 1
           ent.visual_size.y = 1
           ent.owner = ow
           minetest.debug("owner of tnt is " .. ow)
           nodeupdate(p)
		end
	end
    end
	
end)

local TNT = {
	-- Static definition
	physical = true, -- Collides with things
	-- weight = 5,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual_size = {x=1, y=1},
	visual = "cube",
	textures = {"tnt_tnt_top_burning.png", "tnt_tnt_bottom.png",
			"tnt_tnt_side.png", "tnt_tnt_side.png",
			"tnt_tnt_side.png", "tnt_tnt_side.png"},
	-- Initial value for our timer
	timer = 0,
	-- Number of punches required to defuse
	health = 1,
	blinktimer = 0,
    doomtimer = 0,
    parttimer = 0,
	blinkstatus = true,
	placer = nil,
	owner = "",
}

-- Called when a TNT object is created
function TNT:on_activate(staticdata)
	self.object:setvelocity({x=0, y=4, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^[brighten")
	self.object:set_armor_groups({immortal=1})
end


local destroy = function(pos)
	local nodename = minetest.env:get_node(pos).name
	if nodename ~= "air" then
		minetest.env:remove_node(pos)
		nodeupdate(pos)
		if minetest.registered_nodes[nodename].groups.flammable ~= nil then
			minetest.env:set_node(pos, {name="fire:flame_normal"})
			return
		end
		local drop = minetest.get_node_drops(nodename, "")
		for _,item in ipairs(drop) do
			if type(item) == "string" then
				local obj = minetest.env:add_item(pos, item)
				if obj == nil then
					return
				end
				obj:get_luaentity().collect = true
				obj:setacceleration({x=0, y=-10, z=0})
				obj:setvelocity({x=math.random(0,6)-3, y=10, z=math.random(0,6)-3})
			else
				for i=1,item:get_count() do
					local obj = minetest.env:add_item(pos, item:get_name())
					if obj == nil then
						return
					end
					obj:get_luaentity().collect = true
					obj:setacceleration({x=0, y=-10, z=0})
					obj:setvelocity({x=math.random(0,6)-3, y=10, z=math.random(0,6)-3})
				end
			end
		end
	end
end


boom = function(pos, puncher)
local po = {x= pos.x, y=pos.y, z=pos.z}
minetest.debug("boom ".. minetest.pos_to_string(pos))
minetest.debug("boom2 ".. puncher)
		minetest.sound_play("tnt_explode", {pos=pos, gain=1.5, max_hear_distance=2*64})
		local objects = minetest.env:get_objects_inside_radius(pos, 7)
		for _,obj in ipairs(objects) do
			if obj:is_player() or (obj:get_luaentity() 
			                       and obj:get_luaentity().name ~= "__builtin:item" 
			                       and obj:get_luaentity().name ~= "tnt:tnt" 
			                       and obj:get_luaentity().name ~= "tnt:smoke"
			                       and obj:get_luaentity().name ~= "tnt:smoke2" 
			                       and obj:get_luaentity().name ~= "tnt:explosion") 
			   then
				local obj_p = obj:getpos()
				local vec = {x=obj_p.x-pos.x, y=obj_p.y-pos.y, z=obj_p.z-pos.z}
				local dist = (vec.x^2+vec.y^2+vec.z^2)^0.5
				local damage = (80*0.5^dist)*2
				obj:punch(obj, 1.0, {
					full_punch_interval=1.0,
					groupcaps={
						fleshy={times={[1]=1/damage, [2]=1/damage, [3]=1/damage}},
						snappy={times={[1]=1/damage, [2]=1/damage, [3]=1/damage}},
					}
				}, nil)
			end
		end

		
		for dx=-2,2 do		
			for dz=-2,2 do
				for dy=2,-2,-1 do
					local p = {}
					p.x = po.x + dx
					p.y = po.y + dy
					p.z = po.z + dz
					
					
					local node = minetest.env:get_node(p)	
                    owne = minetest.env:get_meta(p):get_string("owner")
					pl = minetest.env:get_player_by_name(puncher)				
					if node.name == "tnt:tnt" and pl 
					then 
	                   minetest.node_punch(p, node, pl)                       					
					end
					if node.name ~= "fire:flame_normal" 
					    and not string.find(node.name, "default:water_") 
					    and not string.find(node.name, "default:lava_") then
						
					
						if math.abs(dx)<2 and math.abs(dy)<2 and math.abs(dz)<2 then -- check for ownership
							if shared_autoban ~= nil
							    then 
							        if check_ownership_once(p,puncher) 
							           then
							           	    destroy(p)							          
							           end
							    else
							    destroy(p)
							end
						else
							if math.random(1,5) <= 4 then -- check for ownership
							if shared_autoban ~= nil
							    then 
							        if check_ownership_once(p,puncher) 
							           then
							           	    destroy(p)							          
							           end
							    else							    
							    destroy(p)
							end
							end
						end
					end
					
					pos.x = pos.x-dx
					pos.y = pos.y-dy
					pos.z = pos.z-dz
				end
			end
		end

end

-- Called periodically
function TNT:on_step(dtime)
	--print("TNT:on_step()")
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
    self.doomtimer = self.doomtimer + dtime
	if self.blinktimer > 0.5 then
		self.blinktimer = self.blinktimer - 0.5
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^[brighten")
		end
		self.blinkstatus = not self.blinkstatus

	end	
	if self.doomtimer > 3.5 then	
       local i = self.visual_size.x + 0.05	   
  			prop = {
				visual_size = {x=i, y=i},
			}
			self.object:set_properties(prop)        	
       
	end

	if self.doomtimer > 4 then	
	   boom(self.object:getpos(),self.owner)
	   self.object:remove()	   
		local pos = self.object:getpos()
		for i=1,10 do
					local __x=math.random(-1,1)
					local __y=math.random(-1,1)
					local __z=math.random(-1,1)					
		    minetest.env:add_entity({x=pos.x+__x, y=pos.y+__y, z=pos.z+__z},"tnt:explosion")		    
		end
		
		for _x=-1,1,0.4 do
            for _y=-1,1,0.4 do
                for _z=-1,1,0.4 do
				    minetest.env:add_entity({x=pos.x+_x*0.1, y=pos.y+_y*0.1, z=pos.z+_z*0.1},"tnt:smoke2"):setacceleration({x=_x*3, y=_y*3, z=_z*3})
				end
			end
		end       
	end
	self.parttimer = self.parttimer + dtime
    if self.parttimer > 0.25 then
	   self.parttimer = self.parttimer - 0.25
       local pos = self.object:getpos()        
	   local ent = minetest.env:add_entity({x=pos.x, y=pos.y+0.5, z=pos.z}, "tnt:smoke")		
	   ent:get_luaentity().visual_size.x = 0.05
	   ent:get_luaentity().visual_size.y = 0.05
	end
end


function TNT:on_punch(hitter)
	print("TNT:on_punch()")
	self.health = self.health - 1
	if self.health <= 0 then
		self.object:remove()
		--hitter:get_inventory():add_item("main", "experimental:tnt")
		--hitter:set_hp(hitter:get_hp() - 1)
	end

	
end

minetest.register_entity("tnt:tnt", TNT)
minetest.register_alias("TNT", "tnt:tnt")
