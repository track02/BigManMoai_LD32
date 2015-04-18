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
	speed = 5, 
	texture = love.graphics.newImage("PlayerU.png"), 
	up = false, 
	down = false, 
	jumpframes = 20,
	incx = 0,
	incy = 0}





	calcPlayerPosition()


	--Offset ranges
	posx = love.window.getWidth() -- 1/2 windowwidth -> windowwidth x+
	posy = 0 -- 1/2 windowheight -> 0 y+
	negx = 0
	negy = love.window.getHeight()	
	
	--current direction


	--Enemy shots (?)


	--Enemy attackers
	enemies = {}



end

--Every frame
function love.update(dt)

	--Handle player/planet movement
	jump()
	shiftplanet()

	--Handle enemy movement
	updateEnemies()

	--Handle projectiles

	--Handle x/y/z


end


--Key handling
function love.keypressed(key, isrepeat)


	if key == "a" and player.up == false and player.down == false then
		player.posangle = player.posangle + player.speed
		calcPlayerPosition()
	end

	if key == "d" and player.up == false and player.down == false then
		player.posangle = player.posangle - player.speed
		calcPlayerPosition()
	end

	if key == "w" then

		if player.up == false and player.down == false then


	--Ranges for each angle
	if(player.posangle >= 338 or player.posangle < 23) then -- 0 - wrapping around so use OR
		player.incx = 0
		player.incy = -1
		love.graphics.print("JUMP!", 100, 100)
	elseif(player.posangle >= 23 and player.posangle < 68) then -- 45
		player.incx = - 1
		player.incy = -1	
	elseif(player.posangle >= 68 and player.posangle < 113) then -- 90
		player.incx = -1		
		player.incy = 0
	elseif(player.posangle >= 113 and player.posangle < 158) then -- 135
		player.incy = 1
		player.incx = -1
	elseif(player.posangle >= 158 and player.posangle < 203) then --180
		player.incy = 1
		player.incx = 0	
	elseif(player.posangle >= 203 and player.posangle < 248) then --225
		player.incx = 1
		player.incy = 1
	elseif(player.posangle >= 248 and player.posangle < 293) then --270
		player.incx = 1
		player.incy = 0	
	elseif(player.posangle >= 293 and player.posangle < 338) then --315
		player.incx =  1
		player.incy = -1
	end



			player.up = true
		end


	end




end	




function love.draw()

	love.graphics.print(player.posangle,0,0)




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
		player.posangle = 0 + (player.posangle - 360)
	end

	--Top Left Point at position angle on circle circumference 
	player.x = (planet.x + (planet.radius) * math.sin(player.posangle * 0.01745)) 
	player.y = (planet.y + (planet.radius) * math.cos(player.posangle * 0.01745))


	--This is the position of the top left point of the rectangle
	--Rotate coordinates as player moves around the planet


end

function calcPlayerRotation()
	love.graphics.translate(player.x, player.y)
	love.graphics.rotate(-(player.posangle * 0.01745))
	love.graphics.translate(-player.x, -player.y)
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



function jump()

	--Need to check where on circle jumping from - movement in 8 directions
	-- Need to check if planet is moving, end landing early so we don't fall through

	--Jump up until frames = 0
	if player.up then
		player.y = player.y - player.incy
		player.x = player.x - player.incx
		player.jumpframes = player.jumpframes - 1

		if player.jumpframes == 0 then
			player.up = false
			player.down = true
		end
	elseif player.down then




		player.y = player.y + player.incy
		player.x = player.x + player.incx
		player.jumpframes = player.jumpframes + 1

		if player.jumpframes == 20 then
			player.down = false

			--Landed
			--Shift planet & player
			planet.incx = player.incx
			planet.incy = player.incy

			planet.planetshift = true
		end
	end
end


function shiftplanet()

	if planet.planetshift then

		planet.shiftframes = planet.shiftframes - 1;

		--will need to check which side jump came from and determine angle!
		planet.x = planet.x + planet.incx
		planet.y = planet.y + planet.incy
		player.y = player.y + planet.incy
		player.x = player.x + planet.incx

		if(planet.frames == 0) then

			planet.planetshift = false
			planet.shiftframes = 10
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





function hitDetection()
-- Enemy bullets against player / planet (?)
end