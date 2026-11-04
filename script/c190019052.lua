-- U-T-W Master Diamond Weapons Mode Two
-- Card ID: 190019052
-- Level 12 / EARTH / Rock / Fusion / Effect
-- Fusion Materials: 3 Rock monsters
--
-- [REQUIREMENT]
-- Shuffle 3 Rock monsters from your Graveyard into the Deck.
--
-- [EFFECT]
-- Until the end of your opponent's turn, this card cannot be destroyed by
-- card effects nor be returned to the Extra Deck, then you can Special Summon
-- 1 DARK Galaxy monster from your Graveyard.

local s,id=GetID()

function s.initial_effect(c)
	-- Fusion Summon: 3 Rock monsters
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_ROCK),3)

	-- [REQUIREMENT] Shuffle 3 Rock monsters from your GY.
	-- [EFFECT] Protection until the end of opponent's turn, then optionally
	-- Special Summon 1 DARK Galaxy monster from your GY.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

-- Rock monsters that can actually be shuffled into the Main Deck as a cost
function s.costfilter(c)
	return c:IsMonster() and c:IsRace(RACE_ROCK) and c:IsAbleToDeckAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,3,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

-- "Dark Galaxy Monster" is implemented as a DARK-Attribute Galaxy-Type monster.
function s.spfilter(c,e,tp)
	return c:IsMonster()
		and c:IsRace(RACE_GALAXY)
		and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	-- "This card" must still be face-up to gain the protection.
	if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end

	-- Protection lasts through this turn's End Phase and the opponent's End Phase.
	local reset=RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END

	-- Cannot be destroyed by card effects.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(1)
	e1:SetReset(reset,2)
	c:RegisterEffect(e1)

	-- A Fusion Monster returned to the Deck goes to the Extra Deck.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_TO_DECK)
	e2:SetReset(reset,2)
	c:RegisterEffect(e2)

	-- A Fusion Monster that would be returned to the hand is also returned
	-- to the Extra Deck, so block that route as well.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_TO_HAND)
	e3:SetReset(reset,2)
	c:RegisterEffect(e3)

	-- Then you can Special Summon 1 DARK Galaxy monster from your GY.
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if not Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),
		tp,LOCATION_GRAVE,0,1,nil,e,tp) then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),
		tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
