--Destruction Technique U-T-S Override
--ID: 190019080
local s,id=GetID()

local STARGAZER=160011639

function s.initial_effect(c)
	--[REQUIREMENT] None
	--[EFFECT]
	--Send 3 Level 1 monsters from your face-up field to the GY
	--as Fusion Material for "Ultimate Trinity Stargazer".
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

--3 face-up Level 1 monsters on your field
function s.matfilter(c)
	return c:IsFaceup()
		and c:IsMonster()
		and c:IsLevel(1)
		and c:IsAbleToGrave()
end

--At activation, only confirm Stargazer exists in the Extra Deck.
--Do NOT check summon-zone availability yet, because the 3 materials
--will leave the field before Stargazer is summoned.
function s.stargazerfilter(c)
	return c:IsCode(STARGAZER)
		and c:IsType(TYPE_FUSION)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
				s.matfilter,tp,LOCATION_MZONE,0,3,nil
			)
			and Duel.IsExistingMatchingCard(
				s.stargazerfilter,tp,LOCATION_EXTRA,0,1,nil
			)
	end

	Duel.SetOperationInfo(
		0,CATEGORY_TOGRAVE,nil,3,tp,LOCATION_MZONE
	)
	Duel.SetOperationInfo(
		0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA
	)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Stargazer must still be in the Extra Deck.
	local fc=Duel.GetFirstMatchingCard(
		s.stargazerfilter,tp,LOCATION_EXTRA,0,nil
	)
	if not fc then return end

	--Select exactly 3 face-up Level 1 monsters.
	if Duel.GetMatchingGroupCount(
		s.matfilter,tp,LOCATION_MZONE,0,nil
	)<3 then
		return
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	local mg=Duel.SelectMatchingCard(
		tp,s.matfilter,tp,LOCATION_MZONE,0,3,3,nil
	)
	if #mg~=3 then return end

	--Register these monsters as Stargazer's Fusion Materials.
	fc:SetMaterial(mg)

	--Send all 3 materials to the Graveyard first.
	local ct=Duel.SendtoGrave(
		mg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION
	)
	if ct~=3 then return end

	Duel.BreakEffect()

	--Now the Monster Zones have been freed, so check whether
	--Stargazer can actually be Fusion Summoned.
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
		return
	end
	if not fc:IsCanBeSpecialSummoned(
		e,SUMMON_TYPE_FUSION,tp,false,false
	) then
		return
	end

	if Duel.SpecialSummon(
		fc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP
	)>0 then
		fc:CompleteProcedure()
	end
end
