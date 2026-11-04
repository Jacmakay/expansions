--Emperor's Finality Blade
--Card ID: 190019092
local s,id=GetID()

function s.initial_effect(c)
	--[EFFECT]
	--Fusion Summon a Celestial Warrior monster using monsters
	--from your hand or field as Fusion Material.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(Fusion.SummonEffTG(s.fusfilter))
	e1:SetOperation(Fusion.SummonEffOP(s.fusfilter))
	c:RegisterEffect(e1)
end

--Only Celestial Warrior Fusion Monsters
function s.fusfilter(c,tp)
	return c:IsRace(RACE_CELESTIALWARRIOR)
end
