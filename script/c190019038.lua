--Perfect Dragonic Requiem Technique Crimson Flux
local s,id=GetID()

function s.initial_effect(c)
	--Fusion Summon 1 Wyrm Fusion Monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.fustg)
	e1:SetOperation(s.fusop)
	c:RegisterEffect(e1)
end

function s.fusfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_WYRM)
end

--If the opponent controls a Level 9 or higher monster,
--Fusion Materials in your GY can also be used.
function s.oppfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(9)
end

function s.gravematcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.oppfilter,tp,0,LOCATION_MZONE,1,nil)
end

function s.gravematfilter(c)
	return c:IsMonster() and c:IsAbleToDeck()
end

function s.extrafil(e,tp,mg)
	if not s.gravematcon(e) then
		return nil
	end
	return Duel.GetMatchingGroup(s.gravematfilter,tp,LOCATION_GRAVE,0,nil)
end

--Materials normally go from hand/field to the GY.
--GY materials are shuffled into the Deck instead.
function s.extraop(e,tc,tp,sg)
	local gy=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	local normal=sg-gy

	if #normal>0 then
		Duel.SendtoGrave(normal,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	end
	if #gy>0 then
		Duel.SendtoDeck(gy,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	end
end

function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	local params={
		fusfilter=s.fusfilter,
		extrafil=s.extrafil,
		extraop=s.extraop
	}
	if chk==0 then
		return Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0)
	end
	Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,1)
end

function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	local params={
		fusfilter=s.fusfilter,
		extrafil=s.extrafil,
		extraop=s.extraop
	}
	Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp)
end
