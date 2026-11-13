-- Reversal Technique Ultimas
-- Custom EDOPro Rush Duel Normal Spell
-- Card ID: 190019208
--
-- [REQUIREMENT]
-- Shuffle exactly 3 cards from your GY into the Deck.
--
-- [EFFECT]
-- Destroy 1 face-up monster your opponent controls with 3000 or less ATK.
-- Then, you can Special Summon 1 Level 8 LIGHT Dragon monster from
-- your GY in face-up Attack Position.

local s,id=GetID()

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TODECK|CATEGORY_DESTROY|CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Requirement: choose any 3 cards that can actually be shuffled back
-- into the Main Deck. Extra Deck monsters are excluded.
function s.costfilter(c)
    return c:IsAbleToDeckAsCost()
        and not (c:IsMonster() and c:IsType(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK))
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,3,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,3,3,nil)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

-- Only face-up monsters have an ATK value that can be checked here.
function s.desfilter(c)
    return c:IsFaceup() and c:IsMonster() and c:IsDestructable()
        and c:GetAttack()>=0 and c:GetAttack()<=3000
end

function s.spfilter(c,e,tp)
    return c:IsMonster() and c:IsLevel(8)
        and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_DRAGON)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Select and destroy an eligible opponent's monster on resolution.
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
    if #g==0 then return end
    if Duel.Destroy(g,REASON_EFFECT)==0 then return end

    -- "Then you can": the Special Summon is optional and is offered
    -- only after successfully destroying a monster.
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local f=aux.NecroValleyFilter(s.spfilter)
    if not Duel.IsExistingMatchingCard(f,tp,LOCATION_GRAVE,0,1,nil,e,tp) then
        return
    end
    -- Optional custom database string (str1):
    -- "Special Summon 1 Level 8 LIGHT Dragon monster from your GY?"
    if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end

    Duel.BreakEffect()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,f,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #sg>0 then
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_ATTACK)
    end
end
