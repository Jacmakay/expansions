--Gandora the Dark Dragon of Annihilation
--Custom Rush Duel Legend Monster
--Card ID: 190019090
--DARK / Dragon / Effect / Level 8 / ATK 0 / DEF 0
local s,id=GetID()

function s.initial_effect(c)
    --Mark this custom card as a Rush Duel LEGEND card.
    --Official Rush Duel legends are listed in proc_rush.lua;
    --a custom card needs this flag to be recognized by Card.IsLegend.
    if EFFECT_IS_LEGEND then
        local e0=Effect.CreateEffect(c)
        e0:SetType(EFFECT_TYPE_SINGLE)
        e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
        e0:SetCode(EFFECT_IS_LEGEND)
        c:RegisterEffect(e0)
    end

    --Cannot be Special Summoned.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetValue(aux.FALSE)
    c:RegisterEffect(e1)

    --[REQUIREMENT] Pay either 1000 or 2000 LP.
    --[EFFECT] Destroy all other cards on the field, then this card
    --gains (the number of cards destroyed x 300) + LP paid as ATK
    --until the end of the next turn.
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY|CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.cost)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.CheckLPCost(tp,1000)
    end
    local paid=1000
    if Duel.CheckLPCost(tp,2000) then
        --Prompts the player to choose exactly 1000 or 2000.
        paid=Duel.AnnounceNumber(tp,1000,2000)
    end
    Duel.PayLPCost(tp,paid)
    e:SetLabel(paid)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
    --Count cards actually destroyed, not just cards attempted.
    local destroyed=0
    if #g>0 then
        destroyed=Duel.Destroy(g,REASON_EFFECT)
    end
    if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end

    local gain=destroyed*300+e:GetLabel()
    if gain<=0 then return end
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(gain)
    --Two End Phases: this turn and the opponent's following turn.
    --Also ends on leaving the field or being disabled.
    e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END,2)
    c:RegisterEffect(e1)
end
