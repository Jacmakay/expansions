-- Ichigo Bankai Sage Mode
-- Rush Duel | ID 190019197
-- DARK / Level 9 / Spellcaster / Fusion / Effect
-- Fusion Materials: "The Shinigami From Afar - Born in the Dark" (190019100)
--                   + 1 Spellcaster monster
local s,id=GetID()
local SHINIGAMI_ID=190019100

function s.initial_effect(c)
    -- Fusion Materials
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,SHINIGAMI_ID,s.matfilter)

    -- [REQUIREMENT] Shuffle 2 Spell Cards from your GY into the Deck.
    -- [EFFECT] Gain 1000 ATK this turn, then optionally destroy an
    -- opponent's Spell Card. If destroyed, gain piercing this turn.
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.matfilter(c,fc,sumtype,tp,sub,mg,sg,contact)
    return c:IsRace(RACE_SPELLCASTER)
end

function s.spellcostfilter(c)
    return c:IsType(TYPE_SPELL) and c:IsAbleToDeckAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.spellcostfilter,tp,LOCATION_GRAVE,0,2,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.spellcostfilter,tp,LOCATION_GRAVE,0,2,2,nil)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.destroyfilter(c)
    return c:IsType(TYPE_SPELL) and c:IsDestructable()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsFaceup() or not c:IsLocation(LOCATION_MZONE) then return end

    -- +1000 ATK until the end of this turn
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(1000)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)

    -- Destroying a Spell is optional; selecting zero cards skips it.
    if not Duel.IsExistingMatchingCard(s.destroyfilter,tp,0,LOCATION_SZONE,1,nil) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.destroyfilter,tp,0,LOCATION_SZONE,0,1,nil)
    if #g==0 then return end
    if Duel.Destroy(g,REASON_EFFECT)==0 then return end

    -- Piercing battle damage until the end of this turn
    if not c:IsFaceup() or not c:IsLocation(LOCATION_MZONE) then return end
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_PIERCE)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e2)
end
