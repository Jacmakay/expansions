-- Ultimecia the Titan of Endless Darkness
-- Custom EDOPro Rush Duel Effect Monster
-- Card ID: 190019201
-- Level 4 / DARK / Galaxy / Effect / ATK 1600 / DEF 1300
--
-- [REQUIREMENT] Send 1 card from your hand to the GY.
-- [EFFECT] Special Summon 1 Level 8 or higher Dragon, Galaxy, or
-- Spellcaster monster from your GY in face-up Attack Position.
-- If the summoned monster was a Level 8 LIGHT Dragon, you can
-- destroy 1 card in your opponent's Spell & Trap Zone.

local s,id=GetID()

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1) -- Rush Duel: once per turn per face-up copy
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- [REQUIREMENT] Exactly 1 card from the hand, sent as a cost.
function s.costfilter(c)
    return c:IsAbleToGraveAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_COST)
    end
end

-- Can revive Level 8+ monsters of any of the three listed Types.
function s.spfilter(c,e,tp)
    return c:IsMonster() and c:IsLevelAbove(8)
        and c:IsRace(RACE_DRAGON|RACE_GALAXY|RACE_SPELLCASTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),
                tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_SZONE)
end

function s.desfilter(c)
    return c:IsDestructable()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),
        tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if not tc then return end

    -- Summoning a monster sent to the GY for this effect's Requirement
    -- is allowed, provided its Special Summon is otherwise legal.
    if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)==0 then
        return
    end

    -- The bonus requires exactly Level 8, LIGHT Attribute, Dragon Type.
    if not (tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE)
        and tc:IsLevel(8) and tc:IsAttribute(ATTRIBUTE_LIGHT)
        and tc:IsRace(RACE_DRAGON)) then
        return
    end

    if not Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_SZONE,1,nil) then
        return
    end
    -- Optional destruction. Put the question below in texts.str1 of
    -- your custom database for a readable prompt.
    if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local dg=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_SZONE,1,1,nil)
    if #dg>0 then
        Duel.Destroy(dg,REASON_EFFECT)
    end
end
