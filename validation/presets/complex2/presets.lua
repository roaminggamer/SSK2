-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2016 (All Rights Reserved)
-- =============================================================
-- Test Complex Buttons
-- =============================================================
--   Last Updated: 06 JAN 2017
-- Last Validated: 06 JAN 2017
-- =============================================================
--
-- labelsInit.lua - Create Label Presets
--
local mgr = require "ssk2.core.interfaces.buttons"
local imagePath = "images/fantasygui/"
local gameFont = ssk.__gameFont or native.systemFontBold

-- ============================
local params = 
{ 
	unselRectFillColor  	= _DARKGREY_,
	selRectFillColor  	= _GREY_,
}
mgr:addButtonPreset( "wip3", params )

local params = 
{ 
	unselRectFillColor  	= _DARKGREY_,
	selRectFillColor  	= _GREY_,
	toggledRectFillColor = _ORANGE_,
	lockedRectFillColor	= _PINK_,
	toggledStrokeColor 	= _Y_,
	lockedStrokeColor 	= _R_,
	strokeWidth 			= 4
}
mgr:addButtonPreset( "wip4", params )
