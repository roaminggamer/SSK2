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




local function createHUD( group, x, y, duration, params )
	local group = group or display.currentStage

	local params 				= params or {}
	local frameColor			= params.frameColor or _DARKERGREY_
	local barColor 				= params.barColor or _WHITE_
	local hudHeight 			= params.hudHeight or 7
	local hudStrokeWidth 		= params.hudStrokeWidth or 2
	local barHeight 			= params.barHeight or 4
	local cornerRadius 			= params.cornerRadius or 0
	local frameAlpha 			= params.frameAlpha or 0.5
	


	local hud = newRect( group, x, y, 
			{ w = w- 40, h = hudHeight, 
		  	 fill = _TRANSPARENT_, stroke = frameColor, alpha = frameAlpha,
		  	 strokeWidth = hudStrokeWidth, cornerRadius = cornerRadius} )
	hud.left = hud.x - hud.contentWidth/2 + hudStrokeWidth
	hud.maxWidth = hud.contentWidth - 2 * hudStrokeWidth

	hud.time = 0
	hud.duration = duration or 15
	
	hud.setPercent = function( self, percent )

		if(percent < 0 ) then percent = 0 end
		if(percent > 1 ) then percent = 1 end
		if( self.line ) then display.remove( self.line ) end
		local len = self.maxWidth * percent
		self.line = display.newLine( group, self.left, self.y, self.left + len, self.y  )
		self.line:setStrokeColor(unpack(barColor))
		self.line.strokeWidth = barHeight
		--self.line:toBack()
	end

	hud.timer = function( self )
		if( self.isRunning == false ) then return end
		self.time = self.time + 0.1

		if( self.time < self.duration ) then
			self:setPercent( self.time/self.duration )			
			self.lastTimer = timer.performWithDelay( 100, self )
		else
			self.time = self.duration
			self:setPercent( self.time/self.duration )		
			post( "onTimerDuration", { duration = self.duration }, 2 )	
		end
	end

	hud.start = function( self, reset )	
		if( self.isRunning == true ) then return end
		self.isRunning = true
		if( reset and self.lastTimer ) then
			timer.cancel(self.lastTimer)
			self.lastTimer = nil
			self.time = 0 
		end
		self:setPercent( self.time/self.duration )			
		self.lastTimer = timer.performWithDelay( 100, self )
	end

	hud.stopTimer = function( self )
		if( self.isRunning == false ) then return end
		self.isRunning = false
	end
	hud.stop = hud.stopTimer

	listen("stopTimer", hud )

	return hud
end

local function destroyHUD()
end

local public = {}
public.create 	= createHUD
public.destroy 	= destroyHUD
return public
