-- Faded Memory From Afar - Mugetsu
-- Rush Duel Ritual Monster
-- Card ID: 190019107

local s,id=GetID()

local SHINIGAMI_FROM_AFAR=190019100

function s.initial_effect(c)
	-- Rush Duel Ritual Monster
	-- In Rush Duel mode, Ritual Monsters are placed in the Extra Deck by the duel rules.
	c:EnableReviveLimit()

	-- [REQUIREMENT]
	-- During your Main Phase that you Ritual Summoned this card.
	--
	-- [EFFECT]
	-- Destroy all cards on the field, then you can Special Summon
	-- "The Shinigami From Afar - Born in the Dark" from your GY.
	-- For the rest of this turn, you cannot Normal or Special Summon monsters.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

-- During your Main Phase in the same turn this card was Ritual Summoned.
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsMainPhase()
		and c:IsRitualSummoned()
		and c:IsStatus(STATUS_SPSUMMON_TURN)
end

function s.spfilter(c,e,tp)
	return c:IsCode(SHINIGAMI_FROM_AFAR)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- This card itself is on the field, so there is normally always
		-- at least one card to attempt to destroy.
		return true
	end
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetPossibleOperationInfo(
		0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE
	)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- Destroy all cards on the field.
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	local ct=0
	if #g>0 then
		ct=Duel.Destroy(g,REASON_EFFECT)
	end

	-- "Then": only continue to the optional summon if at least 1 card
	-- was actually destroyed by the preceding part.
	if ct>0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(
			s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp
		)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then

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

	-- For the rest of this turn, you cannot Normal Summon monsters.
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(aux.TRUE)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)

	-- For the rest of this turn, you cannot Special Summon monsters.
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e2,tp)
end
