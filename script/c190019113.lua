-- The Final Getsuga Tensho
-- Rush Duel custom card
-- Card ID: 190019113

local s,id=GetID()

function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-- Face-up Level 7+ Warrior you control that can satisfy the Requirement
function s.reqfilter(c,tp)
	return c:IsFaceup()
		and c:IsRace(RACE_WARRIOR)
		and c:IsLevelAbove(7)
		and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetLevel())
end

-- Opponent's face-up monster with Level equal to or lower than the stored Level
function s.desfilter(c,lv)
	return c:IsFaceup() and c:IsLevelBelow(lv)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.reqfilter,tp,LOCATION_MZONE,0,1,nil,tp)
	end

	-- Choose the Warrior used to meet the Requirement and remember its Level
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.reqfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if not tc then return end

	e:SetLabel(tc:GetLevel())

	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,1,tp,LOCATION_DECK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	if lv<=0 then return end

	-- Rush Duel effects normally do not target unless the text specifically says so.
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,lv)
	if #g==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg=g:Select(tp,1,1,nil)
	local tc=sg:GetFirst()
	if not tc then return end

	-- "Then" means the draw is only available if the monster was actually destroyed.
	if Duel.Destroy(tc,REASON_EFFECT)>0
		and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
		and Duel.IsPlayerCanDraw(tp,1)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
