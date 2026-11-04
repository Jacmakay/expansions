-- Yggdrago Heavenly Venom
-- Card ID: 190019049
local s,id=GetID()

function s.initial_effect(c)
	-- Fusion Materials: 2 DARK or LIGHT Cyberse monsters
	c:EnableReviveLimit()
	Fusion.AddProcFunRep(c,s.ffilter,2,true)

	-- [REQUIREMENT] During your Main Phase that you Special Summon this card.
	-- [EFFECT] Choose 1 face-up monster your opponent controls;
	-- this card gains ATK equal to that monster's ATK until the end of this turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end

-- Fusion Material filter:
-- DARK or LIGHT Cyberse monster
function s.ffilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_CYBERSE)
		and (c:IsAttribute(ATTRIBUTE_DARK) or c:IsAttribute(ATTRIBUTE_LIGHT))
end

-- This effect can only be used during the turn this card was Special Summoned.
-- As an Ignition Effect, it is naturally activated during your Main Phase.
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN)
end

function s.atkfilter(c)
	return c:IsFaceup()
end

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.atkfilter,tp,0,LOCATION_MZONE,1,nil)
	end
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.atkfilter,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end

	local atk=math.max(tc:GetAttack(),0)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
	c:RegisterEffect(e1)
end
