-- Heaven's End Drasela
-- Card ID: 190019051
local s,id=GetID()

local YGGDRAGO_DRASELA=190019046

function s.initial_effect(c)
	-- Fusion Materials:
	-- "Yggdrago Drasela" + 1 DARK Cyberse monster
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,YGGDRAGO_DRASELA,s.matfilter)

	-- Rush Duel Contact Fusion:
	-- Return the listed face-up materials you control to the Deck/Extra Deck.
	Fusion.AddContactProc(c,s.contactfilter,s.contactop,nil,nil,SUMMON_TYPE_FUSION)

	-- [REQUIREMENT] None
	-- [EFFECT] Special Summon 1 DARK Cyberse monster from your GY,
	-- then this card can attack directly this turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end

-- Second Fusion Material:
-- 1 DARK Cyberse monster
function s.matfilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsRace(RACE_CYBERSE)
end

-- Contact Fusion uses face-up monsters you control that can be
-- returned to the Deck/Extra Deck as material.
function s.contactfilter(tp)
	return Duel.GetMatchingGroup(
		aux.FaceupFilter(Card.IsAbleToDeckOrExtraAsCost),
		tp,LOCATION_MZONE,0,nil
	)
end

function s.contactop(g,tp,c)
	Duel.SendtoDeck(
		g,nil,SEQ_DECKSHUFFLE,
		REASON_COST|REASON_MATERIAL|REASON_FUSION
	)
end

-- GY monster to Special Summon
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsRace(RACE_CYBERSE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(
				aux.NecroValleyFilter(s.spfilter),
				tp,LOCATION_GRAVE,0,1,nil,e,tp
			)
	end
	Duel.SetOperationInfo(
		0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE
	)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(
		tp,
		aux.NecroValleyFilter(s.spfilter),
		tp,LOCATION_GRAVE,0,1,1,nil,e,tp
	)
	if #g==0 then return end

	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0
		and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- This card can attack directly this turn.
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e1)
	end
end
