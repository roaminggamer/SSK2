-- =============================================================
-- Copyright Roaming Gamer, LLC. 2009-2016
-- =============================================================
-- 
-- =============================================================
local RGFiles 	= ssk.files
local genUtil 	= require( "scripts.generation.genUtil" )
local pu 	  	= require( "scripts.generation.packageUtil" )
local atomsUtil = require( "scripts.atoms.atomsUtil" )
local atomsMgr  = require( "scripts.atoms.atomsMgr" )

local package = {}

function package.generate( generatedData, currentProject )

	-- Generata UI files (composer scenes)
	-- Iterate over the map list and buid ONLY the UI records 
	print( "-------------------------------")
	local map = currentProject.map 
	for i = 1, #map do
		local uid = map[i]
		local mapRecord = atomsUtil.getMapByUID( currentProject, uid )
		local mapType = atomsUtil.getRecordType( mapRecord )

		local childRecords
		local isUI
		if(mapType == "map_block_ui") then
			isUI = true
			childRecords = atomsUtil.getUIRecordsByUID( currentProject, uid )

		elseif(mapType == "map_block_world") then
			isUI = false
			childRecords = atomsUtil.getWorldChildRecordsByUID( currentProject, uid )
		end

		if( isUI )		 then
			local uiName = atomsUtil.getAtomFieldValue( mapRecord.atoms[1].atom, "name" )
			local fileName = "ifc/" .. uiName .. ".lua"


	-- =================================================================
	-- 1. Break down details about the UI and children of the UI
	-- =================================================================
	print( "Map Block " .. tostring(uid) .. " is a UI "  .. 
	   	    " and has:\n - " .. atomsUtil.getAtomCount( mapRecord ) .. " configuration atoms\n" ..
	   		" - " .. #childRecords .. " child records.")

			for j = 1, #childRecords do
				local childUID = childRecords[j]
				local childRecord = currentProject.records[childUID]
				local childRecordBaseType = atomsUtil.getRecordType( childRecord  )
				local childRecordAtomCount = atomsUtil.getAtomCount( childRecord )
				print( " => Child (" .. tostring( childUID ) .. ") is a " .. childRecordBaseType .. " with " .. 
					   tostring(childRecordAtomCount) .. " total atoms." )
			end
			-- =================================================================
			-- =================================================================

			-- =================================================================
			-- 2. Now create the scene
			-- =================================================================
			local scene = {}
			--scenes[#scenes+1] = scene

			local uiBaseTypeAtom = atomsUtil.getAtomByNum( mapRecord, 1 )
			scene.name = atomsUtil.getAtomFieldValue( uiBaseTypeAtom, "name")

			local scene  = {}			
			scene.onCreate = {}
			scene.onDestroy = {}
			
			scene.onWillShow = {}
			scene.onWillHide = {}			
			scene.onDidShow = {}
			scene.onDidHide = {}

			for j = 1, #childRecords do
				local childUID = childRecords[j]
				local childRecord = currentProject.records[childUID]				
				local childRecordBaseType = atomsUtil.getRecordType( childRecord )

				print( childUID, childRecord, childRecordBaseType, "----------------")
				atomsMgr.generateCode( scene , childRecord.atoms, childUID )
				table.print_r(scene)

			end	
			

			pu.addGC( generatedData, package.ui( fileName, currentProject, scene), fileName )
		end
	end

end

-- ==
--		UI GENERATOR
-- ==
function package.ui( fileName, currentProject, scene)

	--table.print_r(scene)



	genUtil.resetContent()

	-- Header	
	genUtil.add( 0, "-- =============================================================" )
	genUtil.add( 0, "-- " .. (currentProject.copyright_statement or "Your Copyright Statement Goes Here") )
	genUtil.add( 0, "-- =============================================================" )
	genUtil.add( 0, "--  " .. fileName )
	genUtil.add( 0, "-- =============================================================" )
	genUtil.add( 0, "-- =============================================================" )
	genUtil.nl()

	genUtil.add( 0, 'local composer 		= require( "composer" )')
	genUtil.add( 0, 'local scene    		= composer.newScene()')
	genUtil.nl()

	genUtil.add( 0, '----------------------------------------------------------------------')
	genUtil.add( 0, '-- Localizations (local reference to remote functions for speedup)')
	genUtil.add( 0, '----------------------------------------------------------------------')
	genUtil.add( 0, 'local getInfo = system.getInfo;local getTimer = system.getTimer')
	genUtil.add( 0, 'local newCircle = ssk.display.newCircle;local newRect = ssk.display.newRect')
	genUtil.add( 0, 'local newImageRect = ssk.display.newImageRect;local newSprite = ssk.display.newSprite')
	genUtil.add( 0, 'local quickLayers = ssk.display.quickLayers;local easyIFC = ssk.easyIFC')	
	genUtil.add( 0, 'local isValid = display.isValid;local isInBounds = ssk.easyIFC.isInBounds')
	genUtil.add( 0, 'local normRot = ssk.misc.normRot;local easyAlert = ssk.misc.easyAlert')
	genUtil.nl()


	genUtil.add( 0, '----------------------------------------------------------------------')
	genUtil.add( 0, '-- Locals')
	genUtil.add( 0, '----------------------------------------------------------------------')
	genUtil.nl()

	genUtil.add( 0, '----------------------------------------------------------------------')
	genUtil.add( 0, '-- Forward Declarations')
	genUtil.add( 0, '----------------------------------------------------------------------')
	genUtil.nl()

	genUtil.add( 0, '----------------------------------------------------------------------')
	genUtil.add( 0, '-- Scene Methods')
	genUtil.add( 0, '----------------------------------------------------------------------')
	genUtil.add( 0, '--')
	genUtil.add( 0, '-- Tip: This composer template is slightly different from the "standard" template found here:')
	genUtil.add( 0, '-- https://docs.coronalabs.com/daily/api/library/composer/index.html#scene-template')
	genUtil.add( 0, '--')
	genUtil.add( 0, '-- I have split the scene:show() and scene:hide() methods into these distinct sub-methods:')
	genUtil.add( 0, '--')
	genUtil.add( 0, '-- * scene:willShow() - Called in place of "will" phase of scene:show().')
	genUtil.add( 0, '-- * scene:didShow()  - Called in place of "did" phase of scene:show().')
	genUtil.add( 0, '-- * scene:willHide()  - Called in place of "will" phase of scene:hide().')
	genUtil.add( 0, '-- * scene:didHide()   - Called in place of "did" phase of scene:hide().')
	genUtil.add( 0, '--')
	genUtil.add( 0, '-- I did this to help folks logically separate the phases and for those converting from storyboard.* which')
	genUtil.add( 0, '-- had similar methods.')
	genUtil.add( 0, '--')
	genUtil.add( 0, '----------------------------------------------------------------------')
	genUtil.nl()

	genUtil.add( 0, '----------------------------------------------------------------------')
	genUtil.add( 0, '-- scene:create( event ) - Called on first scene open ONLY (unless')
	genUtil.add( 0, '-- the scene has been manually or automatically destroyed.)')
	genUtil.add( 0, '----------------------------------------------------------------------')
	genUtil.add( 0, 'function scene:create( event )')
	genUtil.add( 1, 'local sceneGroup = self.view')
	genUtil.nl()

	for i = 1, #scene.onCreate do
		genUtil.add( 1, scene.onCreate[i] )
	end
	if( #scene.onCreate > 0 ) then
		genUtil.nl()
	end




	genUtil.add( 0, 'end')
	genUtil.nl()

	genUtil.add( 0, '----------------------------------------------------------------------')
	genUtil.add( 0, '-- scene:willEnter( event ) - Replaces the scene:show() method.  This')
	genUtil.add( 0, '-- method is called during the "will" phase of scene:show().')
	genUtil.add( 0, '----------------------------------------------------------------------')
	genUtil.add( 0, 'function scene:willEnter( event )')
	genUtil.add( 1, 'local sceneGroup = self.view')
	genUtil.nl()

	genUtil.add( 0, 'end')
	genUtil.nl()

	genUtil.add( 0, '----------------------------------------------------------------------')
	genUtil.add( 0, '-- scene:didShow( event ) - Replaces the scene:show() method.  This')
	genUtil.add( 0, '-- method is called during the "did" phase of scene:show().')
	genUtil.add( 0, '----------------------------------------------------------------------')
	genUtil.add( 0, 'function scene:didShow( event )')
	genUtil.add( 1, 'local sceneGroup = self.view')
	genUtil.nl()
	
	genUtil.add( 0, 'end')
	genUtil.nl()

	genUtil.add( 0, '----------------------------------------------------------------------')
	genUtil.add( 0, '-- scene:willHide( event ) - Replaces the scene:hide() method.  This')
	genUtil.add( 0, '-- method is called during the "will" phase of scene:hide().')
	genUtil.add( 0, '----------------------------------------------------------------------')
	genUtil.add( 0, 'function scene:willHide( event )')
	genUtil.add( 1, 'local sceneGroup = self.view')
	genUtil.nl()

	genUtil.add( 0, 'end')
	genUtil.nl()

	genUtil.add( 0, '----------------------------------------------------------------------')
	genUtil.add( 0, '-- scene:didHide( event ) - Replaces the scene:hide() method.  This')
	genUtil.add( 0, '-- method is called during the "did" phase of scene:hide().')
	genUtil.add( 0, '----------------------------------------------------------------------')
	genUtil.add( 0, 'function scene:didHide( event )')
	genUtil.add( 1, 'local sceneGroup = self.view')
	genUtil.nl()

	genUtil.add( 0, 'end')
	genUtil.nl()

	genUtil.add( 0, '----------------------------------------------------------------------')
	genUtil.add( 0, '-- scene:destroy( event ) - Called automatically by Composer scene library')
	genUtil.add( 0, '-- to destroy the contents of the scene (based on settings and memory constraints):')
	genUtil.add( 0, '-- https://docs.coronalabs.com/daily/api/library/composer/recycleOnSceneChange.html')
	genUtil.add( 0, '--')
	genUtil.add( 0, '-- Also called if you manually call composer.removeScene()')
	genUtil.add( 0, '-- https://docs.coronalabs.com/daily/api/library/composer/removeScene.html')
	genUtil.add( 0, '----------------------------------------------------------------------')
	genUtil.add( 0, 'function scene:destroy( event )')
	genUtil.add( 1, 'local sceneGroup = self.view')
	genUtil.nl()

	genUtil.add( 0, 'end')
	genUtil.nl()

	genUtil.add( 0, '----------------------------------------------------------------------')
	genUtil.add( 0, '--				Custom Scene Functions/Methods')
	genUtil.add( 0, '----------------------------------------------------------------------')
	genUtil.nl()

	genUtil.add( 0, '---------------------------------------------------------------------------------')
	genUtil.add( 0, '-- Scene Dispatch Events, Etc. - Generally Do Not Touch Below This Line')
	genUtil.add( 0, '---------------------------------------------------------------------------------')
	genUtil.nl()

	genUtil.add( 0, '-- This code splits the "show" event into two separate events: willShow and didShow')
	genUtil.add( 0, '-- for ease of coding above.')
	genUtil.add( 0, 'function scene:show( event )')
	genUtil.add( 1, 'local sceneGroup 	= self.view')
	genUtil.add( 1, 'local willDid 	= event.phase')
	genUtil.add( 1, 'if( willDid == "will" ) then')
	genUtil.add( 2, 'self:willEnter( event )')
	genUtil.add( 1, 'elseif( willDid == "did" ) then')
	genUtil.add( 2, 'self:didShow( event )')
	genUtil.add( 1, 'end')
	genUtil.add( 0, 'end')
	genUtil.nl()

	genUtil.add( 0, '-- This code splits the "hide" event into two separate events: willHide and didHide')
	genUtil.add( 0, '-- for ease of coding above.')
	genUtil.add( 0, 'function scene:hide( event )')
	genUtil.add( 1, 'local sceneGroup 	= self.view')
	genUtil.add( 1, 'local willDid 	= event.phase')
	genUtil.add( 1, 'if( willDid == "will" ) then')
	genUtil.add( 2, 'self:willHide( event )')
	genUtil.add( 1, 'elseif( willDid == "did" ) then')
	genUtil.add( 2, 'self:didHide( event )')
	genUtil.add( 1, 'end')
	genUtil.add( 0, 'end')
	genUtil.add( 0, 'scene:addEventListener( "create", scene )')
	genUtil.add( 0, 'scene:addEventListener( "show", scene )')
	genUtil.add( 0, 'scene:addEventListener( "hide", scene )')
	genUtil.add( 0, 'scene:addEventListener( "destroy", scene )')
	genUtil.add( 0, '---------------------------------------------------------------------------------')	
	genUtil.add( 0, 'return scene')
	

	-- ==========================================================
	return genUtil.getContent()
end



return package


