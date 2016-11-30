-- =============================================================
-- Basic 'Particle' Generators
-- =============================================================
-- by Roaming Gamer, LLC. 2009-2016 (http://roaminggamer.com/)
-- =============================================================

--
-- Forward Declarations
-- SSK 
local angle2Vector      = ssk.math2d.angle2Vector
local vector2Angle      = ssk.math2d.vector2Angle
local scaleVec          = ssk.math2d.scale
local addVec            = ssk.math2d.add
local subVec            = ssk.math2d.sub
local normVec           = ssk.math2d.normalize
local getNormals        = ssk.math2d.normals
local vecLen            = ssk.math2d.length
local vecLen2           = ssk.math2d.length2
-- Lua and Corona 
local mAbs              = math.abs
local mRand             = math.random
local getInfo           = system.getInfo
local getTimer          = system.getTimer
local strMatch          = string.match
local strFormat         = string.format

local trail = {}

function trail.render( obj, params )
    params = params or {}
    local style         = params.style or 1
    local count         = params.count or 3
    local size          = params.size or 5
    local time          = params.time or 1000
    local fromAlpha     = params.fromAlpha or 1
    local toAlpha       = params.toAlpha or 0.05
    local xJiggle       = params.xJiggle or 2
    local yJiggle       = params.yJiggle or 2
    local fromStroke    = params.fromStroke or size/2
    local toStroke      = params.toStroke or 1
    local myEasing      = params.easing or easing.linear
    local ox            = params.ox or 0
    local oy            = params.oy or 0


    -- Fading Squares
    if( style == 1 ) then
		for i = 1, count do
			local tmp = display.newRect( obj.parent, 
				                         obj.x + math.random(-xJiggle,xJiggle) + ox, 
                                         obj.y + math.random(-yJiggle,yJiggle) + oy, 
				                         size, size )
			tmp.alpha = fromAlpha
            if( params.fill ) then
                tmp:setFillColor(unpack(params.fill))
            else
                tmp:setFillColor(0.25,0.25,0.25)
            end
			
			tmp:toBack()
			transition.to( tmp, { alpha = toAlpha, xScale = 0.5, yScale = 0.5, time = time, transition = easing.myEasing, onComplete = display.remove })
		end    		

    -- Fading Circles
    elseif( style == 2 ) then
		for i = 1, count do
			local tmp = display.newCircle( obj.parent, 
				                         obj.x + math.random(-xJiggle,xJiggle) + ox, 
                                         obj.y + math.random(-yJiggle,yJiggle) + oy, 
				                         size/2 )
			tmp.alpha = fromAlpha
            if( params.fill ) then
                tmp:setFillColor(unpack(params.fill))
            else
                tmp:setFillColor(0.25,0.25,0.25)
            end
			tmp:toBack()
			transition.to( tmp, { alpha = toAlpha, xScale = 0.5, yScale = 0.5, time = time, transition = easing.myEasing, onComplete = display.remove })
		end    		

    -- Lines
    elseif( style == 3 ) then
        if( not obj.lastX ) then
           obj.lastX = obj.x
           obj.lastY = obj.y
           return
        end

		local tmp = display.newLine( obj.parent, obj.lastX, obj.lastY, obj.x + ox, obj.y + oy)
		obj.lastX = obj.x
		obj.lastY = obj.y

		tmp.alpha = fromAlpha
        if( params.fill ) then
            tmp:setStrokeColor(unpack(params.fill))
        else
            tmp:setStrokeColor(0.25,0.25,0.25)
        end
		tmp:toBack()
		tmp.strokeWidth = fromStroke
		transition.to( tmp, { alpha = toAlpha, strokeWidth = toStroke, time = time, transition = easing.myEasing, onComplete = display.remove })

    -- Rainbow Fading Squares
    elseif( style == 4 ) then
		for i = 1, count do
			local tmp = display.newRect( obj.parent, 
				                         obj.x + math.random(-xJiggle,xJiggle) + ox, 
                                         obj.y + math.random(-yJiggle,yJiggle) + oy, 
				                         size, size )
			tmp.alpha = fromAlpha
            if( params.fill ) then
                tmp:setFillColor(unpack(params.fill))
            else
                tmp:setFillColor(math.random(), math.random(), math.random()) 
            end           
			
			tmp:toBack()
			transition.to( tmp, { alpha = toAlpha, xScale = 0.5, yScale = 0.5, time = time, transition = easing.myEasing, onComplete = display.remove })
		end    		

    -- Rainbow Fading Circles
    elseif( style == 5 ) then
		for i = 1, count do
			local tmp = display.newCircle( obj.parent, 
				                         obj.x + math.random(-xJiggle,xJiggle) + ox, 
                                         obj.y + math.random(-yJiggle,yJiggle) + oy, 
				                         size/2 )
			tmp.alpha = fromAlpha
            if( params.fill ) then
                tmp:setFillColor(unpack(params.fill))
            else
                tmp:setFillColor(math.random(), math.random(), math.random()) 
            end           
			tmp:toBack()
			transition.to( tmp, { alpha = toAlpha, xScale = 0.5, yScale = 0.5, time = time, transition = easing.myEasing, onComplete = display.remove })
		end    		

    -- Rainbow Lines
    elseif( style == 6 ) then
        if( not obj.lastX ) then
	       obj.lastX = obj.x
	       obj.lastY = obj.y
           return
        end

		local tmp = display.newLine( obj.parent, obj.lastX, obj.lastY, obj.x + ox, obj.y + oy)
		obj.lastX = obj.x
		obj.lastY = obj.y

		tmp.alpha = fromAlpha
        if( params.fill ) then
            tmp:setStrokeColor(unpack(params.fill))
        else
            tmp:setStrokeColor(math.random(), math.random(), math.random()) 
        end           
		tmp:toBack()
		tmp.strokeWidth = fromStroke

		transition.to( tmp, { alpha = toAlpha, strokeWidth = toStroke, time = time, transition = easing.myEasing, onComplete = display.remove })

    end

end

return trail