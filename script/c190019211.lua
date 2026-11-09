-- Harbinger of Frost Yuki-Onna
-- Custom Rush Duel card - ID 190019211
-- [Requirement] None
-- [Continuous Effect]
-- Monsters summoned from your opponent's Graveyard cannot activate their effects.
-- This card cannot be destroyed by card effects, nor returned from the field
-- to the hand or Deck by card effects.

local s,id=GetID()

function s.initial_effect(c)
    -- Continuous: Monsters summoned from the opponent's GY cannot activate effects.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_TRIGGER)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e1:SetTarget(s.actlimit)
    c:RegisterEffect(e1)

    -- Cannot be destroyed by card effects.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- Cannot be returned from the field to the hand.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_CANNOT_TO_HAND)
    c:RegisterEffect(e3)

    -- Cannot be returned from the field to the Deck.
    local e4=e3:Clone()
    e4:SetCode(EFFECT_CANNOT_TO_DECK)
    c:RegisterEffect(e4)
end

function s.actlimit(e,tc)
    -- The GY belongs to the monster's owner, even if control has changed.
    return tc:IsFaceup()
        and tc:IsSummonLocation(LOCATION_GRAVE)
        and tc:IsOwner(1-e:GetHandlerPlayer())
end
