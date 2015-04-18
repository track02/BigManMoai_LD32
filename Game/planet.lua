
Planet = {} --Empty table
Planet.prototype = {radius = 20, health = 5} --Setup default entry
Planet.mt = {__index = Planet.prototype} --Set defaults - if no key is found check metatable

--constructor
Planet.new = function()
	local pl = {} --Create a empty table in function scope
	setmetatable(pl, Planet.mt) --Set default values, look up metatable
	return pl
end



-- Given distance - determine position on planet in terms of (x,y)
-- Where distance 0 is the top of the plant and distance 1/2 circumference is the bottom
-- Wrap around
function determinePosition(x)








end	