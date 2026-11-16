-- Gum-Gum King Kong Gun
-- Custom Rush Duel card; ID 190019133
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end
function s.luffy(c) return c:IsFaceup() and c:IsCode(190019121) end
function s.l8(c) return c:IsFaceup() and c:IsLevel(8) and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE) end
function s.l10(c) return c:IsFaceup() and c:IsLevel(10) and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE) end
function s.firewarrior(c) return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE) end
function s.high(c) return s.firewarrior(c) and c:IsLevelAbove(6) end
function s.addatk(tc,c,n,turns)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(n)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,turns or 1)
    tc:RegisterEffect(e1)
end
function s.pierce(tc,c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_PIERCE)
    e1:SetValue(1)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
    tc:RegisterEffect(e1)
end
function s.one(tp,fn)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectMatchingCard(tp,fn,tp,LOCATION_MZONE,0,1,1,nil)
    return g:GetFirst()
end
function s.handfilter(c) return c:IsAbleToGraveAsCost() end
function s.sendcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.handfilter,tp,LOCATION_HAND,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.handfilter,tp,LOCATION_HAND,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.l8,tp,LOCATION_MZONE,0,1,nil) end
end
function s.operation(e,tp)
    local tc=s.one(tp,s.l8)
    if not tc then return end
    s.addatk(tc,e:GetHandler(),tc:GetAttack())
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
    tc:RegisterEffect(e1)
end
