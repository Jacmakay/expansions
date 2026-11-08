--Cosmic Tag Team
--Custom Rush Duel Spell Card
--Card ID: 190019224
local s,id=GetID()

function s.initial_effect(c)
    --Special Summon a Level 10+ monster, then optionally destroy 1 opponent's card
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

--Monster that can be Special Summoned from the GY.
function s.spfilter(c,e,tp,att)
    return c:IsMonster() and c:IsLevelAbove(10) and c:IsAttribute(att)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end

--Check that a monster can be sent for the Requirement.
function s.reqfilter(c,e,tp)
    if not c:IsMonster() or not c:IsNotMaximumModeSide()
        or not c:IsAbleToGraveAsCost() then
        return false
    end
    --The monster being sent may itself be the Level 10+ monster,
    --or a matching-Attribute monster may already be in the GY.
    return c:IsLevelAbove(10)
        or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetAttribute())
end

--For Rush Duels, check the Requirement here and perform it at resolution.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.reqfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
    end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end

function s.desfilter(c)
    return c:IsNotMaximumModeSide() and c:IsDestructable()
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    --[REQUIREMENT] Send 1 monster from your field to the GY.
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.reqfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
    if #g==0 then return end
    local att=g:GetFirst():GetAttribute()
    g=g:AddMaximumCheck()
    if Duel.SendtoGrave(g,REASON_COST)==0 then return end

    --[EFFECT] Special Summon 1 Level 10+ monster with the same Attribute.
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),
        tp,LOCATION_GRAVE,0,1,nil,e,tp,att) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),
        tp,LOCATION_GRAVE,0,1,1,nil,e,tp,att)
    if #sg==0 or Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)==0 then
        return
    end

    --Then you can destroy 1 card on your opponent's field.
    if Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local dg=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
        if #dg>0 then
            Duel.HintSelection(dg)
            Duel.Destroy(dg,REASON_EFFECT)
        end
    end
end
