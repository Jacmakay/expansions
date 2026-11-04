-- Overlimit Yggdrago Venom Wing
-- Card ID: 190019050
local s,id=GetID()

-- Space Yggdrago
local SPACE_YGGDRAGO=160211009

function s.initial_effect(c)
	-- Fusion Materials:
	-- "Space Yggdrago" + 1 Cyberse Fusion Monster
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,SPACE_YGGDRAGO,s.matfilter)

	-- [REQUIREMENT] Shuffle 3 Cyberse monsters from your Graveyard into the Deck.
	-- [EFFECT] This card gains ATK equal to the combined ATK of all face-up
	-- monsters your opponent controls until the end of this turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.atkcost)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end

-- Second Fusion Material:
-- 1 Cyberse Fusion Monster
function s.matfilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_CYBERSE)
		and c:IsType(TYPE_FUSION)
end

-- Cyberse monster that can be shuffled into the Deck as the Requirement
function s.costfilter(c)
	return c:IsRace(RACE_CYBERSE)
		and c:IsMonster()
		and c:IsAbleToDeckAsCost()
end

function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
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

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end

	-- Add together the current ATK of all face-up monsters
	-- on the opponent's field.
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local atk=0
	for tc in aux.Next(g) do
		atk=atk+math.max(tc:GetAttack(),0)
	end

	if atk<=0 then return end

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
	c:RegisterEffect(e1)
end
