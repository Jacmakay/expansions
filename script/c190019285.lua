-- Encounter: Dragon Maximus Irae
-- Custom EDOPro Rush Duel Normal Spell
-- Card ID: 190019285
--
-- [REQUIREMENT]
-- You control a Celestial Warrior or Wyrm monster.
-- [EFFECT]
-- Shuffle 1 Wyrm or Celestial Warrior monster from your field into
-- its owner's Deck; then Special Summon 1 Wyrm or Celestial Warrior
-- monster from your GY with a different name than the shuffled monster.
--
-- The shuffle is part of the effect, not an activation cost.

local s,id=GetID()

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK|CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Both Types are permitted, regardless of Attribute or Level.
function s.typefilter(c)
    return c:IsMonster()
        and c:IsRace(RACE_WYRM|RACE_CELESTIALWARRIOR)
end

-- A monster that can be Special Summoned and does not share the
-- shuffled monster's name. Compare its current card name/code.
function s.spfilter(c,e,tp,shuffled_code)
    return s.typefilter(c)
        and not c:IsCode(shuffled_code)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end

-- Only face-up monsters on your field can be identified by Type/name.
-- At activation there must already be an eligible DIFFERENT-name
-- monster in the GY for at least one possible shuffle choice.
function s.shufflefilter(c,e,tp)
    if not (c:IsFaceup() and s.typefilter(c) and c:IsAbleToDeck()) then
        return false
    end
    return Duel.IsExistingMatchingCard(
        aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,
        1,nil,e,tp,c:GetCode())
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.shufflefilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Select the monster to shuffle when the Spell resolves.
    if not Duel.IsExistingMatchingCard(
        s.shufflefilter,tp,LOCATION_MZONE,0,1,nil,e,tp) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.shufflefilter,
        tp,LOCATION_MZONE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if not tc then return end
    local shuffled_code=tc:GetCode()
    Duel.HintSelection(g)

    -- The revival only happens if the shuffle successfully returns
    -- the selected monster to the Deck/Extra Deck.
    if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then
        return
    end

    -- The shuffle freed a Monster Zone if your field was full.
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

    local f=aux.NecroValleyFilter(s.spfilter)
    if not Duel.IsExistingMatchingCard(f,tp,LOCATION_GRAVE,0,
        1,nil,e,tp,shuffled_code) then return end

    Duel.BreakEffect()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,f,tp,LOCATION_GRAVE,0,
        1,1,nil,e,tp,shuffled_code)
    local sc=sg:GetFirst()
    if sc then
        Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
    end
end
