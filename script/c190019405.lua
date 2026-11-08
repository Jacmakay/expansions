--Tides Servant Azuri
--Card ID: 190019405
--Rush Duel: WATER / Cyberse / Level 3

local s,id=GetID()

function s.initial_effect(c)
    --[REQUIREMENT] Send 1 Cyberse monster from your hand to the GY.
    --[EFFECT] Special Summon 1 Level 5 or lower Cyberse monster
    --from your GY to your field.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

--Cyberse monster that can be sent from the hand for the requirement.
function s.reqfilter(c)
    return c:IsMonster() and c:IsRace(RACE_CYBERSE)
        and c:IsAbleToGraveAsCost()
end

--A low-Level monster in hand can become a valid GY Summon option
--after it is sent for the requirement.
function s.handfilter(c)
    return s.reqfilter(c) and c:IsLevelBelow(5)
end

--Level 5 or lower Cyberse monster that can be Special Summoned.
function s.spfilter(c,e,tp)
    return c:IsMonster() and c:IsRace(RACE_CYBERSE)
        and c:IsLevelBelow(5)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

--Rush Duel requirement: check here, perform it at resolution.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.reqfilter,tp,LOCATION_HAND,0,1,nil)
    end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and (Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),
                    tp,LOCATION_GRAVE,0,1,nil,e,tp)
                or Duel.IsExistingMatchingCard(s.handfilter,
                    tp,LOCATION_HAND,0,1,nil))
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    --[REQUIREMENT] Send 1 Cyberse monster from the hand to the GY.
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local rg=Duel.SelectMatchingCard(tp,s.reqfilter,tp,LOCATION_HAND,0,1,1,nil)
    if #rg==0 or Duel.SendtoGrave(rg,REASON_COST)~=1 then return end

    --[EFFECT] The monster just sent can also be chosen if eligible.
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),
        tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #sg>0 then
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
    end
end
