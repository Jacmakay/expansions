--Voidvelg Apocalypse Protostar
local s,id=GetID()

local CARD_DARK_PROPHET=160205048
local CARD_VOIDVELG_GLOBULE=160317015

function s.initial_effect(c)
	--[REQUIREMENT]
	--Shuffle 2 DARK Galaxy monsters from your GY into the Deck.
	--
	--[EFFECT]
	--Add 1 "Dark Prophet" from your GY to your hand,
	--then this card's name becomes "Voidvelg Globule" until the End Phase.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

--DARK Galaxy monsters that can be shuffled into the Deck as the Requirement
function s.costfilter(c)
	return c:IsMonster()
		and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsRace(RACE_GALAXY)
		and c:IsAbleToDeckAsCost()
end

--[REQUIREMENT]
--Shuffle exactly 2 DARK Galaxy monsters from your GY into the Deck.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.costfilter,
			tp,
			LOCATION_GRAVE,
			0,
			2,
			nil
		)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(
		tp,
		s.costfilter,
		tp,
		LOCATION_GRAVE,
		0,
		2,
		2,
		nil
	)

	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

--"Dark Prophet" that can be added to the hand
function s.thfilter(c)
	return c:IsCode(CARD_DARK_PROPHET)
		and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.thfilter,
			tp,
			LOCATION_GRAVE,
			0,
			1,
			nil
		)
	end

	Duel.SetOperationInfo(
		0,
		CATEGORY_TOHAND,
		nil,
		1,
		tp,
		LOCATION_GRAVE
	)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	--Add 1 "Dark Prophet" from the GY to the hand
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(
		tp,
		aux.NecroValleyFilter(s.thfilter),
		tp,
		LOCATION_GRAVE,
		0,
		1,
		1,
		nil
	)

	local tc=g:GetFirst()
	if not tc then return end

	if Duel.SendtoHand(tc,nil,REASON_EFFECT)==0 then
		return
	end
	Duel.ConfirmCards(1-tp,tc)

	--Then this card's name becomes "Voidvelg Globule" this turn
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(CARD_VOIDVELG_GLOBULE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e1)
	end
end
