local dbmgr 		= require "scripts.dbmgr2"
local letterSel 	= require "scripts.letterselector"

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
--
-- Specialized SSK Features
local actions = ssk.actions
local rgColor = ssk.RGColor


local createTile

local minSelectedColors = 2
--local defaultColors = { _RED_, _GREEN_, _BLUE_, _YELLOW_, _WHITE_ }
local defaultColors = { _RED_, _GREEN_, _BLUE_, _YELLOW_ }
local defaultColorImgs = {}


local function isInRadius( obj, obj2, touchRadius2 )
	local len2 = subVec(obj,obj2)
	len2 = len2Vec(len2)
	return (len2 <= touchRadius2)
end

local function testSelectedTiles( selected )

	if( #selected > 0 and selected[1].letter ) then
		local aWord = ""

		for i = 1, #selected do
			aWord = aWord .. selected[i].letter
		end

		aWord = aWord:upper()

		print(aWord)

		if( #selected < 3 ) then return false, aWord end

		if( dbmgr.isWordInDB( aWord ) ) then
			return true, aWord
		elseif( dbmgr.isWordInDB( aWord:reverse() ) ) then 
			return true, aWord:reverse()
		end

		return false, aWord
	
	elseif( #selected > minSelectedColors ) then
		return true, ""
	end

	return false, ""
end


local function resetTiles( self, success, word )

	local selected = self.selected
	local tiles = self.tiles

	if( self.lines ) then
		display.remove( self.lines )			
	end
	self.lines = nil
	
	if( success == true ) then
		if( self.colors ) then			
			local count = #selected
			local color = selected[1]._fill		
			for k,v in pairs( selected ) do		
				local tmp = createTile(v.parent, v.x, v.y, v.params )
				tiles[tmp] = tmp
				tiles[v] = nil
				display.remove( v )			
			end
			post( "onTilesMatch", { count = count, word = word, color = color })
		else
			local delay = 0
			local delta = 50
			local time = 200
			local count = #selected
			local color = selected[1]._fill		

			local function onComplete( tile )

				tile.letter = letterSel.getRandomLetter()
				tile.myLetter.text = tile.letter
				tile:setFillColor(unpack(tile._fill))
				tile.inUse = false				
			end
			for i = 1, #selected do

				if( selected[i].myLetter ) then
					selected[i].myLetter.rotation = 720
					transition.to( selected[i].myLetter, { delay = (i-1) * delta, rotation = 0, time = time} )
				end
				selected[i].rotation = 720
				transition.to( selected[i], { delay = (i-1) * delta, rotation = 0, time = time, onComplete = onComplete } )			
			end
			post( "onTilesMatch", { count = count, word = word, color = color })			
		end
	else
		for k,v in pairs( selected ) do					
			v:setFillColor(unpack(v._fill))
			v.inUse = false
		end
	end
end

local function drawLines( self )
	local selected = self.selected

	if( self.lines ) then
		display.remove( self.lines )			
	end
	self.lines = nil

	if( #selected < 2) then return end

	local linePoints = {}
	for i = 1, #selected do
		linePoints[#linePoints+1] = selected[i].x + self.ox
		linePoints[#linePoints+1] = selected[i].y  + self.oy
	end

	self.lines = display.newLine( unpack( linePoints ) )
	self.parent:insert( self.lines)
	self.lines:toBack()
	self.lines.strokeWidth = 5
end

local function testTile( self )
	local tiles = self.tiles
	local touchRadius2 = self.touchRadius2
	if (not display.isValid( self ) or not tiles) then
		return
	end

	local newTile

	if(self.tx == nil ) then return end

	local selected = self.selected
	local lastTile  = selected[#selected]
	local nextLastTile = selected[#selected-1]

	local txy
	if(self.tx and self.ty) then txy = { x = self.tx, y = self.ty } end

	if( self.colors and #selected > 0 ) then
		for k,v in pairs( tiles ) do		
			if(v._fill == lastTile._fill and isInRadius( txy, v, touchRadius2 ) ) then			
				newTile = v
			end
		end
	else
		for k,v in pairs( tiles ) do		
			if(isInRadius( txy, v, touchRadius2 ) ) then			
				newTile = v
			end
		end
	end

	if( not newTile ) then return end

	if( newTile == lastTile ) then return end 
	if( newTile == nextLastTile ) then
		lastTile:setFillColor(unpack(lastTile._fill))
		lastTile.inUse = false
		table.remove( selected, #selected )
		return
	end

	if(newTile.inUse) then return end


	if( lastTile ) then
		local tweenDist = subVec( lastTile, newTile )
		tweenDist = lenVec( tweenDist )
		--print(tweenDist,self.minTween)
		if( tweenDist > self.minTween ) then 
			return 
		end
	end

	newTile:setFillColor(unpack(newTile._selFill))
	newTile.inUse = true
	selected[#selected+1] = newTile

	--table.dump(selected)
end

local floodTime = 10
local function onTouch( self, event )
	local phase = event.phase
	local id    = event.id 
	local tiles = self.tiles

	if( phase == "began" ) then
		display.getCurrentStage():setFocus( self, id )
		self.isFocus = true
		self.tx = event.x - self.ox
		self.ty = event.y - self.oy
		self.selected = {}
		resetTiles( self )
		self.lastTime = getTimer()
		testTile(self)
		drawLines(self)

	elseif( self.isFocus ) then
		if( phase == "moved" ) then
			local curTime = getTimer()
			local dt = curTime - self.lastTime
			if( dt <= floodTime ) then return true end
			--print(curTime, dt)
			self.lastTime = curTime
			self.tx = event.x - self.ox
			self.ty = event.y - self.oy
			testTile(self)
			drawLines(self)

		elseif( phase == "ended" or phase == "cancelled" ) then
			--print(event.x,event.y)
			display.getCurrentStage():setFocus( self, nil )
			self.isFocus = false
			self.tx = nil
			self.ty = nil		
			local success,word = testSelectedTiles( self.selected )	
			resetTiles( self, success, word )
		end
	end

	return true
end


createTile = function ( group, x, y, params )
	local group  	= group or display.currentStage
	local params 	= params or {}
	local size    	= params.size or 40
	local fill   	= params.fill or _WHITE_
	local selFill   = params.selFill or _CYAN_
	local fontSize  = params.fontSize or 16
	local fontColor = params.fontColor or _BLACK_
	local font      = params.font or system.nativeFont

	local tile
	if( params.colors ) then
		local colors = params.colors
		local num = mRand(1,#colors)
		local color = colors[num]
		local img = params.colorImgs[num]

		local fill = color

		if( img ) then
			tile = newImageRect( group, x, y, img, { size = size, fill = fill })
		
		elseif( params.useCircle ) then
			tile = newCircle( group, x, y, { radius = size/2, fill = fill })
		else
			tile = newRect( group, x, y, { size = size, fill = fill })
		end

		tile._fill = fill
		tile._selFill = selFill

		tile.inUse = false

	else
		if( params.img ) then
			tile = newImageRect( group, x, y, params.img, { size = size, fill = fill })
		
		elseif( params.useCircle ) then
			tile = newCircle( group, x, y, { radius = size/2, fill = fill })
		else
			tile = newRect( group, x, y, { size = size, fill = fill })
		end

		tile._fill = fill
		tile._selFill = selFill

		tile.inUse = false

		-- Add letter to till
		tile.letter = letterSel.getRandomLetter()
		tile.myLetter = display.newText( group, tile.letter, tile.x, tile.y, font, fontSize )
		tile.myLetter:setFillColor( unpack( fontColor ) )
	end

	tile.params = params

	tile.xScale = 0.01
	tile.yScale = 0.01
	transition.to( tile, { xScale = 1, yScale = 1, time = 700, transition = easing.outBounce } )

	return tile
end

local function newLettersRectBoard( group, x, y, params  )
	local group   		= group or display.currentStage
	local params  		= params or {}
	local size    		= params.size or 40
 	local offset  		= params.offset or 0
	local rows    		= params.rows or 5
	local cols    		= params.cols or 5
	local touchRadius 	= params.touchRadius or size/2
	local minTween 		= params.minTween or size * 1.8

	local tiles = {}	

	local board = display.newGroup()
	group:insert(board)

	local sx = -(size * cols + (cols-1) * offset)/2 + size/2
	local sy = -(size * rows + (rows-1) * offset)/2 + size/2
	local tx = sx 
	local ty = sy

	board.touchRadius2 = touchRadius * touchRadius
	board.minTween = minTween

	for row = 1, rows do
		tx = sx
		for col = 1, cols do
			local tmp = createTile( board, tx, ty, params )
			tx = tx + size + offset

			tiles[tmp] = tmp
		end
		ty = ty + size + offset
	end

	board.x = x
	board.y = y

	board.ox = board.x
	board.oy = board.y

	board.tiles = tiles

	board.isHitTestable = true
	board.touch = onTouch
	board:addEventListener( "touch" )

	--board.enterFrame = testTile
	--listen( "enterFrame", board )

	return board
end

local function newLettersCircleBoard( group, x, y, params  )
	local group   		= group or display.currentStage
	local params  		= params or {}
	local size    		= params.size or 40
 	local offset  		= params.offset or 0
	local rings    		= params.rings or params.rows or 3
	local touchRadius 	= params.touchRadius or size/2
	local minTween 		= params.minTween or size * 1.8
	local doHex         = params.doHex or false

	if( not params.img ) then params.useCircle = true end

	local angles     	= { 0, 60, 30, 20, 15 }
	local startAngle 	= { 0, 0, 0, 0, 0 }
	local numPieces  	= { 1 }

	for i = 2, #angles do
		numPieces[i] = 360/angles[i]
	end

	local tiles = {}	

	local board = display.newGroup()
	group:insert(board)

	board.touchRadius2 = touchRadius * touchRadius
	board.minTween = minTween

	for ring = 1, rings do
		local dist = (ring-1) * (size + offset)
		local curAngle = startAngle[ring]
		print("dist", dist)
		for i = 1, numPieces[ring] do
			local vec = angle2Vector(curAngle,true)

			if( doHex == false or ring < 3 ) then
				vec = scaleVec( vec, dist )

			elseif( ring == 3 ) then	
				if( i % 2 == 1  ) then
					vec = scaleVec( vec, dist )
				else
					vec = scaleVec( vec, dist - size/3 + offset/2  )
				end

			elseif( ring == 4 ) then	
				if( i % 3 == 1 ) then
					vec = scaleVec( vec, dist )
				else					
					vec = scaleVec( vec, dist - size/3 + offset/2  )
				end

			elseif( ring == 5 ) then	
				if( i % 4 == 1 ) then					
					vec = scaleVec( vec, dist )

				else					
					if( i%4  == 3 ) then
						print(i, i%4)
						vec = scaleVec( vec, dist - size/3 - offset/2)
					else
						vec = scaleVec( vec, dist - size/3 + offset/2  )						
					end					
				end

			else
				vec = scaleVec( vec, dist )
			end
			vec.x = vec.x
			vec.y = vec.y
			local tmp = createTile( board, vec.x, vec.y, params )
			curAngle = curAngle + angles[ring]
			--print(curAngle)
			tiles[tmp] = tmp
		end
	end

	board.x = x
	board.y = y

	board.ox = x
	board.oy = y


	board.tiles = tiles

	board.isHitTestable = true
	board.touch = onTouch
	board:addEventListener( "touch" )

	--board.enterFrame = testTile
	--listen( "enterFrame", board )

	return board
end



local function newColorsRectBoard( group, x, y, params  )
	local group   		= group or display.currentStage
	local params  		= params or {}
	local size    		= params.size or 40
 	local offset  		= params.offset or 0
	local rows    		= params.rows or 5
	local cols    		= params.cols or 5
	local touchRadius 	= params.touchRadius or size/2
	local minTween 		= params.minTween or size * 1.8
	local colors 		= params.colors or defaultColors
	local colorImgs		= params.colorImgs or defaultColorImgs

	params.colors = colors
	params.colorImgs = colorImgs

	local tiles = {}	

	local board = display.newGroup()
	group:insert(board)

	local sx = -(size * cols + (cols-1) * offset)/2 + size/2
	local sy = -(size * rows + (rows-1) * offset)/2 + size/2
	local tx = sx 
	local ty = sy

	board.touchRadius2 = touchRadius * touchRadius
	board.minTween = minTween

	for row = 1, rows do
		tx = sx
		for col = 1, cols do
			local tmp = createTile( board, tx, ty, params )
			tx = tx + size + offset

			tiles[tmp] = tmp
		end
		ty = ty + size + offset
	end

	board.colors = colors

	board.x = x
	board.y = y

	board.ox = board.x
	board.oy = board.y

	board.tiles = tiles

	board.isHitTestable = true
	board.touch = onTouch
	board:addEventListener( "touch" )

	--board.enterFrame = testTile
	--listen( "enterFrame", board )

	return board
end

local function newColorsCircleBoard( group, x, y, params  )
	local group   		= group or display.currentStage
	local params  		= params or {}
	local size    		= params.size or 40
 	local offset  		= params.offset or 0
	local rings    		= params.rings or params.rows or 3
	local touchRadius 	= params.touchRadius or size/2
	local minTween 		= params.minTween or size * 1.8
	local doHex         = params.doHex or false
	local colors 		= params.colors or defaultColors
	local colorImgs		= params.colorImgs or defaultColorImgs

	if( not params.img ) then params.useCircle = true end

	params.colors = colors
	params.colorImgs = colorImgs

	local angles     	= { 0, 60, 30, 20, 15 }
	local startAngle 	= { 0, 0, 0, 0, 0 }
	local numPieces  	= { 1 }

	for i = 2, #angles do
		numPieces[i] = 360/angles[i]
	end

	local tiles = {}	

	local board = display.newGroup()
	group:insert(board)

	board.touchRadius2 = touchRadius * touchRadius
	board.minTween = minTween

	for ring = 1, rings do
		local dist = (ring-1) * (size + offset)
		local curAngle = startAngle[ring]
		print("dist", dist)
		for i = 1, numPieces[ring] do
			local vec = angle2Vector(curAngle,true)

			if( doHex == false or ring < 3 ) then
				vec = scaleVec( vec, dist )

			elseif( ring == 3 ) then	
				if( i % 2 == 1  ) then
					vec = scaleVec( vec, dist )
				else
					vec = scaleVec( vec, dist - size/3 + offset/2  )
				end

			elseif( ring == 4 ) then	
				if( i % 3 == 1 ) then
					vec = scaleVec( vec, dist )
				else					
					vec = scaleVec( vec, dist - size/3 + offset/2  )
				end

			elseif( ring == 5 ) then	
				if( i % 4 == 1 ) then					
					vec = scaleVec( vec, dist )

				else					
					if( i%4  == 3 ) then
						print(i, i%4)
						vec = scaleVec( vec, dist - size/3 - offset/2)
					else
						vec = scaleVec( vec, dist - size/3 + offset/2  )						
					end					
				end

			else
				vec = scaleVec( vec, dist )
			end
			vec.x = vec.x
			vec.y = vec.y
			local tmp = createTile( board, vec.x, vec.y, params )
			curAngle = curAngle + angles[ring]
			--print(curAngle)
			tiles[tmp] = tmp
		end
	end

	board.colors = colors

	board.x = x
	board.y = y

	board.ox = x
	board.oy = y


	board.tiles = tiles

	board.isHitTestable = true
	board.touch = onTouch
	board:addEventListener( "touch" )

	--board.enterFrame = testTile
	--listen( "enterFrame", board )

	return board
end


public = {}
public.newColorsRectBoard = newColorsRectBoard
public.newColorsCircleBoard = newColorsCircleBoard
public.newLettersRectBoard = newLettersRectBoard
public.newLettersCircleBoard = newLettersCircleBoard
public.newTile = createTile
return public