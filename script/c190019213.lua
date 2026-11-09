-- Enforcer of the Harbinger System
-- Custom EDOPro Rush Duel card - ID 190019213
-- DARK / Galaxy / Level 10 / ATK 3500 / DEF 3000
-- [REQUIREMENT] None
-- [CONTINUOUS EFFECT]
-- This card can make up to 3 attacks on monsters.
-- Each monster this card destroys by battle is returned to the bottom
-- of its owner's Deck instead of being sent to the Graveyard.
-- This card cannot be destroyed, or returned to the hand or Deck,
-- by card effects.

local s,id=GetID()

function s.initial_effect(c)
    -- Can make 2 additional attacks, each against a monster (3 in total).
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
    e1:SetValue(2)
    c:RegisterEffect(e1)

    -- Monsters this card destroys by battle go to the bottom of the Deck.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
    e2:SetValue(LOCATION_DECKBOT)
    c:RegisterEffect(e2)

    -- Cannot be destroyed by card effects.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    -- Cannot be returned from the field to the hand.
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EFFECT_CANNOT_TO_HAND)
    c:RegisterEffect(e4)

    -- Cannot be returned to the Deck by card effects. Using a send
    -- replacement instead of EFFECT_CANNOT_TO_DECK preserves its ability
    -- to be shuffled as Contact Fusion material (a summoning procedure).
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCode(EFFECT_SEND_REPLACE)
    e5:SetTarget(s.deckreptg)
    e5:SetValue(s.deckrepval)
    c:RegisterEffect(e5)
end

-- Stop effect-based returns to the Deck, but not a Contact Fusion's
-- material shuffle, which uses REASON_COST|REASON_MATERIAL|REASON_FUSION.
function s.deckreptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return (r&REASON_EFFECT)~=0 and eg:IsContains(c)
            and c:GetDestination()==LOCATION_DECK
    end
    return true
end

function s.deckrepval(e,c)
    return c==e:GetHandler()
end
