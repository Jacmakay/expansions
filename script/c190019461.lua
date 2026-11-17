-- Yuki-Musume, Servant of Frost | 190019461
-- WATER / Zombie / Level 3 / 500 ATK / 1500 DEF
-- [REQUIREMENT] Send the top 2 cards of your Deck to the GY.
-- [EFFECT] Special Summon 1 WATER Zombie with 1500 or less ATK from your GY
-- in face-up Defense Position.
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCategory(CATEGORY_DECKDES|CATEGORY_SPECIAL_SUMMON)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,2) end
    Duel.DiscardDeck(tp,2,REASON_COST)
end
function s.spfilter(c,e,tp)
    return c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_ZOMBIE)
        and c:IsAttackBelow(1500)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    -- The two cards sent as the Requirement may be the ones revived.
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local f=aux.NecroValleyFilter(s.spfilter)
    if not Duel.IsExistingMatchingCard(f,tp,LOCATION_GRAVE,0,1,nil,e,tp) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,f,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE) end
end
