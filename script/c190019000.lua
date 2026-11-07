-- Dominus Noir
local s,id=GetID()

function s.initial_effect(c)
 -- tribute summon using 1 level 1 or 2 monster
 local e1=aux.AddNormalSummonProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),s.cfilter)
 -- change battle position also shuffle a backrow
 local e1=Effect.CreateEffect(c)
 	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

function s.cfilter(c)
    return c:IsLevelBetween(1,2)
end

function s.shfilter(c)
    return c:IsFacedown() and c:IsAbleToDeck()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(IsAbleToGraveAsCost,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanChangePositionRush,tp,0,LOCATION_MZONE,1,nil) end
    local tdg=Duel.GetMatchingGroup(s.shfilter,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #tdg>0 end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectMatchingCard(tp,Card.IsCanChangePositionRush,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.HintSelection(g)
	if Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)>0 then
    if Duel.IsExistingMatchingCard(s.shfilter,tp,0,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local g=Duel.SelectMatchingCard(tp,s.shfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
			if #g==0 then return end
			Duel.HintSelection(g)
			Duel.BreakEffect()
			Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
    end
  end
end