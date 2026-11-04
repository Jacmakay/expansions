-- Yggdrago Drasela
-- Card ID: 190019046
local s,id=GetID()

function s.initial_effect(c)
	-- [REQUIREMENT] Send this card to the Graveyard.
	-- [EFFECT] Special Summon 1 Level 7 or higher DARK Cyberse monster
	-- from your Graveyard to your field.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToGraveAsCost()
	end
	Duel.SendtoGrave(c,REASON_COST)
end

function s.spfilter(c,e,tp)
	return c:IsLevelAbove(7)
		and c:IsAttribute(ATTRIBUTE_DARK)
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
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(
		tp,
		aux.NecroValleyFilter(s.spfilter),
		tp,LOCATION_GRAVE,0,1,1,nil,e,tp
	)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
