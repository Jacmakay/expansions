-- Nozett the Ultimate Paladin
-- Card ID: 190019299 (using the uploaded file's ID)
-- EDOPro Rush Duel
-- Level 11 / LIGHT / Magical Knight / Fusion / Effect
-- ATK 3600 / DEF 3000
-- Fusion Materials: "Nozett The Ultimate Soul" (190019289)
--                   + 1 Level 10 Psychic monster
--
-- [REQUIREMENT] Send the top 2 cards of your Deck to the Graveyard.
-- [EFFECT] This card gains 1000 ATK, can attack twice, and cannot be
-- destroyed by card effects until the end of your opponent's turn.
-- If you have a Level 4 LIGHT Galaxy monster in your Graveyard,
-- this card gains 1500 ATK instead of 1000.

local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Fusion materials: Nozett The Ultimate Soul + Level 10 Psychic
    Fusion.AddProcMix(c,false,true,190019289,s.matfilter)

    -- Rush Duel effect: once per turn for this copy
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- The second Fusion Material must be a Level 10 Psychic monster.
function s.matfilter(c,fc,sumtype,tp)
    return c:IsType(TYPE_MONSTER)
        and c:IsLevel(10)
        and c:IsRace(RACE_PSYCHIC)
end

-- [REQUIREMENT] Mill exactly 2 cards as the activation cost.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsPlayerCanDiscardDeckAsCost(tp,2)
    end
    Duel.DiscardDeck(tp,2,REASON_COST)
end

-- Check whether the GY contains a Level 4 LIGHT Galaxy monster.
function s.galaxyfilter(c)
    return c:IsType(TYPE_MONSTER)
        and c:IsLevel(4)
        and c:IsAttribute(ATTRIBUTE_LIGHT)
        and c:IsRace(RACE_GALAXY)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end

    -- Evaluate the GY AFTER the requirement has sent the top 2 cards.
    local atk=1000
    if Duel.IsExistingMatchingCard(s.galaxyfilter,tp,LOCATION_GRAVE,0,1,nil) then
        atk=1500
    end

    -- All three effects last until the end of your opponent's turn,
    -- or until the monster undergoes a standard reset.
    local reset=RESET_EVENT+RESETS_STANDARD_DISABLE
        +RESET_PHASE+PHASE_END+RESET_OPPO_TURN

    -- Gain 1000 or 1500 ATK.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(atk)
    e2:SetReset(reset)
    c:RegisterEffect(e2)

    -- Can make 1 additional attack (2 attacks total).
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_EXTRA_ATTACK)
    e3:SetValue(1)
    e3:SetReset(reset)
    c:RegisterEffect(e3)

    -- Cannot be destroyed by card effects.
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e4:SetValue(1)
    e4:SetReset(reset)
    c:RegisterEffect(e4)
end
