-- Harbinger of Infinity Anima
-- Custom Rush Duel Monster
-- Card ID: 190019212
local s,id=GetID()

function s.initial_effect(c)
    -- While this card is face-up, you take no battle damage
    -- from battles involving your other monsters.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(1,0)
    e1:SetCondition(s.battlecon)
    c:RegisterEffect(e1)

    -- Gains 100 ATK for each Fiend or Machine monster in your GY.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)

    -- Cannot be destroyed by card effects.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    -- Cannot be returned to the hand by card effects.
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_CANNOT_TO_HAND)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(1,1)
    e4:SetTarget(s.returnlimit)
    c:RegisterEffect(e4)

    -- Cannot be returned to the Deck by card effects.
    local e5=e4:Clone()
    e5:SetCode(EFFECT_CANNOT_TO_DECK)
    c:RegisterEffect(e5)
end

function s.battlecon(e)
    local self=e:GetHandler()
    local tp=self:GetControler()
    local a=Duel.GetAttacker()
    local d=Duel.GetAttackTarget()
    return (a and a~=self and a:IsControler(tp))
        or (d and d~=self and d:IsControler(tp))
end

function s.gyfilter(c)
    return c:IsMonster() and c:IsRace(RACE_FIEND|RACE_MACHINE)
end

function s.atkval(e,c)
    return Duel.GetMatchingGroupCount(
        s.gyfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)*100
end

function s.returnlimit(e,c)
    return c==e:GetHandler()
end
