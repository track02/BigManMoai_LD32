--[[

TODO

- Fixes
	- Rotation of player
		- Currently on outside of planet which is correct, but top left corner needs to be pointing upwards 
		- Observer where bullets are drawn from 

	- Projectile paths
		- Rewrite update so bullets travel in a straight line
		- Want collision detection with planet


	- Enemy paths


- Features

		- Planet
			- Jump to "push" planet away, avoid attacks and crush enemies



	- Different enemy types


	- Textures
		- Planet
		- Player
		- Enemies
		- Bullets

	- Animations


	- Sounds / Music



- Extras

	- Implement a polar coordinate system 

	- Main menu

	- Upgrades system

	- Details
		- Building / plants on planet
		- Other planets, comets, asteroids
		- background texture

	- Multiplayer



- Code Cleanup

	- Split into smaller classes / oop approach
	]]

function love.conf(t)

	t.window.width = 800
	t.window.height = 600
	t.console = true

end


function love.load()

	love.keyboard.setKeyRepeat(true)

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
			  height = 40, width = 20, 
			  speed = 0, speedcap = 50,
			  texture = love.graphics.newImage("PlayerU.png"), 
			  up = false, 
			  down = false, 
			  jumpframes = 20,
			  incx = 0,
			  incy = 0,
			  incxsign = 0,
			  incysign = 0,
			  chargerate = 5,
			  jumpmultiplier = 5,
			  dropmultiplier = 5,
			  weight = 50,
			  charging = false}

	calcPlayerPosition()

	planetinertia = 10

	decel = 0

	pdistx = 0
	pdisty = 0
	distance = 0
	--current direction
	left = false
	right = false
	jumpticks = 0



	--jump dist
	maxheight = planet.radius + planet.radius

	--Enemy shots (?)


	--Enemy attackers
	enemies = {}



end

--Every frame
function love.update(dt)	
		
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
		updateEnemies()
		
		--Handle projectiles
		hitDetection()

	--Handle x/y/z

	if decel ~= 0 and player.speed ~= 0 then
		player.speed = player.speed + decel
	end
end


--Key handling
function love.keypressed(key, isrepeat)


	if key == "a" and right == false and player.speed > -player.speedcap and player.speed <= 0  then
		player.speed = player.speed - 5
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
		player.speed = player.speed + 5
		if(player.speed > player.speedcap) then
			player.speed = player.speedcap
		end
		decel = 0
	end

	if key == "s" and player.down then

		player.down = true
		player.up = false
	end


end	


function love.keyreleased(key)

	--Jump off
	if(key == "a" and left == true and right == false) then
		decel = 1
		left = false
	end

	if(key == "d" and left == false and right == true) then
		decel = -1
		right = false
	end

	if(key == "w") then

	--If not jumping or falling 
		love.graphics.print("JUMP!", 100, 100)

		--One jump at a time
		if player.down == false and player.up == false then
		
			player.up = true
			player.down = false	
			jump = true
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

	love.graphics.print(player.posangle,0,0)

	love.graphics.print(player.speed,0,10)


	--Draw enemies
	drawEnemies()


	--Draw planet
	love.graphics.draw(planet.texture, planet.x - (planet.radius), planet.y - (planet.radius))

	--Draw player last due to rotations
	calcPlayerRotation()
	love.graphics.draw(player.texture, player.x, player.y)
	--love.graphics.rectangle("fill", player.x, player.y, player.height, player.width)





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



function updateEnemies()

	--How many enemies are currently in the game - use a timer system instead
	if(#enemies < 3) then	


	--Generate another?
	--Init at center and translate away by random amount
	
		plusmin = math.random(0,1)

		if(plusmin == 0) then
			enemyx = planet.x + math.random(2 * planet.radius, love.window.getWidth())
		else
			enemyx = planet.x - math.random(2 * planet.radius, love.window.getWidth())
		end

		plusmin = math.random(0,1)

		if(plusmin == 0) then
			enemyy = planet.y + math.random(2 * planet.radius, love.window.getHeight())
		else
			enemyy = planet.y - math.random(2 * planet.radius, love.window.getHeight())
		end


		table.insert(enemies, {x = enemyx, y = enemyy, endx = planet.x, endy = planet.y, speed = 3, cleanup = false})

	end

	--Update positions

	for i, enemy in pairs(enemies) do


		--Rewrite this

		if(enemy.x < enemy.endx) then
			enemy.x = enemy.x + enemy.speed
		elseif (enemy.x > enemy.endx) then
			enemy.x = enemy.x - enemy.speed
		end

		if(enemy.y < enemy.endy) then
			enemy.y = enemy.y + enemy.speed
		elseif (enemy.y > enemy.endy) then
			enemy.y = enemy.y - enemy.speed
		end


		if(enemy.x >= enemy.endx and enemy.y >= enemy.endy) then
			enemy.cleanup = true	
		end

	end

end

function drawEnemies()

for i, enemy in pairs(enemies) do

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
	if( (player.down or (player.up)) and (distance) <= planet.radius) then
		
		--If player was falling push back on planet, else catch player
		if(player.down) then
			planet.incx = planet.incx + player.incx
			planet.incy = planet.incx + player.incy
		end
		
		--Complete jump
		player.down = false
		player.up = false
		jumpticks = 0
		
	end



	--bounce planet off edge of screen

	if(planet.x - planet.radius < 0 or planet.x  + planet.radius> love.window.getWidth()) then

		planet.incx = - planet.incx

	end


	if(planet.y - planet.radius < 0 or planet.y + planet.radius> love.window.getHeight()) then

		planet.incy = - planet.incy
	end

end