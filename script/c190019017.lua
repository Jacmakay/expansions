-- Spirit of Eris (190019017)
-- Custom Rush Duel effect. Intentionally allows Ritual monster revival
-- even when the Ritual monster was not Ritual Summoned first (house rule).
local s,id=GetID()

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
end

-- [REQUIREMENT] Send this card from the field to the Graveyard.
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToGraveAsCost() end
    Duel.SendtoGrave(c,REASON_COST)
end

-- [EFFECT] Special Summon 1 DARK Warrior or DARK Galaxy Ritual monster
-- from your Graveyard. nocheck=true and nolimit=true bypass the usual
-- Ritual summoning/revival restrictions, but NOT player summon locks.
function s.spfilter(c,e,tp)
    return c:IsType(TYPE_RITUAL)
        and c:IsAttribute(ATTRIBUTE_DARK)
        and (c:IsRace(RACE_WARRIOR) or c:IsRace(RACE_GALAXY))
        and c:IsCanBeSpecialSummoned(e,0,tp,true,true,POS_FACEUP)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),
                tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),
        tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc then
        Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
    end
end
