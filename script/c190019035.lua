--Crimson Sovereign
local s,id=GetID()

function s.initial_effect(c)
	--Fusion Materials: 2 Level 9 or higher Wyrm monsters
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.matfilter,2)

	--[REQUIREMENT]
	--During your Main Phase that you Fusion Summoned this card.
	--[EFFECT]
	--Destroy all Attack Position monsters your opponent controls with 3000 or less ATK,
	--then this card gains 500 ATK for each monster destroyed.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end

function s.matfilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_WYRM) and c:IsLevelAbove(9)
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsMainPhase()
		and c:IsSummonType(SUMMON_TYPE_FUSION)
		and c:IsStatus(STATUS_SPSUMMON_TURN)
end

function s.desfilter(c)
	return c:IsFaceup()
		and c:IsAttackPos()
		and c:IsAttackBelow(3000)
		and c:IsDestructable()
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end

	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
