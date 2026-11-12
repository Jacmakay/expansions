--Dracoridge
--Rush Duel custom card - 190019242
local s,id=GetID()

function s.initial_effect(c)
    --[REQUIREMENT] Send 1 card from your field to the Graveyard.
    --[EFFECT] Special Summon 1 Level 7 DARK Dragon from your Graveyard.
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCost(RD.CostSendOnFieldToGrave(Card.IsAbleToGraveAsCost,1,1,false))
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
end

function s.spfilter(c,e,tp)
    return c:IsAttribute(ATTRIBUTE_DARK)
        and c:IsLevel(7)
        and c:IsRace(RACE_DRAGON)
        and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        -- Sending a monster as the requirement can free a Monster Zone.
        local has_zone=Duel.GetMZoneCount(tp)>0
            or Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,
                tp,LOCATION_MZONE,0,1,nil)
        return has_zone and Duel.IsExistingMatchingCard(
            s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    RD.SelectAndSpecialSummon(aux.NecroValleyFilter(s.spfilter),
        tp,LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP)
end
