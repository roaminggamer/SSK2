-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
-- myCC.lua - Collision Settings
-- =============================================================
local myCC = ssk.cc:newCalculator()

myCC:addNames( "arrow", "player", "balloon", "wall" )

myCC:collidesWith( "arrow", { "wall", "balloon" } )

return myCC
