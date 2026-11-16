-- Observation Haki
-- Custom Rush Duel card; ID 190019138
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetCondition(s.condition)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end
function s.condition(e,tp)
    local tc=Duel.GetAttackTarget()
    local ac=Duel.GetAttacker()
    return ac and ac:IsControler(1-tp) and tc and tc:IsControler(tp) and tc:IsFaceup() and tc:IsCode(190019121)
end
function s.operation(e,tp)
    local tc=Duel.GetAttackTarget()
    local ac=Duel.GetAttacker()
    if not tc or not ac or not tc:IsControler(tp) or not tc:IsFaceup() then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(math.floor(math.max(0,ac:GetAttack())/2))
    e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
    tc:RegisterEffect(e1)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetValue(1)
    e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
    tc:RegisterEffect(e2)
end
