-- =============================================================
-- Copyright Roaming Gamer, LLC. 2009-2015
-- =============================================================
-- (Composer) Scene Generator 
-- =============================================================
-- 								License
-- =============================================================
--[[
		TBD TBD TBD TBD TBD TBD TBD TBD TBD TBD TBD TBD TBD TBD 
]]
-- =============================================================
if( not _G.ssk ) then
	_G.ssk = {}
end
local sceneGen = {}
_G.ssk.sceneGen = sceneGen

local composer 		= require( "composer" )

-- Table of scene loaders
local loaders = {}

-- Backup copy of gotoScene and loadScene
local composer_gotoScene = composer.gotoScene
local composer_loadScene = composer.loadScene
function composer.gotoScene( ... )	
	local name = arg[1]
	if( composer.loadedScenes[name] == nil ) then
		ssk.sceneGen.newScene(name,loaders[name])
	end
	return composer_gotoScene( unpack( arg ) )
end
function composer.loadScene( ... )	
	local name = arg[1]
	if( composer.loadedScenes[name] == nil ) then
		ssk.sceneGen.newScene(name,loaders[name])
	end
	return composer_loadScene( unpack( arg ) )
end



function sceneGen.registerScenes( name, params )
	loaders[name] = params
end

function sceneGen.newScene( name, params )
	params = params or {}
	local scene    		= composer.newScene()

	----------------------------------------------------------------------
	-- scene:create( event ) - Called on first scene open ONLY (unless
	-- the scene has been manually or automatically destroyed.)
	----------------------------------------------------------------------
	function scene:create( event )
	   if( params.onCreate ) then params.onCreate( scene, event ) end
	end

	----------------------------------------------------------------------
	-- scene:willEnter( event ) - Replaces the scene:show() method.  This
	-- method is called during the 'will' phase of scene:show().
	----------------------------------------------------------------------
	function scene:willEnter( event )
	   local sceneGroup = self.view
	   if( params.onWillEnter ) then params.onWillEnter( scene, event ) end
	end

	----------------------------------------------------------------------
	-- scene:didEnter( event ) - Replaces the scene:show() method.  This
	-- method is called during the 'did' phase of scene:show().
	----------------------------------------------------------------------
	function scene:didEnter( event )
	   local sceneGroup = self.view
	   if( params.onDidEnter ) then params.onDidEnter( scene, event ) end
	end

	----------------------------------------------------------------------
	-- scene:willExit( event ) - Replaces the scene:hide() method.  This
	-- method is called during the 'will' phase of scene:hide().
	----------------------------------------------------------------------
	function scene:willExit( event )
	   local sceneGroup = self.view
	   if( params.onWillEnter ) then params.onWillEnter( scene, event ) end
	end

	----------------------------------------------------------------------
	-- scene:didExit( event ) - Replaces the scene:hide() method.  This
	-- method is called during the 'did' phase of scene:hide().
	----------------------------------------------------------------------
	function scene:didExit( event )
	   local sceneGroup = self.view
	   if( params.onDidExit ) then params.onDidExit( scene, event ) end
	end

	----------------------------------------------------------------------
	-- scene:destroy( event ) - Called automatically by Composer scene library
	-- to destroy the contents of the scene (based on settings and memory constraints):
	-- https://docs.coronalabs.com/daily/api/library/composer/recycleOnSceneChange.html
	--
	-- Also called if you manually call composer.removeScene()
	-- https://docs.coronalabs.com/daily/api/library/composer/removeScene.html
	----------------------------------------------------------------------
	function scene:destroy( event )
	   local sceneGroup = self.view
	   if( params.onDestroy ) then params.onDestroy( scene, event ) end
	end

	---------------------------------------------------------------------------------
	-- Scene Dispatch Events, Etc. - Generally Do Not Touch Below This Line
	---------------------------------------------------------------------------------

	-- This code splits the 'show' event into two separate events: willShow and didShow
	-- for ease of coding above.
	function scene:show( event )
	   local sceneGroup 	= self.view
	   local willDid 	= event.phase
	   if( willDid == "will" ) then
	      self:willEnter( event )
	   elseif( willDid == "did" ) then
	      self:didEnter( event )
	   end
	end

	-- This code splits the 'show' event into two separate events: willHide and didHide
	-- for ease of coding above.
	function scene:hide( event )
	   local sceneGroup 	= self.view
	   local willDid 	= event.phase
	   if( willDid == "will" ) then
	      self:willExit( event )
	   elseif( willDid == "did" ) then
	      self:didExit( event )
	   end
	end
	scene:addEventListener( "create", scene )
	scene:addEventListener( "show", scene )
	scene:addEventListener( "hide", scene )
	scene:addEventListener( "destroy", scene )

	composer.loadedScenes[name] = scene
	return scene
end


return sceneGen