-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
local blackjackTest = {}

local blackjackM = require "scripts.blackjackM"
blackjackM.init()


function blackjackTest.run( group, params )
   group = group or display.currentStage
   params = params or {}

   -- Forward declare labels table for players and house
   local labels = {}
   labels.player = {}


   -- Choose 1 or 2 player (not including house)
   --
   local numPlayers = 2 

   -- Create a game 
   --
   local game = blackjackM.new( numPlayers )

   -- Deal the initial hand
   --
   game:deal()

   -- Draw the initial hand
   --

   -- House
   local hand = game:getCards( 0 )
   labels.house = display.newText( group, "", left + 15, top + 100, nil, 32 )
   labels.house.anchorX = 0
   for i = 1, #hand do
   	table.dump(hand[i],nil,tostring(i))
   	game:drawCard( group, 
   		            centerX - 150 + i * 90, -- x
   		            top + 100, -- y
   		            140, -- width
   		            190, -- height
   		            hand[i] ) -- cardData
   end
   labels.house.text = "House: " .. game:countHand(0)


   -- Players
   for i = 1, numPlayers do
	   local hand = game:getCards( i )
	   labels.player[i] = display.newText( group, "", left + 15, top + 100 + i * 200, nil, 32 )
	   labels.player[i].anchorX = 0
	   for j = 1, #hand do
	   	print("card", j)
	   	table.dump(hand[j],nil,tostring(i))
	   	game:drawCard( group, 
	   		            centerX - 150 + j * 90, -- x
	   		            top + 100 + i * 200, -- y
	   		            140, -- width
	   		            190, -- height
	   		            hand[j] ) -- cardData
	   end
	   labels.player[i].text = "Player #" .. i .. ": " .. game:countHand(i)
	end

	-- Tap handler (tap screen to 'auto' play each player and house)
	--
	local isRunning = true
	local function tap()
		if( isRunning == false ) then return end

		local didHit = false

		-- Hit house?
		if( game:countHand(0) < 17 ) then
			game:hit(0)
			didHit = true

			local cards  = game:getCards( 0 )
	   	
	   	game:drawCard( group, 
	   		            centerX - 150 + #cards * 90, -- x
	   		            top + 100, -- y
	   		            140, -- width
	   		            190, -- height
	   		            cards[#cards] ) -- cardData
	   	if( game:countHand(0) == 21 ) then
	   		labels.house.text = "House: " .. game:countHand(0) .. " (Blackjack)"
	   	elseif( game:countHand(0) > 21 ) then
	   		labels.house.text = "House: " .. game:countHand(0) .. " (Busted)"
	   	else
	   		labels.house.text = "House: " .. game:countHand(0)
	   	end
		end

		-- Hit players?
		for i = 1, numPlayers do
			if( game:countHand(i) < 17 ) then
				game:hit(i)
				didHit = true

				local cards  = game:getCards( i )
		   	
		   	game:drawCard( group, 
		   		            centerX - 150 + #cards * 90, -- x
		   		            top + 100 + i * 200, -- y
		   		            140, -- width
		   		            190, -- height
		   		            cards[#cards] ) -- cardData
		   	if( game:countHand(i) == 21 ) then
		   		labels.player[i].text = "Player #" .. i .. ": " .. game:countHand(i) .. " (Blackjack)"
		   	elseif( game:countHand(i) > 21 ) then
		   		labels.player[i].text = "Player #" .. i .. ": " .. game:countHand(i) .. " (Busted)"
		   	else
		   		labels.player[i].text = "Player #" .. i .. ": " .. game:countHand(i)
		   	end
			end
		end

		if( not didHit ) then 
			print("Game Over")
			ignore( "tap", tap )
			isRunning = false 
			local totals = {}
			totals[0] = game:countHand(0)
			for i = 1, numPlayers do
				totals[i] = game:countHand(i)
			end

			local markedWinner = false

			if( totals[0] == 21 ) then
				-- House won.

			else
				local highest = 0
				for i = 1, numPlayers do
					if( totals[i] < 22 and totals[i] > highest ) then
						highest = totals[i] 
					end
				end

				if( highest == 0 ) then
					-- House won.					
				else
					-- Did a player(s) win?					
					for i = 1, numPlayers do
						if( (totals[0] > 21 or highest > totals[0]) and totals[i] == highest ) then
							labels.player[i].text = labels.player[i].text .. " - WON!"
							markedWinner = true
						end
					end
				end
			end

			if( not markedWinner ) then
				labels.house.text = labels.house.text .. " - WON!"
			end
		end

	end
	listen( "tap", tap )


end

return blackjackTest