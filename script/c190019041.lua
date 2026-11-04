-- Red-Eyes Maximum Violet Dragon, The Darkness in Purple
-- Card ID: 190019041
-- Fusion Materials: Maximum Violet Whelp + 1 Level 7 DARK Dragon monster
local s,id=GetID()

function s.initial_effect(c)
	c:EnableReviveLimit()

	-- Fusion materials
	Fusion.AddProcMix(c,true,true,190019008,s.matfilter)

	-- Contact Fusion procedure: shuffle the listed materials you control into the Deck.
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)

	-- This card's name becomes "Red-Eyes Black Dragon" while in the GY.
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetRange(LOCATION_GRAVE)
	e0:SetValue(CARD_REDEYES_B_DRAGON or 74677422)
	c:RegisterEffect(e0)

	-- [REQUIREMENT] Send the top 3 cards of your Deck to the GY.
	-- [EFFECT] Send 1 card from your hand to the GY. Then add 1 LIGHT/DARK
	-- Dragon/Warrior monster from your GY to your hand. Also, you can add
	-- 1 "Hand's Combination Technique" from your GY to your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

function s.matfilter(c,fc,sumtype,tp)
	return c:IsLevel(7)
		and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsRace(RACE_DRAGON)
end

-- Contact Fusion materials must be face-up monsters you control.
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
end

function s.contactop(g,tp)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST|REASON_MATERIAL|REASON_FUSION)
end

function s.splimit(e,se,sp,st)
	return true
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
	end
	Duel.DiscardDeck(tp,3,REASON_COST)
end

function s.handfilter(c)
	return c:IsAbleToGrave()
end

function s.thfilter(c)
	return c:IsMonster()
		and (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK))
		and (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_WARRIOR))
		and c:IsAbleToHand()
end

-- Replace this ID if your "Hand's Combination Technique" card uses a different ID.
s.hand_combination_technique=190019029

function s.techfilter(c)
	return c:IsCode(s.hand_combination_technique) and c:IsAbleToHand()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- Send 1 card from hand to GY.
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local hg=Duel.SelectMatchingCard(tp,s.handfilter,tp,LOCATION_HAND,0,1,1,nil)
	if #hg==0 or Duel.SendtoGrave(hg,REASON_EFFECT)==0 then return end

	-- Then add 1 LIGHT/DARK Dragon/Warrior monster from GY.
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end

	-- Also, optionally add "Hand's Combination Technique" from GY.
	if Duel.IsExistingMatchingCard(s.techfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.techfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
