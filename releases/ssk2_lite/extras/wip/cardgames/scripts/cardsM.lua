-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
local cardsM = {}

-- =============================================================
-- cardsM.init( params ) - Initialize Module
-- =============================================================
cardsM.cardsPath = "images/cards"
local singleDeck
function cardsM.init( cardsPath )
	cardsM.cardsPath = cardsPath or cardsM.cardsPath
	-- Build A French Deck (w/o Jokers)
	singleDeck = {}
	local suits = { "Clubs", "Diamonds", "Hearts", "Spades" }
	local ranks = { '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A' }
	for i = 1, #suits do
		for j = 1, #ranks do
			singleDeck[#singleDeck+1] = 
			{ 
				fileName = "card" .. suits[i] .. ranks[j] .. ".png",
				suit = suits[i],
				rank = ranks[j],
			}
		end
	end
	--table.print_r(singleDeck)
end

-- =============================================================
-- cardsM.new( numDecks ) - Create a new set of cards containing the
-- equivalent of one or more decks of cards.
-- =============================================================
function cardsM.new( numDecks )
	numDecks = numDecks or 1
   
   -- Blank 'deck' as shuffle bag
   local deck = ssk.shuffleBag.new()
   
   -- Add cards to the bag
   for i = 1, numDecks do
   	for j = 1, #singleDeck do
   		deck:insert( table.deepCopy(singleDeck[j] ) )
   	end
   end

   return deck
end

-- =============================================================
-- cardsM.new( numDecks ) - Render a card.
-- =============================================================
function cardsM.drawCard( group, x, y, cardData, deck, params )
	local width 	= params.w or 140
	local height 	= params.h or 190

	local card = display.newRect( group, x, y, width, height )
	card._isFaceUp = false	

	card.fill = { type = "image", filename = cardsM.cardsPath .. "/back.png" }

	-- Returns 'true' if card face is showing.
	--
	function card.isFaceUp( self )
		return card._isFaceUp
	end

	-- Helper that returns the suit of the card
	--
	function card.suit( self )
		return cardData.suit
	end

	-- Helper that returns the rank of the card
	--
	function card.rank( self )
		return cardData.rank
	end


	-- Remove the display object and put the card back in the deck
	--
	function card.destroy( self )
		deck:putBack( cardData )
		display.remove(self)
	end

	-- Flips card exposing face or showing back of card
	function card.flip( self )
		card._isFaceUp =  not card._isFaceUp
		if( card._isFaceUp ) then
			card.fill = { type = "image", filename = cardsM.cardsPath .. "/" .. cardData.fileName }
		else
			card.fill = { type = "image", filename = cardsM.cardsPath .. "/back.png" }
		end
	end

	if( params.showFace ) then
		card:flip()
	end

	return card
end


return cardsM