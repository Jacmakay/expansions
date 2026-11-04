--Voidvelg Protostar Asura
local s,id=GetID()

local CARD_VOIDVELG_GLOBULE=160317015
local CARD_DARK_PROPHET=160205048
local CARD_DARK_HOLE=160205069
local CARD_DARK_HOLE_DEVICE=160014050

function s.initial_effect(c)
	c:EnableReviveLimit()

	--Fusion Materials: "Voidvelg Globule" + "Dark Prophet"
	if Fusion and Fusion.AddProcMix then
		Fusion.AddProcMix(c,true,true,CARD_VOIDVELG_GLOBULE,CARD_DARK_PROPHET)
	else
		aux.AddFusionProcCode2(c,CARD_VOIDVELG_GLOBULE,CARD_DARK_PROPHET,true,true)
	end

	-------------------------------------------------
	-- CONTACT FUSION
	-- Manual procedure for the user's Rush build.
	-------------------------------------------------
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.cfcon)
	e0:SetOperation(s.cfop)
	e0:SetValue(SUMMON_TYPE_FUSION)
	c:RegisterEffect(e0)

	-------------------------------------------------
	-- Mark this card when it is Fusion Summoned normally.
	-------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)

	-------------------------------------------------
	-- MAIN EFFECT
	-------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end

-------------------------------------------------
-- CONTACT FUSION MATERIALS
-------------------------------------------------

function s.globfilter(c)
	return c:IsFaceup()
		and c:IsCode(CARD_VOIDVELG_GLOBULE)
		and c:IsAbleToDeckAsCost()
end

function s.prophetfilter(c)
	return c:IsFaceup()
		and c:IsCode(CARD_DARK_PROPHET)
		and c:IsAbleToDeckAsCost()
end

function s.cfcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(
		s.globfilter,tp,LOCATION_MZONE,0,1,nil
	)
	and Duel.IsExistingMatchingCard(
		s.prophetfilter,tp,LOCATION_MZONE,0,1,nil
	)
end

function s.cfop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	local g1=Duel.SelectMatchingCard(
		tp,s.globfilter,tp,LOCATION_MZONE,0,1,1,nil
	)
	if #g1==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	local g2=Duel.SelectMatchingCard(
		tp,s.prophetfilter,tp,LOCATION_MZONE,0,1,1,nil
	)
	if #g2==0 then return end

	g1:Merge(g2)
	c:SetMaterial(g1)

	Duel.SendtoDeck(
		g1,nil,SEQ_DECKSHUFFLE,
		REASON_COST+REASON_MATERIAL+REASON_FUSION
	)

	--Remember that this card was Contact Fusioned this turn.
	c:RegisterFlagEffect(
		id,
		RESET_PHASE+PHASE_END,
		0,
		1
	)
end

-------------------------------------------------
-- NORMAL FUSION SUMMON FLAG
-------------------------------------------------

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	if c:IsSummonType(SUMMON_TYPE_FUSION) then
		c:RegisterFlagEffect(
			id,
			RESET_PHASE+PHASE_END,
			0,
			1
		)
	end
end

-------------------------------------------------
-- REQUIREMENT
-- During your Main Phase that you Fusion Summoned this card.
--
-- Ignition effects are used during the Main Phase, so the
-- important check here is whether this card was marked as
-- Fusion Summoned this turn.
-------------------------------------------------

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end

-------------------------------------------------
-- "DARK HOLE" RECOVERY FILTER
--
-- Important compatibility fix:
-- Dark Hole Device changes its name/code in the GY.
-- GetOriginalCode() still identifies it as 160014050.
-------------------------------------------------

function s.thfilter(c)
	if not c:IsAbleToHand() then
		return false
	end

	return c:IsCode(CARD_DARK_HOLE)
		or c:GetOriginalCode()==CARD_DARK_HOLE
		or c:GetOriginalCode()==CARD_DARK_HOLE_DEVICE
end

-------------------------------------------------
-- DARK GALAXY MONSTER
-------------------------------------------------

function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsRace(RACE_GALAXY)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-------------------------------------------------
-- OPPONENT ATTACK POSITION MONSTERS
-------------------------------------------------

function s.desfilter(c)
	return c:IsFaceup() and c:IsAttackPos()
end

-------------------------------------------------
-- TARGET
-------------------------------------------------

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.thfilter,
			tp,
			LOCATION_GRAVE,
			0,
			1,
			nil
		)
	end

	Duel.SetOperationInfo(
		0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE
	)

	local dg=Duel.GetMatchingGroup(
		s.desfilter,tp,0,LOCATION_MZONE,nil
	)

	if #dg>0 then
		Duel.SetOperationInfo(
			0,CATEGORY_DESTROY,dg,#dg,0,0
		)
	end

	Duel.SetOperationInfo(
		0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE
	)
end

-------------------------------------------------
-- EFFECT
-------------------------------------------------

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Add 1 "Dark Hole" from your GY to your hand
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)

	local hg=Duel.SelectMatchingCard(
		tp,
		s.thfilter,
		tp,
		LOCATION_GRAVE,
		0,
		1,
		1,
		nil
	)

	local hc=hg:GetFirst()
	if not hc then return end

	if Duel.SendtoHand(hc,nil,REASON_EFFECT)==0 then
		return
	end

	Duel.ConfirmCards(1-tp,hc)

	--Then destroy all Attack Position monsters your opponent controls
	local dg=Duel.GetMatchingGroup(
		s.desfilter,tp,0,LOCATION_MZONE,nil
	)

	if #dg>0 then
		Duel.Destroy(dg,REASON_EFFECT)
	end

	--Special Summon 1 DARK Galaxy monster from your GY, if available
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local sg=Duel.GetMatchingGroup(
			s.spfilter,
			tp,
			LOCATION_GRAVE,
			0,
			nil,
			e,tp
		)

		if #sg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=sg:Select(tp,1,1,nil):GetFirst()

			if sc then
				Duel.SpecialSummon(
					sc,0,tp,tp,false,false,POS_FACEUP
				)
			end
		end
	end

	--Only Fusion Monsters can attack for the rest of this turn
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.atklimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
end

function s.atklimit(e,c)
	return not c:IsType(TYPE_FUSION)
end
