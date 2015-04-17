function love.load()

	require 'fish'

	fish = Fish(30,10,1)

 	love.keyboard.setKeyRepeat(false)

 	arrowbox_start_x = 700
 	arrowbox_start_y = 500

	arrowbox_X = 700
	arrowbox_Y = 500

	arrow_move = 10

	catch_x = 50
	catch_y = 50
	catch_height = 25
	catch_progress = 50


	arrow_up = love.graphics.newImage("up.png")
	arrow_down = love.graphics.newImage("down.png")
	arrow_left = love.graphics.newImage("left.png")
	arrow_right = love.graphics.newImage("right.png")

	a = {}
	a[0] = arrow_up	
	a[1] = arrow_down
	a[2] = arrow_left
	a[3] = arrow_right


	arrow_match = true
	arrow_pick = math.random(4) - 1


	min_dt = 1/60
	next_time = love.timer.getTime()

	pulse = 0
	pulse_count = 0
	tick_length = fish.speed

	clear = false
	catch = 0

	arrow_move = 650 /  fish.speed

	cast = false


end

--Every frame
function love.update(dt)




	catching()

end


function love.keypressed(key, isrepeat)

	--Lock after choice is made - can currently increase meter before next arrow is drawn

	if key == "right" and arrow_pick == 3 then
		clear = true
    end

    if key == "left" and arrow_pick == 2 then
    	clear = true
    end

    if key == "up" and arrow_pick == 0 then
    	clear = true
    end

    if key == "down" and arrow_pick == 1 then
    	clear = true
    end

    if key == "a" then
    	pulse = 0
    	tick_length = tick_length * 2
    end

    if key == "d" then
    	pulse = 0
    	tick_length = tick_length / 2
    end	

    if key == "z" and not cast then
    	cast = true
    end	

    if clear and catch_progress < 100 then
    	catch_progress = catch_progress + 10
    end

end	



function love.draw()


	if(not clear) then
		love.graphics.draw(a[arrow_pick], arrowbox_X, arrowbox_Y)
	end
	--love.graphics.print(next_time, 400, 300)
	love.graphics.print(fish.speed, 400, 200)
	love.graphics.print(pulse, 400, 300)
	love.graphics.print(love.timer.getFPS(), 100, 200)


	if catch == -1 then
		love.graphics.print("Got Away!", 300, 300)
	end	
	if catch == 1 then
		love.graphics.print("Caught it!", 300, 300)
	end


	if(pulse == fish.speed) then
		love.graphics.print("TICK", 500,500)
		pulse = 0
	end	



	love.graphics.rectangle("fill", catch_x, catch_y, catch_progress * 2, catch_height)


   local cur_time = love.timer.getTime()
   if next_time <= cur_time then
      next_time = cur_time
      return
   end
   love.timer.sleep(next_time - cur_time)



end


function catching()

	if cast then

	next_time = next_time + min_dt
	pulse = pulse + 1
	arrowbox_X = arrowbox_X - arrow_move


		--If pulse - new arrow
		if pulse >= fish.speed then

			if not clear then
				catch_progress = catch_progress - fish.strength
			end	


			if catch_progress <= 0 then
				catch = -1
				
				fish = Fish((math.random(6) + 1) * 10, (math.random(10) + 1) * 2, math.random(4) + 1)
				arrow_move = 650 /  fish.speed
				catch_progress = 50
				cast = false	


			end

			if catch_progress >= 100 then
				catch = 1
				fish = Fish((math.random(6) + 1) * 10, (math.random(10) + 1) * 2, math.random(4) + 1)
				arrow_move = 650 /  fish.speed
				catch_progress = 50
				cast = false

			end


			arrow_pick = math.random(4) - 1
			arrowbox_X = arrowbox_start_x
			arrowbox_y = arrowbox_start_Y
			clear = false
			pulse = 0

		end

	end

end


function casting()


end

