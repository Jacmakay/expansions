-- Yggdrago Venom
-- Card ID: 190019047
local s,id=GetID()

function s.initial_effect(c)
	-- [REQUIREMENT] Send this card to the Graveyard.
	-- [EFFECT] Fusion Summon 1 Level 7 or higher DARK Cyberse monster,
	-- using monsters from your hand or field as material.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.fuscost)
	e1:SetTarget(Fusion.SummonEffTG({
		fusfilter=s.fusfilter
	}))
	e1:SetOperation(Fusion.SummonEffOP({
		fusfilter=s.fusfilter
	}))
	c:RegisterEffect(e1)
end

-- Send this card to the Graveyard as the Requirement.
function s.fuscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToGraveAsCost()
	end
	Duel.SendtoGrave(c,REASON_COST)
end

-- The Fusion Monster must be Level 7 or higher, DARK, and Cyberse.
function s.fusfilter(c,tp)
	return c:IsLevelAbove(7)
		and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsRace(RACE_CYBERSE)
end
