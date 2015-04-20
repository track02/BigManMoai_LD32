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




function love.load()

	love.keyboard.setKeyRepeat(true)


	--Sprites - Move into single spritesheet
	leftframes = {"PL1.png","PL2.png","PL3.png","PL4.png","PL5.png","PL6.png","PL7.png","PL8.png"}
	rightframes = {"PR1.png", "PR2.png", "PR3.png", "PR4.png", "PR5.png", "PR6.png", "PR7.png", "PR8.png"}
	chargingframes = {"PC1.png","PC2.png","PC2.png","PC4.png","PC5.png","PC6.png","PC7.png","PC8.png" }
	fallingframes = {"PLD1.png","PLD2.png","PLD3.png","PLD4.png","PLD5.png","PLD6.png","PLD7.png","PLD8.png"}
	landingframes = {"PLAND1.png","PLAND2.png","PLAND3.png","PLAND4.png","PLAND5.png","PLAND6.png","PLAND7.png","PLAND8.png"}

	enemyframes = {"EnemyMin.png", "EnemyMed.png", "EnemyBig.png"}



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
	player = {posangle = 270, centangle = 265, --Estimated angle, should calculate
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
			  facing = 0,	  
			  centx = 0,
			  centy = 0,
			  height = 0,
			  width = 0
			  }

	player.height = (player.texture):getHeight()
	player.width = (player.texture):getWidth()

	player.centx = player.x - (player.width / 2)
	player.centy = player.y - (player.height / 2)


	jumpticks = 0

	planetinertia = 30

	decel = 0

	pdistx = 0
	pdisty = 0
	distance = 0

	cdistx = 0
	cdisty = 0
	cdistance = 0

	--current direction
	left = false
	right = false


	ycdist =  math.abs(player.centy - (planet.y))
	xcdist = math.abs(player.centx - (planet.x))
	centerplayerdistance = 	math.sqrt( (ycdist * ycdist) + (xcdist * xcdist))


	started = false



	--jump dist
	maxheight = planet.radius + (planet.radius * 0.5)

	--Enemy shots (?)


	--Enemy attackers
	enemies = {}

	calcPlayerPosition()


	background = love.graphics.newImage("Menu.png")


	min_dt = 1/60
	next_time = love.timer.getTime()

end

--Every frame
function love.update(dt)	


		if(started == true) then

			--Handle projectiles
			hitDetection()

			next_time = next_time + min_dt


			--Determine where player lies in relation to planet
			--Update player segment location as they move around the planet
			findSegment()
			
			player.posangle = player.posangle + (player.speed * dt) --rotate with planet surface
			player.centangle = player.centangle + (player.speed * dt) --rotate with planet surface

			if(player.up) then
				--move player up (reverse inc vals)	
				player.y = player.y - (dt * player.incy) - (dt* player.incy * player.jumpmultiplier)
				player.x = player.x - (dt * player.incx) - (dt* player.incx * player.jumpmultiplier)
				player.centx = player.centx - (dt * player.incx) - (dt* player.incx * player.jumpmultiplier)
				player.centy = player.centy - (dt * player.incy) - (dt* player.incy * player.jumpmultiplier)


				jumpticks = jumpticks + 1


			elseif(player.down) then
				--move player down (reverse inc vals)
				player.y = player.y + (dt * player.incy) + (dt* player.incy * player.dropmultiplier)
				player.x = player.x + (dt * player.incx) + (dt* player.incx * player.dropmultiplier)
				player.centx = player.centx + (dt * player.incx) + (dt* player.incx * player.dropmultiplier)
				player.centy = player.centy + (dt * player.incy) + (dt* player.incy * player.dropmultiplier)

			end

			--Shift planet
			planet.x = planet.x + (dt * planet.incx)
			planet.y = planet.y + (dt * planet.incy)
			--Player too if he's not jumping off planet
			if (player.up and player.down == false) or (player.up == false and player.down == false) then
					player.x = player.x + (dt * planet.incx)
					player.y = player.y + (dt * planet.incy)
					player.centx = player.centx + (dt * planet.incx)
					player.centy = player.centy + (dt * planet.incy)

			end
		


			--Determine player position
			calcPlayerPosition()
			

			--Handle enemy movement
			updateEnemies(dt)
			


			--Animations / Sound Effects
			sfxanim()

			


		if decel ~= 0 and player.speed ~= 0 then
			player.speed = player.speed + decel
		end

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

	if(key == "z") then
		started = true
		background = love.graphics.newImage("Background.png")
	end


	--Slam back down
	if(key == "s" and player.up == true) then
		--Set down to false --
		player.down = true
		player.up = false
	end


end




function love.draw()


	love.graphics.draw(background, 0,0)

	if(started) then


		--Draw enemies
		drawEnemies()


		--Draw planet
		love.graphics.draw(planet.texture, planet.x - (planet.radius), planet.y - (planet.radius))


		love.graphics.circle("fill", player.centx, player.centy, 3, 5)



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


	--get center player distance from planet
	cpdistx = math.abs(player.centx - (planet.x))
	cpdisty = math.abs(player.centy - (planet.y))
	cdistance = math.sqrt( (cpdistx * cpdistx) + (cpdisty * cpdisty))

	--Check if player is inside planet, move outwards if so
	if(distance < planet.radius) then
		distance = planet.radius
	end

	if(cdistance < centerplayerdistance) then

		cdistance = centerplayerdistance	
	end

	
	--Rotate about origin around a circle with radius of distance - total player distance from planet centre
	player.x =  (planet.x) + (distance * math.cos(player.posangle * 0.01745))
	player.y =  (planet.y) + (distance * math.sin(player.posangle * 0.01745))
	player.centx = (planet.x) + (cdistance * math.cos(player.centangle * 0.01745))
	player.centy = (planet.y) + (cdistance * math.sin(player.centangle * 0.01745))
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
	
		insert = true

		--Generate potential coordinates, test, spawn enemy if pass
		randomx = math.random(0,love.window.getWidth())
		randomy = math.random(0,love.window.getHeight())


		--Should calculate best place to spawn based on planet location - not enough time now

		if randomy - 50 < 0 or randomx - 50 < 0 then
			insert = false
		end

		if(randomy + 50 > love.window.getHeight() or randomx + 50 > love.window.getWidth()) then
			insert = false
		end


		disttoplanetx = math.abs(randomx - planet.x)
		disttoplanety = math.abs(randomy - planet.y)
		disttotal = math.sqrt((disttoplanetx * disttoplanetx) + (disttoplanety * disttoplanety))

		if(disttotal - 50 <= 0) then
			inser = false
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

		if(insert) then
			table.insert(enemies, {x = randomy, y = randomx, incx = enemyincx, incy = enemyincy, radius = 25, frame = 3})
		end
	end
	--Update positions
	for i, enemy in pairs(enemies) do


		enemy.x = enemy.x + (enemy.incx * dt)
		enemy.y = enemy.y + (enemy.incy * dt)		


	end


end

function drawEnemies()

for i, enemy in pairs(enemies) do

		enemytexture = love.graphics.newImage(enemyframes[enemy.frame])

		love.graphics.print(enemy.x, 50, 10)
		love.graphics.print(enemy.y, 50, 20)
		--love.graphics.circle("fill", enemy.x, enemy.y, enemy.radius, 50)

		love.graphics.draw(enemytexture, enemy.x - enemy.radius, enemy.y - enemy.radius)


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
	

	--Bounce planet off edge if player touches




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



		--Enemy distance to player
		epydistx = math.abs(enemy.x - (player.centx))
		epydisty = math.abs(enemy.y - (player.centy))
		epydistance = math.sqrt((epydistx * epydistx) + (epydisty * epydisty))


		--20 => rough guess of radius if circle was drawn around player
		--Easier to check for collisions that keeping track of edge orientation for rectangular hbox
		if(epydistance - 20 - enemy.radius) <= 0 then

			--Damage player!
			-- code here
			--

			--Bounce off


			if(epydistance - 20 - enemy.radius) < 0 then
				
				-- Push away from player and planet
				enemy.incx = -player.incx + planet.incx
				enemy.incy = -player.incy + planet.incx
			end


		end


		--Enemy distance to planet
		epdistx = math.abs(enemy.x - (planet.x))
		epdisty = math.abs(enemy.y - (planet.y))
		epdistance = math.sqrt( (epdistx * epdistx) + (epdisty * epdisty))


		--Remove planet / enemy radii 
		if (epdistance - planet.radius - enemy.radius) <= 0 then


			planet.incx = -planet.incx/2
			planet.incy = -planet.incy/2


			--Split in two
			enemy.radius = enemy.radius - 10
			enemy.frame = enemy.frame - 1

			if(enemy.radius < 5) then
				table.remove(enemies, i)
			else

				enemy.incx = enemy.incx + planet.incx
				enemy.incy = enemy.incy + planet.incy

				--Find best spot to spawn child

				potx1 = enemy.x + enemy.radius + 10 -- 5 tolerance
				potx2 = enemy.x - enemy.radius - 10
				poty1 = enemy.y + enemy.radius + 10
				poty2 = enemy.y - enemy.radius - 10

				chosenx = potx1
				choseny = poty1

				--Just check for edges
				if(potx2 < 0 or potx2 > love.window.getWidth()) then
					potx2 = -1
				end
				if(potx1 < 0 or potx1 > love.window.getWidth()) then
					potx1 = -1
					chosenx = potx2
				end
				if(poty2 < 0 or poty1 > love.window.getHeight()) then
					poty2 = -1
				end
				if(poty1 < 0 or poty1 > love.window.getHeight()) then
					poty1 = -1
					choseny = poty2
				end





				if(chosenx > 0 and choseny > 0 ) then
					table.insert(enemies, {x = chosenx, y = choseny, incx = -enemy.incx, incy = -enemy.incy, radius = enemy.radius, frame = enemy.frame})
				end
			end
		end



		--Lastly check for enemy - enemy collisions
		for j, enemy2 in pairs(enemies) do

			if(enemy ~= enemy2) then

				eedistx = math.abs(enemy.x - (enemy2.x))
				eedisty = math.abs(enemy.y - (enemy2.y))
				eedistance = math.sqrt( (eedistx * eedistx) + (eedisty * eedisty))

				if(eedistance - enemy.radius - enemy2.radius - 5 <= 0) then

					enemy.incx = enemy2.incx * 1
					enemy.incy = enemy2.incy * 1
				end

			end
		end


		if(enemy.x - enemy.radius <= 0 or enemy.x + enemy.radius >= love.window.getWidth()) then

			enemy.incx = -enemy.incx 
		end


		if(enemy.y - enemy.radius <= 0 or enemy.y + enemy.radius >= love.window.getHeight()) then

			enemy.incy = -enemy.incy
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
				

		if player.frame > #landingframes then
			player.frame = 1
		end


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

