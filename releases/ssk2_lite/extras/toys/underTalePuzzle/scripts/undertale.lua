-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
-- undertale.lua - Part of undertale puzzle implementation
-- =============================================================


-- =============================================================
-- Module Begins
-- =============================================================
local undertale = {}

function undertale.run( parent, offsets, iterations, speed, randomize )
	parent = parent or display.currentStage
	iterations = iterations or 1
	speed = speed or 100


	local container = display.newContainer( parent, 300, 300 )
	container.x = centerX
	container.y = centerY

	local border = ssk.display.newRect( container, 0, 0, { size = 300, strokeWidth = 5, stroke = _W_, fill = _T_ })

	local index = randomize and math.random(1,#offsets) or 1
	local count = 0
	local maxCount = #offsets * iterations

	local width = 20
	local tween = 40

	local parts = {}

	while( count < maxCount ) do
		local topBlockade = ssk.display.newRect( container, -count * tween, offsets[index] - 20, { w = width, h = 300, anchorY = 1, fill = _R_ }, { isSensor = true, gravityScale = 0 } )
		local botBlockade = ssk.display.newRect( container,  -count * tween, offsets[index] + 20, { w = width, h = 300, anchorY = 0, fill = _G_  }, { isSensor = true, gravityScale = 0 } )

		parts[#parts+1] = topBlockade
		parts[#parts+1] = botBlockade

		index = index + 1
		if( index > #offsets ) then index = 1 end
		count = count + 1
	end

	border:toFront()

	timer.performWithDelay( 1000, 
		function() 
			for i = 1, #parts do
				parts[i]:setLinearVelocity( speed, 0 )		
			end 
		end )


	return container

end


return undertale



