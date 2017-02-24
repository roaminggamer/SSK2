-- =============================================================
-- Copyright Roaming Gamer, LLC. 2009-2016 (All Rights Reserved)
-- =============================================================

-- =============================================================
-- Localizations
-- =============================================================
-- Lua
local getInfo           = system.getInfo
local getTimer          = system.getTimer
local mRand          	= math.random
local mAbs 					= math.abs

--
-- Common SSK Display Object Builders
local newCircle = ssk.display.newCircle;local newRect = ssk.display.newRect
local newImageRect = ssk.display.newImageRect;local newSprite = ssk.display.newSprite
local quickLayers = ssk.display.quickLayers
--
-- Common SSK Helper Modules
local easyIFC = ssk.easyIFC;local persist = ssk.persist
--
-- Common SSK Helper Functions
local isValid = display.isValid;local isInBounds = ssk.easyIFC.isInBounds
local normRot = math.normRot;local easyAlert = ssk.misc.easyAlert
--
-- SSK 2D Math Library
local addVec = ssk.math2d.add;local subVec = ssk.math2d.sub;local diffVec = ssk.math2d.diff
local lenVec = ssk.math2d.length;local len2Vec = ssk.math2d.length2;
local normVec = ssk.math2d.normalize;local vector2Angle = ssk.math2d.vector2Angle
local angle2Vector = ssk.math2d.angle2Vector;local scaleVec = ssk.math2d.scale
-- =============================================================
-- =============================================================
-- =============================================================
local kernel = {}

local proxy = ssk.proxy

local size 			= 160
local count 		= 11

local function test1()
	local reel 			= {}	
	local lastTime 	= getTimer()
	local rate 			= 500

	--local group = display.newGroup()
	local group = display.newContainer( size, 3 * size )
	group.x = centerX
	group.y = centerY

	for i = 1, count do
		local tmp = newImageRect( group, 0, (i - 1 ) * size, string.format( "images/reel1/%2.2d.png", i ),
			                     { size = size } )
		tmp.myReel = reel
		reel[tmp] = tmp
	end

	newRect( group, 0, 0, { w = size, h = 3 *size-2, fill = _T_, strokeWidth = 2 } )

	local function advance()	
		local curTime = getTimer()
		local dt = curTime - lastTime
		lastTime = curTime
		local dy = rate * dt / 1000
		for k,v in pairs( reel ) do
			v.y = round(v.y + dy)
		end
	end

	local function wrap()
		for k,v in pairs( reel ) do
			if( v.y > size * 2 ) then
				v.y = v.y - count * size
			end
		end
	end

	local function enterFrame( )
		advance()
		wrap()
	end

	wrap()

	timer.performWithDelay( 30, enterFrame, 25 )
	listen( "enterFrame", enterFrame )
end

local function test2(x)
	x = x or centerX
	local reel 			= {}		
	local lastTime 	= getTimer()
	local rate 			= 500

	--local group = display.newGroup()
	local group = display.newContainer( size, 3 * size )
	group.x = x
	group.y = centerY

	for i = 1, count do
		local tmp = newImageRect( group, 0, (i - 1 ) * size, string.format( "images/reel1/%2.2d.png", i ),
			                     { size = size } )
		tmp.myReel = reel
		reel[tmp] = tmp
	end

	newRect( group, 0, 0, { w = size, h = 3 *size-2, fill = _T_, strokeWidth = 2 } )

	local function wrap()
		for k,v in pairs( reel ) do
			if( v.y > size * 3 ) then
				v.y = v.y - count * size
			end
		end
	end
	wrap()

	local function clean()	
		for k,v in pairs( reel ) do
			v.y = round(v.y/size) * size
			print(v.y)
		end
	end		

	local function doSpin( rolls, rate )
		rolls = rolls or 10
		rate 	= rate or 500
		local tmp = newRect( nil, 10, 0, { size = 5 } )
		tmp.y0 = 0
		tmp.y1 = 0
		tmp = proxy.get_proxy_for( tmp )

		local function advance()	
			local dy = tmp.y0 - tmp.y1
			tmp.y1 = tmp.y0
			for k,v in pairs( reel ) do
				v.y = v.y + dy				
			end
		end	

		function tmp:onComplete()
			clean()
			self:removeEventListener( "propertyUpdate" )
			print("DONE", self.y0, self.y1, self.y )
			display.remove(self)

			nextFrame( 
				function()
					doSpin( rolls, rate )
				end, 1000 )
		end

		function tmp:propertyUpdate( event )
			if( event.key == "y0" ) then
				--print( "Changed " .. event.key .. " to " .. event.value )
				advance() 
				wrap()
			end
		end
		tmp:addEventListener( "propertyUpdate" )

		local time = 1000 * (size * rolls)/rate
		transition.to( tmp, { y0 = size * rolls, time = time, onComplete = tmp, transition = easing.linear } )
	end

	doSpin( mRand(15, 20), 2000 )
	

	--timer.performWithDelay( 5000, function() doSpin() end )

end



function kernel.run( group, params )
   group = group or display.currentStage
   params = params or { example = 1 }

   if(params.example == 1) then
   	test1()
   
   elseif(params.example == 2) then
		test2(centerX - 2 * size)
		test2(centerX - size)
		test2(centerX)
		test2(centerX + size)
		test2(centerX + 2 * size)
	end

end

return kernel
