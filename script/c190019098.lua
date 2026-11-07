-- U-T-W Gladiness The Emperor's Flagbearer
-- EDOPro Rush Duel | Card ID 190019098
-- Ritual Spell: Dominus Empire Flag (190019099)
local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    -- [REQUIREMENT] During the turn this card was Ritual Summoned,
    -- send 1 card from your hand or field to the GY.
    -- [EFFECT] Change all opponent's monsters to face-down Defense Position,
    -- then destroy 1 card in their Spell & Trap Zone.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_POSITION|CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- Only during the turn it was Ritual Summoned.
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_RITUAL)
        and c:IsStatus(STATUS_SPSUMMON_TURN)
end

function s.costfilter(c)
    return c:IsAbleToGraveAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end

function s.posfilter(c)
    return c:IsFaceup() and c:IsCanTurnSet()
end

function s.destroyfilter(c)
    return c:IsDestructable()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil)
    end
    local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_SZONE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
    if #g==0 then return end

    -- "Then": only proceed if at least one monster changed position.
    local ct=Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
    if ct==0 then return end

    if Duel.IsExistingMatchingCard(s.destroyfilter,tp,0,LOCATION_SZONE,1,nil) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local dg=Duel.SelectMatchingCard(tp,s.destroyfilter,tp,0,LOCATION_SZONE,1,1,nil)
        if #dg>0 then
            Duel.Destroy(dg,REASON_EFFECT)
        end
    end
end
