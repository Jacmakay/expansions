-- Terminus Blade
-- EDOPro / Rush Duel
-- Card ID: 190019214
-- Summons "Enforcer Of The Harbinger System" (190019213) from the GY.
local s,id=GetID()
local ENFORCER_ID=190019213

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

s.listed_names={ENFORCER_ID}

-- [REQUIREMENT] Send 1 card from your hand to the Graveyard.
function s.handfilter(c)
    return c:IsAbleToGrave()
end

-- The Rush Duel requirement is carried out in the operation.
-- Here, SetCost only checks whether it is possible.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.handfilter,tp,LOCATION_HAND,0,1,nil)
    end
end

function s.spfilter(c,e,tp)
    return c:IsCode(ENFORCER_ID)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- Requirement: send exactly one card from your hand to the GY.
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local hg=Duel.SelectMatchingCard(tp,s.handfilter,tp,LOCATION_HAND,0,1,1,nil)
    local hc=hg:GetFirst()
    if not hc then return end
    if Duel.SendtoGrave(hc,REASON_EFFECT)==0 or not hc:IsLocation(LOCATION_GRAVE) then
        return
    end

    -- Effect: Special Summon the named monster face-up in Attack Position.
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #sg>0 then
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_ATTACK)
    end
end
