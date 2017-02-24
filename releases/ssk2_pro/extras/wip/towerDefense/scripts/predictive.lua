local quad
local intercept


-- As this code solves the target/bullet impact location the firing angle and bullet velocity x,y still need to be calculated.

-- source: http://stackoverflow.com/questions/2248876/2d-game-fire-at-a-moving-target-by-predicting-intersection-of-projectile-and-u
-- ref: http://gamedev.stackexchange.com/questions/25277/how-to-calculate-shot-angle-and-velocity-to-hit-a-moving-target

local tiny = 0.000001
--[[ /**
 * Return solutions for quadratic
 */ ]]--
quad = function (a,b,c)
	local sol -- var sol = null;
	if (math.abs(a) < tiny) then 
		if (math.abs(b) < tiny) then 
			if (math.abs(c) < tiny) then 
				sol = {x=0, y=0} else sol = nil 
			end 
		else
			sol = {x=-c/b, y=-c/b} 
		end 
	else 
		local disc = b*b - 4*a*c 
		if (disc >= 0) then 
			disc = math.sqrt(disc)
			a = 2*a
			sol = { x=(-b-disc)/a, y=(-b+disc)/a }
		end
	end
	return sol
end 

--[[ /**
 * Return the firing solution for a projectile starting at 'src' with
 * velocity 'v', to hit a target, 'dst'.
 *
 * @param Object src position of shooter
 * @param Object dst position & velocity of target
 * @param Number v   speed of projectile
 * @return Object Coordinate at which to fire (and where intercept occurs)
 *
 * E.g.
 * >>> intercept({x:2, y:4}, {x:5, y:7, vx: 2, vy:1}, 5)
 * = {x: 8, y: 8.5}
 */ ]]--
intercept =  function (src, dst, v, aimJitter) -- {
	if (dst.getLinearVelocity) then
		dst.vx, dst.vy = dst:getLinearVelocity()
	end

	-- EDOCHI
	if( aimJitter and aimJitter > 0) then
		local curJitter = mRand( -aimJitter, aimJitter )/100

		dst.vx = dst.vx * (1 + curJitter)
		dst.vy = dst.vy * (1 + curJitter)
	end


	local tx, ty, tvx, tvy = dst.x - src.x, dst.y - src.y, dst.vx, dst.vy 

	-- Get quadratic equation components
	local a = tvx*tvx + tvy*tvy - v*v 
	local b = 2 * (tvx * tx + tvy * ty)
	local c = tx*tx + ty*ty 

	-- Solve quadratic
	local ts = quad(a, b, c)

	-- Find smallest positive solution
	local sol 
	if (ts) then 
		local t0, t1 = ts.x, ts.y 
		local t = math.min(t0, t1) 
		if (t < 0) then 
			t=math.max(t0,t1) 
		end 

		if (t > 0) then
			sol = {x=dst.x + dst.vx*t, y=dst.y + dst.vy*t} 
		end 
	end 

	return sol, sol ~= nil
end 
 


 local public = {}
public.quad = quad
public.intercept = intercept
return public
