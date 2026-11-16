-- True Bankai - Tensa Zangetsu (190019112)
-- DARK / Warrior / Level 12 / Ritual / 4000 ATK / 3000 DEF
-- No nonexistent "Blood Chains" card is referenced.
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Continuous: cannot be destroyed by opponent's monster effects.
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e0:SetValue(s.indval)
    c:RegisterEffect(e0)
    -- Recycle two Warriors; destroy up to two face-up monsters, +500 each;
    -- if any was destroyed, attack twice this turn.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end
function s.indval(e,re,rp)
    return rp~=e:GetHandlerPlayer() and re and re:IsActiveType(TYPE_MONSTER)
end
function s.costfilter(c)
    return c:IsMonster() and c:IsRace(RACE_WARRIOR) and c:IsAbleToDeckAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,2,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,2,2,nil)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.desfilter(c)
    return c:IsFaceup() and c:IsDestructable()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
    local ct=0
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local sg=g:Select(tp,1,math.min(2,#g),nil)
        ct=Duel.Destroy(sg,REASON_EFFECT)
    end
    if not c:IsFaceup() or not c:IsRelateToEffect(e) or ct<=0 then return end
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(500*ct)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e2)
    -- Total of two attacks, not two EXTRA attacks.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_EXTRA_ATTACK)
    e3:SetValue(1)
    e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e3)
end
