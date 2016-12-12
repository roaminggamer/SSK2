-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2016 (All Rights Reserved)
-- =============================================================

-- =============================================================
-- Localizations
-- =============================================================
-- Lua
local getTimer = system.getTimer; local mRand = math.random
local mAbs = math.abs
local strMatch = string.match; local strGSub = string.gsub; local strSub = string.sub
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
ssk.misc.countLocals(1)

-- =============================================================
-- =============================================================

-- PLUGIN REQUIRES GO HERE

-- =============================================================
local test = {}

function test.run( group, params )
   group = group or display.currentStage
   params = params or {}

	-- Circles
	newCircle( group, 45, top + 50 )	
	newCircle( group, 95, top + 50, { fill = _R_ } )
	newCircle( group, 145, top + 50, { radius = 10, fill = _B_, stroke = _W_, strokeWidth = 2 } )
	newCircle( group, 195, top + 50, { size = 20, fill = _O_ } )
	newCircle( group, 245, top + 50, { radius = 20, scale = 0.5, fill = _Y_ } )
	newCircle( group, 295, top + 50, { xScale = 0.75, fill = _C_ } )
	newCircle( group, 345, top + 50, { yScale = 0.75, rotation = 15, fill = _PURPLE_ } )
	newCircle( group, 395, top + 50, { fill = { type = "image", baseDir = system.ResourceDirectory, filename = "images/water.png"} } )
	newCircle( group, 445, top + 50, { 
		fill = { type = "gradient", color1 = { 1, 0, 0.4 }, color2 = { 1, 0, 0, 0.2 }, direction = "down" }, strokeWidth = 4, 
		stroke = { type = "gradient", color1 = { 0, 1, 0.4 }, color2 = { 0, 0, 1, 0.2 }, direction = "up" } } )

	-- Rectangles
	newRect( group, 45, top + 100 )	 
	newRect( group, 95, top + 100, { fill = _R_ } )
	newRect( group, 145, top + 100, { radius = 10, fill = _B_, stroke = _W_, strokeWidth = 2 } )
	newRect( group, 195, top + 100, { size = 20, fill = _O_ } )
	newRect( group, 245, top + 100, { radius = 20, scale = 0.5, fill = _Y_ } )
	newRect( group, 295, top + 100, { xScale = 0.75, fill = _C_ } )
	newRect( group, 345, top + 100, { yScale = 0.75, rotation = 15, fill = _PURPLE_ } )
	newRect( group, 395, top + 100, { fill = { type = "image", baseDir = system.ResourceDirectory, filename = "images/water.png"} } )
	newRect( group, 445, top + 100, { 
		fill = { type = "gradient", color1 = { 1, 0, 0.4 }, color2 = { 1, 0, 0, 0.2 }, direction = "down" }, strokeWidth = 4, 
		stroke = { type = "gradient", color1 = { 0, 1, 0.4 }, color2 = { 0, 0, 1, 0.2 }, direction = "up" } } )

	-- Image Rectangles
	newImageRect( group, 45, top + 150, "images/smiley.png" )	 
	newImageRect( group, 95, top + 150, "images/smiley.png", { fill = _R_ } )
	newImageRect( group, 145, top + 150, "images/smiley.png", { radius = 10, fill = _B_, stroke = _W_, strokeWidth = 2 } )
	newImageRect( group, 195, top + 150, "images/smiley.png", { size = 20, fill = _O_ } )
	newImageRect( group, 245, top + 150, "images/smiley.png", { radius = 20, scale = 0.5, fill = _Y_ } )
	newImageRect( group, 295, top + 150, "images/smiley.png", { xScale = 0.75, fill = _C_ } )
	newImageRect( group, 345, top + 150, "images/smiley.png", { yScale = 0.75, rotation = 15, fill = _PURPLE_ } )
	newImageRect( group, 395, top + 150, "images/smiley.png", { fill = { type = "image", baseDir = system.ResourceDirectory, filename = "images/water.png"} } )
	newImageRect( group, 445, top + 150, "images/smiley.png", { 
		fill = { type = "gradient", color1 = { 1, 0, 0.4 }, color2 = { 1, 0, 0, 0.2 }, direction = "down" }, strokeWidth = 4, 
		stroke = { type = "gradient", color1 = { 0, 1, 0.4 }, color2 = { 0, 0, 1, 0.2 }, direction = "up" } } )

	-- basic physicsParams
	local physics = require "physics"
	physics.setGravity( 0, 10 )
	physics.start()
	--physics.setDrawMode( "hybrid" )

	local ball = display.newImageRect( group, "images/kenney/physicsAssets/yellow_round.png", 40, 40 )
	ball.x = left + 50
	ball.y = centerY - 100
	physics.addBody( ball, { radius = 20, bounce = 1, radius = 20  } )
	ball.gravityScale = 0.2

	local block = display.newImageRect( group, "images/kenney/physicsAssets/stone/square2.png", 40, 40 )
	block.x = left + 50
	block.y = centerY + 50
	physics.addBody( block, "static" )

	if( ssk.__isPro ) then 
		-- Arcs
		local spinGroup = display.newGroup()
		group:insert(spinGroup)
		spinGroup.x = centerX - 300
		spinGroup.y = centerY - 50
		ssk.display.arc( spinGroup, 0, 0 , 
			              { radius = 50, s = 0, sweep = 90,
			                strokeColor = _R_, strokeWidth = 6 })
		ssk.display.arc( spinGroup, 0, 0 , 
			              { radius = 50, s = 90, sweep = 90,
			                strokeColor = _G_, strokeWidth = 6 })
		ssk.display.arc( spinGroup, 0, 0 , 
			              { radius = 50, s = 180, sweep = 90, 
			                strokeColor = _B_, strokeWidth = 6 })
		ssk.display.arc( spinGroup, 0, 0 , 
			              { radius = 50, s = 270, sweep = 90,
			                strokeColor = _Y_, strokeWidth = 6 })

		function spinGroup.enterFrame( self )
			self.rotation = self.rotation + 5 
		end; listen("enterFrame", spinGroup)


		-- Poly Arcs
		ssk.display.polyArc( group, centerX-150, centerY-50,
	         { radius = 50, s = 0, sweep = 180, incr = -0.25, fillColor = _O_ } )

		
		ssk.display.polyArc( group, centerX-50, centerY-50,
	         { radius = 50, s = 45, sweep = 180, incr = -0.25, fillColor = _P_ } )

		-- Pac Man
		local pac
		local curSep = 90
		local curDir = -15

		--local marker = newCircle( group, centerX + 200, centerY, { fill = _R_, radius = 10, alpha = 0.2} )

		local function chomp()
			display.remove(pac)
		   pac = ssk.display.polyArc( group, centerX - 200, centerY + 100,
	         { radius = 50, s = 90 - curSep/2, sweep = 360 - curSep, incr = -0.1, fillColor = _Y_ } )
		   curSep = curSep + curDir
		   if( curSep <= 0 ) then
		   	curSep = 0
		   	curDir = 15
		   elseif( curSep >= 90 ) then
		   	curSep = 90
		   	curDir = -15
		   end
		   --marker:toFront()
		end
		timer.performWithDelay( 30, chomp, -1 )


	end
end

return test
