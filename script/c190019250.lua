-- Salamandus Flames of Time
-- Custom EDOPro Rush Duel card, ID 190019250
-- Level 11 / FIRE / Pyro / Ritual / Effect / ATK 4000 / DEF 3000
-- Rush Ritual Monsters are summoned from the Extra Deck by a Ritual Spell.
-- This script implements the monster's effect, not a Ritual Spell.
local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- [Requirement] Shuffle 5 Pyro monsters from your GY into your Deck.
    -- [Effect] Opponent's face-up monsters lose 3500 ATK this turn.
    -- If Ritual Summoned with a Maximum or Fusion Monster, this card may
    -- attack 3 times this turn and is immune to effect destruction until
    -- the end of your opponent's turn.
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TODECK|CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.costfilter(c)
    return c:IsMonster() and c:IsRace(RACE_PYRO) and c:IsAbleToDeckAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,5,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,5,5,nil)
    if #g~=5 then return end
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.wasritualwithspecialmat(c)
    if not c:IsSummonType(SUMMON_TYPE_RITUAL) then return false end
    -- Ritual scripts set these materials via tc:SetMaterial(mat).
    local g=c:GetMaterial()
    return g and g:IsExists(function(mc)
        return mc:IsType(TYPE_FUSION|TYPE_MAXIMUM)
            or mc:IsOriginalType(TYPE_FUSION|TYPE_MAXIMUM)
    end,1,nil)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    -- Lower only the ATK of monsters that are currently face-up.
    -- These reductions remain until this turn's End Phase even if
    -- Salamandus subsequently leaves the Monster Zone.
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    for tc in aux.Next(g) do
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(-3500)
        e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
        tc:RegisterEffect(e1)
    end

    -- Bonus requires this card to be face-up and still related to the
    -- effect, and a Ritual Summon using Maximum or Fusion material.
    if not c:IsRelateToEffect(e) or not c:IsFaceup()
        or not c:IsLocation(LOCATION_MZONE)
        or not s.wasritualwithspecialmat(c) then return end

    -- Two extra attacks = three attacks total this turn.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EXTRA_ATTACK)
    e2:SetValue(2)
    e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
    c:RegisterEffect(e2)

    -- Effect-destruction protection persists through the END of the
    -- opponent's turn, but ends early if flipped face-down/leaves field.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetValue(1)
    e3:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END|RESET_OPPO_TURN)
    c:RegisterEffect(e3)
end
