-- The Shinigami of Twin Realms - Zangetsu Unleashed
-- Rush Duel custom card
-- Card ID: 190019106

local s,id=GetID()

local SHINIGAMI_FROM_AFAR=190019100
local ZANGETSU=190019101
local FINAL_GETSUGA_TENSHO=190019113
local PIERCING_GETSUGA=190019114

function s.initial_effect(c)
	c:EnableReviveLimit()

	-- [MATERIALS]
	-- "The Shinigami From Afar - Born in the Dark" + "Zangetsu"
	Fusion.AddProcMix(c,true,true,SHINIGAMI_FROM_AFAR,ZANGETSU)

	-- Can also be Special Summoned from the Extra Deck by shuffling
	-- the above face-up cards from your field into the owners' Decks.
	Fusion.AddContactProc(
		c,
		s.contactmat,
		s.contactop,
		nil,
		nil,
		SUMMON_TYPE_FUSION
	)

	-- [REQUIREMENT]
	-- Shuffle 1 Spell or Trap from your Graveyard into your Deck.
	--
	-- [EFFECT]
	-- This card gains 400 ATK until the end of this turn.
	-- Then, you can add 1 "The Final Getsuga Tensho" or
	-- "Piercing Getsuga" from your Graveyard to your hand.
	-- If you do, this card cannot be destroyed by your opponent's
	-- card effects until the end of your opponent's turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_ATKCHANGE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

-- Contact Fusion materials come only from your face-up Monster Zone.
-- Fusion.AddContactProc uses this pool together with the listed Fusion
-- material procedure above, so it will require exactly the two named cards.
function s.contactmat(tp)
	return Duel.GetMatchingGroup(
		Card.IsFaceup,tp,LOCATION_MZONE,0,nil
	)
end

-- Shuffle the selected face-up Fusion Materials into their owners' Decks.
function s.contactop(g,tp,c)
	c:SetMaterial(g)
	Duel.SendtoDeck(
		g,nil,SEQ_DECKSHUFFLE,
		REASON_MATERIAL+REASON_FUSION
	)
end

-- Spell/Trap for the Requirement
function s.costfilter(c)
	return c:IsSpellTrap() and c:IsAbleToDeckAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.costfilter,tp,LOCATION_GRAVE,0,1,nil
		)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(
		tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil
	)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	end
end

-- The two Getsuga cards this effect can recover
function s.thfilter(c)
	return c:IsCode(FINAL_GETSUGA_TENSHO,PIERCING_GETSUGA)
		and c:IsAbleToHand()
end

-- Protection applies only against the opponent's card effects.
function s.indval(e,re,rp)
	return rp~=e:GetHandlerPlayer()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsFaceup() and c:IsRelateToEffect(e)) then return end

	-- This card gains 400 ATK until the end of this turn.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(400)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)

	-- Then, you can recover 1 of the listed Getsuga cards.
	if Duel.IsExistingMatchingCard(
			s.thfilter,tp,LOCATION_GRAVE,0,1,nil
		)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(
			tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil
		)
		local tc=g:GetFirst()
		if not tc then return end

		if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,tc)

			-- If you do, this card cannot be destroyed by the opponent's
			-- card effects until the end of the opponent's turn.
			if c:IsFaceup() and c:IsRelateToEffect(e) then
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
				e2:SetValue(s.indval)
				-- The effect is activated during your turn:
				-- reset after your End Phase and the opponent's End Phase.
				e2:SetReset(
					RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,
					2
				)
				c:RegisterEffect(e2)
			end
		end
	end
end
