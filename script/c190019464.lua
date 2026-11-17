-- Shafu, Servant of Frost | 190019464
-- WATER / Zombie / Level 3 / 1200 ATK / 400 DEF
-- [REQUIREMENT] Send 1 WATER Zombie monster from your hand to the GY.
-- [EFFECT] Revive 1 Level 4 or lower WATER Zombie in face-up Defense
-- Position. Optionally place another WATER Zombie in your GY on the
-- bottom of your Deck.
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCategory(CATEGORY_TOGRAVE|CATEGORY_SPECIAL_SUMMON|CATEGORY_TODECK)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end
function s.handfilter(c)
    return c:IsMonster() and c:IsAttribute(ATTRIBUTE_WATER)
        and c:IsRace(RACE_ZOMBIE) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.handfilter,tp,LOCATION_HAND,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.handfilter,tp,LOCATION_HAND,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end
function s.spfilter(c,e,tp)
    return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_WATER)
        and c:IsRace(RACE_ZOMBIE)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.bottomfilter(c)
    return c:IsMonster() and c:IsAttribute(ATTRIBUTE_WATER)
        and c:IsRace(RACE_ZOMBIE) and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local f=aux.NecroValleyFilter(s.spfilter)
    if not Duel.IsExistingMatchingCard(f,tp,LOCATION_GRAVE,0,1,nil,e,tp) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,f,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g==0 or Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)==0 then return end
    local bf=aux.NecroValleyFilter(s.bottomfilter)
    if Duel.IsExistingMatchingCard(bf,tp,LOCATION_GRAVE,0,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local sg=Duel.SelectMatchingCard(tp,bf,tp,LOCATION_GRAVE,0,1,1,nil)
        if #sg>0 then Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT) end
    end
end
