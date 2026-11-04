-- Void Diabolos (Rush Duel)
-- Card ID: 190019015
local s,id=GetID()
function s.initial_effect(c)
	-- Alternative Summon Condition: 1 tribute in Attack Position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1164)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.otcon)
	e1:SetOperation(s.otop)
	e1:SetValue(SUMMON_TYPE_TRIBUTE)
	c:RegisterEffect(e1)
	
	-- Requirement & Effect: Special Summon & optional Fusion
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.condition)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_names={id}

-- 1 Tribute Summon filter and condition
function s.otfilter(c,tp)
	return c:IsRace(RACE_GALAXY) and c:IsControler(tp)
end
function s.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	return minc<=1 and Duel.CheckTribute(c,1,1,nil,tp,s.otfilter) and c:IsAttackPos()
end
function s.otop(e,tp,eg,ep,ev,re,r,rp,c,minc)
	local sg=Duel.SelectTribute(tp,c,1,1,nil,tp,s.otfilter)
	c:SetMaterial(sg)
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end

-- REQUIREMENT: Tribute 1 Galaxy Type monster
function s.costfilter(c)
	return c:IsRace(RACE_GALAXY)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.costfilter,1,false,nil,e:GetHandler()) end
	local g=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,nil,e:GetHandler())
	Duel.Release(g,REASON_COST)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end

-- Filter for Level 8 Galaxy Monster in Graveyard
function s.ssfilter(c,e,tp)
	return c:IsLevel(8) and c:IsRace(RACE_GALAXY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Fusion Hand/Field material filter
function s.ffilter1(c,e)
	return not c:IsImmuneToEffect(e)
end

-- Dark Galaxy Fusion Monster filter
function s.ffilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_GALAXY) and c:IsAttribute(ATTRIBUTE_DARK) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and m:IsExists(s.fcheck,1,nil,chkf,c,m)
end
function s.fcheck(c,chkf,fc,m)
	return m:IsContains(c) and fc:CheckFusionMaterial(m,c,chkf)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
end

-- EFFECT: Special Summon, then optional Fusion Summon using this card
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		
		local c=e:GetHandler()
		-- Verify Void Diabolos is face-up and under your control
		if not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:IsFacedown() then return end
		
		local chkf=tp
		-- Get all potential materials from your Hand and Field
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.ffilter1,nil,e)
		if not mg1:IsContains(c) then return end
		
		-- Check if a valid DARK Galaxy Fusion monster can be summoned using these materials
		if Duel.IsExistingMatchingCard(s.ffilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local fg=Duel.SelectMatchingCard(tp,s.ffilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg1,nil,chkf)
			local tc=fg:GetFirst()
			if tc then
				-- Let the core engine prompt the material selection window properly
				local mat=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
				tc:SetMaterial(mat)
				
				-- FORCE material usage: send materials to Graveyard explicitly
				Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				Duel.BreakEffect()
				
				-- Summon the chosen Fusion monster
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
				tc:CompleteProcedure()
			end
		end
	end
end
