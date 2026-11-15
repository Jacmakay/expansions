-- Zangetsu
-- Rush Duel custom card
-- Card ID: 190019101

local s,id=GetID()

local SHINIGAMI_FROM_AFAR=190019100

function s.initial_effect(c)
	-- [REQUIREMENT]
	-- Shuffle 1 Warrior-Type monster from your Graveyard into the Deck.
	--
	-- [EFFECT]
	-- Choose 1 "The Shinigami From Afar - Born in the Dark" from your Graveyard
	-- and add it to your hand. Then, this card gains 500 ATK until the end of this turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

-- Card to recover
function s.thfilter(c)
	return c:IsCode(SHINIGAMI_FROM_AFAR) and c:IsAbleToHand()
end

-- Warrior used for the Requirement.
-- If the Warrior itself is "The Shinigami From Afar - Born in the Dark",
-- only allow it to be shuffled if another valid copy will remain in the GY.
function s.costfilter(c,tp)
	if not (c:IsMonster() and c:IsRace(RACE_WARRIOR) and c:IsAbleToDeckAsCost()) then
		return false
	end
	if c:IsCode(SHINIGAMI_FROM_AFAR) then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,c)
	end
	return true
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(
		tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp
	)

	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.thfilter,tp,LOCATION_GRAVE,0,1,nil
		)
	end

	Duel.SetOperationInfo(
		0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE
	)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	-- Choose 1 "The Shinigami From Afar - Born in the Dark" from your GY
	-- and add it to your hand.
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(
		tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil
	)

	local tc=g:GetFirst()
	if not tc then return end

	if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,tc)

		-- Then, this card gains 500 ATK until the end of this turn.
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end
