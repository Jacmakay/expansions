--U-T-W Takami
--ID: 190019073
local s,id=GetID()

function s.initial_effect(c)
	--[REQUIREMENT] Send 1 Spell Card from your hand to the GY
	--[EFFECT] Gain 9 Levels, then optionally Ritual Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_LVCHANGE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

function s.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end

--Level 10 or lower Galaxy Ritual Monster in the Extra Deck
function s.ritfilter(c,e,tp)
	return c:IsType(TYPE_RITUAL)
		and c:IsRace(RACE_GALAXY)
		and c:IsLevelBelow(10)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,false)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end

	--Increase Takami's Level by 9
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(9)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)

	--Only continue if Takami is now Level 10 or higher
	if c:GetLevel()<10 then return end

	--Rush Ritual Monsters are selected from the Extra Deck
	if not c:IsAbleToGrave() then return end
	if not Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.ritfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local rc=g:GetFirst()
	if not rc then return end

	--Send Takami to the GY as the Ritual Material
	if Duel.SendtoGrave(c,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)==0 then return end
	if not c:IsLocation(LOCATION_GRAVE) then return end

	--Ritual Summon the selected monster
	if Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,false,POS_FACEUP)>0 then
		rc:CompleteProcedure()
	end
end
