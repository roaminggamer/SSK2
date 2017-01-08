-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2016 (All Rights Reserved)
-- =============================================================
--   Last Updated: 29 NOV 2016
-- Last Validated: 29 NOV 2016
-- =============================================================
-- Development Notes:
-- Add EasyFPSMeter

local misc = {}
_G.ssk = _G.ssk or {}
_G.ssk.misc = misc

local pairs 			= pairs
local socket			= require "socket"
local getTimer			= system.getTimer
local strGSub			= string.gsub
local strSub			= string.sub
local strFormat 		= string.format
local mFloor			= math.floor
local angle2Vector	= ssk.math2d.angle2Vector
local scaleVec			= ssk.math2d.scale

misc.isConnectedToWWW = function( url )
	local url = url or "www.google.com" 
	local hostFound = true
	local con = socket.tcp()
	con:settimeout( 2 ) -- Timeout connection attempt after 2 seconds
						
	-- Check if socket connection is open
	if con:connect(url, 80) == nil then 
			hostFound = false
	end

	return hostFound
end

function misc.secondsToTimer( seconds, version )	
	local seconds = seconds or 0
	version = version or 1

	if(version == 1) then
		seconds = tonumber(seconds)
		local minutes = math.floor(seconds/60)
		local remainingSeconds = seconds - (minutes * 60)

		local timerVal = "" 

		if(remainingSeconds < 10) then
			timerVal =	minutes .. ":" .. "0" .. remainingSeconds
		else
			timerVal = minutes .. ":"	.. remainingSeconds
		end

		return timerVal
	elseif( version == 2 ) then
		seconds = tonumber(seconds)
		local nHours = string.format("%02.f", mFloor(seconds/3600));
		local nMins = string.format("%02.f", mFloor(seconds/60 - (nHours*60)));
		local nSecs = string.format("%02.f", mFloor(seconds - nHours*3600 - nMins *60));
		return nHours..":"..nMins.."."..nSecs

	elseif( version == 3 ) then
		local nDays = 0
		seconds = tonumber(seconds)
		local nHours = string.format("%02.f", mFloor(seconds/3600));
		local nMins = string.format("%02.f", mFloor(seconds/60 - (nHours*60)));
		local nSecs = string.format("%02.f", mFloor(seconds - nHours*3600 - nMins *60));

		nHours = tonumber(nHours)
		nMins = tonumber(nMins)
		
		while (nHours >= 24) do
			nDays = nDays + 1
			nHours = nHours - 24
		end

		return nDays,nHours,nMins,nSecs 
	end
end

function misc.easyUnderline( obj, color, strokeWidth, extraWidth, yOffset )
		color = color or { 1,1,1,1 }
		strokeWidth = strokeWidth or 1
		extraWidth = extraWidth or 0
		yOffset = yOffset or 0
		local lineWidth = obj.contentWidth + extraWidth
		local x = obj.x - lineWidth/2
		local y = obj.y + obj.contentHeight/2 + strokeWidth + yOffset
		local line = display.newLine( obj.parent, x, y, x + lineWidth, y )
		line:setStrokeColor( unpack(color) )
		line.strokeWidth = strokeWidth
		return line
end

misc.shortenString = function( text, maxLen, appendMe )
  if not text then return "" end
  --print( text, maxLen, appendMe )
  appendMe = appendMe or ""
  local outText = text
  if(outText:len() > maxLen) then
    outText = outText:sub(1,maxLen) .. appendMe
  end
  return outText
end

misc.shortenString2 = function( text, maxLen, prependMe )
  if not text then return "" end
  --print( text, maxLen, appendMe )
  prependMe = prependMe or ""
  local outText = text
  if(outText:len() > maxLen) then
    outText = prependMe .. outText:sub(outText:len()-maxLen+1,outText:len()) 
  end
  return outText
end


misc.fitText = function( obj, origText, maxWidth )
	origText = origText or ""
	local textLen = string.len( origText )
	while(obj.contentWidth > maxWidth and textLen > 1 ) do
			textLen = textLen - 1
			obj.text = misc.shortenString( origText, textLen, "..." )
	end	
end

misc.getImageSize = function ( path, basePath )
	basePath = basePath or system.ResourceDirectory	
	local tmp = display.newImage( path, basePath, 10000,10000 )
	if( not tmp ) then
		return 0, 0
	end
	local sx = tmp.contentWidth
	local sy = tmp.contentHeight
	display.remove(tmp)
	return sx,sy
end


misc.rotateAbout = function( obj, x, y, params	)	
	x = x or display.contentCenterX
	y = y or display.contentCenterY
	params = params or {}
		
	local radius		= params.radius or 50
	obj._pathRot		= params.startA or 0
	local endA			= params.endA or (obj._pathRot + 360 )
	local time			= params.time or 1000
	local delay 		= params.delay or 0
	local myEasing		= params.myEasing or easing.linear
	local debugEn		= params.debugEn

	-- Start at right position
	local vx,vy = angle2Vector( obj._pathRot )
	vx,vy = scaleVec( vx, vy, radius )
	obj.x = x + vx 
	obj.y = y + vy

	-- remove 'enterFrame' listener when we finish the transition.
	obj.onComplete = function( self )
		if(params.onComplete) then 
			params.onComplete( obj )
		end
		Runtime:removeEventListener( "enterFrame", self )
	end

	-- Update position every frame
	obj.enterFrame = function ( self )
		local vx,vy = angle2Vector( self._pathRot )
		vx,vy = scaleVec( vx, vy, radius )
		self.x = x + vx 
		self.y = y + vy

		if( debugEn ) then
			local tmp = display.newCircle( self.parent, self.x, self.y, 1 )
			tmp:toBack()
		end
	end
	Runtime:addEventListener( "enterFrame", obj )

	-- Use transition to change the angle (gives us access to nice effects)
	transition.to( obj, { _pathRot = endA, delay = delay, time = time, transition = myEasing, onComplete = obj } )
end

misc.createEasyMemMeter = function( x , y, width, fontSize )
	x = x or centerX
	y = y or centerY
	width = width or 200
	fontSize = fontSize or 11
	local group = display.newGroup()	

	local hudFrame = display.newRect( group, x, y, width, 30)
	hudFrame:setFillColor(0.2,0.2,0.2)
	hudFrame:setStrokeColor(1,1,0)
	hudFrame.strokeWidth = 2

	local mMemLabel = display.newText( group, "", 40, hudFrame.y, native.systemFont, fontSize )
	mMemLabel:setFillColor(1,0.4,0)
	mMemLabel.anchorX = 1

	local tMemLabel = display.newText( group, "", 40, hudFrame.y, native.systemFont, fontSize )
	tMemLabel:setFillColor(0.2,1,0)
	tMemLabel.anchorX = 0

	hudFrame.touch = function( self, event )
		local target  = event.target
		local eventID = event.id

		if(event.phase == "began") then
			display.getCurrentStage():setFocus( target, eventID )
			target.isFocus = true
			target._x0 = target.x
			target._y0 = target.y

		elseif(target.isFocus) then
			local dx = event.x - event.xStart
			local dy = event.y - event.yStart
			target.x = target._x0 + dx
			target.y = target._y0 + dy

			if(event.phase == "ended" or event.phase == "cancelled") then
				display.getCurrentStage():setFocus( nil, eventID )
				target.isFocus = false
			end
		end
	end; hudFrame:addEventListener( "touch" )
	
	hudFrame.enterFrame = function( self )
		if( group.removeSelf == nil) then
			ignore( "enterFrame", hudFrame )
			return
		end
		-- Fill in current main memory usage
		collectgarbage("collect") -- Collect garbage every frame to get 'true' current memory usage
		local mmem = collectgarbage( "count" ) 
		mMemLabel.text = "M: " .. round(mmem/(1024),2) .. " MB"
		mMemLabel.x = hudFrame.x - 10
		mMemLabel.y = hudFrame.y

		-- Fill in current texture memory usage
		local tmem = system.getInfo( "textureMemoryUsed" )
		tMemLabel.text = "T: " .. round(tmem/(1024 * 1024),2) .. " MB"
		tMemLabel.x = hudFrame.x + 10
		tMemLabel.y = hudFrame.y
		group:toFront()
	end; listen( "enterFrame", hudFrame )
	return group
end

-- Easy Blur
--
misc.easyBlur = function( group, time, color, params )
	params = params or { touchEn = true }
	group = group or display.getCurrentStage()
	time = time or 0
	color = color or {0.5,0.5,0.5}
	local blur = display.captureScreen()
	blur.x, blur.y = centerX, centerY
	blur:setFillColor(unpack(color))
	--blur.fill.effect = "filter.blur"
	blur.fill.effect = "filter.blurGaussian"
	blur.fill.effect.horizontal.blurSize = params.hBlurSize or 8
	blur.fill.effect.horizontal.sigma = params.hBlurSigma or 128
	blur.fill.effect.vertical.blurSize = params.vBlurSize or 8
	blur.fill.effect.vertical.sigma = params.vBlurSigma or 128
	blur.alpha = 0
	group:insert( blur )
	if( params.touchEn ) then
		function blur.onComplete( self )
			if( params.onComplete ) then params.onComplete( blur ) end 
			display.remove( blur )
		end
		blur:addEventListener("touch", 
			function( event ) 
				if( event.phase == "ended" or event.phase == "cancelled" ) then
					transition.to( blur, { alpha = 0, time = time, onComplete = blur } )
				end
				return true 
			end )
	end
	transition.to( blur, { alpha = 1, time = time } )
	return blur
end

-- Easy Shake
--
-- Derived from this: http://forums.coronalabs.com/topic/53736-simple-shake-easing-code-and-demo/
misc.easyShake = function( obj, amplitude, time )
	obj = obj or display.currentStage
	amplitude = amplitude or 100
	time = time or 1000
	local shakeEasing = function(currentTime, duration, startValue, targetDelta)
		local shakeAmplitude = amplitude -- maximum shake in pixels, at start of shake
		local timeFactor = (duration-currentTime)/duration -- goes from 1 to 0 during the transition
		local scaledShake =( timeFactor*shakeAmplitude)+1 -- adding 1 prevents scaledShake from being less then 1 which would throw an error in the random code in the next line
		local randomShake = math.random(scaledShake)
		return startValue + randomShake - scaledShake*0.5 -- the last part detracts half the possible max shake value so the shake is "symmetrical" instead of always being added at the same side
	end -- shakeEasing
	if( not obj._shakeX0 ) then
		obj._shakeX0 = obj.x
		obj._shakeY0 = obj.y
	end
	local function onComplete(self)
		if( obj.removeSelf == nil ) then return end
		obj.x = obj._shakeX0
		obj.y = obj._shakeY0
	end
	transition.to(obj , {time = time, x = obj.x, y = obj.y, transition = shakeEasing, onComplete = onComplete } ) -- use the displayObjects current x and y as parameter
end

-- Easy alert popup
--
-- title - Name on popup.
-- msg - message in popup.
-- buttons - table of tables like this:
-- { { "button 1", opt_func1 }, { "button 2", opt_func2 }, ...}
--
misc.easyAlert = function( title, msg, buttons )
	local function onComplete( event )
		local action = event.action
		local index = event.index
		if( action == "clicked" ) then
			local func = buttons[index][2]
			if( func ) then func() end 
	    end
	    --native.cancelAlert()
	end

	local names = {}
	for i = 1, #buttons do
		names[i] = buttons[i][1]
	end
	--print( title, msg, names, onComplete )
	local alert = native.showAlert( title, msg, names, onComplete )
	return alert
end


misc.isValidEmail = function( val, debugEn )

	if( debugEn ) then
		print( val, string.len(val), string.match( val, "@" ), #val:split("@") )
	end
	if( not val or string.len(val) == 0 ) then return false end
	if( string.match( val, "@" ) == nil ) then return false end
	val = val:split("@") 
	if(#val<2) then return false end
	return true
end



--
-- Add Smart Touch Listener To Object 
-- - Calls optional user listener
--
local function isInBounds( obj, obj2 )
	if(not obj2) then return false end
	local bounds = obj2.contentBounds
	if( obj.x > bounds.xMax ) then return false end
	if( obj.x < bounds.xMin ) then return false end
	if( obj.y > bounds.yMax ) then return false end
	if( obj.y < bounds.yMin ) then return false end
	return true
end
function misc.addSmartTouch( obj, params )
	params = params or {}
	obj.touch = function( self, event )
		local phase = event.phase
		local id 	= event.id
		if( phase == "began" ) then
			self.isFocus = true
			display.currentStage:setFocus( self, id )
			if( params.toFront ) then self:toFront() end
			if( params.listener ) then
				return params.listener( self, event )
			end
		elseif( self.isFocus ) then
			event.inBounds = isInBounds( event, self )
			if( phase == "ended" or phase == "cancelled" ) then
				self.isFocus = false
				display.currentStage:setFocus( self, nil )
			end
			if( params.listener ) then
				return params.listener( self, event )
			end
		end
		if( params.listener ) then
			return params.listener( self, event )
		else
			return false
		end		
	end; obj:addEventListener("touch")
end


--
-- Add Smart Drag Listener To Object 
-- - Dispatches: onDragged, onDropped events
-- - Calls optional user listener
--
function misc.addSmartDrag( obj, params )
	params = params or {}
	obj.touch = function( self, event )
		local phase = event.phase
		local id 	= event.id
		if( phase == "began" ) then
			self.isFocus = true
			display.currentStage:setFocus( self, id )
			self.x0 = self.x
			self.y0 = self.y
			if( params.toFront ) then self:toFront() end
			if( self.onDragged ) then
				self:onDragged( { obj = self, phase = event.phase, x = event.x, y = event.y,  dx = 0, dy = 0, time = getTimer(), target = self } )
			end
			post("onDragged", { obj = self, phase = event.phase, x = event.x, y = event.y, dx = 0, dy = 0, time = getTimer(), target = self } )
			if( params.listener ) then
				return params.listener( self, event )
			end						
		elseif( self.isFocus ) then
			local dx = event.x - event.xStart
			local dy = event.y - event.yStart
			self.x = self.x0 + dx
			self.y = self.y0 + dy

			event.dx = dx
			event.dy = dy

			if( phase == "ended" or phase == "cancelled" ) then
				self.isFocus = false
				display.currentStage:setFocus( self, nil )
				if( self.onDragged ) then
					self:onDragged( { obj = self, phase = event.phase, x = event.x, y = event.y, dx = dx, dy = dy, time = getTimer(), target = self } )
				end
				if( self.onDropped ) then
					self:onDropped( { obj = self, phase = event.phase, x = event.x, y = event.y, dx = dx, dy = dy, time = getTimer(), target = self } )
				end
				post("onDragged", { obj = self, phase = event.phase, x = event.x, y = event.y, dx = dx, dy = dy, time = getTimer(), target = self } )
				post("onDropped", { obj = self, phase = event.phase, x = event.x, y = event.y, dx = dx, dy = dy, time = getTimer(), target = self } )
			else
				if( self.onDragged ) then
					self:onDragged( { obj = self, phase = event.phase, x = event.x, y = event.y, dx = dx, dy = dy, time = getTimer(), target = self } )
				end
				post("onDragged", { obj = self, phase = event.phase, x = event.x, y = event.y, dx = dx, dy = dy, time = getTimer(), target = self } )
			end
			if( params.listener ) then
				return params.listener( self, event )
			end
		end
		if( params.listener ) then
			return params.listener( self, event )
		else
			return false
		end		
	end; obj:addEventListener("touch")
end



-- temporarily block touches
--
misc.blockTouchesForDuration = function( duration, subtle )
	duration = duration or 1000
	local blocker = ssk.display.newRect( nil, centerX, centerY, { w = fullw, h = fullh, fill = _K_, alpha = 0 , isHitTestable = true} )
	local upAlpha = 0.5
	if(subtle) then upAlpha = 0 end
	transition.to( blocker, { alpha = upAlpha, time = 350 } )

	blocker.enterFrame = function( self )
		if( not self.toFront ) then
			ignore("enterFrame", self)
			return
		end
		self:toFront()
		loading:toFront()
	end
	blocker.touch = function() return true end
	blocker:addEventListener( "touch" )

	blocker.timer = function(self)
		if( not self.removeSelf ) then return end
		local function onComplete()
			if( not self.removeSelf ) then return end
			ignore("enterFrame", blocker)
			blocker:removeEventListener( "touch" )
			display.remove(blocker)
			display.remove(loading)
		end
		transition.to( blocker, { alpha = 0, time = 250, onComplete = onComplete } )		
	end
	timer.performWithDelay( duration, blocker )
end

misc.easyRemoteImage = function( curImg, fileName, imageURL, baseDirectory ) 
	baseDirectory = baseDirectory or system.TemporaryDirectory

	if( string.match( imageURL, "http" ) == nil ) then
		imageURL =  "http:" .. imageURL
	end

	if( io.exists( fileName, baseDirectory ) ) then
		curImg.fill = { type = "image", baseDir = baseDirectory, filename = fileName }
		return
	end

	local function networkListener( event )
	    if ( event.isError ) then
	        --print( "Network error - download failed" )
	    elseif ( event.phase == "began" ) then
	        --print( "Progress Phase: began" )
	    elseif ( event.phase == "ended" ) then
	        --print( "Displaying response image file" )
	        curImg.fill = { type = "image", baseDir = event.response.baseDirectory, filename = event.response.filename }
	    end
	end

	local params = {}
	params.progress = false

	network.download(
	    imageURL,
	    "GET",
	    networkListener,
	    params,
	    fileName,
	    baseDirectory
	)
end

-- 
--
function misc.createSlicedImage( group, path, x, y, width, height )
    group = group or display.currentStage
    local slices = display.newGroup()
    group:insert( slices )
    local function cw( obj ) return obj.contentWidth end
    local function ch( obj ) return obj.contentHeight end
    local w2 = width/2
    local h2 = height/2
    local slice_1 = display.newImage( slices, path .. "/slice_1.png", 0, 0  )
    local slice_2 = display.newImage( slices, path .. "/slice_2.png", 0, 0  )
    local slice_3 = display.newImage( slices, path .. "/slice_3.png", 0, 0  )
    --
    slice_1.anchorX = 0
    slice_1.anchorY = 0
    slice_1.x = -w2
    slice_1.y = -h2
    --
    slice_2.anchorY = 0
    slice_2.y = -h2
    --
    slice_3.anchorX = 1
    slice_3.anchorY = 0
    slice_3.x = w2
    slice_3.y = -h2
    --
    local slice_4 = display.newImage( slices, path .. "/slice_4.png", 0, 0  )
    local slice_5 = display.newImage( slices, path .. "/slice_5.png", 0, 0  )
    local slice_6 = display.newImage( slices, path .. "/slice_6.png", 0, 0  )
    --
    slice_4.anchorX = 0
    slice_4.x = -w2
    --
    slice_6.anchorX = 1
    slice_6.x = w2
    
    --
    local slice_7 = display.newImage( slices, path .. "/slice_7.png", 0, 0  )
    local slice_8 = display.newImage( slices, path .. "/slice_8.png", 0, 0  )
    local slice_9 = display.newImage( slices, path .. "/slice_9.png", 0, 0  )
    --
    slice_7.anchorX = 0
    slice_7.anchorY = 1
    slice_7.x = -w2
    slice_7.y = h2
    --
    slice_8.anchorY = 1
    slice_8.y = h2
    --
    slice_9.anchorX = 1
    slice_9.anchorY = 1
    slice_9.x = w2
    slice_9.y = h2

    local wscale = (width - (cw(slice_1) + cw(slice_3)))/cw(slice_2)
    local hscale = (height - (ch(slice_2) + ch(slice_8)))/ch(slice_5)
    slice_2:scale( wscale, 1 )
    slice_4:scale( 1, hscale )
    slice_5:scale( wscale, hscale )
    slice_6:scale( 1, hscale )
    slice_8:scale( wscale, 1 )


    slices.x = x
    slices.y = y
    return slices
end


-- ========================================================================
function misc.oLeft( obj ) 
	if( obj.anchorX == 0 ) then
		return obj.x
	elseif( obj.anchorX == 1 ) then
		return obj.x - obj.contentWidth
	end
	return obj.x - obj.contentWidth/2
end

function misc.oRight( obj ) 
	if( obj.anchorX == 1 ) then
		return obj.x
	elseif( obj.anchorX == 0 ) then
		return obj.x + obj.contentWidth
	end
	return obj.x + obj.contentWidth/2
end

function misc.oHorizCenter( obj ) 
	if( obj.anchorX == 1 ) then
		return obj.x - obj.contentWidth/2
	elseif( obj.anchorX == 0 ) then
		return obj.x + obj.contentWidth/2
	end
	return obj.x 
end

function misc.oBottom( obj ) 
	if( obj.anchorY == 0 ) then
		return obj.y + obj.contentHeight
	elseif( obj.anchorY == 1 ) then
		return obj.y
	end
	return obj.y + obj.contentHeight/2
end

function misc.oTop( obj ) 
	if( obj.anchorY == 0 ) then
		return obj.y 
	elseif( obj.anchorY == 1 ) then
		return obj.y - obj.contentHeight
	end
	return obj.y - obj.contentHeight/2
end

function misc.oVertCenter( obj ) 
	if( obj.anchorY == 0 ) then
		return obj.y + obj.contentHeight/2
	elseif( obj.anchorY == 1 ) then
		return obj.y - obj.contentHeight/2
	end
	return obj.y
end



if( debug ) then
   function misc.countLocals( debugLvl, level )          
      level = level or 2
      local i = 1
      while(debug.getlocal(level,i) ~= nil ) do
         local name,value = debug.getlocal(level,i)
         if( debugLvl and debugLvl > 1 ) then
            print(name,value)
         end
         i = i + 1
      end
      if( debugLvl and debugLvl > 0 ) then
         print("Found: " .. tostring( i ) .. " Locals" )
      end
      return i
   end
else
   function misc.countLocals()
      return 0
   end
end


-- ========================================================================

return misc