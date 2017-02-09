-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
local cardTest = {}

local cardsM = require "scripts.cardsM"
cardsM.init() 


function cardTest.run( group, params )
   group = group or display.currentStage
   params = params or {}  
  

   local deck = cardsM.new( 2 )

	deck:shuffle()

	local cards = {}
	for i = 1, 5 do
		local cardData = deck:take()
		local card = cardsM.drawCard( group, 
			                       		left + 80 + (i-1) * 160, 
			                       		centerY,
			                       		cardData,
			                       		deck,
			                       		{ w = 140, h = 190, showFace = false } )
		cards[i] = card
		print( deck:getCounts() )
	end

	for i = 1, #cards do
		timer.performWithDelay( i * 500, 
			function() 
				cards[i]:flip()
				print( print(cards[i]:rank() .. " of " .. cards[i]:suit() ) )
			end )
	end

	for i = 1, #cards do
		timer.performWithDelay( #cards * 500 + i * 100, 
			function() 
				cards[i]:flip()
			end )
	end

	--[[
	print(cards[2]:isFaceUp())
	cards[2]:flip()
	print(cards[2]:isFaceUp())
	print(cards[2]:suit())
	print(cards[2]:rank())
	--]]

	--[[
	for i = 1, #cards do
		cards[i]:destroy()
	end
	print( deck:getCounts() )
	--]]


end

return cardTest