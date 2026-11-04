-- Card ID: 190019016
local s, id = GetID()
function s.initial_effect(c)
	--Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,160010025,1,s.matfilter,1)
	-- Requirement: Send top card of Deck to GY. Effect: Tribute 1 Galaxy, destroy 2 opponent cards.
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

-- Material filter for the 2nd Fusion material (Level 8 DARK Attribute)
function s.matfilter(c, fc, sumtype, tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevel(8)
end

-- REQUIREMENT: Send the top card of your Deck to the Graveyard
function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp, 1) end
	Duel.DiscardDeck(tp, 1, REASON_COST)
end

-- TARGET: Check for the additional Tribute requirement (1 Galaxy monster) and opponent targets
function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then 
		return Duel.CheckReleaseGroupCost(tp, Card.IsRace, 1, false, nil, nil, RACE_GALAXY)
			and Duel.IsExistingMatchingCard(nil, tp, 0, LOCATION_ONFIELD, 2, nil)
	end
	local g = Duel.SelectReleaseGroupCost(tp, Card.IsRace, 1, 1, false, nil, nil, RACE_GALAXY)
	Duel.Release(g, REASON_COST)
	
	local dg = Duel.GetMatchingGroup(nil, tp, 0, LOCATION_ONFIELD, nil)
	Duel.SetOperationInfo(0, CATEGORY_DESTROY, dg, 2, 0, 0)
end

-- EFFECT: Destroy 2 cards your opponent controls
function s.operation(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
	local g = Duel.SelectMatchingCard(tp, nil, tp, 0, LOCATION_ONFIELD, 2, 2, nil)
	if #g == 2 then
		Duel.HintSelection(g)
		Duel.Destroy(g, REASON_EFFECT)
	end
end
