--U-T-W Mad Fiend Deity
--ID: 190019076
local s,id=GetID()

local CARD_UTW_COMBINATION_MANUEVER=190019079

function s.initial_effect(c)
	--[REQUIREMENT]
	--Shuffle 3 cards from your Graveyard into the Deck
	--[EFFECT]
	--Increase this card's Level by 8, then you can add
	--1 "U-T-W Combination Manuever" from your Graveyard to your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_LVCHANGE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

function s.costfilter(c)
	return c:IsAbleToDeckAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.costfilter,tp,LOCATION_GRAVE,0,3,nil
		)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(
		tp,s.costfilter,tp,LOCATION_GRAVE,0,3,3,nil
	)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.thfilter(c)
	return c:IsCode(CARD_UTW_COMBINATION_MANUEVER)
		and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SetOperationInfo(
		0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE
	)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	--Increase this card's Level by 8
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		c:UpdateLevel(8)
	end

	--Then you can add 1 "U-T-W Combination Manuever"
	if Duel.IsExistingMatchingCard(
		s.thfilter,tp,LOCATION_GRAVE,0,1,nil
	) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(
			tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil
		)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
