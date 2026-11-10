-- Endbringers: The Phoenix and Turtle
-- Custom EDOPro Rush Duel Normal Spell
-- Card ID: 190019223
-- [Requirement] Shuffle 5 monsters from your GY into the Deck.
-- [Effect] Special Summon 1 Level 11 or lower FIRE, WATER, or WIND monster
-- from your GY in Attack Position. If it was Level 11, you may Fusion
-- Summon 1 FIRE, WATER, or WIND Fusion Monster from your Extra Deck,
-- using monsters from your hand or field as Fusion Material.
local s,id=GetID()

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TODECK|CATEGORY_SPECIAL_SUMMON|CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

local VALID_ATTRIBUTES=ATTRIBUTE_FIRE|ATTRIBUTE_WATER|ATTRIBUTE_WIND

function s.costfilter(c)
    return c:IsMonster() and c:IsAbleToDeckAsCost()
end

function s.spfilter(c,e,tp)
    return c:IsMonster() and c:IsLevelBelow(11)
        and c:IsAttribute(VALID_ATTRIBUTES)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end

-- Restrict the five-card requirement to groups that still leave a
-- legally summonable monster in the GY after the shuffle.
function s.costcheck(sg,e,tp,mg)
    if #sg~=5 then return false end
    return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),
        tp,LOCATION_GRAVE,0,1,sg,e,tp)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
        return false
    end
    local mg=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_GRAVE,0,nil)
    if chk==0 then
        return #mg>=5 and aux.SelectUnselectGroup(mg,e,tp,5,5,s.costcheck,0)
    end
    local sg=aux.SelectUnselectGroup(mg,e,tp,5,5,s.costcheck,1,tp,HINTMSG_TODECK)
    if not sg or #sg~=5 then return end
    Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsPlayerCanSpecialSummon(tp)
            and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),
                tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.fusionfilter(c,tp)
    return c:IsAttribute(VALID_ATTRIBUTES)
end

function s.fusionmatfilter(c,e,tp,chk)
    return c:IsMonster() and c:IsControler(tp)
        and c:IsLocation(LOCATION_HAND|LOCATION_MZONE)
        and c:IsAbleToGrave()
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),
        tp,LOCATION_GRAVE,0,1,nil,e,tp) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),
        tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if not tc then return end
    if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)==0 then return end

    -- The bonus Fusion Summon is optional and only available if the
    -- successfully revived monster is Level 11.
    if not tc:IsLevel(11) then return end
    local fusion_target=Fusion.SummonEffTG(s.fusionfilter,s.fusionmatfilter)
    if fusion_target(e,tp,eg,ep,ev,re,r,rp,0)
        and Duel.SelectYesNo(tp,1170) then
        local fusion_operation=Fusion.SummonEffOP(s.fusionfilter,s.fusionmatfilter)
        fusion_operation(e,tp,eg,ep,ev,re,r,rp)
    end
end
