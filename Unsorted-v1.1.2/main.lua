--- STEAMODDED HEADER
--- MOD_NAME: Unsorted
--- MOD_ID: unsorted
--- MOD_AUTHOR: [Telbone]
--- MOD_DESCRIPTION: A vanilla-style mod that introduces cards based on other card types
--- BADGE_COLOUR: dab772
--- PREFIX: Unsorted
----------------------------------------------
------------MOD CODE -------------------------

to_big = to_big or function(a)
  return a
end

to_number = to_number or function(a)
   return a
end

function is_in(table, item)
   for k, v in pairs(table) do
      if v == item then return true end
   end
   return false
end

SMODS.Atlas{
	key = 'atlas1',
	path = 'atlas1.png',
	px = 71,
	py = 95
}

SMODS.Atlas{
	key = 'atlasTarots',
	path = 'atlasTarots.png',
	px = 71,
	py = 95
}

SMODS.Atlas{
	key = 'atlasEnhancements',
	path = 'atlasEnhancements.png',
	px = 71,
	py = 95
}

--Foolish Joker
SMODS.Joker{
	key = 'j_foolish',
	loc_txt = {
		name = 'Foolish Joker',
		text = {
			'{C:green}#1# in #2#{} chance to create an',
			'extra random {C:attention}Consumeable{} when ',
			'a {C:tarot}Fool{} card is used',
			'{C:inactive}(Must have room){}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 2, y = 1},
	config = { extra = {
		odds = 2
	}},
	rarity = 2,
	cost = 4,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	loc_vars = function(self,info_queue,center)
	  info_queue[#info_queue+1] = {key = 'c_fool', set = 'Tarot'}
	  return {vars = {G.GAME.probabilities.normal,
	                  center.ability.extra.odds}}
	end,
	calculate = function(self,card,context)
	 if context.using_consumeable and context.consumeable.ability.name == 'The Fool' then
	  if pseudorandom('foolish') < G.GAME.probabilities.normal / card.ability.extra.odds then
         if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
             G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
             G.E_MANAGER:add_event(Event({
                        trigger = 'before',
                        delay = 0.0,
                        func = (function()
                                local card = create_card('Consumeables',G.consumeables, nil, nil, nil, nil, nil, 'foolish')
                                card:add_to_deck()
                                G.consumeables:emplace(card)
                                G.GAME.consumeable_buffer = 0
								card:juice_up(0.5, 0.5)
                            return true
                        end)}))
		    return{
			   card = card,
			   message = localize('k_plus_tarot'),
			   colour = G.C.PURPLE
		    }
		 end
	  end
	 end
    end
}

--Magic Show
SMODS.Joker{
	key = 'j_magic',
	loc_txt = {
		name = 'Magic Show',
		text = {
			'Played {C:attention}Lucky{} and {C:attention}Trick{} cards',
			'have a {C:green}#1# in #2#{} chance to',
			'give {X:mult,C:white}X#3#{} Mult when scored'
		}
	},
	atlas = 'atlas1',
	pos = {x = 6, y = 1},
	config = { extra = {
		odds = 4,
		Xmult = 2.5
	}},
	rarity = 3,
	cost = 7,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	loc_vars = function(self,info_queue,center)
	  info_queue[#info_queue+1] = G.P_CENTERS.m_lucky
	  info_queue[#info_queue+1] = G.P_CENTERS.m_Unsorted_trick
	  return {vars = {G.GAME.probabilities.normal,
	                  center.ability.extra.odds,
	                  center.ability.extra.Xmult}}
	end,
	calculate = function(self,card,context)
	   if context.individual and context.cardarea == G.play and (context.other_card.ability.name == 'Lucky Card' or context.other_card.ability.name == 'Trick Card') then
	      if pseudorandom('magic') < G.GAME.probabilities.normal / card.ability.extra.odds then
		     return{
				card = card,
				x_mult = card.ability.extra.Xmult
			}
		  end
	   end
    end
}

--Solar Flair
SMODS.Joker{
	key = 'j_flair',
	loc_txt = {
		name = 'Solar Flair',
		text = {
			'Destroys all held {C:planet}Planet{} cards for',
			'played {C:attention}Poker Hand{}, gains',
			'{X:mult,C:white}X#1#{} Mult for each {C:planet}Planet{}',
			'card destroyed this way',
			'{C:inactive}(Currently{} {X:mult,C:white}X#2#{} {C:inactive}Mult){}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 1, y = 1},
	config = { extra = {
		Xmult_mod = 0.3,
		Xmult = 1
	}},
	rarity = 3,
	cost = 9,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	loc_vars = function(self,info_queue,center)
	  return {vars = {center.ability.extra.Xmult_mod,
	                  center.ability.extra.Xmult}}
	end,
	calculate = function(self,card,context)
	  if context.before and not context.blueprint then
		local planet_dest = false
	    for i=1, #G.consumeables.cards do
		 local planet
	     if G.consumeables.cards[i].ability.consumeable.hand_type == context.scoring_name then
		  planet = G.consumeables.cards[i]
		  card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_mod
		  planet_dest = true
		  G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot1')
                        planet.T.r = -0.2
                        planet:juice_up(0.3, 0.4)
                        planet.states.drag.is = true
                        planet.children.center.pinch.x = true
                        planet:start_dissolve()
                        planet = nil
                        delay(0.3)
                        return true
                    end
          }))
	     end
		end
		if planet_dest then
		card_eval_status_text((card), 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_xmult', vars = {card.ability.extra.Xmult}}})
		end
	  elseif context.joker_main and card.ability.extra.Xmult > 1 then
	  return{
			card = card,
		  Xmult_mod = card.ability.extra.Xmult,
		  message = 'X' .. card.ability.extra.Xmult .. ' Mult',
		  colour = G.C.RED
		}
	  end
    end
}

--Impressive Joker
SMODS.Joker{
	key = 'j_impressive',
	loc_txt = {
		name = 'Impressive Joker',
		text = {
			'{C:mult}+#1#{} Mult every time a {C:attention}Mult Card{}',
			'is scored, {C:mult}-#2#{} Mult every time',
			'a {C:attention}non-Mult Card{} is scored',
			'{C:inactive}(Currently{} {C:mult}+#3#{} {C:inactive}Mult){}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 6, y = 2},
	config = { extra = {
		mult_mod = 4,
		non_mult_mod = 1,
		mult = 0
	}},
	rarity = 1,
	cost = 4,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	loc_vars = function(self,info_queue,center)
	info_queue[#info_queue+1] = G.P_CENTERS.m_mult
	  return {vars = {
	                  center.ability.extra.mult_mod,
	                  center.ability.extra.non_mult_mod,
	                  center.ability.extra.mult}}
	end,
	calculate = function(self,card,context)
	   if context.individual and not context.blueprint and context.cardarea == G.play then
	      if context.other_card.ability.effect == 'Mult Card' then
		     card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
			 return{
				 extra = {focus = card, message = localize('k_upgrade_ex')},
                            card = card,
                            colour = G.C.RED
			 }
		  else
		     if to_big(card.ability.extra.mult) > to_big(0) then
		       card.ability.extra.mult = card.ability.extra.mult - card.ability.extra.non_mult_mod
		     end
			 return{
				            extra = {focus = card, message = '-' .. card.ability.extra.non_mult_mod .. ' Mult'},
                            card = card,
                            colour = G.C.RED
			 }
		  end
	   elseif context.joker_main then
			 return{
				 card = card,
				 mult_mod = card.ability.extra.mult,
				 message = '+' .. card.ability.extra.mult .. ' Mult',
				 colour = G.C.RED
			 }
	   end
    end
}

--The Empire
SMODS.Joker{
	key = 'j_empire',
	loc_txt = {
		name = 'The Empire',
		text = {
			'Gains {C:chips}+#1#{} chips every time an',
			'{C:tarot}Emperor{} card is used',
			'{C:inactive}(Currently{} {C:chips}+#2#{} {C:inactive}chips){}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 5, y = 1},
	config = { extra = {
		chip_mod = 30,
		chips = 0
	}},
	rarity = 1,
	cost = 4,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	loc_vars = function(self,info_queue,center)
	  info_queue[#info_queue+1] = {key = 'c_emperor', set = 'Tarot'}
	  return {vars = {center.ability.extra.chip_mod,
	                  center.ability.extra.chips}}
	end,
	calculate = function(self,card,context)
	   if context.using_consumeable and context.consumeable.ability.name == 'The Emperor' then
	      card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
			   G.E_MANAGER:add_event(Event({
                    func = function() card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_chips',vars={card.ability.extra.chips}}}); return true
                    end}))
                return
		    
	   elseif context.joker_main then
	   return{
			   card = card,
			   chip_mod = card.ability.extra.chips,
			   message = '+' .. card.ability.extra.chips,
			   colour = G.C.CHIPS
		    }
		end
    end
}

--Jackpot!
SMODS.Joker{
	key = 'j_jackpot',
	loc_txt = {
		name = 'Jackpot!',
		text = {
			'{C:green}#1# in #2#{} chance for {X:red,C:white}X#3#{} Mult,',
			'increase {C:green}probability{} by {C:attention}1{} every time',
			'a {C:attention}Bonus Card{} or {C:attention}7{} is scored',
			'{C:inactive,s:0.8}Resets after hand is played{}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 5, y = 2},
	config = { extra = {
		odds1 = 1,
		odds2 = 7,
		Xmult = 3.5
	}},
	rarity = 2,
	cost = 7,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	loc_vars = function(self,info_queue,center)
	info_queue[#info_queue+1] = G.P_CENTERS.m_bonus
	  return {vars = {
	                  center.ability.extra.odds1*G.GAME.probabilities.normal,
	                  center.ability.extra.odds2,
	                  center.ability.extra.Xmult}}
	end,
	calculate = function(self,card,context)
	   if context.individual and not context.blueprint and context.cardarea == G.play then
	      if context.other_card.ability.effect == 'Bonus Card' then
		     if context.other_card:get_id() == 7 then card.ability.extra.odds1 = card.ability.extra.odds1 + 1 end
		     card.ability.extra.odds1 = card.ability.extra.odds1 + 1
			 return{
				 extra = {focus = card, message = G.GAME.probabilities.normal*card.ability.extra.odds1 .. ' in ' .. card.ability.extra.odds2},
                            card = card,
                            colour = G.C.GREEN
			 }
		  elseif context.other_card:get_id() == 7 then
		     card.ability.extra.odds1 = card.ability.extra.odds1 + 1
			 return{
				 extra = {focus = card, message = G.GAME.probabilities.normal*card.ability.extra.odds1 .. ' in ' .. card.ability.extra.odds2},
                            card = card,
                            colour = G.C.GREEN
			 }
		  end
	   elseif context.joker_main then
	      if pseudorandom('jackpot') < G.GAME.probabilities.normal*card.ability.extra.odds1 / card.ability.extra.odds2 then
			 return{
				 card = card,
				 Xmult_mod = card.ability.extra.Xmult,
				 message = 'X' .. card.ability.extra.Xmult .. ' Mult',
				 colour = G.C.RED
			 }
		  end
	   elseif context.after and not context.blueprint and card.ability.extra.odds1 > 1 then
	       card.ability.extra.odds1 = 1
	   end
    end
}

--Lovestruck joker
SMODS.Joker{
	key = 'j_lovestruck',
	loc_txt = {
		name = 'Lovestruck Joker',
		text = {
			'Gains {X:mult,C:white}X#2#{} Mult every time a',
			'{C:attention}Wild{} Card is scored',
			'{C:inactive}(Currently{} {X:mult,C:white}X#1#{} {C:inactive}Mult){}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 4, y = 2},
	config = { extra = {
		Xmult = 1,
		Xmult_mod = 0.1
	}},
	rarity = 2,
	cost = 6,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	loc_vars = function(self,info_queue,center)
	info_queue[#info_queue+1] = G.P_CENTERS.m_wild
	  return {vars = {
	                  center.ability.extra.Xmult,
	                  center.ability.extra.Xmult_mod}}
	end,
	calculate = function(self,card,context)
	   if context.cardarea == G.play and context.individual and not context.blueprint then
	     if context.other_card.ability.name == 'Wild Card' then
		     card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_mod
             return{
                      extra = {focus = card, message = localize('k_upgrade_ex')},
                            card = card,
                            colour = G.C.MULT
                   }
           
		 end
	   elseif context.joker_main and to_big(card.ability.extra.Xmult) > to_big(1) then
	   return{
			   card = card,
			   Xmult_mod = card.ability.extra.Xmult,
			   message = 'X' .. card.ability.extra.Xmult .. ' Mult',
			   colour = G.C.MULT
		    }
		end
	     
    end
}

--Factory
SMODS.Joker{
	key = 'j_factory',
	loc_txt = {
		name = 'Factory',
		text = {
			'Played {C:attention}Steel{} Cards have a',
			'{C:green}#1# in #2#{} chance to become',
			'{C:dark_edition}Negative{} when scored'
		}
	},
	atlas = 'atlas1',
	pos = {x = 2, y = 2},
	config = { extra = {
		odds = 2
	}},
	rarity = 3,
	cost = 9,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	loc_vars = function(self,info_queue,center)
	info_queue[#info_queue+1] = G.P_CENTERS.m_steel
	info_queue[#info_queue+1] = G.P_CENTERS.e_negative
	  return {vars = {G.GAME.probabilities.normal,
	                  center.ability.extra.odds}}
	end,
	calculate = function(self,card,context)
	   if context.cardarea == G.play and context.individual then
	      if context.other_card.ability.name == 'Steel Card' and pseudorandom('factory') < G.GAME.probabilities.normal / card.ability.extra.odds and not context.other_card.edition then
		     
                            context.other_card:set_edition({negative = true}, false)
							card:juice_up(0.5, 0.5)
                             
		  end
	   end
    end
}

--Police Officer
SMODS.Joker{
	key = 'j_police',
	loc_txt = {
		name = 'Police Officer',
		text = {
			'All scored {C:attention}Glass{} cards lose',
			'their {C:attention}Enhancement{} and gain a',
			'random {C:attention}Seal{} or {C:dark_edition}Edition{}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 0, y = 2},
	config = { extra = {
	}},
	rarity = 2,
	cost = 7,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	loc_vars = function(self,info_queue,center)
	  info_queue[#info_queue+1] = G.P_CENTERS.m_glass
	  return {vars = {}}
	end,
	calculate = function(self,card,context)
	   if context.cardarea == G.jokers and context.before and not context.blueprint then
	      local glass = {}
                        for k, v in ipairs(context.scoring_hand) do
                            if v.config.center == G.P_CENTERS.m_glass and not v.debuff and not v.vampired then 
                                glass[#glass+1] = v
                                v.vampired = true
                                v:set_ability(G.P_CENTERS.c_base, nil, true)
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        v:juice_up()
                                        v.vampired = nil
                                        return true
                                    end
                                })) 
								if not v.seal and not v.edition then
								 local choices = {'Seal', 'Edition'}
								 local choice = pseudorandom_element(choices, pseudoseed('police1'))
								 if not v.seal and choice == 'Seal' then
								   local options = {'Red', 'Blue', 'Gold', 'Purple'}
								   local seal = pseudorandom_element(options, pseudoseed('police'))
								   v:set_seal(seal, nil, true)
								 end
								 if not v.edition and choice == 'Edition' then
								   local edition = poll_edition('aura', nil, true, true)
								   v:set_edition(edition, true)
								 end
								elseif not v.seal and v.edition then
								   local options = {'Red', 'Blue', 'Gold', 'Purple'}
								   local seal = pseudorandom_element(options, pseudoseed('police'))
								   v:set_seal(seal, nil, true)
								elseif v.seal and not v.edition then
								   local edition = poll_edition('aura', nil, true, true)
								   v:set_edition(edition, true)
								end
                            end
                        end
	   end
    end
}

--Hermit Crab
SMODS.Joker{
	key = 'j_crab',
	loc_txt = {
		name = 'Hermit Crab',
		text = {
			'Gains {C:mult}+#1#{} Mult when {C:attention}Blind',
			'is selected if you have {C:money}$#2#{} or more',
			'{C:inactive}(Currently{} {C:mult}+#3#{} {C:inactive}Mult){}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 3, y = 1},
	config = { extra = {
		mult_mod = 3,
		money = 20,
		mult = 0
	}},
	rarity = 1,
	cost = 4,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	loc_vars = function(self,info_queue,center)
	  return {vars = {center.ability.extra.mult_mod,
	                  center.ability.extra.money,
	                  center.ability.extra.mult}}
	end,
	calculate = function(self,card,context)
	 if context.setting_blind and not context.blueprint then
	      if G.GAME.dollars >= to_big(card.ability.extra.money) then
	        card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
	        card_eval_status_text((card), 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_mult', vars = {card.ability.extra.mult}}})
		  end
	 elseif context.joker_main and card.ability.extra.mult > 0 then
	   return{
			   card = card,
			   mult_mod = card.ability.extra.mult,
			   message = '+' .. card.ability.extra.mult .. ' Mult',
			   colour = G.C.MULT
		    }
		end
    end
}

--Fortune Cookie
SMODS.Joker{
	key = 'j_cookie',
	loc_txt = {
		name = 'Fortune Cookie',
		text = {
			'After {C:attention}5{} {C:inactive}(#1#){} {C:attention}rounds{}, sell this',
			'card to add {C:dark_edition}Polychrome{}',
			'to a {C:attention}random Joker{}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 2, y = 3},
	config = { extra = {
		rounds = 0
	}},
	rarity = 1,
	cost = 2,
	unlocked = true,
    discovered = true,
	blueprint_compat = false,
	eternal_compat = false,
	perishable_compat = false,
	loc_vars = function(self,info_queue,center)
	  return {vars = {
	                  center.ability.extra.rounds}}
	end,
	calculate = function(self,card,context)
	   if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then 
	      card.ability.extra.rounds = card.ability.extra.rounds + 1
		  if card.ability.extra.rounds < 5 then
		  return{
			  message = (card.ability.extra.rounds .. '/5'),
			  colour = G.C.FILTER
		  }
		  else
		  local eval = function(card) 
		                  return not card.REMOVED 
					   end
            juice_card_until(card, eval, true)
		    return{
			  message = localize('k_active_ex'),
			  colour = G.C.FILTER
		    }
		  end
	   elseif context.selling_self and not context.blueprint then
	       if card.ability.extra.rounds >= 5 then
	            local jokers = {}
                for i=1, #G.jokers.cards do 
                    if G.jokers.cards[i] ~= card and not G.jokers.cards[i].edition then
                        jokers[#jokers+1] = G.jokers.cards[i]
                    end
                end
                if #jokers > 0 then 
                        local chosen_joker = pseudorandom_element(jokers, pseudoseed('cookie'))
						local edition = {polychrome = true}
						chosen_joker:set_edition(edition, true)
						card_eval_status_text(card, 'extra', nil, nil, nil, {message = 'Polychrome!', colour = G.C.PURPLE})
				end
		   end
	   end
    end
}

--Bodybuilder
SMODS.Joker{
	key = 'j_bodybuilder',
	loc_txt = {
		name = 'Bodybuilder',
		text = {
			'{C:attention}Increase rank{} of all cards in',
			'{C:attention}first discard{} of round by {C:attention}#1#{}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 7, y = 1},
	config = { extra = {
		strength = 1
	}},
	rarity = 1,
	cost = 5,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	loc_vars = function(self,info_queue,center)
	  return {vars = {center.ability.extra.strength}}
	end,
	calculate = function(self,card,context)
	   if context.pre_discard and G.GAME.current_round.discards_used <= 0 then
	      for i=1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.3,func = function()
                    local _card = G.hand.highlighted[i]
                    local suit_prefix = string.sub(_card.base.suit, 1, 1)..'_'
                    local rank_suffix = _card.base.id == 14 and 2 or math.min(_card.base.id+1, 14)
                    if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
                    elseif rank_suffix == 10 then rank_suffix = 'T'
                    elseif rank_suffix == 11 then rank_suffix = 'J'
                    elseif rank_suffix == 12 then rank_suffix = 'Q'
                    elseif rank_suffix == 13 then rank_suffix = 'K'
                    elseif rank_suffix == 14 then rank_suffix = 'A'
                    end
                    _card:set_base(G.P_CARDS[suit_prefix..rank_suffix])
					_card:juice_up(0.5, 0.5)
					card:juice_up(0.5, 0.5)
					play_sound('tarot1')
                return true end }))
          end
	   end
    end
}

--Executioner
SMODS.Joker{
	key = 'j_executioner',
	loc_txt = {
		name = 'Executioner',
		text = {
			'Gains {C:chips}+#1#{} Chips when',
			'any card is {C:attention}destroyed{}',
			'{C:inactive}(Currently {C:chips}+#2#{} {C:inactive}Chips)'
		}
	},
	atlas = 'atlas1',
	pos = {x = 0, y = 0},
	config = { extra = {
	chip_mod = 20,
	chips = 0
	}},
	rarity = 1,
	cost = 5,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	loc_vars = function(self,info_queue,center)
	  return {vars = {
		  center.ability.extra.chip_mod,
	      center.ability.extra.chips}}
	end,
	calculate = function(self,card,context)
	if context.cards_destroyed and not context.blueprint then
	    local cards = 0
		for k, v in ipairs(context.glass_shattered) do
                    cards = cards + 1
        end
		if cards > 0 then
		  card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod * cards
		  card_eval_status_text((card), 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_chips', vars = {card.ability.extra.chips}}})
		end

	  elseif context.remove_playing_cards and not context.blueprint then
	    local cards = 0
		for k, val in ipairs(context.removed) do
                    cards = cards + 1
        end
		if cards > 0 then
		  card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod * cards
		  card_eval_status_text((card), 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_chips', vars = {card.ability.extra.chips}}})
		end
      
	  elseif context.joker_main then
	      return {
			card = card,
			chip_mod = card.ability.extra.chips,
			message = '+' .. card.ability.extra.chips,
			colour = G.C.CHIPS
		  }
	  end
	end
}

--The Reaper
SMODS.Joker{
	key = 'j_reaper',
	loc_txt = {
		name = 'The Reaper',
		text = {
			'If played hand contains exactly',
			'{C:attention}2{} cards, convert the {C:attention}left{} card',
			'into the {C:attention}right{} card after scoring'
		}
	},
	atlas = 'atlas1',
	pos = {x = 1, y = 2},
	config = { extra = {
	}},
	rarity = 3,
	cost = 8,
	unlocked = true,
    discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	loc_vars = function(self,info_queue,center)
	  return {vars = {}}
	end,
	calculate = function(self,card,context)
	   if context.after and not context.blueprint and context.cardarea == G.jokers and #context.full_hand == 2 then
                G.E_MANAGER:add_event(Event({trigger = 'before',delay = 0.1,func = function()
                        copy_card(context.full_hand[2], context.full_hand[1])
                    return true end }))
					return{
						message = localize('k_copied_ex'),
                                colour = G.C.CHIPS,
                                card = card
					}
            end
    end
}

--Short Temper
SMODS.Joker{
	key = 'j_temper',
	loc_txt = {
		name = 'Short Temper',
		text = {
			'Gains {C:money}$#1#{} of {C:attention}sell value{} at',
			'{C:attention}end of round{} for each hand',
			'played after {C:attention}first{} hand of round'
		}
	},
	atlas = 'atlas1',
	pos = {x = 8, y = 1},
	config = { extra = {
		money = 2,
		bonus = 0
	}},
	rarity = 1,
	cost = 5,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	soul_pos= { x = 9, y = 1 },
	loc_vars = function(self,info_queue,center)
	  return {vars = {center.ability.extra.money}}
	end,
	calculate = function(self,card,context)
	   if context.after and G.GAME.current_round.hands_played > 0 and not context.blueprint then
	       card.ability.extra.bonus = card.ability.extra.bonus + card.ability.extra.money
		   return {
			            card = card,
                        message = 'Grrrr...',
                        colour = G.C.RED
                    }
	   elseif context.end_of_round and not context.blueprint and card.ability.extra.bonus > 0 then
	       card.ability.extra_value = card.ability.extra_value + card.ability.extra.bonus
		   card:set_cost()
		   card.ability.extra.bonus = 0
                    return {
                        message = localize('k_val_up'),
                        colour = G.C.MONEY
                    }
	   end
    end
}

--Miner
SMODS.Joker{
	key = 'j_miner',
	loc_txt = {
		name = 'Miner',
		text = {
			'{C:attention}Gold{} Cards held in hand',
			'give {C:mult}Mult{} equal to their rank'
		}
	},
	atlas = 'atlas1',
	pos = {x = 3, y = 2},
	config = { extra = {
	}},
	rarity = 1,
	cost = 5,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	loc_vars = function(self,info_queue,center)
	info_queue[#info_queue+1] = G.P_CENTERS.m_gold
	  return {vars = {}}
	end,
	calculate = function(self,card,context)
	   if context.cardarea == G.hand and context.individual and not context.end_of_round then
	     if context.other_card.ability.name == 'Gold Card' then
	       if context.other_card.debuff then
                return{
                      message = localize('k_debuffed'),
                      colour = G.C.RED,
                      card = card,
                      }
           else
		        local mult = context.other_card:get_id()
				if mult == 14 then mult = 11
				elseif mult > 10 then mult = 10 end

                return{
                      h_mult = mult,
                      card = card,
                      }
           end
		 end
	   end
    end
}

--The Pyramid
SMODS.Joker{
	key = 'j_pyramid',
	loc_txt = {
		name = 'The Pyramid',
		text = {
			'{X:mult,C:white}X#1#{} Mult if there are at least',
			'{C:attention}#2# Stone{} cards in your {C:attention}Full Deck{}',
			'{C:inactive}(Currently{} {C:attention}#3#{} {C:inactive}Stone#4#){}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 4, y = 1},
	config = { extra = {
		Xmult = 3,
		stones_req = 10,
		stones = 0,
		s = 's'
	}},
	rarity = 2,
	cost = 6,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	update = function(self,card,dt)
	  if G.STAGE == G.STAGES.RUN then
	        card.ability.extra.stones = 0
            for k, v in pairs(G.playing_cards) do
                if v.config.center == G.P_CENTERS.m_stone then card.ability.extra.stones = card.ability.extra.stones+1 end
            end
			if card.ability.extra.stones == 1 then
			 s = ''
			else 
			 s = 's'
			end
	  end
	end,
	loc_vars = function(self,info_queue,center)
	  info_queue[#info_queue+1] = G.P_CENTERS.m_stone
	  return {vars = {center.ability.extra.Xmult,
	                  center.ability.extra.stones_req,
	                  center.ability.extra.stones,
	                  center.ability.extra.s}}
	end,
	calculate = function(self,card,context)
	   if context.joker_main and card.ability.extra.stones >= card.ability.extra.stones_req then
	   return{
			   card = card,
			   Xmult_mod = card.ability.extra.Xmult,
			   message = 'X' .. card.ability.extra.Xmult .. ' Mult',
			   colour = G.C.MULT
		    }
		end
    end
}

--Starry Night
SMODS.Joker{
	key = 'j_starry',
	loc_txt = {
		name = 'Starry Night',
		text = {
			'Gains {C:mult}+#1#{} Mult every time',
			'a card with {C:diamonds}Diamond{} suit is scored,',
			'resets after beating {C:attention}Boss Blind{}',
			'{C:inactive}(Currently{} {C:mult}+#2#{} {C:inactive}Mult){}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 0, y = 1},
	config = { extra = {
		mult_mod = 2,
		mult = 0
	}},
	rarity = 1,
	cost = 5,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	loc_vars = function(self,info_queue,center)
	  return {vars = {center.ability.extra.mult_mod,
	                  center.ability.extra.mult}}
	end,
	calculate = function(self,card,context)
	  if context.individual and context.cardarea == G.play and not context.blueprint then
	    if context.other_card:is_suit('Diamonds') then
		  card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
		  return{
			  card = card,
			  extra = {focus = card, message = localize('k_upgrade_ex')},
			  colour = G.C.RED
		  }
		end
	  elseif context.joker_main and to_big(card.ability.extra.mult) > to_big(0) then 
	    return{
		  card = card,
		  mult_mod = card.ability.extra.mult,
		  message = '+' .. card.ability.extra.mult .. ' Mult',
		  colour = G.C.RED
	    }
	  elseif context.end_of_round and not context.blueprint and G.GAME.blind.boss and to_big(card.ability.extra.mult) > to_big(0) then
	   card.ability.extra.mult = 0
	   return{
		   card = card,
		   message = localize('k_reset'),
           colour = G.C.RED
	   }
	  end
    end
}

--Moonlight
SMODS.Joker{
	key = 'j_moonlight',
	loc_txt = {
		name = 'Moonlight',
		text = {
			'Gains {X:mult,C:white}X#1#{} Mult every time',
			'a card with {C:clubs}Club{} suit is scored,',
			'resets after hand is scored',
			'{C:inactive}(Currently{} {X:mult,C:white}X#2#{} {C:inactive}Mult){}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 8, y = 0},
	config = { extra = {
		Xmult_mod = 0.2,
		Xmult = 1
	}},
	rarity = 1,
	cost = 5,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	loc_vars = function(self,info_queue,center)
	  return {vars = {center.ability.extra.Xmult_mod,
	                  center.ability.extra.Xmult}}
	end,
    calculate = function(self,card,context)
	  if context.individual and context.cardarea == G.play and not context.blueprint then
	    if context.other_card:is_suit('Clubs') then
		  card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_mod
		  return{
			  card = card,
			  extra = {focus = card, message = localize('k_upgrade_ex')},
			  colour = G.C.RED
		  }
		end
	  elseif context.joker_main and to_big(card.ability.extra.Xmult) > to_big(1) then 
	    return{
		  card = card,
		  Xmult_mod = card.ability.extra.Xmult,
		  message = 'X' .. card.ability.extra.Xmult .. ' Mult',
		  colour = G.C.RED
	    }
	  elseif context.after and not context.blueprint and to_big(card.ability.extra.Xmult) > to_big(1) and not context.blueprint then
	   card.ability.extra.Xmult = 1
	   return{
		   card = card,
		   message = localize('k_reset'),
           colour = G.C.RED
	   }
	  end
    end
}

--Sunrise
SMODS.Joker{
	key = 'j_sunrise',
	loc_txt = {
		name = 'Sunrise',
		text = {
			'Gains {C:chips}+#1#{} Chips for each',
			'scored card with {C:hearts}Heart{} suit',
			'in {C:attention}first hand{} of round,',
			'Resets at {C:attention}end of round{}',
			'{C:inactive}(Currently{} {C:chips}+#2#{} {C:inactive}Chips){}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 7, y = 0},
	config = { extra = {
		chip_mod = 30,
		chips = 0
	}},
	rarity = 1,
	cost = 5,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	loc_vars = function(self,info_queue,center)
	  return {vars = {center.ability.extra.chip_mod,
	                  center.ability.extra.chips}}
	end,
    calculate = function(self,card,context)
	  if context.before and context.cardarea == G.jokers and not context.blueprint then
	   if G.GAME.current_round.hands_played == 0 then
	    for i = 1, #context.scoring_hand do
	      if context.scoring_hand[i]:is_suit('Hearts') then
		   card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
		  end
		end
	   end
	  end
	  if context.joker_main then 
	    return{
		  card = card,
		  chip_mod = card.ability.extra.chips,
		  message = '+' .. card.ability.extra.chips,
		  colour = G.C.CHIPS
	    }
	  end
	  if context.end_of_round and not context.blueprint and to_big(card.ability.extra.chips) > to_big(0) then
	   card.ability.extra.chips = 0
	   return{
		   message = localize('k_reset'),
                        colour = G.C.BLUE
	   }
	  end
    end
}

--Judge
SMODS.Joker{
	key = 'j_judge',
	loc_txt = {
		name = 'Judge',
		text = {
			'When this {C:attention}Joker{} is {C:attention}sold{},',
			'create a {C:attention}Joker{} whose {C:attention}Collection{}',
			'{C:attention}number{} matches your current {C:money}money{}',
			'{C:inactive}({}{C:legendary}Legendaries{} {C:inactive}excluded){}',
			'{C:inactive,s:0.8}Currently creating:{} {C:attention,s:0.8}#1#{}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 4, y = 0},
	config = { extra = {
		joker = 'None'
	}},
	rarity = 3,
	cost = 10,
	unlocked = true,
    discovered = true,
	blueprint_compat = false,
	eternal_compat = false,
	perishable_compat = true,
	loc_vars = function(self,info_queue,center)
	  return {vars = {
	  center.ability.extra.joker}}
	end,
	update = function(self,card,dt)
	 if G.STAGE == G.STAGES.RUN then
	  local jokers = {
		 'Joker', 'Greedy Joker', 'Lusty Joker', 'Wrathful Joker', 'Gluttonous Joker', 'Jolly Joker', 'Zany Joker', 
		 'Mad Joker', 'Crazy Joker', 'Droll Joker', 'Sly Joker', 'Wily Joker', 'Clever Joker', 'Devious Joker', 'Crafty Joker',
		 'Half Joker', 'Joker Stencil', 'Four Fingers', 'Mime', 'Credit Card', 'Ceremonial Dagger', 'Banner', 'Mystic Summit',
		 'Marble Joker', 'Loyalty Card', '8 Ball', 'Misprint', 'Dusk', 'Raised Fist', 'Chaos the Clown', 'Fibonacci',
		 'Steel Joker', 'Scary Face', 'Abstract Joker', 'Delayed Gratification', 'Hack', 'Pareidolia', 'Gros Michel',
		 'Even Steven', 'Odd Todd', 'Scholar', 'Business Card', 'Supernova', 'Ride the Bus', 'Space Joker', 'Egg', 'Burglar',
		 'Blackboard', 'Runner', 'Ice Cream', 'DNA', 'Splash', 'Blue Joker', 'Sixth Sense', 'Constellation', 'Hiker',
		 'Faceless Joker', 'Green Joker', 'Superposition', 'To Do List', 'Cavendish', 'Card Sharp', 'Red Card', 'Madness',
		 'Square Joker', 'Seance', 'Riff Raff', 'Vampire', 'Shortcut',
		 'Hologram', 'Vagabond', 'Baron', 'Cloud 9', 'Rocket', 'Obelisk', 'Midas Mask', 'Luchador',
		 'Photograph', 'Gift Card', 'Turtle Bean', 'Erosion', 'Reserved Parking', 'Mail-In Rebate', 'To The Moon', 
		 'Hallucination', 'Fortune Teller', 'Juggler', 'Drunkard', 'Stone Joker', 'Golden Joker', 'Lucky Cat', 'Baseball Card',
		 'Bull', 'Diet Cola', 'Trading Card', 'Flash Card', 'Popcorn', 'Spare Trousers', 'Ancient Joker', 'Ramen',
		 'Walkie Talkie', 'Seltzer', 'Castle', 'Smiley Face', 'Campfire', 'Golden Ticket', 'Mr. Bones', 'Acrobat',
		 'Sock and Buskin', 'Swashbuckler', 'Troubadour', 'Certificate', 'Smeared Joker', 'Throwback', 'Hanging Chad',
		 'Rough Gem', 'Bloodstone', 'Arrowhead', ' Onyx Agate', 'Glass Joker', 'Showman', 'Flower Pot',
		 'Blueprint', 'Wee Joker', 'Merry_andy', 'Oops! All 6s', 'The Idol', 'Seeing Double', 'Matador', 'Hit The Road',
		 'The Duo', 'The Trio', 'The Family', 'The Order', 'The Tribe', 'Stuntman', 'Invisible Joker', 'Brainstorm', 'Satellite',
		 'Shoot The Moon', 'Drivers License', 'Cartomancer', 'Astronomer', 'Burnt Joker', 'Bootstraps', 'Canio',
		 'Triboulet', 'Yorick', 'Chicot', 'Perkeo', 'Foolish Joker', 'Magic Show', 'Solar Flair',
		 'Impressive Joker', 'The Empire', 'Jackpot!', 'Lovestruck Joker', 'Factory',
		 'Police Officer', 'Hermit Crab', 'Fortune Cookie', 'Bodybuilder', 'Executioner',
		 'The Reaper', 'Short Temper', 'Miner', 'The Pyramid', 'Starry Night', 'Moonlight', 'Sunrise', 'Judge', 'Fertile Soil',
		 'Mad World', 'Groom', 'Tin Cans', 'Tally Marks', 'Explorer', 'Bank',
		 'Signal', 'Squeegee', 'Echo Joker', "I'm Late!", 'Anchor',
		 'DJ', 'Hexagonal Joker', 'Transportation', 'High Risk, High Reward', 'Encrypted Joker'
	  }
	  if (G.GAME.dollars >= to_big(146) and G.GAME.dollars <= to_big(150)) or G.GAME.dollars > to_big(188) or G.GAME.dollars < to_big(1) then
	   card.ability.extra.joker = 'None'
      else
	      card.ability.extra.joker = jokers[to_number(G.GAME.dollars)]
	  end
	 end
	end,
    calculate = function(self,card,context)
	 local slugs = {
		 'j_joker', 'j_greedy_joker', 'j_lusty_joker', 'j_wrathful_joker', 'j_gluttenous_joker', 'j_jolly',
		 'j_zany', 'j_mad', 'j_crazy', 'j_droll', 'j_sly', 'j_wily', 'j_clever', 'j_devious', 'j_crafty', 'j_half',
		 'j_stencil', 'j_four_fingers', 'j_mime', 'j_credit_card', 'j_ceremonial', 'j_banner', 'j_mystic_summit',
		 'j_marble', 'j_loyalty_card', 'j_8_ball', 'j_misprint', 'j_dusk', 'j_raised_fist', 'j_chaos', 'j_fibonacci',
		 'j_steel_joker', 'j_scary_face', 'j_abstract', 'j_delayed_grat', 'j_hack', 'j_pareidolia', 'j_gros_michel',
		 'j_even_steven', 'j_odd_todd', 'j_scholar', 'j_business', 'j_supernova', 'j_ride_the_bus', 'j_space', 'j_egg',
		 'j_burglar', 'j_blackboard', 'j_runner', 'j_ice_cream', 'j_dna', 'j_splash', 'j_blue_joker', 'j_sixth_sense',
		 'j_constellation', 'j_hiker', 'j_faceless', 'j_green_joker', 'j_superposition', 'j_todo_list', 'j_cavendish',
		 'j_card_sharp', 'j_red_card', 'j_madness', 'j_square', 'j_seance', 'j_riff_raff', 'j_vampire', 'j_shortcut',
		 'j_hologram', 'j_vagabond', 'j_baron', 'j_cloud_9', 'j_rocket', 'j_obelisk', 'j_midas_mask', 'j_luchador',
		 'j_photograph', 'j_gift', 'j_turtle_bean', 'j_erosion', 'j_reserved_parking', 'j_mail', 'j_to_the_moon', 
		 'j_hallucination', 'j_fortune_teller', 'j_juggler', 'j_drunkard', 'j_stone', 'j_golden', 'j_lucky_cat', 'j_baseball',
		 'j_bull', 'j_diet_cola', 'j_trading', 'j_flash', 'j_popcorn', 'j_trousers', 'j_ancient', 'j_ramen',
		 'j_walkie_talkie', 'j_selzer', 'j_castle', 'j_smiley', 'j_campfire', 'j_ticket', 'j_mr_bones', 'j_acrobat',
		 'j_sock_and_buskin', 'j_swashbuckler', 'j_troubadour', 'j_certificate', 'j_smeared', 'j_throwback', 'j_hanging_chad',
		 'j_rough_gem', 'j_bloodstone', 'j_arrowhead', 'j_onyx_agate', 'j_glass', 'j_ring_master', 'j_flower_pot',
		 'j_blueprint', 'j_wee', 'j_merry_andy', 'j_oops', 'j_idol', 'j_seeing_double', 'j_matador', 'j_hit_the_road',
		 'j_duo', 'j_trio', 'j_family', 'j_order', 'j_tribe', 'j_stuntman', 'j_invisible', 'j_brainstorm', 'j_satellite',
		 'j_shoot_the_moon', 'j_drivers_license', 'j_cartomancer', 'j_astronomer', 'j_burnt', 'j_bootstraps', 'j_caino',
		 'j_triboulet', 'j_yorick', 'j_chicot', 'j_perkeo', 'j_Unsorted_j_foolish', 'j_Unsorted_j_magic', 'j_Unsorted_j_flair',
		 'j_Unsorted_j_impressive', 'j_Unsorted_j_empire', 'j_Unsorted_j_jackpot', 'j_Unsorted_j_lovestruck', 'j_Unsorted_j_factory',
		 'j_Unsorted_j_police', 'j_Unsorted_j_crab', 'j_Unsorted_j_cookie', 'j_Unsorted_j_bodybuilder', 'j_Unsorted_j_executioner',
		 'j_Unsorted_j_reaper', 'j_Unsorted_j_temper', 'j_Unsorted_j_miner', 'j_Unsorted_j_pyramid', 'j_Unsorted_j_starry',
		 'j_Unsorted_j_moonlight', 'j_Unsorted_j_sunrise', 'j_Unsorted_j_judge', 'j_Unsorted_j_soil', 'j_Unsorted_j_madworld',
		 'j_Unsorted_j_groom', 'j_Unsorted_j_cans', 'j_Unsorted_j_tally', 'j_Unsorted_j_explorer', 'j_Unsorted_j_bank',
		 'j_Unsorted_j_signal', 'j_Unsorted_j_squeegee', 'j_Unsorted_j_echo', 'j_Unsorted_j_late', 'j_Unsorted_j_anchor',
		 'j_Unsorted_j_dj', 'j_Unsorted_j_hexagonal', 'j_Unsorted_j_transport', 'j_Unsorted_j_risk', 'j_Unsorted_j_encrypted'
	 }
	 
	 if context.selling_self and not context.blueprint and (G.GAME.dollars <= to_big(146) or G.GAME.dollars >= to_big(150)) and G.GAME.dollars <= to_big(188) and G.GAME.dollars >= to_big(1) then
	 
	    local card = create_card('Joker', G.jokers, nil, nil, nil, nil, slugs[to_number(G.GAME.dollars)])
        card:add_to_deck()
        G.jokers:emplace(card)
	 end
    end
}

--Fertile Soil
SMODS.Joker{
	key = 'j_soil',
	loc_txt = {
		name = 'Fertile Soil',
		text = {
			'Earn {C:money}#1#${} at {C:attention}end of round{},',
			'increase payout by {C:money}#2#${} if Scored Hand',
			'contains only {C:spades}Spades{}, {C:attention}resets{} when',
			'a {C:attention}non-Spade{} card is scored'
		}
	},
	atlas = 'atlas1',
	pos = {x = 9, y = 0},
	config = { extra = {
		money = 0,
		money_mod = 1
	}},
	rarity = 1,
	cost = 5,
	unlocked = true,
    discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = false,
	loc_vars = function(self,info_queue,center)
	  return {vars = {center.ability.extra.money,
	                  center.ability.extra.money_mod}}
	end,

	calc_dollar_bonus = function(self, card)
	if card.ability.extra.money > 0 then
        return card.ability.extra.money
		end
    end,
    calculate = function(self,card,context)
	  if not context.blueprint and context.before then
	    local valid = true
	    for i = 1, #context.scoring_hand do
	     if not context.scoring_hand[i]:is_suit('Spades') then
		 valid = false
		 end
		end
		if not valid and card.ability.extra.money > 0 then
		  card.ability.extra.money = 0
	      return{
		   card = card,
		   message = localize('k_reset'),
           colour = G.C.MONEY
	      }
		elseif valid then
		  card.ability.extra.money = card.ability.extra.money + card.ability.extra.money_mod
		  return{
		   card = card,
		   message = localize('k_upgrade_ex'),
           colour = G.C.MONEY
	      }
		end
	  end
    end
}

--Mad World
SMODS.Joker{
	key = 'j_madworld',
	loc_txt = {
		name = 'Mad World',
		text = {
			'{C:attention}First{} played {C:attention}Face{} Card',
			'of each {C:attention}Enhancement{} gives',
			'{C:mult}+#1#{} Mult when scored'
		}
	},
	atlas = 'atlas1',
	pos = {x = 0, y = 3},
	config = { extra = {
		mult = 9
	}},
	rarity = 1,
	cost = 4,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	loc_vars = function(self,info_queue,center)
	  return {vars = {
	                  center.ability.extra.mult}}
	end,
	calculate = function(self,card,context)
	   if context.individual and context.cardarea == G.play then
	      local repeat_card1 = nil
		  local repeat_card2 = nil
		  local repeat_card3 = nil
		  local repeat_card4 = nil
		  local used_enhancements = {}
		  for i=1, #context.scoring_hand do
		   if context.scoring_hand[i]:is_face() then
		     local card_enhancement = 'Base'
		     if context.scoring_hand[i].ability.name == nil then
			    if context.scoring_hand[i].ability.effect ~= nil then
				   card_enhancement = context.scoring_hand[i].ability.effect
				end
			 else
		        card_enhancement = context.scoring_hand[i].ability.name
			 end
		     if is_in(used_enhancements, card_enhancement) then
			    if repeat_card1 == nil then repeat_card1 = context.scoring_hand[i]
				elseif repeat_card2 == nil then repeat_card2 = context.scoring_hand[i]
				elseif repeat_card3 == nil then repeat_card3 = context.scoring_hand[i]
				elseif repeat_card4 == nil then repeat_card4 = context.scoring_hand[i] end
			 else 
			    used_enhancements[#used_enhancements+1] = card_enhancement
			 end
		   end
		  end
	      
		  if context.other_card ~= repeat_card1 and 
		     context.other_card ~= repeat_card2 and 
			 context.other_card ~= repeat_card3 and 
			 context.other_card ~= repeat_card4 and 
			 context.other_card:is_face() then return {
                            mult = card.ability.extra.mult,
                            card = card
                        }
		  end
	   end
    end
}

--Groom
SMODS.Joker{
	key = 'j_groom',
	loc_txt = {
		name = 'Groom',
		text = {
			'{C:attention}First{} played {C:attention}Ace{}',
			'of each {C:attention}Enhancement{} gives',
			'{X:mult,C:white}X#1#{} Mult when scored'
		}
	},
	atlas = 'atlas1',
	pos = {x = 1, y = 3},
	config = { extra = {
		Xmult = 2
	}},
	rarity = 1,
	cost = 4,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	loc_vars = function(self,info_queue,center)
	  return {vars = {
	                  center.ability.extra.Xmult}}
	end,
	calculate = function(self,card,context)
	   if context.individual and context.cardarea == G.play then
	      local repeat_card1 = nil
		  local repeat_card2 = nil
		  local repeat_card3 = nil
		  local repeat_card4 = nil
		  local used_enhancements = {}
		  for i=1, #context.scoring_hand do
		   if context.scoring_hand[i]:get_id() == 14 then
		     local card_enhancement = 'Base'
		     if context.scoring_hand[i].ability.name == nil then
			    if context.scoring_hand[i].ability.effect ~= nil then
				   card_enhancement = context.scoring_hand[i].ability.effect
				end
			 else
		        card_enhancement = context.scoring_hand[i].ability.name
			 end
		     if is_in(used_enhancements, card_enhancement) then
			    if repeat_card1 == nil then repeat_card1 = context.scoring_hand[i]
				elseif repeat_card2 == nil then repeat_card2 = context.scoring_hand[i]
				elseif repeat_card3 == nil then repeat_card3 = context.scoring_hand[i]
				elseif repeat_card4 == nil then repeat_card4 = context.scoring_hand[i] end
			 else 
			    used_enhancements[#used_enhancements+1] = card_enhancement
			 end
		   end
		  end
	      
		  if context.other_card ~= repeat_card1 and 
		     context.other_card ~= repeat_card2 and 
			 context.other_card ~= repeat_card3 and 
			 context.other_card ~= repeat_card4 and
			 context.other_card:get_id() == 14 then return {
                            x_mult = card.ability.extra.Xmult,
                            card = card
                        }
		  end
	   end
    end
}

--Tin Cans
SMODS.Joker{
	key = 'j_cans',
	loc_txt = {
		name = 'Tin Cans',
		text = {
			'{C:attention}First{} played {C:attention}numbered{} Card',
			'of each {C:attention}Enhancement{} gives',
			'{C:chips}+#1#{} Chips when scored'
		}
	},
	atlas = 'atlas1',
	pos = {x = 9, y = 2},
	config = { extra = {
		chips = 35
	}},
	rarity = 1,
	cost = 4,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	loc_vars = function(self,info_queue,center)
	  return {vars = {
	                  center.ability.extra.chips}}
	end,
	calculate = function(self,card,context)
	   if context.individual and context.cardarea == G.play then
	      local repeat_card1 = nil
		  local repeat_card2 = nil
		  local repeat_card3 = nil
		  local repeat_card4 = nil
		  local used_enhancements = {}
		  for i=1, #context.scoring_hand do
		   if context.scoring_hand[i]:get_id() >= 2 and context.scoring_hand[i]:get_id() <= 10 then
		     local card_enhancement = 'Base'
		     if context.scoring_hand[i].ability.name == nil then
			    if context.scoring_hand[i].ability.effect ~= nil then
				   card_enhancement = context.scoring_hand[i].ability.effect
				end
			 else
		        card_enhancement = context.scoring_hand[i].ability.name
			 end
		     if is_in(used_enhancements, card_enhancement) then
			    if repeat_card1 == nil then repeat_card1 = context.scoring_hand[i]
				elseif repeat_card2 == nil then repeat_card2 = context.scoring_hand[i]
				elseif repeat_card3 == nil then repeat_card3 = context.scoring_hand[i]
				elseif repeat_card4 == nil then repeat_card4 = context.scoring_hand[i] end
			 else 
			    used_enhancements[#used_enhancements+1] = card_enhancement
			 end
		   end
		  end
	      
		  if context.other_card ~= repeat_card1 and 
		     context.other_card ~= repeat_card2 and 
			 context.other_card ~= repeat_card3 and 
			 context.other_card ~= repeat_card4 and 
			 context.other_card:get_id() >= 2 and context.other_card:get_id() <= 10 then return {
                            chips = card.ability.extra.chips,
                            card = card
                        }
		  end
	   end
    end
}

--Tally Marks
SMODS.Joker{
	key = 'j_tally',
	loc_txt = {
		name = 'Tally Marks',
		text = {
			'Gains {C:mult}+#1#{} Mult and {C:chips}+#4#{} Chips',
			'for every {C:attention}5{} {C:inactive}[#3#]{} {C:money}Gold Seals{} scored',
			'{C:inactive}(Currently{} {C:mult}+#2#{} {C:inactive}Mult and{} {C:chips}+#5#{} {C:inactive}Chips){}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 7, y = 3},
	config = { extra = {
		mult_mod = 5,
		mult = 0,
		golds_left = 5,
		chip_mod = 20,
		chips = 0
	}},
	rarity = 1,
	cost = 5,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	loc_vars = function(self,info_queue,center)
	  return {vars = {center.ability.extra.mult_mod,
		              center.ability.extra.mult,
	                  center.ability.extra.golds_left,
	                  center.ability.extra.chip_mod,
	                  center.ability.extra.chips}}
	end,
	calculate = function(self,card,context)
	  if context.individual and context.cardarea == G.play and not context.blueprint then
	     if context.other_card:get_seal(false) == 'Gold' then
		    card.ability.extra.golds_left = card.ability.extra.golds_left - 1
			if card.ability.extra.golds_left == 0 then
			   card.ability.extra.golds_left = 5
			   card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
			   card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
			   return {
                            extra = {focus = card, message = localize('k_upgrade_ex')},
                            card = card,
                            colour = G.C.FILTER
                        }
			end
		 end
	  elseif context.joker_main and to_big(card.ability.extra.mult) > to_big(0) then
	     return{
			   card = card,
			   mult_mod = card.ability.extra.mult,
			   chip_mod = card.ability.extra.chips,
			   message = '+' .. card.ability.extra.mult .. ', +' .. card.ability.extra.chips,
			   colour = G.C.PURPLE
		 }
	  end
    end
}

--Explorer
SMODS.Joker{
	key = 'j_explorer',
	loc_txt = {
		name = 'Explorer',
		text = {
			'Played cards with an {C:dark_edition}Edition{}',
			'permanently gain {C:chips}+#1#{} Chips when scored'
		}
	},
	atlas = 'atlas1',
	pos = {x = 6, y = 3},
	config = { extra = {
		chips = 24
	}},
	rarity = 2,
	cost = 7,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	loc_vars = function(self,info_queue,center)
	  return {vars = {
		              center.ability.extra.chips}}
	end,
	calculate = function(self,card,context)
	  if context.individual and context.cardarea == G.play and context.other_card.edition then
	      context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus or 0
          context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus + card.ability.extra.chips
               return {
                   extra = {message = localize('k_upgrade_ex'), colour = G.C.CHIPS},
                   colour = G.C.CHIPS,
                   card = card
               }
	   end
    end
}

--Bank
SMODS.Joker{
	key = 'j_bank',
	loc_txt = {
		name = 'Bank',
		text = {
			'At {C:attention}end of shop{}, set money to',
			'{C:money}$0{} and gain {X:mult,C:white}X#1#{} Mult',
			'for each {C:money}$1{} lost this way',
			'{C:inactive}(Currently{} {X:mult,C:white}X#2#{} {C:inactive}Mult){}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 3, y = 3},
	config = { extra = {
		Xmult_mod = 0.02,
		Xmult = 1
	}},
	rarity = 3,
	cost = 8,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	loc_vars = function(self,info_queue,center)
	  return {vars = {
	                  center.ability.extra.Xmult_mod,
	                  center.ability.extra.Xmult}}
	end,
	calculate = function(self,card,context)
	   if context.ending_shop and not context.blueprint then
	      local money = 0
		  if G.GAME.dollars > to_big(0) then
		     money = to_number(G.GAME.dollars)
		  end
		  ease_dollars(-(to_number(G.GAME .dollars)), true)
		  if to_big(money) > to_big(0) then
		     card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_mod * money
		     card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_xmult',vars={card.ability.extra.Xmult}}})
		  end
	   elseif context.joker_main then
	      if to_big(card.ability.extra.Xmult) > to_big(1) then
	         return{
				 card = card,
				 Xmult_mod = card.ability.extra.Xmult,
				 message = 'X' .. card.ability.extra.Xmult .. ' Mult',
				 colour = G.C.RED
			 }
		  end
	   end
    end
}

--Signal
SMODS.Joker{
	key = 'j_signal',
	loc_txt = {
		name = 'Signal',
		text = {
			'Each card held in hand',
			'gives {C:mult}+#1#{} Mult if {C:attention}all{}',
			'of them are {V:1}#2#{}',
			'{C:inactive,s:0.8}Suit changes at end of{}',
			'{C:inactive,s:0.8}round based on cards in deck{}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 4, y = 3},
	config = { extra = {
		mult = 5
	}},
	rarity = 1,
	cost = 6,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	loc_vars = function(self,info_queue,card)
	  return {vars = {
		              card.ability.extra.mult,
	                  localize(G.GAME.current_round.idol_card.suit, 'suits_plural'),
					  colours = {G.C.SUITS[G.GAME.current_round.idol_card.suit]}}}
	end,
	calculate = function(self,card,context)
	   if context.individual and context.cardarea == G.hand then
	      local valid = true
	      for i=1, #G.hand.cards do
		     if not G.hand.cards[i]:is_suit(G.GAME.current_round.idol_card.suit) then valid = false end
		  end
		  if valid == true then
		     return {
                 h_mult = card.ability.extra.mult,
                 card = card,
             }
		  end
	   end
    end
}

--Squeegee
SMODS.Joker{
	key = 'j_squeegee',
	loc_txt = {
		name = 'Squeegee',
		text = {
			'Convert all scored {C:attention}cards{}',
			'into a random {C:attention}card{} in poker hand'
		}
	},
	atlas = 'atlas1',
	pos = {x = 3, y = 0},
	config = { extra = {
	}},
	rarity = 2,
	cost = 7,
	unlocked = true,
    discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	loc_vars = function(self,info_queue,center)
	  return {vars = {}}
	end,
    calculate = function(self,card,context)
	 if context.before and context.cardarea == G.jokers and not context.blueprint then
	  local cards = {}
	  for k, v in ipairs(context.scoring_hand) do
                 cards[#cards + 1] = v
      end
	  local card = pseudorandom_element(cards, pseudoseed('squeegee'))
	  for k, v in ipairs(context.scoring_hand) do 
	              copy_card(card, v)
      end
	      return {
			card = card,
			message = 'Copied!',
			colour = G.C.MONEY
		  }
	 end
    end
}

--Echo Joker
SMODS.Joker{
	key = 'j_echo',
	loc_txt = {
		name = 'Echo Joker',
		text = {
			'Create an {C:spectral}Ectoplasm{} Card ',
			'if played hand is a {C:attention}Royal Flush{}',
			'{C:inactive}(Must have room){}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 5, y = 3},
	config = { extra = {
	}},
	rarity = 2,
	cost = 6,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	loc_vars = function(self,info_queue,center)
	  return {vars = {}}
	end,
	calculate = function(self,card,context)
	  if context.cardarea == G.jokers and context.before then
	     if (next(context.poker_hands['Straight Flush'])) then
		   local valid = true
		     for i = 1, #context.scoring_hand do
                if context.scoring_hand[i]:get_id() < 10 then valid = false end
             end
		   if valid == true then 
		     if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
						trigger = 'before',
                        delay = 0.0,
                        func = (function()
                            local card = create_card('Spectral', G.consumeables, nil, nil, nil, nil, 'c_ectoplasm')
                            card:add_to_deck()
                            G.consumeables:emplace(card)
                            G.GAME.consumeable_buffer = 0
                            return true
                end)}))   
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_plus_spectral'), colour = G.C.SECONDARY_SET.Spectral})
             end
		   end
		 end
	  end
    end
}

--I'm Late!
SMODS.Joker{
	key = 'j_late',
	loc_txt = {
		name = "I'm Late!",
		text = {
			'Earn {C:money}$#1#{} at end of round,',
			'{C:red}Self-destructs{} after beating',
			'{C:attention}Boss Blind{} unless a {C:attention}playing card{}',
			'is destroyed this ante',
			'{C:inactive,s:0.8}#2#{}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 8, y = 3},
	config = { extra = {
		money = 6,
		safe = false,
		safe_text = 'Late!'
	}},
	rarity = 1,
	cost = 7,
	unlocked = true,
    discovered = true,
	blueprint_compat = false,
	eternal_compat = false,
	perishable_compat = true,
	loc_vars = function(self,info_queue,center)
	  return {vars = {center.ability.extra.money,
	                  center.ability.extra.safe_text}}
	end,
	calc_dollar_bonus = function(self, card)
          return card.ability.extra.money
    end,
	calculate = function(self,card,context)
	  if context.cards_destroyed and not context.blueprint then
	    local cards = 0
		for k, v in pairs(context.glass_shattered) do
                    cards = cards + 1
        end
		if cards > 0 and card.ability.extra.safe == false then
		   card.ability.extra.safe = true
		   card.ability.extra.safe_text = 'Safe!'
		   return{
			   card = card,
			   message = 'Safe!',
			   colour = G.C.RED
		   }
		end

	  elseif context.remove_playing_cards and not context.blueprint then
	    local cards = 0
		for k, v in pairs(context.removed) do
                    cards = cards + 1
        end
		if cards > 0 and card.ability.extra.safe == false then
		  card.ability.extra.safe = true
		  card.ability.extra.safe_text = 'Safe!'
		  card_eval_status_text(card, 'extra', nil, nil, nil, {message = 'Safe!'})
		end
	  elseif context.end_of_round and not context.individual and not context.repetition and G.GAME.blind.boss and not context.blueprint then 
	     if card.ability.extra.safe == false then
	       G.E_MANAGER:add_event(Event({
                            func = function()
                                play_sound('tarot1')
                                card.T.r = -0.2
                                card:juice_up(0.3, 0.4)
                                card.states.drag.is = true
                                card.children.center.pinch.x = true
                                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                                    func = function()
                                            G.jokers:remove_card(card)
                                            card:remove()
                                            card = nil
                                        return true; end})) 
                                return true
                            end
                        })) 
                        return {
                            message = 'Too late',
							colour = G.C.FILTER
                        }
		 else 
		    card.ability.extra.safe_text = 'Late!' 
			card.ability.extra.safe = false
		 end
	  end
    end
}

--Anchor
SMODS.Joker{
	key = 'j_anchor',
	loc_txt = {
		name = 'Anchor',
		text = {
			'{X:mult,C:white}X#1#{} Mult if you have',
			'another {C:attention}Anchor{}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 7, y = 2},
	config = { extra = {
		Xmult = 4,
		id = 'this is an anchor!!'
	}},
	rarity = 2,
	cost = 7,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	loc_vars = function(self,info_queue,center)
	  return {vars = {
	                  center.ability.extra.Xmult}}
	end,
	calculate = function(self,card,context)
	   if context.joker_main then
	     if not context.blueprint then
	       local anchors = 0
		   for k, v in pairs(G.jokers.cards) do
		            if v.ability.extra ~= nil then
					if type(v.ability.extra) == 'table' then
                    if v ~= card and v.ability.extra.id == card.ability.extra.id then anchors = anchors + 1 end end end
		   end
	     
	       if anchors > 0 then
			  return{
				 card = card,
				 Xmult_mod = card.ability.extra.Xmult,
				 message = 'X' .. card.ability.extra.Xmult .. ' Mult',
				 colour = G.C.RED
			  }
		   end
		 elseif context.blueprint then
		   return{
				 card = card,
				 Xmult_mod = card.ability.extra.Xmult,
				 message = 'X' .. card.ability.extra.Xmult .. ' Mult',
				 colour = G.C.RED
			  }
		 end
	   end
    end
}

--DJ
SMODS.Joker{
	key = 'j_dj',
	loc_txt = {
		name = 'DJ',
		text = {
			'{C:attention}Retrigger{} all',
			'{C:attention}cards{} with {C:attention}Seals{}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 6, y = 0},
	config = { extra = {
		rep = 1
	}},
	rarity = 2,
	cost = 6,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	loc_vars = function(self,info_queue,center)
	  return {vars = {}}
	end,
    calculate = function(self,card,context)
	  if context.repetition and context.other_card.seal and context.cardarea == G.hand then
	       if (next(context.card_effects[1]) or #context.card_effects > 1) then
              return{
				card = card,
				message = localize('k_again_ex'),
                repetitions = card.ability.extra.rep
		      }
		   end
	  end
		if context.repetition and context.other_card.seal and context.cardarea == G.play then return{
				card = card,
				message = localize('k_again_ex'),
                repetitions = card.ability.extra.rep
		      }
		end
      
	  if context.discard and not context.other_card.debuff and context.other_card.seal == 'Purple' then 
	        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.0,
                func = (function()
                        local card = create_card('Tarot',G.consumeables, nil, nil, nil, nil, nil, '8ba')
                        card:add_to_deck()
                        G.consumeables:emplace(card)
                        G.GAME.consumeable_buffer = 0
                    return true
                end)}))
				return{
				card = card,
				message = localize('k_again_ex')
				}
	  end
    end
}

--Hexagonal Joker
SMODS.Joker{
	key = 'j_hexagonal',
	loc_txt = {
		name = 'Hexagonal Joker',
		text = {
			'Gives {X:mult,C:white}X#1#{} Mult for each',
			'{C:dark_edition}Polychrome{} {C:attention}Joker{} you have',
			'{C:inactive}(Currently {X:mult,C:white}X#2#{} {C:inactive}Mult)'
		}
	},
	atlas = 'atlas1',
	pos = {x = 2, y = 0},
	config = { extra = {
	Xmult_mod = 1.5,
	Xmult = 1,
	polychrome_tally = 0
	}},
	rarity = 3,
	cost = 8,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	loc_vars = function(self,info_queue,center)
	  info_queue[#info_queue+1] = G.P_CENTERS.e_polychrome
	  return {vars = {
		  center.ability.extra.Xmult_mod,
	      center.ability.extra.Xmult}}
	end,
	update = function(self,card,dt)
	  if G.STAGE == G.STAGES.RUN then
	        card.ability.extra.polychrome_tally = 0
            for k, v in pairs(G.jokers.cards) do
                if v.edition and v.edition.polychrome then card.ability.extra.polychrome_tally = card.ability.extra.polychrome_tally+1 end
            end
			card.ability.extra.Xmult = 1 + card.ability.extra.Xmult_mod * card.ability.extra.polychrome_tally
	  end
	end,
	calculate = function(self,card,context)
	  if context.joker_main then
	    if to_big(card.ability.extra.Xmult) ~= to_big(1) then
	      return {
			card = card,
			Xmult_mod = card.ability.extra.Xmult,
			message = 'X' .. card.ability.extra.Xmult .. ' Mult',
			colour = G.C.MULT
		  }
	      end
	    end
      end
}

--Transportation
SMODS.Joker{
	key = 'j_transport',
	loc_txt = {
		name = 'Transportation',
		text = {
			'{C:blue}Blue Seals{} activate',
			'when {C:attention}scored{}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 5, y = 0},
	config = { extra = {
	}},
	rarity = 2,
	cost = 5,
	unlocked = true,
    discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	loc_vars = function(self,info_queue,center)
	  return {vars = {}}
	end,
    calculate = function(self,card,context)
	  if context.individual and context.cardarea == G.play and context.other_card:get_seal(false) == 'Blue' and not context.blueprint and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
        local card_type = 'Planet'
        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
        G.E_MANAGER:add_event(Event({
            func = (function()
                
                    local _planet = 0
                    for k, v in pairs(G.P_CENTER_POOLS.Planet) do
                        if v.config.hand_type == G.GAME.last_hand_played then
                            _planet = v.key
                        end
                    end
                    local card = create_card(card_type,G.consumeables, nil, nil, nil, nil, _planet, 'blusl')
                    card:add_to_deck()
                    G.consumeables:emplace(card)
                    G.GAME.consumeable_buffer = 0
                
                return true
            end)}))
			return{
				card = card,
				message = 'Planet!',
				colour = G.C.CHIPS
			}
      end
    end
}

--High Risk, High Reward
SMODS.Joker{
	key = 'j_risk',
	loc_txt = {
		name = 'High Risk, High Reward',
		text = {
			'Create a {C:tarot}Tarot{} card when',
			'scored for each {C:attention}2 Jokers{} to',
			'the left, {C:attention}Blind{} gets {C:attention}+#1#%{}',
			'chips for each {C:tarot}Tarot{} card created',
			'{C:inactive}(Must have room){}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 8, y = 2},
	config = { extra = {
		percent = 50
	}},
	rarity = 2,
	cost = 8,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	loc_vars = function(self,info_queue,center)
	  return {vars = {
	                  center.ability.extra.percent}}
	end,
	calculate = function(self,card,context)
	   if context.before then
	      local jokers = 0
		  local tarots = 0
	      for i = 1, #G.jokers.cards do
	         if card.T.x + card.T.w/2 > G.jokers.cards[i].T.x + G.jokers.cards[i].T.w/2 then
			    jokers = jokers + 1
			 end
		  end
		  if jokers%2 == 0 then
		     jokers = jokers / 2
		  else
		     jokers = jokers / 2
			 jokers = jokers - 0.5
		  end
		  if jokers > 0 then
		     for i=1, jokers do
			     if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
				    tarots = tarots + 1
				 end
			 end
		  end
		  if tarots > 0 then
		     return{
				 card = card,
				 message = 'Difficulty Up!',
				 colour = G.C.RED
			 }
		  end
	   end
	   if context.joker_main then
	      local jokers = 0
		  local tarots = 0
	      for i = 1, #G.jokers.cards do
	         if card.T.x + card.T.w/2 > G.jokers.cards[i].T.x + G.jokers.cards[i].T.w/2 then
			    jokers = jokers + 1
			 end
		  end
		  if jokers%2 == 0 then
		     jokers = jokers / 2
		  else
		     jokers = jokers / 2
			 jokers = jokers - 0.5
		  end
		  if jokers > 0 then
		     for i=1, jokers do
			     if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
				    tarots = tarots + 1
				    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    G.E_MANAGER:add_event(Event({
                        trigger = 'before',
                        delay = 0.0,
                        func = (function()
                                local card = create_card('Tarot',G.consumeables, nil, nil, nil, nil, nil, 'risk')
                                card:add_to_deck()
                                G.consumeables:emplace(card)
                                G.GAME.consumeable_buffer = 0
                            return true
                        end)}))
				 end
			 end
		  end
		  if tarots > 0 then
		     G.GAME.blind.chips = G.GAME.blind.chips * (1 + (card.ability.extra.percent/100) * tarots)
			 G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
		     return {
                        message = localize('k_plus_tarot'),
                        card = card
                    }
		  end
	   end
    end
}

--Encrypted Joker
SMODS.Joker{
	key = 'j_encrypted',
	loc_txt = {
		name = 'Encrypted Joker',
		text = {
			'{C:mult}+#1#{} Mult for each scored card',
			'if all scored cards are of',
			'the same {C:attention}rank{} and {C:attention}suit{}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 1, y = 0},
	config = { extra = {
	mult = 20
	}},
	rarity = 2,
	cost = 5,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	loc_vars = function(self,info_queue,center)
	  return {vars = {
		  center.ability.extra.mult}}
	end,
	calculate = function(self,card,context)
	  if context.joker_main then
	    local rank = context.scoring_hand[1]:get_id()
		local suit = '' 
		for i = 1, #context.scoring_hand do
		  if context.scoring_hand[i].ability.name ~= 'Wild Card' then
		    if context.scoring_hand[i]:is_suit('Hearts') then 
		       suit = 'Hearts'
		    elseif context.scoring_hand[i]:is_suit('Diamonds') then 
		       suit = 'Diamonds'
		    elseif context.scoring_hand[i]:is_suit('Clubs') then 
		       suit = 'Clubs'
		    elseif context.scoring_hand[i]:is_suit('Spades') then 
		       suit = 'Spades'
			elseif context.scoring_hand[i].ability.name == 'Stone Card' then
			   suit = 'None'
			   rank = 0
		    break
	      end
		end
	      
		local valid = true
		if #context.scoring_hand ~= 1 then
		 for i = 2, #context.scoring_hand do
		  if context.scoring_hand[i].ability.name ~= 'Stone Card' and context.scoring_hand[i].ability.name ~= 'Wild Card' then
            if context.scoring_hand[i]:get_id() ~= rank then
			   valid = false
		    end
			if context.scoring_hand[i]:is_suit('Hearts') and suit ~= 'Hearts' then
			  valid = false
			end
			if context.scoring_hand[i]:is_suit('Diamonds') and suit ~= 'Diamonds' then
			  valid = false
			end
			if context.scoring_hand[i]:is_suit('Clubs') and suit ~= 'Clubs' then
			  valid = false
			end
			if context.scoring_hand[i]:is_suit('Spades') and suit ~= 'Spades' then
			  valid = false
			end
		  elseif context.scoring_hand[i].ability.name == 'Wild Card' then
		    if context.scoring_hand[i]:get_id() ~= rank then
			   valid = false
			end
	      elseif context.scoring_hand[i].ability.name == 'Stone Card' then
		    if rank ~= 0 and suit ~= 'None' then
			   valid = false
			end
		  end
		 end
		end

		if valid == true then
	      return {
			card = card,
			mult_mod = card.ability.extra.mult * #context.scoring_hand,
			message = '+' .. card.ability.extra.mult * #context.scoring_hand .. ' Mult',
			colour = G.C.MULT
		  }
	      end
		end
	  end
	end
}

--Essencia
SMODS.Joker{
	name = 'Essencia',
	key = 'j_essencia',
	loc_txt = {
		name = 'Essencia',
		text = {
			'Create a {C:dark_edition}Negative{} {C:tarot}Eternal{} {C:legendary}Legendary{}',
			'{C:attention}Joker{}, replace it with a new one',
			'when {C:attention}Blind is skipped{}',
			'{C:legendary,s:0.8}Essencia{} {C:inactive,s:0.8}cannot be created,{}',
			'{C:inactive,s:0.8}Destroy extra Joker when{} {C:legendary,s:0.8}Essencia{} {C:inactive,s:0.8}is sold{}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 10, y = 3},
	config = { extra = {
		created = false
	}},
	rarity = 4,
	cost = 20,
	unlocked = true,
    discovered = true,
	blueprint_compat = false,
	eternal_compat = false,
	perishable_compat = false,
	soul_pos= { x = 10, y = 2 },
	loc_vars = function(self,info_queue,center)
	  return {vars = {}}
	end,
	calculate = function(self,card,context)
	  if card.ability.extra.created == false and context.setting_blind and not context.blueprint then
	     card.ability.extra.created = true
		 local choices = {'j_caino', 'j_triboulet', 'j_yorick', 'j_chicot', 'j_perkeo', 'j_Unsorted_j_quasaro'}
		 local choice = pseudorandom_element(choices, pseudoseed('essencia'))
		 local joker = create_card('Joker', G.jokers, nil, nil, nil, nil, choice)
         joker:add_to_deck()
         G.jokers:emplace(joker)
		 local edition = {negative = true}
		 joker:set_edition(edition, true)
		 joker:set_eternal(true)
	  elseif context.skip_blind and not context.blueprint then
	     if card.ability.extra.created == true then
	      for i=1, #G.jokers.cards do
		    if G.jokers.cards[i].config.center.rarity == 4 and G.jokers.cards[i].ability.eternal then
			   G.jokers.cards[i].ability.eternal = nil
			   G.jokers.cards[i]:start_dissolve(nil, true)
			   break
			end
		  end
		 end
	     local choices = {'j_caino', 'j_triboulet', 'j_yorick', 'j_chicot', 'j_perkeo', 'j_Unsorted_j_quasaro'}
		 local choice = pseudorandom_element(choices, pseudoseed('essencia'))
		 local joker = create_card('Joker', G.jokers, nil, nil, nil, nil, choice)
         joker:add_to_deck()
         G.jokers:emplace(joker)
		 local edition = {negative = true}
		 joker:set_edition(edition, true)
		 joker:set_eternal(true)
		 card.ability.extra.created = true
	  elseif context.selling_self and not context.blueprint then
	    for i=1, #G.jokers.cards do
		    if G.jokers.cards[i].config.center.rarity == 4 and G.jokers.cards[i].ability.eternal then
			   G.jokers.cards[i].ability.eternal = nil
			   G.jokers.cards[i]:start_dissolve(nil, true)
			   break
			end
		end
	  end
    end
}

--Quasaro
SMODS.Joker{
	name = 'Quasaro',
	key = 'j_quasaro',
	loc_txt = {
		name = 'Quasaro',
		text = {
			'{C:green}#1# in #2#{} chance to upgrade level of',
			'{C:attention}all{} poker hands at {C:attention}end of round{}'
		}
	},
	atlas = 'atlas1',
	pos = {x = 10, y = 1},
	config = { extra = {
		odds = 2
	}},
	rarity = 4,
	cost = 20,
	unlocked = true,
    discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	soul_pos= { x = 10, y = 0 },
	loc_vars = function(self,info_queue,center)
	  return {vars = {G.GAME.probabilities.normal,
	                  center.ability.extra.odds}}
	end,
	calculate = function(self,card,context)
	  if context.end_of_round and not context.individual and not context.repetition then
	   if pseudorandom('quasaro') < G.GAME.probabilities.normal / card.ability.extra.odds then
	     update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize('k_all_hands'),chips = '...', mult = '...', level=''})
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
            play_sound('tarot1')
            card:juice_up(0.8, 0.5)
            G.TAROT_INTERRUPT_PULSE = true
            return true end }))
        update_hand_text({delay = 0}, {mult = '+', StatusText = true})
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
            play_sound('tarot1')
            card:juice_up(0.8, 0.5)
            return true end }))
        update_hand_text({delay = 0}, {chips = '+', StatusText = true})
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
            play_sound('tarot1')
            card:juice_up(0.8, 0.5)
            G.TAROT_INTERRUPT_PULSE = nil
            return true end }))
        update_hand_text({sound = 'button', volume = 0.7, pitch = 0.9, delay = 0}, {level='+1'})
        delay(1.3)
        for k, v in pairs(G.GAME.hands) do
            level_up_hand(card, k, true)
        end
        update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
	   end
	  end
    end
}

--TAROT CARDS

local function valid_consumeable_use(max, selected)
   if selected > 0 and selected <= max then 
        return true
   else return false
   end
end

local function change_enhancement(hand, newcenter)
	for i=1, #hand do
		local percent = 1.15 - (i-0.999)/(#hand-0.998)*0.3
		G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() hand[i]:flip();play_sound('card1', percent);hand[i]:juice_up(0.3, 0.3);return true end }))
	end
	delay(0.2)
	for i=1, #hand do
	G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
				hand[i]:set_ability(G.P_CENTERS[newcenter])
				return true end }))
	end
	for i=1, #hand do
		local percent = 0.85 + (i-0.999)/(#hand-0.998)*0.3
		G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() hand[i]:flip();play_sound('tarot2', percent, 0.6);hand[i]:juice_up(0.3, 0.3);return true end }))
	end
	G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
	delay(0.5)
end

--The Trash
SMODS.Consumable{
	set = 'Tarot',
	atlas = 'atlasTarots',
	key = 'trash',
	config = { extra = {
		dollars = 4
	}},
	pos = {x = 0, y = 0},
	can_use = function(self, card)
	   return true
	end,
	loc_txt = {
        name = 'The Trash',
        text = {
            'Gives {C:money}$#1#{} for each',
            '{C:red}Discard{} you have'
        }
    },
	loc_vars = function(self,info_queue,center)
	  return {vars = {center.ability.extra.dollars}}
	end,
	cost = 3,
	use = function(self, card, area, copier)
	   ease_dollars(card.ability.extra.dollars * G.GAME.current_round.discards_left)
	end
}

--The Illusionist
SMODS.Consumable{
	set = 'Tarot',
	atlas = 'atlasTarots',
	key = 'illusionist',
	config = { extra = {
		max = 1
	}},
	pos = {x = 2, y = 0},
	can_use = function(self, card)
	 if G.hand then
	   return valid_consumeable_use(card.ability.extra.max, #G.hand.highlighted)
	 else return false
	 end
	end,
	loc_txt = {
        name = 'The Illusionist',
        text = {
            'Enhances {C:attention}#1#{} selected',
			'card into a',
            '{C:attention}Trick{} card'
        }
    },
	loc_vars = function(self,info_queue,center)
	  info_queue[#info_queue+1] = G.P_CENTERS.m_Unsorted_trick
	  return {vars = {center.ability.extra.max}}
	end,
	cost = 3,
	use = function(self, card, area, copier)
			change_enhancement(G.hand.highlighted, 'm_Unsorted_trick')
	end
}

--The Sign
SMODS.Consumable{
	set = 'Tarot',
	atlas = 'atlasTarots',
	key = 'sign',
	config = { extra = {
		tags = {'tag_charm', 'tag_meteor', 'tag_buffoon'}
	}},
	pos = {x = 4, y = 0},
	can_use = function(self, card)
	   return true
	end,
	loc_txt = {
        name = 'The Sign',
        text = {
            'Gain a {C:attention}Charm Tag{},',
            '{C:attention}Meteor Tag{} or {C:attention}Buffoon Tag{}'
        }
    },
	loc_vars = function(self,info_queue,center)
	    info_queue[#info_queue+1] = {key = 'tag_charm', set = 'Tag'}
        info_queue[#info_queue+1] = {key = 'tag_meteor', set = 'Tag'}
        info_queue[#info_queue+1] = {key = 'tag_buffoon', set = 'Tag'}
	  return {vars = {}}
	end,
	cost = 3,
	use = function(self, card, area, copier)
	   add_tag(Tag(pseudorandom_element(card.ability.extra.tags, pseudoseed('sign'))))
	end
}

--The Scales
SMODS.Consumable{
	set = 'Tarot',
	atlas = 'atlasTarots',
	key = 'scales',
	config = { extra = {
		max = 1
	}},
	pos = {x = 1, y = 0},
	can_use = function(self, card)
	 if G.hand then
	   return valid_consumeable_use(card.ability.extra.max, #G.hand.highlighted)
	 else return false
	 end
	end,
	loc_txt = {
        name = 'The Scales',
        text = {
            'Enhances {C:attention}#1#{} selected',
			'card into a',
            '{C:attention}Balance{} card'
        }
    },
	loc_vars = function(self,info_queue,center)
	  info_queue[#info_queue+1] = G.P_CENTERS.m_Unsorted_balance
	  return {vars = {center.ability.extra.max}}
	end,
	cost = 3,
	use = function(self, card, area, copier)
			change_enhancement(G.hand.highlighted, 'm_Unsorted_balance')
	end
}

--The Chaos
SMODS.Consumable{
	set = 'Tarot',
	atlas = 'atlasTarots',
	key = 'chaos',
	config = { extra = {
		max = 5
	}},
	pos = {x = 3, y = 0},
	can_use = function(self, card)
	 if G.hand then
	   return valid_consumeable_use(card.ability.extra.max, #G.hand.highlighted)
	 else return false
	 end
	end,
	loc_txt = {
        name = 'The Chaos',
        text = {
            'Randomize the {C:attention}suit{} and',
			'{C:attention}rank{} of up to',
            '{C:attention}#1#{} selected cards'
        }
    },
	loc_vars = function(self,info_queue,center)
	  return {vars = {center.ability.extra.max}}
	end,
	cost = 3,
	use = function(self, card, area, copier)
			for i=1, #G.hand.highlighted do
		local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
		G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
	  end
	  delay(0.2)
	  for i=1, #G.hand.highlighted do
	     local _suit = pseudorandom_element({'S','H','D','C'}, pseudoseed('chaos1'))
	     local _rank = pseudorandom_element({'2','3','4','5','6','7','8','9','T','J','Q','K','A'}, pseudoseed('chaos2'))
	     G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
		 local suit_prefix = _suit..'_'
                    local rank_suffix = _rank
				G.hand.highlighted[i]:set_base(G.P_CARDS[suit_prefix..rank_suffix])
				return true end }))
	  end
	  for i=1, #G.hand.highlighted do
		local percent = 0.85 + (i-0.999)/(#G.hand.highlighted-0.998)*0.3
		G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('tarot2', percent, 0.6);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
	  end
	  G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
	  delay(0.5)
    end
}

--NEW ENHANCEMENTS
SMODS.Enhancement {
    key = 'balance',
	pos = {x = 0, y = 0},
	replace_base_card = false,
    no_suit = false,
    no_rank = false,
    always_scores = false,
    loc_txt = {
        name = 'Balance Card',
        text = {'Balances {C:chips}Chips{} and',
		        '{C:mult}Mult{}, then gives',
                '{X:mult,C:white}X#1#{} Mult'}
    },
    atlas = 'atlasEnhancements',
    config = {extra = {Xmult = 0.5}},
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.Xmult}}
    end,
	calculate = function(self, card, context)
	   if context.cardarea == G.play and context.main_scoring then
	      local total = hand_chips + mult
		  hand_chips = mod_chips(math.floor(total/2))
		  mult = mod_mult(math.floor(total/2))
		  update_hand_text({delay = 0}, {mult = mult, chips = hand_chips})
		  return {
				x_mult = card.ability.extra.Xmult,
				message = localize('k_balanced'),
				colour = {0.8, 0.45, 0.85, 1},
				card = card
		  }
	   end
	end
}

SMODS.Enhancement {
    key = 'trick',
	pos = {x = 1, y = 0},
	replace_base_card = false,
    no_suit = false,
    no_rank = false,
    always_scores = false,
    loc_txt = {
        name = 'Trick Card',
        text = {'Gives {X:mult,C:white}X#1#{} Mult for',
		        'each {C:attention}Consumable{}',
                'you have'}
    },
    atlas = 'atlasEnhancements',
    config = {extra = {Xmult = 0.25}},
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.Xmult}}
    end,
	calculate = function(self, card, context)
	   if context.cardarea == G.play and context.main_scoring then
		  return {
				x_mult = card.ability.extra.Xmult * #G.consumeables.cards + 1,
				colour = G.C.MULT,
				card = card
		  }
	   end
	end
}

----------------------------------------------
------------MOD CODE END----------------------
