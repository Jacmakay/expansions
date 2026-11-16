-- Gum-Gum Balloon
-- Custom Rush Duel card; ID 190019139
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
    return ac and ac:IsControler(1-tp) and tc and tc:IsControler(tp) and tc:IsFaceup() and tc:IsRace(RACE_WARRIOR) and tc:IsAttribute(ATTRIBUTE_FIRE)
end
function s.operation(e,tp)
    local tc=Duel.GetAttackTarget()
    if not tc or not tc:IsControler(tp) or not tc:IsFaceup() then return end
    if Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)>0 then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_DEFENSE)
        e1:SetValue(2000)
        e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
        tc:RegisterEffect(e1)
    end
end
