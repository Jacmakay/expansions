-- Finality's Creation U-T-W Silent Magician | 190019470
-- LIGHT / Spellcaster / Level 9 / 3000 ATK / 2500 DEF
-- If a Level 1 or 9 monster is on your field or in your GY, you may
-- Special Summon this card from your hand.
-- [REQUIREMENT] During the turn this card was Special Summoned, pay 500 LP.
-- [EFFECT] Destroy up to 1 Level 1 or 9 monster you control. Cards already
-- in your opponent's S/T Zones cannot activate effects through the end of
-- the opponent's next turn. You cannot activate this card's effects again
-- this turn.
local s,id=GetID()
function s.initial_effect(c)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_SPSUMMON_SUCCESS)
    e0:SetOperation(s.record)
    c:RegisterEffect(e0)
    -- Summon from hand with no Tribute when a Level 1 or 9 monster exists.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetCountLimit(1)
    e1:SetCondition(s.handcon)
    e1:SetTarget(s.handtg)
    e1:SetOperation(s.handop)
    c:RegisterEffect(e1)
    -- Activated monster effect after this copy has been Special Summoned.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetCondition(s.fieldcon)
    e2:SetCost(s.cost)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end
function s.level19(c)
    return c:IsFaceup() and c:IsMonster() and (c:IsLevel(1) or c:IsLevel(9))
end
function s.gylevel19(c)
    return c:IsMonster() and (c:IsLevel(1) or c:IsLevel(9))
end
function s.handcon(e,tp)
    return Duel.IsExistingMatchingCard(s.level19,tp,LOCATION_MZONE,0,1,nil)
        or Duel.IsExistingMatchingCard(s.gylevel19,tp,LOCATION_GRAVE,0,1,nil)
end
function s.handtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_HAND)
end
function s.handop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_ATTACK)
    end
end
function s.record(e,tp)
    e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
end
function s.fieldcon(e,tp)
    return e:GetHandler():GetFlagEffect(id)>0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,500) end
    Duel.PayLPCost(tp,500)
end
function s.destroyfilter(c)
    return c:IsMonster() and (c:IsLevel(1) or c:IsLevel(9)) and c:IsDestructable()
end
function s.cannotactivate(e,re,tp)
    local rc=re:GetHandler()
    return rc and rc:IsLocation(LOCATION_SZONE) and rc:GetFlagEffect(id)>0
end
function s.restrictsame(e,re,tp)
    local rc=re:GetHandler()
    return rc and rc:IsCode(id)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.IsExistingMatchingCard(s.destroyfilter,tp,LOCATION_MZONE,0,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local g=Duel.SelectMatchingCard(tp,s.destroyfilter,tp,LOCATION_MZONE,0,1,1,nil)
        if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
    end
    -- Mark ONLY the specific S/T cards presently on the opponent's field.
    local g=Duel.GetFieldGroup(tp,0,LOCATION_SZONE)
    for tc in aux.Next(g) do
        tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
    end
    if #g>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EFFECT_CANNOT_ACTIVATE)
        e1:SetTargetRange(0,1)
        e1:SetValue(s.cannotactivate)
        -- Activated on your Main Phase: own End Phase then opponent's End Phase.
        e1:SetReset(RESET_PHASE|PHASE_END,2)
        Duel.RegisterEffect(e1,tp)
    end
    -- Restrict further activation of this named card's effects this turn.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_CANNOT_ACTIVATE)
    e2:SetTargetRange(1,0)
    e2:SetValue(s.restrictsame)
    e2:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e2,tp)
end
