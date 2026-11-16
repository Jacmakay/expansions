-- Terminus Servitor - Yamato Eclipse
-- Custom EDOPro Rush Duel Fusion -- ID 190019181
local s,id=GetID()
local VERGIL=190019180
local TERMINUS_BLADE=190019214
s.material={VERGIL,TERMINUS_BLADE}

function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,false,false,VERGIL,TERMINUS_BLADE)

    -- Judgement Cut End:
    -- [REQUIREMENT] Send 1 card from hand to GY.
    -- [EFFECT] Send up to 3 face-up opposing monsters to GY,
    -- deal 500 damage per monster sent, and prohibit your other
    -- monsters from attacking directly for the rest of the turn.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
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
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end

function s.sendfilter(c)
    return c:IsFaceup() and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.sendfilter,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
function s.directattacklimit(e,c)
    -- Preserve the activating Fusion Monster's field identity.
    return c:GetFieldID()~=e:GetLabel()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.sendfilter,tp,0,LOCATION_MZONE,1,3,nil)
    local ct=0
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
        ct=g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
    end
    if ct>0 then
        Duel.Damage(1-tp,ct*500,REASON_EFFECT)
    end

    -- For the remainder of this turn, only this copy of Yamato Eclipse
    -- may declare a direct attack; other monsters can still attack monsters.
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(s.directattacklimit)
    e1:SetLabel(e:GetHandler():GetFieldID())
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
