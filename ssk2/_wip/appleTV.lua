-- =============================================================
-- Copyright Roaming Gamer, LLC. 2009-2015
-- =============================================================
--                              License
-- =============================================================
--[[
    > SSK is free to use.
    > SSK is free to edit.
    > SSK is free to use in a free or commercial game.
    > SSK is free to use in a free or commercial non-game app.
    > SSK is free to use without crediting the author (credits are still appreciated).
    > SSK is free to use without crediting the project (credits are still appreciated).
    > SSK is NOT free to sell for anything.
    > SSK is NOT free to credit yourself with.
]]
-- =============================================================
--
-- =============================================================
_G.ssk = _G.ssk or {}
local rgAppleTV = {}
_G.ssk.rgAppleTV = rgAppleTV

rgAppleTV.relSwipe = require "com.roaminggamer.ssk.appletv.relswipe"
rgAppleTV.xSwipe = require "com.roaminggamer.ssk.appletv.xswipe"
rgAppleTV.ySwipe = require "com.roaminggamer.ssk.appletv.yswipe"

return rgAppleTV