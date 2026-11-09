-- Enough!!!
-- Custom Rush Duel Normal Spell
-- Card ID: 190019225
-- Assumption: the summoned monster comes from your Graveyard.

local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DECKDES|CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Requirement: Shuffle exactly 3 Main Deck monsters from your GY into your Deck.
function s.costfilter(c)
    return c:IsMonster()
        and not c:IsType(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)
        and c:IsAbleToDeckAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,3,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,3,3,nil)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

-- Summon a monster from your GY with ATK <= the total ATK milled.
function s.spfilter(c,e,tp,atk)
    return c:IsMonster() and c:GetAttack()>=0 and c:GetAttack()<=atk
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        -- The cost adds 3 cards to the Deck before the 9-card mill.
        return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)+3>=9
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    end
    Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,9)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsPlayerCanDiscardDeck(tp,9) then return end
    if Duel.DiscardDeck(tp,9,REASON_EFFECT)==0 then return end

    -- Only monsters actually sent to the GY by this mill contribute ATK.
    local g=Duel.GetOperatedGroup():Filter(function(c)
        return c:IsMonster() and c:IsLocation(LOCATION_GRAVE)
    end,nil)
    local total_atk=0
    for tc in aux.Next(g) do
        total_atk=total_atk+math.max(0,tc:GetAttack())
    end

    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local f=aux.NecroValleyFilter(s.spfilter)
    if not Duel.IsExistingMatchingCard(f,tp,LOCATION_GRAVE,0,1,nil,e,tp,total_atk) then return end
    Duel.BreakEffect()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,f,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,total_atk)
    if #sg>0 then
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
    end
end
