-- Yoko, Servitor of Frost | 190019466
-- WATER / Zombie / Level 9 / 2900 ATK / 2400 DEF
-- [REQUIREMENT] Send 1 WATER Zombie from your hand to the GY.
-- [EFFECT] Destroy 1 face-up monster your opponent controls. If this
-- card was Special Summoned from your GY this turn, you may destroy
-- one additional opposing monster (face-up or face-down).
local s,id=GetID()
function s.initial_effect(c)
    -- Record that this card was Special Summoned from the GY this turn.
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_SPSUMMON_SUCCESS)
    e0:SetOperation(s.summonop)
    c:RegisterEffect(e0)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCategory(CATEGORY_TOGRAVE|CATEGORY_DESTROY)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end
function s.summonop(e,tp)
    if e:GetHandler():IsPreviousLocation(LOCATION_GRAVE) then
        e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
    end
end
function s.handfilter(c)
    return c:IsMonster() and c:IsAttribute(ATTRIBUTE_WATER)
        and c:IsRace(RACE_ZOMBIE) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.handfilter,tp,LOCATION_HAND,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.handfilter,tp,LOCATION_HAND,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end
function s.destroyfirst(c)
    return c:IsFaceup() and c:IsMonster() and c:IsDestructable()
end
function s.destroysecond(c)
    return c:IsMonster() and c:IsDestructable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.destroyfirst,tp,0,LOCATION_MZONE,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.destroyfirst,tp,0,LOCATION_MZONE,1,1,nil)
    if #g==0 or Duel.Destroy(g,REASON_EFFECT)==0 then return end
    if e:GetHandler():GetFlagEffect(id)==0 then return end
    if Duel.IsExistingMatchingCard(s.destroysecond,tp,0,LOCATION_MZONE,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local sg=Duel.SelectMatchingCard(tp,s.destroysecond,tp,0,LOCATION_MZONE,1,1,nil)
        if #sg>0 then Duel.Destroy(sg,REASON_EFFECT) end
    end
end
