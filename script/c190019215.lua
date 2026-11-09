-- Enforcer of the Harbinger System Terminus Proxy
-- EDOPro Rush Duel custom card
-- Card ID: 190019215
-- LIGHT / Galaxy / Fusion / Effect / Level 12 / ATK 4500 / DEF 3000
-- Fusion materials:
--   Enforcer of the Harbinger System (190019213)
--   Terminus Blade                  (190019214)
--
-- You can Contact Fusion Summon this card using the two named materials
-- from your face-up Monster Zone, shuffling them into the Deck.
-- [REQUIREMENT] Send all cards in your hand to the Graveyard.
-- [EFFECT] Gains 1000 ATK per card sent, may attack monsters up to 3 times,
-- redirects monsters it destroys by battle to the bottom of their owners'
-- Decks, and is protected against destruction/return by card effects until
-- the end of your opponent's turn.
-- While Terminus Blade is in your GY, this card cannot change battle position.

local s,id=GetID()
local ENFORCER=190019213
local TERMINUS_BLADE=190019214

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Normal Fusion materials: exactly Enforcer + Terminus Blade.
    Fusion.AddProcCode2(c,ENFORCER,TERMINUS_BLADE,false,true)

    -- Contact Fusion: shuffle the two face-up materials you control from
    -- your Monster Zone into the Deck, without a Fusion Spell.
    Fusion.AddContactProc(c,s.contactgroup,s.contactop,nil,nil,SUMMON_TYPE_FUSION)

    -- [REQUIREMENT] Send every card in your hand to the GY.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)

    -- While Terminus Blade is in your Graveyard, this card's battle
    -- position cannot be changed (including by card effects).
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
    e2:SetCondition(s.poscondition)
    c:RegisterEffect(e2)
end

function s.contactfilter(c)
    return c:IsFaceup() and c:IsAbleToDeckAsCost()
end

function s.contactgroup(tp)
    return Duel.GetMatchingGroup(s.contactfilter,tp,LOCATION_MZONE,0,nil)
end

function s.contactop(g,tp,fc)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST|REASON_MATERIAL|REASON_FUSION)
end

-- Requirement: there must be at least one card in hand, and ALL hand
-- cards must be eligible to be sent to the GY as the requirement.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
    if chk==0 then
        return #hg>0 and hg:FilterCount(Card.IsAbleToGraveAsCost,nil)==#hg
    end
    Duel.SendtoGrave(hg,REASON_COST)
    -- Count only cards that actually reached the GY.
    e:SetLabel(hg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE))
end

-- All granted effects expire after TWO End Phases: your current turn's
-- End Phase, then your opponent's End Phase.
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end
    local sent=e:GetLabel()
    local reset=RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END

    -- Gain 1000 ATK for each card sent from the hand to the GY.
    if sent>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(sent*1000)
        e1:SetReset(reset,2)
        c:RegisterEffect(e1)
    end

    -- Up to three attacks on monsters total (two additional attacks).
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
    e2:SetValue(2)
    e2:SetReset(reset,2)
    c:RegisterEffect(e2)

    -- Monsters this card destroys by battle go to the bottom of their
    -- owners' Decks instead of the Graveyard.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
    e3:SetValue(LOCATION_DECKBOT)
    e3:SetReset(reset,2)
    c:RegisterEffect(e3)

    -- Cannot be destroyed by card effects.
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e4:SetValue(1)
    e4:SetReset(reset,2)
    c:RegisterEffect(e4)

    -- Cannot be returned from the field to the hand or Deck.
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_CANNOT_TO_HAND)
    e5:SetReset(reset,2)
    c:RegisterEffect(e5)

    local e6=e5:Clone()
    e6:SetCode(EFFECT_CANNOT_TO_DECK)
    c:RegisterEffect(e6)
end

function s.poscondition(e)
    return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),
        LOCATION_GRAVE,0,1,nil,TERMINUS_BLADE)
end
