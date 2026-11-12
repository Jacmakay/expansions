-- Nozett The Ultimate Sage
-- Card ID: 190019298
-- EDOPro Rush Duel
-- Level 11 / LIGHT / Spellcaster / Fusion / Effect
-- ATK 3600 / DEF 3000
-- Fusion Materials: "Nozett The Ultimate Soul" (190019289)
--                   + 1 Level 10 Spellcaster monster
--
-- [REQUIREMENT] Shuffle 2 Spell Cards from your GY into your Deck.
-- [EFFECT] Special Summon 1 Level 10 monster from your GY to your
-- field in face-up Defense Position. Then, if you have a Level 4
-- LIGHT Galaxy monster in your GY, you can shuffle 1 card on your
-- opponent's field into its owner's Deck.

local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Fusion Materials
    Fusion.AddProcMix(c,false,true,190019289,s.matfilter)

    -- Rush Duel effect (once per turn, per copy)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- Other Fusion Material: Level 10 Spellcaster
function s.matfilter(c,fc,sumtype,tp)
    return c:IsType(TYPE_MONSTER)
        and c:IsLevel(10)
        and c:IsRace(RACE_SPELLCASTER)
end

-- [REQUIREMENT]: exactly 2 Spell Cards in the GY to shuffle into Deck
function s.costfilter(c)
    return c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,2,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,2,2,nil)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

-- Eligible Level 10 monsters to revive in face-up Defense Position
function s.spfilter(c,e,tp)
    return c:IsType(TYPE_MONSTER)
        and c:IsLevel(10)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

-- Condition for the optional shuffle-into-Deck effect
function s.galfilter(c)
    return c:IsType(TYPE_MONSTER)
        and c:IsLevel(4)
        and c:IsAttribute(ATTRIBUTE_LIGHT)
        and c:IsRace(RACE_GALAXY)
end

function s.tdfilter(c)
    return c:IsAbleToDeck()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),
                tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

    -- Mandatory first step: revive a Level 10 monster.
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),
        tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if not tc then return end
    if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)==0 then
        return
    end

    -- Optional second step: only available after a successful summon,
    -- with a Level 4 LIGHT Galaxy monster still in your GY.
    if Duel.IsExistingMatchingCard(s.galfilter,tp,LOCATION_GRAVE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.tdfilter,tp,0,LOCATION_ONFIELD,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local dg=Duel.SelectMatchingCard(tp,s.tdfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
        if #dg>0 then
            -- SendtoDeck returns the card to its owner's Deck (or Extra Deck).
            Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        end
    end
end
