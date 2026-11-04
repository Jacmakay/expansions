--Magiclad Limilth
local s,id=GetID()

function s.initial_effect(c)
	--Tribute Summon with 1 Wyrm monster
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCondition(s.otcon)
	e0:SetOperation(s.otop)
	e0:SetValue(SUMMON_TYPE_TRIBUTE)
	c:RegisterEffect(e0)

	--[REQUIREMENT]
	--During your Main Phase that you Normal or Special Summoned this card.
	--[EFFECT] Fusion Summon 1 Wyrm Fusion Monster using monsters
	--from your hand or field as material.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.fuscon)
	e1:SetTarget(Fusion.SummonEffTG({
		fusfilter=s.fusfilter
	}))
	e1:SetOperation(Fusion.SummonEffOP({
		fusfilter=s.fusfilter
	}))
	c:RegisterEffect(e1)
end

function s.relfilter(c)
	return c:IsRace(RACE_WYRM) and c:IsReleasable()
end

function s.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	return minc<=1
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.CheckReleaseGroup(tp,s.relfilter,1,false,1,true,c,tp,nil,false,nil)
end

function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(tp,s.relfilter,1,1,false,true,true,c,tp,nil,false,nil)
	c:SetMaterial(g)
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end

function s.fuscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsMainPhase()
		and (c:IsStatus(STATUS_SUMMON_TURN)
			or c:IsStatus(STATUS_SPSUMMON_TURN))
end

function s.fusfilter(c)
	return c:IsRace(RACE_WYRM) and c:IsType(TYPE_FUSION)
end
