-- Enjin the Flaming Paladin
-- Custom EDOPro Rush Duel card - 190019249
-- Level 8 / FIRE / Pyro / Fusion / Effect / ATK 3000 / DEF 2500
local s,id=GetID()
local SPIRIT_OF_ENJIN=190019246
s.listed_names={SPIRIT_OF_ENJIN}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Fusion Materials: "Spirit of Enjin" + 1 FIRE Maximum Monster.
    Fusion.AddProcMix(c,false,false,SPIRIT_OF_ENJIN,s.fusmatfilter)

    -- [Requirement] Place 1 Maximum Monster from your GY on top of your Deck.
    -- [Effect] Destroy 1 card in your opponent's Spell & Trap Zones.
    -- If destroyed, gain +1000 ATK and protection from destruction by
    -- card effects until the end of your opponent's turn.
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY|CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- Only a FIRE Maximum Monster can be the second Fusion Material.
-- A Maximum Mode side piece cannot be used as Fusion Material.
function s.fusmatfilter(c)
    return c:IsType(TYPE_MAXIMUM) and c:IsAttribute(ATTRIBUTE_FIRE)
        and not c:IsMaximumModeSide()
end

function s.costfilter(c)
    return c:IsMonster() and c:IsType(TYPE_MAXIMUM) and c:IsAbleToDeck()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    -- Use SEQ_DECKTOP, not SEQ_DECKSHUFFLE: the requirement says "top".
    Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_COST)
end

function s.desfilter(c)
    return c:IsDestructable()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_STZONE,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_STZONE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- The effect does not target; choose the opposing Spell/Trap at resolution.
    if not Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_STZONE,1,nil) then
        return
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_STZONE,1,1,nil)
    if #g==0 or Duel.Destroy(g,REASON_EFFECT)==0 then return end

    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsFaceup()
        or not c:IsLocation(LOCATION_MZONE) then
        return
    end

    -- Rush ignition effects are activated on your turn. RESET_OPPO_TURN
    -- preserves the effects through your End Phase and expires at the
    -- end of your opponent's turn. Normal event resets clear them early
    -- if Paladin leaves the field or is flipped face-down.
    local reset=RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END|RESET_OPPO_TURN

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetValue(1)
    e1:SetReset(reset)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(1000)
    e2:SetReset(reset)
    c:RegisterEffect(e2)
end
