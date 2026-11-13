-- Dracoridge
-- Custom EDOPro Rush Duel monster (190019242)
local s,id=GetID()

function s.initial_effect(c)
    -- [REQUIREMENT] Send 1 card from your field to the GY.
    -- [EFFECT] Special Summon 1 Level 7 DARK Dragon from your GY.
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.costfilter(c)
    return c:IsAbleToGraveAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        -- Sending a Monster Zone card can open a zone for the Summon.
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,nil)
            and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
                or Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil))
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
    if #g>0 then Duel.SendtoGrave(g,REASON_COST) end
end

function s.spfilter(c,e,tp)
    return c:IsMonster() and c:IsLevel(7)
        and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,
        LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
