-- Salamandus Salamangreat
-- Custom EDOPro / Rush Duel monster
-- Card ID: 190019247
-- Level 3 FIRE / Pyro / Effect, ATK 1500 / DEF 1000
local s,id=GetID()
local CHEMICALIZED_SALAMANDER=160010020
s.listed_names={CHEMICALIZED_SALAMANDER}

function s.initial_effect(c)
    -- This card's name is "Chemicalized Salamander" while in the Graveyard.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetValue(CHEMICALIZED_SALAMANDER)
    c:RegisterEffect(e1)

    -- [Requirement] Place 2 Maximum monsters from your GY on top of the Deck.
    -- [Effect] Revive 1 Level 7+ Pyro from your GY in Attack Position,
    -- then this card's name becomes "Chemicalized Salamander" this turn.
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK|CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

function s.maxfilter(c)
    return c:IsMonster() and c:IsType(TYPE_MAXIMUM) and c:IsAbleToDeckAsCost()
end

function s.spfilter(c,e,tp)
    return c:IsMonster() and c:IsRace(RACE_PYRO) and c:IsLevelAbove(7)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end

-- Do not allow choosing a cost group that would leave no valid revival target.
function s.costcheck(sg,e,tp,mg)
    return #sg==2 and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),
        tp,LOCATION_GRAVE,0,1,sg,e,tp)
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 and (Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
        or not Duel.IsPlayerCanSpecialSummon(tp)) then
        return false
    end
    local mg=Duel.GetMatchingGroup(s.maxfilter,tp,LOCATION_GRAVE,0,nil)
    if chk==0 then
        return #mg>=2 and aux.SelectUnselectGroup(mg,e,tp,2,2,s.costcheck,0)
    end
    local sg=aux.SelectUnselectGroup(mg,e,tp,2,2,s.costcheck,1,tp,HINTMSG_TODECK)
    if not sg or #sg~=2 then return end
    local ct=Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_COST)
    -- Explicitly keep the two returned cards on top, in the chosen order.
    if ct==2 then Duel.SortDecktop(tp,tp,2) end
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsPlayerCanSpecialSummon(tp)
            and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),
                tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),
        tp,LOCATION_GRAVE,0,1,nil,e,tp) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),
        tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if not tc or Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)==0 then
        return
    end

    -- Only change this card's name after the summon succeeded.
    local c=e:GetHandler()
    if c:IsFaceup() and c:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_CODE)
        e1:SetValue(CHEMICALIZED_SALAMANDER)
        e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
        c:RegisterEffect(e1)
    end
end
