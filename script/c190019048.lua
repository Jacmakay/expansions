-- Yggdrago Clear Wing
-- Card ID: 190019048
local s,id=GetID()

-- Official Rush Duel database index for "Space Yggdrago"
local SPACE_YGGDRAGO=160211009

function s.initial_effect(c)
	-- If you have a DARK Cyberse monster in your GY,
	-- you can Special Summon this card from your hand
	-- in face-up Defense Position.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_SPSUM_PARAM)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)

	-- [REQUIREMENT] Send 1 card from your hand to the Graveyard.
	-- [EFFECT] This card's name becomes "Space Yggdrago" this turn,
	-- then you can Special Summon 1 DARK Cyberse monster from your GY,
	-- except a Fusion Monster or a Level 7 monster.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end

-- Self Special Summon condition
function s.gyfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsRace(RACE_CYBERSE)
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil)
end

-- Requirement: send 1 card from your hand to the GY
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end

-- The Special Summon part is optional, so the effect can be activated
-- even if no valid monster is currently available.
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsRace(RACE_CYBERSE)
		and not c:IsType(TYPE_FUSION)
		and not c:IsLevel(7)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end

	-- This card's name becomes "Space Yggdrago" until the End Phase.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetValue(SPACE_YGGDRAGO)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
	c:RegisterEffect(e1)

	-- Then, you can Special Summon an eligible DARK Cyberse monster.
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if not Duel.IsExistingMatchingCard(
		aux.NecroValleyFilter(s.spfilter),
		tp,LOCATION_GRAVE,0,1,nil,e,tp
	) then
		return
	end

	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end

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
