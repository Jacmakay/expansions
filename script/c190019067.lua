-- Wota Zero Mode Finality
-- Custom Rush Duel monster
-- Level 8 / DARK / Machine / Effect
-- ATK 3000 / DEF 0
local s,id=GetID()

function s.initial_effect(c)
    -- [REQUIREMENT] Send the top 2 cards of your Deck to the Graveyard.
    -- [EFFECT] Gain 500 ATK; this card can attack monsters up to twice this turn.
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsPlayerCanDiscardDeckAsCost(tp,2)
    end
    Duel.DiscardDeck(tp,2,REASON_COST)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
    local reset=RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END

    -- +500 ATK until the end of this turn.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(500)
    e1:SetReset(reset)
    c:RegisterEffect(e1)

    -- One extra attack on a monster (two monster attacks total).
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
    e2:SetValue(1)
    e2:SetReset(reset)
    c:RegisterEffect(e2)
end
