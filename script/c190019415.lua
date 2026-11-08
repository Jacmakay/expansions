--Infinity Servitor Indiora
--Card ID: 190019415
--Rush Duel

local s,id=GetID()

function s.initial_effect(c)
    --[REQUIREMENT] Shuffle 3 Machine and/or Fiend monsters from your GY
    --into the Deck.
    --[EFFECT] Destroy 1 Level 8 or lower monster your opponent controls,
    --then Special Summon 1 Level 1 Fiend monster from your GY.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY|CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

--Machine and Fiend monsters can be mixed to meet the requirement.
function s.deckfilter(c)
    return c:IsMonster()
        and c:IsRace(RACE_MACHINE|RACE_FIEND)
        and c:IsAbleToDeck()
end

--A Level 1 Fiend must remain available after shuffling 3 monsters.
function s.reservefilter(c,e,tp)
    return s.spfilter(c,e,tp)
        and Duel.IsExistingMatchingCard(s.deckfilter,tp,LOCATION_GRAVE,0,3,c)
end

--Shuffle exactly 3 qualifying monsters into the Deck as the requirement.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.reservefilter,
            tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    --Reserve one legal monster so the shuffle cannot remove every
    --monster that could be Special Summoned by this effect.
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local keep=Duel.SelectMatchingCard(tp,s.reservefilter,
        tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.deckfilter,
        tp,LOCATION_GRAVE,0,3,3,keep)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

--A monster's Level must be public to select it by Level.
function s.destroyfilter(c)
    return c:IsFaceup()
        and c:IsMonster()
        and c:IsLevelBelow(8)
        and c:IsDestructable()
end

function s.spfilter(c,e,tp)
    return c:IsMonster()
        and c:IsRace(RACE_FIEND)
        and c:IsLevel(1)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.destroyfilter,tp,0,LOCATION_MZONE,1,nil)
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    --Destroy an opponent's Level 8 or lower face-up monster.
    if not Duel.IsExistingMatchingCard(s.destroyfilter,tp,0,LOCATION_MZONE,1,nil) then
        return
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local dg=Duel.SelectMatchingCard(tp,s.destroyfilter,tp,0,LOCATION_MZONE,1,1,nil)
    if #dg==0 or Duel.Destroy(dg,REASON_EFFECT)==0 then
        return
    end

    --Then Special Summon a Level 1 Fiend if one is still available.
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
        or not Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),
            tp,LOCATION_GRAVE,0,1,nil,e,tp) then
        return
    end
    Duel.BreakEffect()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),
        tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #sg>0 then
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
    end
end
