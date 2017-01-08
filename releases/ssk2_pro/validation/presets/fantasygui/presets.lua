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
local mgr = require "ssk2.interfaces.buttons"
local imagePath = "images/fantasygui/"
local gameFont = ssk.__gameFont or native.systemFontBold

-- ============================
local params = 
{ 
	unselImgSrc  	= imagePath .. "wip_01.png",
	selImgSrc    	= imagePath .. "wip_03.png",
}
mgr:addButtonPreset( "wip", params )

local params = 
{ 
	unselImgSrc  	= imagePath .. "wip_01.png",
	selImgSrc    	= imagePath .. "wip_03.png",
	toggledImgSrc 	= imagePath .. "wip_02.png",
	lockedImgSrc 	= imagePath .. "wip_04.png",
}
mgr:addButtonPreset( "wip2", params )
