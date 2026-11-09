-- Madness of Equilibrium
-- EDOPro Custom Rush Duel Ritual Monster
-- Card ID: 190019231
-- DARK / Fiend / Ritual / Effect - Level 10 - ATK 3500 / DEF 3500
--
-- [REQUIREMENT]
-- Shuffle 3 LIGHT and/or DARK monsters from your GY into the Deck.
-- [EFFECT]
-- Destroy 1 monster on your opponent's field. If you shuffled at least
-- 1 LIGHT and at least 1 DARK monster, this card gains 1500 ATK until
-- the end of your opponent's next turn.
--
-- The Ritual Summon itself is handled by a Ritual Spell (e.g.,
-- Equilibrium Ritual, 190019232), not by this monster script.

local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TODECK|CATEGORY_DESTROY|CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1) -- once per turn for each face-up copy (Rush Duel)
    e1:SetCost(s.reqcheck)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- LIGHT and/or DARK monsters that can be returned to the Deck.
function s.reqfilter(c)
    return c:IsMonster()
        and c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK)
        and c:IsAbleToDeck()
end

function s.lightfilter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT)
end

function s.darkfilter(c)
    return c:IsAttribute(ATTRIBUTE_DARK)
end

function s.desfilter(c)
    return c:IsMonster() and c:IsDestructable()
end

-- Check the Rush Duel [REQUIREMENT]. Its action is performed first
-- during resolution, following the custom Rush scripts in this set.
function s.reqcheck(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.reqfilter,tp,LOCATION_GRAVE,0,3,nil)
    end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- [REQUIREMENT] Choose exactly 3 LIGHT and/or DARK monsters in your GY.
    if not Duel.IsExistingMatchingCard(s.reqfilter,tp,LOCATION_GRAVE,0,3,nil) then
        return
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local sg=Duel.SelectMatchingCard(tp,s.reqfilter,tp,LOCATION_GRAVE,0,3,3,nil)
    if #sg~=3 then return end

    -- Save which Attributes were selected before shuffling them away.
    local shuffled_light=sg:IsExists(s.lightfilter,1,nil)
    local shuffled_dark=sg:IsExists(s.darkfilter,1,nil)
    if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)~=3 then
        return
    end

    -- [EFFECT] Destroy 1 of your opponent's monsters (no target at activation).
    if Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local dg=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
        if #dg>0 then
            Duel.Destroy(dg,REASON_EFFECT)
        end
    end

    -- If BOTH LIGHT and DARK were shuffled, gain 1500 ATK through
    -- your opponent's following turn (2 End Phases from activation).
    local c=e:GetHandler()
    if shuffled_light and shuffled_dark and c:IsFaceup()
        and c:IsRelateToEffect(e) then
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_UPDATE_ATTACK)
        e2:SetValue(1500)
        e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,2)
        c:RegisterEffect(e2)
    end
end
