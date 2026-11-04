-- Aiza of Transcendence (Rush Duel)
-- Card ID: 190019003
local s, id = GetID()
function s.initial_effect(c)
	-- Requirement: Shuffle 2 monsters from GY into Deck
	-- Effect: Change name and optionally Special Summon 1 Level 4 or lower Dark Galaxy monster from GY
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

-- Dark Matter Dragon ID
s.dark_matter_dragon_id = 160018006

-- Safely fall back to LOCATION_GRAVE if LOCATION_GRAVEYARD is nil
local GY_LOCATION = LOCATION_GRAVEYARD or LOCATION_GRAVE or 0x10

function s.condition(e, tp, eg, ep, ev, re, r, rp)
	return tp == Duel.GetTurnPlayer()
end

function s.costfilter(c)
	return c:IsType(TYPE_MONSTER)
		and ((c:IsType(TYPE_FUSION) or c:IsType(TYPE_RITUAL)) and c:IsAbleToExtraAsCost()
			or (not c:IsType(TYPE_FUSION) and not c:IsType(TYPE_RITUAL) and c:IsAbleToDeckAsCost()))
end

function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(s.costfilter, tp, GY_LOCATION, 0, 2, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
	local g = Duel.SelectMatchingCard(tp, s.costfilter, tp, GY_LOCATION, 0, 2, 2, nil)
	Duel.HintSelection(g)
	Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST)
end

function s.spfilter(c, e, tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_GALAXY) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return true end
	-- Safely call SetPossibleCategory only if the engine version supports it
	if Duel.SetPossibleCategory then
		Duel.SetPossibleCategory(e, CATEGORY_SPECIAL_SUMMON)
	end
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- Change name to Dark Matter Dragon
		local e1 = Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(s.dark_matter_dragon_id)
		-- Until the end of your opponent's next turn
		if Duel.GetTurnPlayer() == tp then
			e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END + RESET_OPPO_TURN, 1)
		else
			e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END + RESET_OPPO_TURN, 2)
		end
		c:RegisterEffect(e1)
		
		-- Then you can Special Summon 1 level 4 or lower Dark Galaxy monster from your GY
		local sg = Duel.GetMatchingGroup(s.spfilter, tp, GY_LOCATION, 0, nil, e, tp)
		if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 
			and #sg > 0
			and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
			
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
			local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, GY_LOCATION, 0, 1, 1, nil, e, tp)
			if #g > 0 then
				Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
			end
		end
	end
end
