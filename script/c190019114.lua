-- Piercing Getsuga
-- Rush Duel custom card
-- Card ID: 190019114

local s,id=GetID()

function s.initial_effect(c)
	-- Activate when an opponent's monster declares an attack
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-- Face-up Warrior-Type monster you control
function s.warriorfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end

-- Level 7 or higher Warrior-Type monster in your Graveyard
function s.highwarriorfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsLevelAbove(7)
end

-- Level 4 or lower Warrior-Type monster that can be Special Summoned
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR)
		and c:IsLevelBelow(4)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	return a
		and a:IsControler(1-tp)
		and Duel.IsExistingMatchingCard(s.warriorfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local a=Duel.GetAttacker()
		return a and a:IsControler(1-tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,Duel.GetAttacker(),1,0,-1000)
	-- The Special Summon is optional and is checked again when the effect resolves.
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	if not a or not a:IsRelateToBattle() or not a:IsFaceup() then return end

	-- The attacking monster loses 1000 ATK until the end of this turn.
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	a:RegisterEffect(e1)

	-- Then, if you have a Level 7 or higher Warrior in your Graveyard,
	-- you can Special Summon 1 Level 4 or lower Warrior from your Graveyard
	-- in face-up Defense Position.
	if Duel.IsExistingMatchingCard(s.highwarriorfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
