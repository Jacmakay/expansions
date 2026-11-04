--U-T-W Combined Manuever
--ID: 190019079
local s,id=GetID()

function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.costfilter(c)
	return c:IsMonster()
		and c:IsAttack(500)
		and c:IsAbleToDeckAsCost()
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

function s.desfilter(c)
	return c:IsLocation(LOCATION_SZONE)
end

function s.lv9filter(c)
	return c:IsMonster() and c:IsLevel(9)
end

function s.spfilter(c,e,tp)
	return c:IsMonster()
		and c:IsLevel(1)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.desfilter,tp,0,LOCATION_SZONE,1,nil
		)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_SZONE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(
		tp,s.desfilter,tp,0,LOCATION_SZONE,1,1,nil
	)
	if #g==0 then return end

	Duel.Destroy(g,REASON_EFFECT)

	if Duel.GetMatchingGroupCount(
		s.lv9filter,tp,LOCATION_GRAVE,0,nil
	)>=2
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(
			s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp
		) then

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(
			tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp
		)

		if #sg>0 then
			Duel.SpecialSummon(
				sg,0,tp,tp,false,false,POS_FACEUP
			)
		end
	end
end
