--Timaeus X
--Custom Rush Duel monster - 190019264
local s,id=GetID()

function s.initial_effect(c)
    --Track the card name for Rush Duel's activation-history condition.
    -- Effect name is already tracked by SetCountLimit(1,id).

    --[REQUIREMENT] You have not activated "Timaeus X" this turn.
    --Send the top 2 cards of your Deck to the Graveyard.
    --[EFFECT] Special Summon 1 Dragon, Spellcaster, Magical Knight,
    --or Warrior monster from your Graveyard.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return true -- once-per-turn code limit handles the requirement
end

function s.spfilter(c,e,tp)
    return (c:IsRace(RACE_DRAGON)
        or c:IsRace(RACE_SPELLCASTER)
        or c:IsRace(RACE_MAGICALKNIGHT)
        or c:IsRace(RACE_WARRIOR))
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        --The Deck-mill cost can place a valid monster into the GY,
        --so do not require one to be there before paying that cost.
        return Duel.GetMZoneCount(tp)>0
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetMZoneCount(tp)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),
        tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,2) end
    Duel.DiscardDeck(tp,2,REASON_COST)
end
