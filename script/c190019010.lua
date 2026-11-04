--Red Technique Reversal
local s,id=GetID()

function s.initial_effect(c)
	--【REQUIREMENT】Shuffle 2 Dragon monsters from your GY into the Deck.
	--【EFFECT】Add 1 Level 7 or 8 LIGHT/DARK Dragon monster from your GY to your hand.
	--Then, if you added a Level 7 DARK Dragon, you can destroy 1 card
	--in your opponent's Spell & Trap Zone.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

--Requirement: 2 Dragon monsters in your GY that can be returned to the Deck.
function s.costfilter(c)
	return c:IsRace(RACE_DRAGON)
		and ((c:IsType(TYPE_FUSION) or c:IsType(TYPE_RITUAL)) and c:IsAbleToExtraAsCost()
			or (not c:IsType(TYPE_FUSION) and not c:IsType(TYPE_RITUAL) and c:IsAbleToDeckAsCost()))
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,2,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

--Level 7 or 8 LIGHT/DARK Dragon monster.
function s.thfilter(c)
	return c:IsRace(RACE_DRAGON)
		and (c:IsLevel(7) or c:IsLevel(8))
		and (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK))
		and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end

	local lv7dark=tc:IsLevel(7) and tc:IsAttribute(ATTRIBUTE_DARK)
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)==0 then return end
	Duel.ConfirmCards(1-tp,tc)

	--If the added monster was a Level 7 DARK Dragon, optionally destroy
	--1 opponent Spell/Trap.
	if lv7dark and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_SZONE,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_SZONE,1,1,nil)
		if #dg>0 then
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
