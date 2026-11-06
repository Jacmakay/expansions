-- Dominus Emperot's Loyal Servant
local s,id=GetID()
function s.initial_effect(c)
 -- Shuffle 3 monsters, then shuffle a card from the spell and trap zone
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

function s.cfilter(c)
	return c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local cg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(cg,e,tp,3,3,0) end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tdg=Duel.GetMatchingGroup(Card.IsExists,tp,0,LOCATION_STZONE,nil)
	if chk==0 then return #tdg>0 end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local cg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	local g=aux.SelectUnselectGroup(cg,e,tp,3,3,1,tp,HINTMSG_TODECK)
	Duel.HintSelection(g)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)<1 then return end
	--Effect
	local tdg=Duel.GetMatchingGroup(Card.IsExists,tp,0,LOCATION_STZONE,nil)
	if #dg>0 then
		local sg=tdg:Select(tp,1,1,nil)
		Duel.HintSelection(sg)
		Duel.SendtoDeck(sg,REASON_EFFECT)
	end
end