-- Voidvelg Garlandolf (Rush Duel)
-- Card ID: 190019020
local s,id=GetID()
function s.initial_effect(c)
	-- Effect: Name change + Set 1 Ritual Spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

-- Requirement: Send the top card of your Deck to the Graveyard
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
	Duel.DiscardDeck(tp,1,REASON_COST)
end

-- Target: Check if the effect can activate
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

-- Operation: Name change, then optional Set from GY
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- Becomes "Garlandolf" (ID: 30646525) until the end of the turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(30646525)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		
		-- FIX: Direct hexadecimal bitmasks bypass the parameter bugs in your engine variant.
		-- 0x10 = LOCATION_GRAVEYARD, 0x2 = TYPE_SPELL
		local g=Duel.GetMatchingGroup(Card.IsType,tp,0x10,0,nil,0x2)
		
		-- Filter out only cards that also have the TYPE_RITUAL (0x80) bitmask property
		g=g:Filter(function(rc) return rc:IsType(0x80) end,nil)
		
		-- Check conditions and set the card
		if #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local sg=g:Select(tp,1,1,nil)
			if #sg>0 then
				Duel.SSet(tp,sg:GetFirst())
			end
		end
	end
end
