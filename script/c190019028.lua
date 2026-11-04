--Advent of Chaos
--ID 190019028
--Standalone custom Rush Ritual Spell.
--Does not use Rush Ritual helper/database APIs.
local s,id=GetID()

function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.ritualmonster(c,e,tp)
	return c:IsCode(190019027)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end

function s.material(c)
	return c:IsMonster() and c:IsAbleToGrave() and c:GetLevel()>0
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	--Search both Extra Deck and hand so this works without relying on
	--the engine's Rush Ritual database placement rules.
	local rg=Duel.GetMatchingGroup(s.ritualmonster,tp,LOCATION_EXTRA|LOCATION_HAND,0,nil,e,tp)
	local mg=Duel.GetMatchingGroup(s.material,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)

	if chk==0 then
		return #rg>0
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and mg:CheckWithSumGreater(Card.GetLevel,10,1,#mg)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,rg,1,tp,LOCATION_EXTRA|LOCATION_HAND)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	local rg=Duel.GetMatchingGroup(s.ritualmonster,tp,LOCATION_EXTRA|LOCATION_HAND,0,nil,e,tp)
	if #rg==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local rc=rg:Select(tp,1,1,nil):GetFirst()
	if not rc then return end

	local mg=Duel.GetMatchingGroup(s.material,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
	if not mg:CheckWithSumGreater(Card.GetLevel,10,1,#mg) then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local mat=mg:SelectWithSumGreater(tp,Card.GetLevel,10,1,#mg)
	if not mat or #mat==0 then return end

	--Rush Ritual materials are sent to the GY.
	Duel.SendtoGrave(mat,REASON_EFFECT|REASON_MATERIAL)
	if not rc:IsLocation(LOCATION_EXTRA|LOCATION_HAND) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	--Custom Ritual summon: deliberately avoids SUMMON_TYPE_RITUAL and
	--Rush Ritual helper functions, so it can work without the Rush DB/API.
	if Duel.SpecialSummon(rc,0,tp,tp,true,true,POS_FACEUP)>0 then
		rc:CompleteProcedure()

		--Mark it as having been Ritual Summoned this turn for its requirement.
		rc:RegisterFlagEffect(190019027,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
	end
end
