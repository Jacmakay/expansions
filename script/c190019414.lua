--Infinity Pritima
--Card ID: 190019414
--Rush Duel

local s,id=GetID()

function s.initial_effect(c)
    --[Effect] Fusion Summon 1 Level 10 or lower Fiend Fusion Monster
    --using monsters in your hand and/or on your field as material.
    local params={
        fusfilter=s.fusfilter,
        matfilter=s.matfilter
    }
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(Fusion.SummonEffTG(params))
    e1:SetOperation(Fusion.SummonEffOP(params))
    c:RegisterEffect(e1)
end

--Only Fiend Fusion Monsters of Level 10 or lower can be summoned.
function s.fusfilter(c,tp)
    return c:IsType(TYPE_FUSION)
        and c:IsRace(RACE_FIEND)
        and c:IsLevelBelow(10)
end

--Use only your monsters in your hand or on the field as Fusion Material.
--The Fusion helper checks the selected Fusion Monster's material recipe
--and sends the selected materials to the GY upon resolution.
function s.matfilter(c,e,tp,chk)
    return c:IsControler(tp)
        and c:IsLocation(LOCATION_HAND|LOCATION_MZONE)
        and c:IsMonster()
        and c:IsAbleToGrave()
end
