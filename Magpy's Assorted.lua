--- STEAMODDED HEADER
--- MOD_NAME: Magpy's Assorted
--- MOD_ID: MASS
--- MOD_AUTHOR: [magpy]
--- MOD_DESCRIPTION: Adds a few Jokers and a deck.
--- DEPENDENCIES: [Steamodded>=1.0.0~ALPHA-0812d]
--- BADGE_COLOR: bada55
--- PREFIX: mass
----------------------------------------------
------------MOD CODE -------------------------

--[[
------------------------------Basic Table of Contents------------------------------
Line 27, Atlas ---------------- Explains the parts of the atlas.
Line 39, Joker 2 -------------- Explains the basic structure of a joker
Line 98, Runner 2 ------------ Uses a bit more complex contexts, and shows how to scale a value.
Line 147, Golden Joker 2 ------ Shows off a specific function that's used to add money at the end of a round.
Line 173, Merry Andy 2 -------- Shows how to use add_to_deck and remove_from_deck.
Line 217, Sock and Buskin 2 --- Shows how you can retrigger cards and check for faces
Line 250, Perkeo 2 ------------ Shows how to use the event manager, eval_status_text, randomness, and soul_pos.
Line 295, Walkie Talkie 2 ----- Shows how to look for multiple specific ranks, and explains returning multiple values
Line 329, Gros Michel 2 ------- Shows the no_pool_flag, sets a pool flag, another way to use randomness, and end of round stuff.
Line 403, Cavendish 2 --------- Shows yes_pool_flag, has X Mult, mainly to go with Gros Michel 2.
]]

--Creates an atlas for cards to use
SMODS.Atlas {
  -- Key for code to find it with
  key = "MASS",
  -- The name of the file, for the code to pull the atlas from
  path = "MASS.png",
  -- Width of each sprite in 1x size
  px = 71,
  -- Height of each sprite in 1x size
  py = 95
}

local create_card_ref = create_card

-- Literally just for the Overlay cards
-- function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
	-- local card = create_card_ref(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
	-- print(card.ability.name)
	-- if card.ability.name == "mass-fOverlay" then
		-- card:set_edition({foil = true}, true)
	-- end
	-- if card.ability.name == "mass-hOverlay" then
		-- card:set_edition({holo = true}, true)
	-- end
	-- if card.ability.name == "mass-pOverlay" then
		-- card:set_edition({polychrome = true}, true)
	-- end
	-- if card.ability.name == "mass-nOverlay" then
		-- card:set_edition({negative = true}, true)
	-- end
	-- return card
-- end

-- local set_ability_ref = Card:set_ability
-- function set_ability(center, initial, delay_sprites)
	-- local result = set_ability_ref(center, initial, delay_sprites)
	-- if result.ability.name == "mass-fOverlay" then
		-- result:set_edition({foil = true}, true)
	-- end
	-- if result.ability.name == "mass-hOverlay" then
		-- result:set_edition({holo = true}, true)
	-- end
	-- if result.ability.name == "mass-pOverlay" then
		-- result:set_edition({polychrome = true}, true)
	-- end
	-- if result.ability.name == "mass-nOverlay" then
		-- result:set_edition({negative = true}, true)
	-- end
-- end

SMODS.Joker {
  key = 'libraryCard',
  loc_txt = {
    name = 'Library Card',
    text = {
      "Gains {X:mult,C:white}X#2#{} Mult",
      "if played hand",
      "contains a {C:attention}Flush{}",
      "and a {C:attention}Wild Card{}",
      "{C:inactive,s:0.8}(Currently {X:mult,C:white,s:0.8}X#1#{C:inactive,s:0.8} Mult)"
    }
  },
  config = { extra = { Xmult = 1, Xmult_gain = 0.1 } },
  rarity = 2,
  atlas = 'MASS',
  pos = { x = 0, y = 0 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.Xmult, card.ability.extra.Xmult_gain } }
  end,
  calculate = function(self, card, context)
	if context.joker_main then
      return {
        message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } },
        Xmult_mod = card.ability.extra.Xmult
      }
    end

    -- context.before checks if context.before == true, and context.before is true when it's before the current hand is scored.
    -- (context.poker_hands['Straight']) checks if the current hand is a 'Straight'.
    -- The 'next()' part makes sure it goes over every option in the table, which the table is context.poker_hands.
    -- context.poker_hands contains every valid hand type in a played hand.
    -- not context.blueprint ensures that Blueprint or Brainstorm don't copy this upgrading part of the joker, but that it'll still copy the added chips.
    if context.before and next(context.poker_hands['Flush']) and not context.blueprint then
	  local flushed = false
	  for k, v in ipairs(context.scoring_hand) do
          if v.config.center ~= G.P_CENTERS.c_base and not v.debuff then
              if v.config.center == G.P_CENTERS.m_mult or v.config.center == G.P_CENTERS.m_wild then
                flushed = true
              end
		  end
	  end
      -- Updated variable is equal to current variable, plus the amount of chips in chip gain.
      -- 1.1 = 1+0.1, 1.2 = 1.1+0.1, 1.3 = 1.2+0.1.
	  if flushed == true then
		card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_gain
		return {
			message = 'Upgraded!',
			colour = G.C.RED,
			card = card
		}
	  end
    end
  end
}

SMODS.Joker {
  key = 'threeCardMonte',
  loc_txt = {
    name = 'Three Card Monte',
    text = {
      "Each played {C:attention}3{}, {C:attention}6{}, {C:attention}9{},",
      "or {C:attention}Queen{} gives {C:mult}+#1#{} Mult when scored",
      "Gains {C:mult}+#2#{} Mult if three or more",
      "of these cards are scored in one hand"
    }
  },
  config = { extra = { mult = 3, mult_gain = 1 , combo = 0} },
  rarity = 2,
  atlas = 'MASS',
  pos = { x = 1, y = 0 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.mult, card.ability.extra.mult_gain, card.ability.extra.combo } }
  end,
  calculate = function(self, card, context)
    -- Combo reset
	if context.before and not context.blueprint then
	  card.ability.extra.combo = 0
	end
    if context.individual and context.cardarea == G.play then
      -- :get_id tests for the rank of the card. Other than 2-10, Jack is 11, Queen is 12, King is 13, and Ace is 14.
      if context.other_card:get_id() == 3 or context.other_card:get_id() == 6 or context.other_card:get_id() == 9 or context.other_card:get_id() == 12 then
        -- Specifically returning to context.other_card is fine with multiple values in a single return value, chips/mult are different from chip_mod and mult_mod, and automatically come with a message which plays in order of return.
        card.ability.extra.combo = card.ability.extra.combo + 1
		if card.ability.extra.combo == 3 then
			card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
			SMODS.eval_this(card, {message = 'Upgraded!',
				colour = G.C.RED})
		end
	  end
		return {
          chips = card.ability.extra.chips,
          mult = card.ability.extra.mult,
          card = context.other_card
		}
	  end
	end
}

SMODS.Joker {
  key = 'swordSwallower',
  loc_txt = {
    name = 'Sword Swallower',
    text = {
      "{C:mult}+#1#{} Mult if played hand is,",
      "{C:attention}exactly{} a {C:attention}High Card{}",
      "If first hand of round",
      "is a {C:attention}High Card{}, {C:chips}+1{} Hand"
    }
  },
  config = { extra = { mult = 5 } },
  rarity = 1,
  atlas = 'MASS',
  pos = { x = 2, y = 0 },
  cost = 4,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.mult} }
  end,
  calculate = function(self, card, context)
    if context.joker_main and next(context.poker_hands['High Card']) and not context.blueprint then
		if G.GAME.current_round.hands_played == 0 then
			ease_hands_played(1)
		end
		return {
			mult_mod = card.ability.extra.mult,
			message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }
		}
    end
  end
}

SMODS.Joker {
  key = 'flowerTrick',
  loc_txt = {
    name = 'Flower Trick',
    text = {
	  "Gains Mult whenever you",
      "gain {C:money}${} from {C:attention}Interest",
      "{C:inactive,s:0.8}(Currently {C:mult,s:0.8}+#1#{C:inactive,s:0.8} Mult)"
    }
  },
  config = { extra = { mult = 0} },
  rarity = 2,
  atlas = 'MASS',
  pos = { x = 3, y = 0 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.mult} }
  end,
  calculate = function(self, card, context)
    -- end of round: gain mult based off of interest
	-- Funny story: G.GAME.interest_amount... is the amount of interest *per 5$.* Fixed now.
	if context.end_of_round and not context.blueprint and not context.repetition and not context.individual then
		card.ability.extra.mult = card.ability.extra.mult + (G.GAME.interest_amount*math.min(math.floor(G.GAME.dollars/5), G.GAME.interest_cap/5))
		SMODS.eval_this(card, {message = 'Upgraded!',
				colour = G.C.RED})
	end
	if context.joker_main then
      return {
        mult_mod = card.ability.extra.mult,
        message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }
      }
    end
  end
}

SMODS.Joker {
  key = 'shippingChart',
  loc_txt = {
    name = 'Shipping Chart',
    text = {
	  "{C:mult}+#1#{} Mult for each {C:attention}different{}",
      "Suit in the scored hand"
    }
  },
  config = { extra = { mult = 5, hearts = 0, diamonds = 0, clubs = 0, spades = 0} },
  rarity = 2,
  atlas = 'MASS',
  pos = { x = 4, y = 0 },
  cost = 7,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.mult, card.ability.extra.hearts, card.ability.extra.diamonds, card.ability.extra.clubs, card.ability.extra.spades} }
  end,
  calculate = function(self, card, context)
	-- Reset!
	if context.before and not context.blueprint then
	  card.ability.extra.hearts = 0
	  card.ability.extra.diamonds = 0
	  card.ability.extra.clubs = 0
	  card.ability.extra.spades = 0
	end
	if context.individual and context.cardarea == G.play then
      -- Checks for each (canon) suit.
      if context.other_card:is_suit("Hearts") then
	    card.ability.extra.hearts = 1
	  end
      if context.other_card:is_suit("Diamonds") then
	    card.ability.extra.diamonds = 1
	  end
      if context.other_card:is_suit("Clubs") then
	    card.ability.extra.clubs = 1
	  end
      if context.other_card:is_suit("Spades") then
	    card.ability.extra.spades = 1
	  end
	end
	if context.joker_main then
      return {
        mult_mod = card.ability.extra.mult * (card.ability.extra.hearts + card.ability.extra.diamonds + card.ability.extra.clubs + card.ability.extra.spades),
        message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }
      }
    end
  end
}

SMODS.Joker {
  key = 'rebirth',
  loc_txt = {
    name = 'Rebirth',
    text = {
	  "Every time you sell {C:attention}2{} Jokers,",
      "gain a {C:black}Negative Tag",
      "{C:inactive,s:0.8}Currently {C:attention,s:0.8}#1#{C:inactive,s:0.8}/2 Jokers sold)"
    }
  },
  config = { extra = { counter = 0} },
  rarity = 3,
  atlas = 'MASS',
  pos = { x = 5, y = 0 },
  cost = 8,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.counter} }
  end,
  calculate = function(self, card, context)
    -- two jokers sold -> one negative tag
	if context.selling_card and context.card.ability.set == "Joker" then
		card.ability.extra.counter = card.ability.extra.counter + 1

		SMODS.eval_this(card, {message = card.ability.extra.counter .. '/2',
				colour = G.C.MONEY})
		-- create Negative tag!
		if card.ability.extra.counter == 2 then
			SMODS.eval_this(card, {message = 'Negative!',
				colour = G.C.BLACK})
			add_tag(Tag("tag_negative"))
			card.ability.extra.counter = 0
		end
	end
  end
}

SMODS.Joker {
  key = 'degenerate',
  loc_txt = {
    name = 'Degenerate',
    text = {
      "{X:mult,C:white} X#1# {} Mult if played hand's",
      "Blackjack score is {C:attention}21{} or less",
      "{C:inactive,s:0.8}(Ace = 1, Jack/Queen/King = 10)"
    }
  },
  config = { extra = { Xmult = 2, blackjack = 0 } },
  rarity = 2,
  atlas = 'MASS',
  pos = { x = 0, y = 1 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.Xmult, card.ability.extra.blackjack } }
  end,
  calculate = function(self, card, context)
    -- Blackjack reset
	if context.before and not context.blueprint then
	  card.ability.extra.blackjack = 0
	end
    if context.individual and context.cardarea == G.play then
      -- :get_id tests for the rank of the card. Other than 2-10, Jack is 11, Queen is 12, King is 13, and Ace is 14.
	  if card.ability.extra.blackjack < 22 then
		-- Face cards are 10s in Blackjack.
		if context.other_card:get_id() == 11 or context.other_card:get_id() == 12 or context.other_card:get_id() == 13 then
			-- Specifically returning to context.other_card is fine with multiple values in a single return value, chips/mult are different from chip_mod and mult_mod, and automatically come with a message which plays in order of return.
			card.ability.extra.blackjack = card.ability.extra.blackjack + 10
	    end
		-- Aces are either 1s or 11s in Blackjack, though we're not playing with a dealer, so they're always 1s.
		if context.other_card:get_id() == 14 then
			-- Specifically returning to context.other_card is fine with multiple values in a single return value, chips/mult are different from chip_mod and mult_mod, and automatically come with a message which plays in order of return.
			card.ability.extra.blackjack = card.ability.extra.blackjack + 1
	    end
		-- Everything else.
		if context.other_card:get_id() < 11 then
			-- Specifically returning to context.other_card is fine with multiple values in a single return value, chips/mult are different from chip_mod and mult_mod, and automatically come with a message which plays in order of return.
			card.ability.extra.blackjack = card.ability.extra.blackjack + context.other_card:get_id()
	    end
		SMODS.eval_this(card, {message = card.ability.extra.blackjack .. "/21",
				colour = G.C.RED})
		if card.ability.extra.blackjack > 21 then
			SMODS.eval_this(card, {message = "Bust!",
				colour = G.C.BLACK})
	    end
	  end
	end
    if context.joker_main and card.ability.extra.blackjack < 22 then
      return {
        message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } },
        Xmult_mod = card.ability.extra.Xmult
      }
    end
  end
}


SMODS.Joker {
  key = 'superEnergy',
  loc_txt = {
    name = 'Super Energy',
    text = {
      "Create a {C:tarot}Strength{} when",
      "{C:attention}Blind{} is selected",
      "{C:inactive,s:0.8}(Increases rank of up to {C:attention,s:0.8}2{}",
	  "{C:inactive,s:0.8}selected cards by {C:attention,s:0.8}1{C:inactive,s:0.8})"
    }
  },
  config = { extra = {} },
  rarity = 2,
  atlas = 'MASS',
  pos = { x = 1, y = 1 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = {} }
  end,
  calculate = function(self, card, context)
	if context.setting_blind and not (context.blueprint_card or card).getting_sliced then
		local card = create_card("Tarot", G.consumeables, nil, nil, nil, nil, "c_strength", "deck")
		card:add_to_deck()
		G.consumeables:emplace(card)
		return true
	end
  end
}

SMODS.Joker {
  name = "mass-fOverlay",
  key = 'foilOverlay',
  loc_txt = {
    name = 'Foil Overlay',
    text = {
			"{C:attention}ALWAYS {C:dark_edition}Foil{}",
			"After two rounds, sell to make the",
			"leftmost editionless Joker {C:dark_edition}Foil{}",
			"{C:inactive,s:0.8}(Currently {C:attention,s:0.8}#1#{C:inactive,s:0.8}/2)",
    }
  },
  config = { extra = {counter = 0} },
  rarity = 1,
  atlas = 'MASS',
  pos = { x = 2, y = 1 },
  cost = 4,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.counter } }
  end,
  calculate = function(self, card, context)
	if context.end_of_round and not context.blueprint and not context.repetition and not context.individual then
		if card.ability.extra.counter < 2 then
			card.ability.extra.counter = card.ability.extra.counter + 1
			SMODS.eval_this(card, {message = card.ability.extra.counter .. "/2",
				colour = G.C.DARK_EDITION})
			if card.ability.extra.counter == 2 then
				SMODS.eval_this(card, {message = "Ready!",
					colour = G.C.DARK_EDITION})
			end
		end
	end
	-- leftmost becomes foil
	if context.selling_self and card.ability.extra.counter == 2 and not (context.retrigger_joker or context.blueprint) then
		local eligiblejokers = {}
		for k, v in pairs(G.jokers.cards) do
			if v.ability.set == "Joker" and not v.edition and v ~= card then
				table.insert(eligiblejokers, v)
			end
		end
		if #eligiblejokers > 0 then
			local over = false --wof code
			local eligible_card = eligiblejokers[1]
			local edition = { polychrome = true }
			eligible_card:set_edition(edition, true)
			check_for_unlock({ type = "have_edition" })
		end
	end
  end,
  set_ability = function(self, card, initial, delay_sprites)
    card:set_edition({foil = true}, true)
  end
}

SMODS.Joker {
  name = "mass-hOverlay",
  key = 'holographicOverlay',
  loc_txt = {
    name = 'Holographic Overlay',
    text = {
			"{C:attention}ALWAYS {C:dark_edition}Holographic{}",
			"After two rounds, sell to make the",
			"leftmost editionless Joker {C:dark_edition}Holographic{}",
			"{C:inactive,s:0.8}(Currently {C:attention,s:0.8}#1#{C:inactive,s:0.8}/2)",
    }
  },
  config = { extra = {counter = 0} },
  rarity = 2,
  atlas = 'MASS',
  pos = { x = 2, y = 1 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.counter } }
  end,
  calculate = function(self, card, context)
	if context.end_of_round and not context.blueprint and not context.repetition and not context.individual then
		if card.ability.extra.counter < 2 then
			card.ability.extra.counter = card.ability.extra.counter + 1
			SMODS.eval_this(card, {message = card.ability.extra.counter .. "/2",
				colour = G.C.DARK_EDITION})
			if card.ability.extra.counter == 2 then
				SMODS.eval_this(card, {message = "Ready!",
					colour = G.C.DARK_EDITION})
			end
		end
	end
	-- leftmost becomes foil
	if context.selling_self and card.ability.extra.counter == 2 and not (context.retrigger_joker or context.blueprint) then
		local eligiblejokers = {}
		for k, v in pairs(G.jokers.cards) do
			if v.ability.set == "Joker" and not v.edition and v ~= card then
				table.insert(eligiblejokers, v)
			end
		end
		if #eligiblejokers > 0 then
			local over = false --wof code
			local eligible_card = eligiblejokers[1]
			local edition = { holo = true }
			eligible_card:set_edition(edition, true)
			check_for_unlock({ type = "have_edition" })
		end
	end
  end,
  set_ability = function(self, card, initial, delay_sprites)
    card:set_edition({holo = true}, true)
  end
}

SMODS.Joker {
  name = "mass-pOverlay",
  key = 'polychromeOverlay',
  loc_txt = {
    name = 'Polychrome Overlay',
    text = {
			"{C:attention}ALWAYS {C:dark_edition}Polychrome{}",
			"After two rounds, sell to make the",
			"leftmost editionless Joker {C:dark_edition}Polychrome{}",
			"{C:inactive,s:0.8}(Currently {C:attention,s:0.8}#1#{C:inactive,s:0.8}/2)",
    }
  },
  config = { extra = {counter = 0} },
  rarity = 3,
  atlas = 'MASS',
  pos = { x = 2, y = 1 },
  cost = 8,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.counter } }
  end,
  calculate = function(self, card, context)
	if context.end_of_round and not context.blueprint and not context.repetition and not context.individual then
		if card.ability.extra.counter < 2 then
			card.ability.extra.counter = card.ability.extra.counter + 1
			SMODS.eval_this(card, {message = card.ability.extra.counter .. "/2",
				colour = G.C.DARK_EDITION})
			if card.ability.extra.counter == 2 then
				SMODS.eval_this(card, {message = "Ready!",
					colour = G.C.DARK_EDITION})
			end
		end
	end
	-- leftmost becomes foil
	if context.selling_self and card.ability.extra.counter == 2 and not (context.retrigger_joker or context.blueprint) then
		local eligiblejokers = {}
		for k, v in pairs(G.jokers.cards) do
			if v.ability.set == "Joker" and not v.edition and v ~= card then
				table.insert(eligiblejokers, v)
			end
		end
		if #eligiblejokers > 0 then
			local over = false --wof code
			local eligible_card = eligiblejokers[1]
			local edition = { polychrome = true }
			eligible_card:set_edition(edition, true)
			check_for_unlock({ type = "have_edition" })
		end
	end
  end,
  set_ability = function(self, card, initial, delay_sprites)
    card:set_edition({polychrome = true}, true)
  end
}

SMODS.Joker {
  name = "mass-nOverlay",
  key = 'negativeOverlay',
  loc_txt = {
    name = 'Negative Overlay',
    text = {
			"{C:attention}ALWAYS {C:dark_edition}Negative{}",
			"After two rounds, sell to make the",
			"leftmost editionless Joker {C:dark_edition}Negative{}",
			"{C:inactive,s:0.8}(Currently {C:attention,s:0.8}#1#{C:inactive,s:0.8}/2)",
    }
  },
  config = { extra = {counter = 0} },
  rarity = 3,
  atlas = 'MASS',
  pos = { x = 2, y = 1 },
  cost = 8,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.counter } }
  end,
  calculate = function(self, card, context)
	if context.end_of_round and not context.blueprint and not context.repetition and not context.individual then
		if card.ability.extra.counter < 2 then
			card.ability.extra.counter = card.ability.extra.counter + 1
			SMODS.eval_this(card, {message = card.ability.extra.counter .. "/2",
				colour = G.C.DARK_EDITION})
			if card.ability.extra.counter == 2 then
				SMODS.eval_this(card, {message = "Ready!",
					colour = G.C.DARK_EDITION})
			end
		end
	end
	-- leftmost becomes foil
	if context.selling_self and card.ability.extra.counter == 2 and not (context.retrigger_joker or context.blueprint) then
		local eligiblejokers = {}
		for k, v in pairs(G.jokers.cards) do
			if v.ability.set == "Joker" and not v.edition and v ~= card then
				table.insert(eligiblejokers, v)
			end
		end
		if #eligiblejokers > 0 then
			local over = false --wof code
			local eligible_card = eligiblejokers[1]
			local edition = { negative = true }
			eligible_card:set_edition(edition, true)
			check_for_unlock({ type = "have_edition" })
		end
	end
  end,
  set_ability = function(self, card, initial, delay_sprites)
    card:set_edition({negative = true}, true)
  end
}

SMODS.Joker {
  key = 'jokersBest',
  loc_txt = {
    name = 'Joker\'s Best',
    text = {
      "Gains {C:mult}+#2#{} Mult if played hand contains a {C:attention}Pair{}",
      "Gains {C:mult}+#3#{} more Mult if played hand contains a {C:attention}Three of a Kind{}",
      "Gains {C:mult}+#4#{} more Mult if played hand contains a {C:attention}Four of a Kind{}",
      "Gains {C:mult}+#5#{} more Mult if played hand contains a {C:attention}Five of a Kind{",
      "{C:inactive,s:0.8}(Currently {C:mult,s:0.8}+#1#{C:inactive,s:0.8} Mult)"
    }
  },
  config = { extra = { mult = 0, pair_gain = 1, three_gain = 1, four_gain = 2, five_gain = 3, } },
  rarity = 2,
  atlas = 'MASS',
  pos = { x = 3, y = 1 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.mult, card.ability.extra.pair_gain, card.ability.extra.three_gain, card.ability.extra.four_gain, card.ability.extra.five_gain } }
  end,
  calculate = function(self, card, context)
	if context.joker_main then
      return {
        message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } },
        Xmult_mod = card.ability.extra.mult
      }
    end

    -- context.before checks if context.before == true, and context.before is true when it's before the current hand is scored.
    -- (context.poker_hands['Straight']) checks if the current hand is a 'Straight'.
    -- The 'next()' part makes sure it goes over every option in the table, which the table is context.poker_hands.
    -- context.poker_hands contains every valid hand type in a played hand.
    -- not context.blueprint ensures that Blueprint or Brainstorm don't copy this upgrading part of the joker, but that it'll still copy the added chips.
    if context.before and not context.blueprint then
	  if next(context.poker_hands['Pair']) then
		card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.pair_gain
	  end
	  if next(context.poker_hands['Three of a Kind']) then
		card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.three_gain
	  end
	  if next(context.poker_hands['Four of a Kind']) then
		card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.four_gain
	  end
	  if next(context.poker_hands['Five of a Kind']) then
		card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.five_gain
	  end
	return {
		message = 'Upgraded!',
		colour = G.C.RED,
		card = card
	}
    end
  end
}

SMODS.Joker {
  key = 'empowered',
  loc_txt = {
    name = 'Empowered',
    text = {
      "Retrigger all {C:attention}Bonus{}",
      "and {C:attention}Mult{} cards"
    }
  },
  config = {},
  rarity = 1,
  atlas = 'MASS',
  pos = { x = 4, y = 1 },
  cost = 5,
  loc_vars = function(self, info_queue, card)
    return { vars = {} }
  end,
 calculate = function(self, card, context)
		--Replay the bonus and mult cards!
		if context.repetition then
			if context.cardarea == G.play then
				if SMODS.has_enhancement(context.other_card, 'm_bonus') or SMODS.has_enhancement(context.other_card, 'm_mult') then
					return {
						message = localize("k_again_ex"),
						repetitions = 1,
						card = card,
					}
				end
			end
		end
	end,
	in_pool = function(self, args)
        for k, v in pairs(G.playing_cards) do
            if SMODS.has_enhancement(v, 'm_bonus') or SMODS.has_enhancement(v, 'm_mult') then
                return true
            end
        end

        return false
    end
}

SMODS.Joker {
  key = 'keepGambling',
  loc_txt = {
    name = 'Keep Gambling',
    text = {
      "Retrigger played cards",
      "of rank {C:attention}#2#{} or lower",
      "Levels up at end of round"
    }
  },
  config = { extra = { level = 1, level_text = "Ace"} },
  rarity = 1,
  atlas = 'MASS',
  pos = { x = 5, y = 1 },
  cost = 5,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.level, card.ability.extra.level_text} }
  end,
  calculate = function(self, card, context)
  -- Repeat code
	if context.repetition then
		if context.cardarea == G.play then
			-- Sneaky tech. Aces are... actually rank 14! But they're supposed to be rank 1...
			if context.other_card:get_id() == 14 then
				return {
					message = localize("k_again_ex"),
					repetitions = 1,
					card = card,
				}
			end
			if context.other_card:get_id() < (card.ability.extra.level + 1) then
				return {
					message = localize("k_again_ex"),
					repetitions = 1,
					card = card,
				}
			end
		end
	end
	-- Scaling code
	if context.end_of_round and not context.blueprint and not context.repetition and not context.individual then
		if card.ability.extra.level < 13 then
			card.ability.extra.level = card.ability.extra.level + 1
			card.ability.extra.level_text = card.ability.extra.level
			if card.ability.extra.level == 11 then
				card.ability.extra.level_text = "Jack"
			end
			if card.ability.extra.level == 12 then
				card.ability.extra.level_text = "Queen"
			end
			if card.ability.extra.level == 13 then
				card.ability.extra.level_text = "King"
			end
			SMODS.eval_this(card, {message = 'Level up!',
				colour = G.C.RED})
		end
	end
  end
}

-- Decks!
SMODS.Back{
	name = "Alchemical Deck",
	key = "MASS_alchemical",
	pos = {x = 6, y = 0},
	config = {},
	atlas = 'MASS',
	loc_txt = {
		name = "Alchemical Deck",
		text ={
			"Start with an {C:tarot}Eternal {C:attention}Rebirth",
			"{C:inactive,s:0.8}(Every time you sell {C:attention,s:0.8}2{C:inactive,s:0.8} Jokers,",
			"{C:inactive,s:0.8}gain a {C:black,s:0.8}Negative Tag{C:inactive,s:0.8})"
		},
    },
	apply = function()
		G.GAME.joker_buffer = G.GAME.joker_buffer + 1
		G.E_MANAGER:add_event(Event(
			{trigger = 'after', delay = 0.8, func = function()
				if G.jokers then
					local card = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_mass_rebirth", nil)
					card:add_to_deck()
					card:start_materialize()
					card:set_eternal(true)
					G.jokers:emplace(card)
					G.GAME.joker_buffer = 0
					return true
				end
			end
		}))
	end
}

SMODS.Back{
	name = "Unstable Deck",
	key = "MASS_unstable",
	pos = {x = 6, y = 1},
	config = {discards = -1},
	atlas = 'MASS',
	loc_txt = {
		name = "Unstable Deck",
		text ={
			"All hands start at {C:attention}LVL 2",
			"{C:mult}#1#{} Discard"
		},
    },
	apply = function(self)
		G.GAME.joker_buffer = G.GAME.joker_buffer + 1
		G.E_MANAGER:add_event(Event(
			{trigger = 'after', delay = 0.8, func = function()
				if G.jokers then
				-- switch G.jokers for appropriate start of game effect?
					for k, v in pairs(G.GAME.hands) do
						level_up_hand(self, k, true)
					end
					return true
				end
			end
		}))
	end,
    loc_vars = function(self)
		return { vars = { self.config.discards }}
	end
}

----------------------------------------------
------------MOD CODE END----------------------
