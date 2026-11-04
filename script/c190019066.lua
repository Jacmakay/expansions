--Ancient Gear Ultimate Golem
--Card ID: 190019066
local s,id=GetID()

local ANCIENT_GEAR_GOLEM=83104731

function s.initial_effect(c)
    --Fusion Materials:
    --"Ancient Gear Golem" + 2 Level 5 or higher Machine monsters
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,false,true,s.golemfilter,s.machinefilter,s.machinefilter)

    --Piercing battle damage
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(e1)

    --Your opponent cannot activate Trap Cards when this card declares an attack
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_ATTACK_ANNOUNCE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetOperation(s.actop)
    c:RegisterEffect(e2)
end

s.listed_names={ANCIENT_GEAR_GOLEM}

function s.golemfilter(c,fc,sumtype,tp)
    return c:IsCode(ANCIENT_GEAR_GOLEM)
end

function s.machinefilter(c,fc,sumtype,tp)
    return c:IsRace(RACE_MACHINE,fc,sumtype,tp)
        and c:IsLevelAbove(5)
end

function s.actop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetTargetRange(0,1)
    e1:SetValue(s.aclimit)
    e1:SetCondition(s.actcon)
    e1:SetReset(RESET_CHAIN)
    Duel.RegisterEffect(e1,tp)
end

function s.aclimit(e,re,tp)
    return re:GetHandler():IsTrap()
        and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end

function s.actcon(e)
    return Duel.GetAttacker()==e:GetHandler()
end
