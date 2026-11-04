-- Linker of Transcendence (Rush Duel)
local s,id=GetID()
function s.initial_effect(c)
	-- Requirement
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

-- Rush Duel enforcement clause (fixed fallback safely checking global constant)
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not EFFECT_RUSH_DUEL then return true end
	return Duel.IsPlayerAffectedByEffect(tp,EFFECT_RUSH_DUEL)
end

-- Cost: Send the top card of your Deck to the Graveyard
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
	Duel.DiscardDeck(tp,1,REASON_COST)
end

-- Effect: Name change until the end of your opponent's next turn
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(160458001) -- Dimension Linker ID
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e1)
	end
end
