--[[

TODO

	- Enemy paths


	- Textures
		- Planet
		- Player
		- Enemies


	- Animations

	- Sounds / Music



- Extras

	- Main menu

	- Details
		- Building / plants on planet
		- Other planets, comets, asteroids
		- background texture

	
- Code Cleanup

	- Remove redundant variables / functions
	- Structure code, more logical to read
		- Load - Update - Draw - Keyevents
		- Custom functions
	- Break up over several smaller files

	- Split up smaller methods
	- Move towards oop approach
	]]

function love.conf(t)

	t.window.width = 800
	t.window.height = 600
	t.console = true

end


function love.load()

	love.keyboard.setKeyRepeat(true)


	--Sprites - Move into single spritesheet
	leftframes = {"PL1.png","PL2.png","PL3.png","PL4.png","PL5.png","PL6.png","PL7.png","PL8.png"}
	rightframes = {"PR1.png", "PR2.png", "PR3.png", "PR4.png", "PR5.png", "PR6.png", "PR7.png", "PR8.png"}
	chargingframes = {"PC1.png","PC2.png","PC2.png","PC4.png","PC5.png","PC6.png","PC7.png","PC8.png" }
	jumpingframes = {}
	fallingframes = {"PLD1.png","PLD2.png","PLD3.png","PLD4.png","PLD5.png","PLD6.png","PLD7.png","PLD8.png"}
	landingframes = {"PLAND1.png","PLAND2.png","PLAND3.png","PLAND4.png","PLAND5.png","PLAND6.png","PLAND7.png","PLAND8.png"}



	--Planet initial details
	planet = {x = love.window.getWidth() / 2, 
			  y = love.window.getHeight() / 2 ,
			  radius = 50, health = 5, 
			  circ = 2 * math.pi * 20, 
			  texture = love.graphics.newImage("Planet.png"), 
			  planetshift = false, 
			  shiftframes = 10,
			  incx = 0,
			  incy = 0
			}

	--Player initial details
	player = {posangle = 270, rotangle = 0, 
			  x = planet.x, 
			  y = planet.y - planet.radius, 
			  speed = 0, speedcap = 200,
			  texture = love.graphics.newImage(rightframes[1]), 
			  up = false, 
			  down = false, 
			  incx = 0,
			  incy = 0,
			  jumpmultiplier = 10,
			  dropmultiplier = 10,
			  charging = false,
			  jumping = false,	
			  landed = false,
			  frame = 1,	
			  facing = 0	  
			  }

	calcPlayerPosition()

	planetinertia = 30

	decel = 0

	pdistx = 0
	pdisty = 0
	distance = 0
	--current direction
	left = false
	right = false



	jumpticks = 0



	--jump dist
	maxheight = planet.radius + (planet.radius * 0.5)

	--Enemy shots (?)


	--Enemy attackers
	enemies = {}



	--Limit fps
	min_dt = 1/60
	next_time = love.timer.getTime()

end

--Every frame
function love.update(dt)	

		next_time = next_time + min_dt


		--Determine where player lies in relation to planet
		--Update player segment location as they move around the planet
		findSegment()
		
		player.posangle = player.posangle + (player.speed * dt) --rotate with planet surface


		if(player.up) then
			--move player up (reverse inc vals)	
			player.y = player.y - (dt * player.incy) - (dt* player.incy * player.jumpmultiplier)
			player.x = player.x - (dt * player.incx) - (dt* player.incx * player.jumpmultiplier)

			jumpticks = jumpticks + 1


		elseif(player.down) then
			--move player down (reverse inc vals)
			player.y = player.y + (dt * player.incy) + (dt* player.incy * player.dropmultiplier)
			player.x = player.x + (dt * player.incx) + (dt* player.incx * player.dropmultiplier)


		end

		--Determine player position
		calcPlayerPosition()
		
		--Shift planet
		planet.x = planet.x + (dt * planet.incx)
		planet.y = planet.y + (dt * planet.incy)
		--Player too if he's not jumping off planet
		if (player.up and player.down == false) or (player.up == false and player.down == false) then
				player.x = player.x + (dt * planet.incx)
				player.y = player.y + (dt * planet.incy)
		end
	
		--Handle enemy movement
		updateEnemies(dt)
		

		--Handle projectiles
		hitDetection()


		--Animations / Sound Effects
		sfxanim()

		


	if decel ~= 0 and player.speed ~= 0 then
		player.speed = player.speed + decel
	end



end


--Key handling
function love.keypressed(key, isrepeat)


	if key == "a" and right == false and player.speed > -player.speedcap and player.speed <= 0  then
		player.speed = player.speed - 10
		left = true
		right = false
		if(player.speed < -player.speedcap) then
			player.speed = -player.speedcap
		end
		decel = 0
	end

	if key == "d" and left == false and player.speed < player.speedcap  and player.speed >= 0 then
		left = false
		right = true
		player.speed = player.speed + 10
		if(player.speed > player.speedcap) then
			player.speed = player.speedcap
		end
		decel = 0
	end

	if key == "w" and player.down == false and player.up == false then
		player.charging = true --Play charging animation
	end


	if key == "s" and player.down then

		player.down = true
		player.up = false
	end


end	


function love.keyreleased(key)

	--Jump off
	if(key == "a" and left == true and right == false) then
		decel = 5
		left = false
		player.facing = -1
	end

	if(key == "d" and left == false and right == true) then
		decel = -5
		right = false
		player.facing = 1
	end

	if(key == "w") then

	--If not jumping or falling 
		love.graphics.print("JUMP!", 100, 100)

		--One jump at a time
		if player.down == false and player.up == false then
		
			player.up = true
			player.down = false	
			jump = true

			--end charging animation
			player.charging = false

			--start spring animation
			jumping = true

		end
		
	end

	--Slam back down
	if(key == "s" and player.up == true) then
		--Set down to false --
		player.down = true
		player.up = false
	end

end




function love.draw()


	love.graphics.print(love.timer.getFPS(), 100,100)


	--Draw enemies
	drawEnemies()


	--Draw planet
	love.graphics.draw(planet.texture, planet.x - (planet.radius), planet.y - (planet.radius))

	--Draw player last due to rotations
	calcPlayerRotation()
	love.graphics.draw(player.texture, player.x, player.y)
	--love.graphics.rectangle("fill", player.x, player.y, player.height, player.width)


   local cur_time = love.timer.getTime() 
   if next_time <= cur_time then
      next_time = cur_time
      return
   end
   love.timer.sleep(next_time - cur_time)


end


function calcPlayerPosition()


	--Wrap around
	if(player.posangle < 0) then
		player.posangle = 360 + player.posangle
	end

	if(player.posangle > 360) then
		player.posangle = 0 + (player.posangle % 360)
	end




	--get player distance from planet
	pdistx = math.abs(player.x - (planet.x))
	pdisty = math.abs(player.y - (planet.y))
	distance = math.sqrt( (pdistx * pdistx) + (pdisty * pdisty))


	--Check if player is inside planet, move outwards if so
	if(distance < planet.radius) then
		distance = planet.radius
	end

	
	--Rotate about origin around a circle with radius of distance - total player distance from planet centre
	player.x =  (planet.x) + (distance * math.cos(player.posangle * 0.01745))
	player.y =  (planet.y) + (distance * math.sin(player.posangle * 0.01745))


	--This is the position of the top left point of the rectangle
	--Rotate coordinates as player moves around the planet


end

function calcPlayerRotation()
	love.graphics.translate(player.x, player.y) -- translate to origin
	love.graphics.rotate(((player.posangle - 90) * 0.01745)) -- rotate
	love.graphics.translate(-player.x, -player.y) -- translate back
end



function updateEnemies(dt)

	--How many enemies are currently in the game - use a timer system instead
	if(#enemies < 4) then	


	--Generate another?
	--Init at center and translate away by random amount
	
		plusmin = math.random(0,1)

		if(plusmin == 0) then
			enemyx = planet.x + planet.radius + planet.radius
		else
			enemyx = planet.x - planet.radius + planet.radius
		end

		plusmin = math.random(0,1)

		if(plusmin == 0) then
			enemyy = planet.y + planet.radius + planet.radius
		else
			enemyy = planet.y - planet.radius + planet.radius
		end

		plusmin = math.random(0,2)
		
		if(plusmin == 0) then
			enemyincy = -25
		elseif(plusmin == 1) then
			enemyincy = 0
		else
			enemyincy = 25
		end
		
		plusmin = math.random(0,2)
		
		if(plusmin == 0) then
			enemyincx = -25
		elseif(plusmin == 1) then
			enemyincx = 0
		else
			enemyincx = 25
		end
		
		if(enemyincx == 0 and enemyincy == 0) then
			enemyincx = 25
		end

		table.insert(enemies, {x = enemyx, y = enemyy, incx = enemyincx, incy = enemyincy, speed = 3, cleanup = false})
		
	end
	--Update positions
	for i, enemy in pairs(enemies) do


		enemy.x = enemy.x + (enemy.incx * dt)
		enemy.y = enemy.y + (enemy.incy * dt)		


	end


end

function drawEnemies()

for i, enemy in pairs(enemies) do

		love.graphics.print(enemy.x, 50, 10)
		love.graphics.print(enemy.y, 50, 20)
		love.graphics.circle("fill", enemy.x, enemy.y, 3, 5)

		--If clean up - draw explode / effect instead
		if(enemy.cleanup) then
			love.graphics.circle("fill", enemy.x, enemy.y, 3, 5)
			table.remove(enemies, i)
		end


	end

end

function findSegment()


		--Find direction to move off in
			if(player.posangle >= 338 or player.posangle < 23) then -- 0 - wrapping around so use OR
				player.incx = -planetinertia
				player.incy = 0
			elseif(player.posangle >= 23 and player.posangle < 68) then -- 45
				player.incx = -planetinertia
				player.incy = -planetinertia	
			elseif(player.posangle >= 68 and player.posangle < 113) then -- 90
				player.incx = 0		
				player.incy = -planetinertia
			elseif(player.posangle >= 113 and player.posangle < 158) then -- 135
				player.incy =-planetinertia
				player.incx = planetinertia
			elseif(player.posangle >= 158 and player.posangle < 203) then --180
				player.incy = 0
				player.incx = planetinertia
			elseif(player.posangle >= 203 and player.posangle < 248) then --225
				player.incx = planetinertia
				player.incy = planetinertia
			elseif(player.posangle >= 248 and player.posangle < 293) then --270
				player.incx = 0
				player.incy = planetinertia	
			elseif(player.posangle >= 293 and player.posangle < 338) then --315
				player.incx =  -planetinertia
				player.incy = planetinertia
			end

end




function hitDetection()


	--If jump apex reached - start to fall
	if(distance >= maxheight) then

		player. up = false
		player.down = true	

	end

	--Start of jump - give some tolerance to clear planet



	--land player back on planet
	if( (player.down or (player.up and jumpticks > 1)) and (distance) <= planet.radius) then
		
		--If player was falling push back on planet, else catch player
		if(player.down) then
			planet.incx = planet.incx + player.incx
			planet.incy = planet.incy + player.incy
		end
		
		--Complete jump
		player.down = false
		player.up = false
		player.landed = true
		player.frames = 1
		jumpticks = 0


		
	end



	--bounce planet off edge of screen

	if(planet.x - planet.radius < 0 or planet.x  + planet.radius> love.window.getWidth()) then

		planet.incx = - planet.incx

	end


	if(planet.y - planet.radius < 0 or planet.y + planet.radius> love.window.getHeight()) then

		planet.incy = - planet.incy
	end
	

	-- Get the widths of the enemies
	for i, enemy in pairs(enemies) do


		plusmin = math.random(0,2)
		
		if(plusmin == 0) then
			enemyincy = -25
		elseif(plusmin == 1) then
			enemyincy = 0
		else
			enemyincy = 25
		end
		
		plusmin = math.random(0,2)
		
		if(plusmin == 0) then
			enemyincx = -25
		elseif(plusmin == 1) then
			enemyincx = 0
		else
			enemyincx = 25
		end

		if(enemyincx == 0 and enemyincy == 0) then
			enemyincx = 25
		end


		if(enemy.x < 0 or enemy.x > love.window.getWidth()) then

			enemy.incx = enemyincx
		end


		if(enemy.y  < 0 or enemy.y > love.window.getHeight()) then

			enemy.incy = enemyincy
		end
	end
end


function sfxanim() 

	--Take in dt
	--Update every second rather than every frame


			--Default position

			--Check facing direction
		if(player.facing == -1) then
			player.texture = love.graphics.newImage(leftframes[1])
		else
			player.texture = love.graphics.newImage(rightframes[1])
		end
	



	if(left and player.up == false and player.down == false) then

					
		 if player.frame >= #leftframes - 1 then
			player.frame = 1
		end
			

		--Repeated animation	
		player.texture = love.graphics.newImage(leftframes[player.frame])
		

		player.frame = player.frame + 1
		

		

	end

	if(right and player.up == false and player.down == false) then

					
	    if player.frame >= #rightframes - 1 then
			player.frame = 1
		end

		--Repeated animation	
		player.texture = love.graphics.newImage(rightframes[player.frame])

		player.frame = player.frame + 1


		


	end

	if(player.charging) then
		
		if player.frame >= #chargingframes - 1 then
			player.frame = 1
		end


		--Repeated animation	
		player.texture = love.graphics.newImage(chargingframes[player.frame])


		player.frame = player.frame + 1
		


	end

	if(player.jumping) then


		--[[
			
		player.texture = jumpingframes[i]

	    --When landing animation ends, set landing to false to stop playing
		if player.frame == #jumpingframes then
			player.jumping = false
			player.frame = 1
		else
			player.frame = player.frame + 1
		end

		]]

		--When spring up animation ends, set jumping to false to stop playing


	end

	if(player.down) then

		

		if player.frame == #fallingframes - 1 then
			player.frame = 1
		end
			
		player.texture = love.graphics.newImage(fallingframes[player.frame])


		player.frame = player.frame + 1
		

		

	end


	if(player.landed) then
				


		player.texture = love.graphics.newImage(landingframes[player.frame])



	    --When landing animation ends, set landing to false to stop playing
		if player.frame == #landingframes then
			player.landed = false
			player.down = false --Jump over
			player.frame = 1
		else
			player.frame = player.frame + 1
		end
		
	end



end

