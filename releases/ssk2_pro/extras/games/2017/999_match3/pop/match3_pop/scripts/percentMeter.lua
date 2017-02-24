local layers 	= require "scripts.gamelayers"

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

local thick = 8
local strokeWidth = 2

local function createHUD( x, y, min, max )
	local hud = newRect( layers.score, x, y, 
			{ w = w- 40, h = thick, 
		  	 fill = _TRANSPARENT_, stroke = _BLUE_, alpha = 0.5,
		  	 strokeWidth = strokeWidth, cornerRadius = 1} )
	hud.left = hud.x - hud.contentWidth/2 + strokeWidth
	hud.maxWidth = hud.contentWidth - 2 * strokeWidth

	hud.myScore = 0
	hud.myMinScore = min or 0 
	hud.myMaxScore = max or 100
	
	hud.setPercent = function( self, percent )
		if( not isDisplayObject(self) ) then
			ignore( "onUpdateScore", self )
			return 
		end
		print("isDisplayObject? ", isDisplayObject(self))
		if(percent < 0 ) then percent = 0 end
		if(percent > 1 ) then percent = 1 end
		if( self.line ) then display.remove( self.line ) end
		local len = self.maxWidth * percent
		self.line = display.newLine( layers.score, self.left, self.y, self.left + len, self.y  )
		self.line:setStrokeColor(unpack(_GREEN_))
		self.line.strokeWidth = strokeWidth
		self.line:toBack()
	end

	hud.onUpdateScore = function( self, event ) 
		if( not isDisplayObject(self) ) then
			ignore( "onUpdateScore", self )
			return 
		end
		self.myScore = self.myScore + event.value

		self:setPercent( self.myScore / self.myMaxScore )

		if( self.myScore <= self.myMinScore ) then
			post( "onHitMinScore", { score = self.myScore }, 2  )
			ignore( "onUpdateScore", self )
		elseif( self.myScore >=  self.myMaxScore ) then
			post( "onHitMaxScore", { score = self.myScore }, 2 )
			ignore( "onUpdateScore", self )
		end		
	end

	listen( "onUpdateScore", hud )

	return hud
end

local function destroyHUD()
end

local public = {}
public.create 	= createHUD
public.destroy 	= destroyHUD
return public
