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

	- Decide on weapon -> Theme: Unconvential Weapons
		- Berries / Seeds / Fruits that grow randomly on planet
			- Player must move over to the plant and eat then spit projectiles at enemies
			- Stockpile berries for later use 
			- Different berries have different effects - mines / slowing / dot / explosive

		- Boomerang / Discus
			- Use gravity of planet to create an orbit to knock away enemies


		- Planet
			- Jump to "push" planet away, avoid attacks and crush enemies



	- Different enemy types


	- Textures
		- Planet
		- Player
		- Enemies
		- Bullets


	- Sounds / Music



- Extras

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
	planet = {x = love.window.getWidth() / 2, y = love.window.getHeight() / 2 ,radius = 50, health = 5, circ = 2 * math.pi * 20}


	--Player initial details
	player = {posangle = 180, rotangle = 0, x = planet.x, y = planet.y - planet.radius, height = 15, width = 15, speed = 3}
	calcPlayerPosition()


	--Player shots
	playerProjectiles = {}

	--Enemy shots (?)


	--Enemy attackers
	enemies = {}



end

--Every frame
function love.update(dt)


	--Handle enemy movement
	updateEnemies()

	--Handle projectiles
	updateProjectiles()

	--Handle x/y/z


end


--Key handling
function love.keypressed(key, isrepeat)


	if key == "a" then
		player.posangle = player.posangle + player.speed
		calcPlayerPosition()
	end

	if key == "d" then
		player.posangle = player.posangle - player.speed
		calcPlayerPosition()
	end

	--Ammo types


end	


--Mouse handling
function love.mousepressed(x,y, button)


	if button == "l" then

		playerFire(x,y)

	end

end




function love.draw()


	--Draw projectiles
	drawProjectiles()

	--Draw enemies
	drawEnemies()

	--Draw planet
	love.graphics.setColor(0,255,0)
	love.graphics.circle("fill", planet.x, planet.y, planet.radius, 350)



	--Draw player last due to rotations
	love.graphics.setColor(0,0,255)
	calcPlayerRotation()
	love.graphics.rectangle("fill", player.x, player.y, player.height, player.width)





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


function playerFire(x,y)

	--Create a new projectile, with a start location (player and end destination (mouse)
	table.insert(playerProjectiles,{x = player.x, y = player.y, endx = x, endy = y, shotspeed = 1, cleanup = false})



end


function updateProjectiles()


	for i, shot in pairs(playerProjectiles) do


		--Rewrite this

		if(shot.x < shot.endx) then
			shot.x = shot.x + shot.shotspeed
		elseif (shot.x > shot.endx) then
			shot.x = shot.x - shot.shotspeed
		end

		if(shot.y < shot.endy) then
			shot.y = shot.y + shot.shotspeed
		elseif (shot.y > shot.endy) then
			shot.y = shot.y - shot.shotspeed
		end

		if(shot.x >= shot.endx and shot.y >= shot.endy) then
			shot.cleanup = true	
		end




	end

	--For shot in enemy projectiles


end	



function drawProjectiles()

	for i, shot in pairs(playerProjectiles) do

		love.graphics.setColor(255,0,0)
		love.graphics.circle("fill", shot.x, shot.y, 3, 5)

		--If clean up - draw explode / effect instead
		if(shot.cleanup) then
			love.graphics.setColor(0,255,0)
			love.graphics.circle("fill", shot.x, shot.y, 3, 5)
			table.remove(playerProjectiles, i)
		end


	end


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

		love.graphics.setColor(125,125,0)
		love.graphics.circle("fill", enemy.x, enemy.y, 3, 5)

		--If clean up - draw explode / effect instead
		if(enemy.cleanup) then
			love.graphics.setColor(0,255,0)
			love.graphics.circle("fill", enemy.x, enemy.y, 3, 5)
			table.remove(enemies, i)
		end


	end




end