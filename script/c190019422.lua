--Harbinger of Infinity: Will of Terminus
--Card ID: 190019422
--Rush Duel - DARK / Fiend / Ritual / Effect
local s,id=GetID()

function s.initial_effect(c)
    --Ritual monsters must first be properly Ritual Summoned
    c:EnableReviveLimit()

    --While this card is face-up, all opponent's Level 10 or lower
    --monsters lose 5000 ATK.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0,LOCATION_MZONE)
    e1:SetTarget(s.atktg)
    e1:SetValue(-5000)
    c:RegisterEffect(e1)

    --Cannot be destroyed by card effects.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    --Cannot be returned from the field to the Extra Deck by card effects.
    --Engine approximation: EFFECT_CANNOT_TO_DECK also prevents returning
    --this card to the Main Deck, including non-effect returns, while on-field.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_CANNOT_TO_DECK)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    --Cannot be destroyed by battle with a Level 11 or lower monster.
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetValue(s.battleval)
    c:RegisterEffect(e4)
end

function s.atktg(e,c)
    return c:IsFaceup() and c:IsLevelBelow(10)
end

function s.battleval(e,c)
    local bc=e:GetHandler():GetBattleTarget()
    return bc~=nil and bc:IsLevelBelow(11)
end
