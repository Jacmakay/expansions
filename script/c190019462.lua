-- Hajun, Servant of Frost | 190019462
-- WATER / Zombie / Level 1 / 600 ATK / 400 DEF
-- [REQUIREMENT] You control no other monsters.
-- [EFFECT] Special Summon 1 Level 4 or lower WATER Zombie from your hand
-- in face-up Defense Position; then you may send the top 2 cards of your
-- Deck to the GY.
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end
function s.condition(e,tp)
    local c=e:GetHandler()
    return c:IsFaceup() and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
end
function s.spfilter(c,e,tp)
    return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_WATER)
        and c:IsRace(RACE_ZOMBIE)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    if #g==0 or Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)==0 then return end
    if Duel.IsPlayerCanDiscardDeckAsCost(tp,2)
        and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.DiscardDeck(tp,2,REASON_EFFECT)
    end
end
