-- =============================================================
-- Copyright Roaming Gamer, LLC. 2009-2017
-- =============================================================
local blackjackM = {}

local cardsM = require( "scripts.cardsM" )	

local reset
local deal
local hit
local getCards
local drawCard
local countHand

-- =============================================================
-- blackjackM.init( cardsPath ) - Sets path to card images.
-- =============================================================
function blackjackM.init( cardsPath )
	cardsM.init( cardsPath )
end

-- =============================================================
-- cardsM.init( params ) - Initialize Module
-- =============================================================
function blackjackM.new( numPlayers, numDecks )
	numPlayers 	= numPlayers or 1 
	numDecks 	= numDecks or 1

	-- Generate a new 'game' object
	--
	local game = {}
	game.numPlayers 	= numPlayers
	game.numDecks 		= numDecks

	-- Get a clean deck of cards and shuffle it
	game.cards = cardsM.new( numDecks )
   game.cards:shuffle()

   -- Create seats for the players
   --
   game.house = {}
   game.player = {}
   for i = 1, numPlayers do
   	game.player[i] = {}
   end

   -- Attach methods
   game.reset 		= reset
   game.deal 		= deal
   game.hit 		= hit
   game.getCards 	= getCards
   game.drawCard 	= drawCard
   game.countHand	= countHand

	table.dump(game)

	return game
end

-- 
-- drawCard( group, x, y, width, height, cardData ) - Draw a card.
--
-- Returns the card display object.
--
drawCard = function( self, group, x, y, width, height, cardData )
	local card = cardsM.drawCard( group, x, y, cardData, self.cards,
			                        { w = width, h = height, 
			                          showFace = true } )
	return card
end

-- 
-- getCards( from, number ) - Get a card or cards from the house or players
--
--   from: 0 (house), 1 (player 1), 2 (player 2), ...
-- number: nil or 0 (all cards); 1 (first card); 2 (second card);
--             -1 (last card), -2 (last two cards)
--
--
getCards = function( self, from, number )
	from = from or 0
	number = number or 0

	local hand = (from == 0) and self.house or self.player[from]

	if( number == 0 ) then		
		return table.deepCopy( hand )
	
	elseif( number > 0 ) then
		-- Requested beyond end of card stack.  Return last card
		if( number > #hand ) then
			return table.deepCopy( hand[#hand] )
		else		
			return table.deepCopy( hand[number] )
		end

	else

		-- Requested more than total cards in hand, just return all
		if( math.abs(number) > #hand ) then
			return table.deepCopy( hand )
		else
			-- Just requesting last card
			if( math.abs(number) == 1 ) then
				return table.deepCopy( hand[#hand] )

			-- Return table of last N cards
			else
				local partialHand = {}
				for i = #hand + number + 1, #hand do
					partialHand[#partialHand+1] = table.deepCopy( hand[i] )
				end
				return partialHand
			end
		end
	end
end

-- reset( shuffle ) - Clear the all prior cards from the house and player seats
--
--   shuffle - If set to 'true' will also shuffle cards.
--
reset = function( self )
	for i = 1, #self.house do
		self.house[i]:destroy()
	end
	for i = 1, self.numPlayers do
		for j = 1, #self.player[i] do
			self.player[i][j]:destroy()
		end
	end

	if( shuffle ) then
		self.cards:shuffle()
	end
end

--
-- Deal the initial hands to house and all players
-- 
deal = function( self )
	-- Clear the all prior cards from the house and player seats
	--
	self:reset()

	for i = 1, 2 do
		for j = 0, self.numPlayers do
			-- Deal the house a card (always first in sequence)
			--
			if( j == 0 ) then
				self.house[i] = self.cards:take( true )

			-- Deal players in order
			--				
			else
				self.player[j][i] = self.cards:take( true )
			end
		end
	end

	print(self.cards:getCounts())
end


--
-- hit( seatNum ) - Deal a new card to the requested seat.
--
--   seatNum - 0 (house); 1 (player 1); 2 (player 2); ... 
-- 
hit = function( self, seatNum )
	seatNum = seatNum or 0

	-- Deal the house a card
	if( seatNum == 0 ) then
		self.house[#self.house+1] = self.cards:take( true )

	-- Deal player a card
	--				
	else
		self.player[seatNum][#self.player[seatNum]+1] = self.cards:take( true )
	end

end

-- countHand( hand) Return the value of a hand using the best values for Aces.
-- 
-- hand - 0 (dealer); 1 (player 1); 2 (player 2); ...
--
countHand = function( self, handNum )
	handNum = handNum or 0
	local hand = (handNum == 0) and self.house or self.player[handNum]

	local values = {}
	local aceCount = 0
	for i = 1, #hand do		
		local card = hand[i]
		local rank = card.rank
		if( tonumber(rank) ~= nil ) then
			values[#values+1] = tonumber(rank)
		elseif( rank == "J" or rank == "Q" or rank == "K" ) then
			values[#values+1] = 10
		else
			aceCount = aceCount + 1
			values[#values+1] = 11
		end
	end

	local total = 0

	for i = 1, #values do
		total = total + values[i]
	end

	while( total > 21 and aceCount > 0 ) do
		--print("Ace count:", aceCount)
		total = 0
		aceCount = aceCount - 1
		local found = false
		local i = 1
		while( not found and i <= #values ) do
			if(values[i] == 11) then
				found = true
				values[i] = 1
				--print("Fixed")
			end
			i = i +1
		end
		for i = 1, #values do
			total = total + values[i]
		end
	end

	return total
end

return blackjackM
