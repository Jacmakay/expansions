-- Blue-Eyes Maximum Violet Dragon, The Pride of Purple
-- Card ID: 190019042
-- Fusion Materials:
-- "Maximum Violet Whelp" + 1 Level 7 or 8 LIGHT Dragon monster
local s,id=GetID()

function s.initial_effect(c)
	c:EnableReviveLimit()

	-- Fusion procedure
	Fusion.AddProcMix(c,true,true,190019008,s.matfilter)

	-- Contact Fusion procedure
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)

	-- This card's name becomes "Blue-Eyes White Dragon" while in the GY.
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetRange(LOCATION_GRAVE)
	e0:SetValue(89631139)
	c:RegisterEffect(e0)

	-- [REQUIREMENT]
	-- Shuffle 3 Dragon monsters from your GY into the Deck.
	-- [EFFECT]
	-- Destroy all face-up monsters your opponent controls.
	-- This card cannot attack directly this turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

-- Level 7 or 8 LIGHT Dragon Fusion Material
function s.matfilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_DRAGON)
		and c:IsAttribute(ATTRIBUTE_LIGHT)
		and (c:IsLevel(7) or c:IsLevel(8))
end

-- Face-up monsters you control can be used for the Contact Fusion.
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
end

-- Return Contact Fusion materials to the Deck.
function s.contactop(g,tp)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,
		REASON_COST|REASON_MATERIAL|REASON_FUSION)
end

function s.splimit(e,se,sp,st)
	return true
end

-- Dragon monsters that can be shuffled into the Deck for the requirement.
function s.costfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToDeckAsCost()
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
	Duel.ShuffleDeck(tp)
end

function s.desfilter(c)
	return c:IsFaceup()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	-- Destroy all face-up monsters the opponent controls.
	local g=Duel.GetMatchingGroup(
		s.desfilter,tp,0,LOCATION_MZONE,nil
	)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end

	-- This card cannot attack directly this turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
	c:RegisterEffect(e1)
end
