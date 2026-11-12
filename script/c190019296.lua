-- Nozett The Ultimate Dragon
-- Card ID: 190019296
-- EDOPro Rush Duel
-- Level 11 / LIGHT / High Dragon / Fusion / Effect
-- ATK 3600 / DEF 3000
-- Fusion Materials: "Nozett The Ultimate Soul" (190019289)
--                   + 1 Level 10 Dragon monster
--
-- [REQUIREMENT] None
-- [EFFECT] Destroy 1 card on your opponent's field, then you can
-- Special Summon 1 Level 10 or 11 LIGHT monster from your GY.
-- If you have a Level 4 LIGHT Galaxy monster in your GY, you can
-- make 1 monster on your opponent's field lose 1500 ATK.

local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Fusion Materials
    Fusion.AddProcMix(c,false,true,190019289,s.matfilter)

    -- Rush Duel ignition effect: once per turn per copy
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(s.efftg)
    e1:SetOperation(s.effop)
    c:RegisterEffect(e1)
end

-- Fusion Material: one Level 10 Dragon monster
function s.matfilter(c,fc,sumtype,tp)
    return c:IsLevel(10) and c:IsRace(RACE_DRAGON)
end

function s.desfilter(c)
    return c:IsDestructable()
end

function s.spfilter(c,e,tp)
    return c:IsType(TYPE_MONSTER)
        and (c:IsLevel(10) or c:IsLevel(11))
        and c:IsAttribute(ATTRIBUTE_LIGHT)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end

-- A Level 4 LIGHT Galaxy monster must be in your GY.
function s.galfilter(c)
    return c:IsType(TYPE_MONSTER)
        and c:IsLevel(4)
        and c:IsAttribute(ATTRIBUTE_LIGHT)
        and c:IsRace(RACE_GALAXY)
end

function s.atkfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end

function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
    -- Mandatory first step: destroy 1 opposing card.
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local dg=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
    if #dg==0 then return end
    if Duel.Destroy(dg,REASON_EFFECT)==0 then return end

    -- Optional second step: Special Summon a Level 10 or 11 LIGHT monster.
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),
            tp,LOCATION_GRAVE,0,1,nil,e,tp)
        and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),
            tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
        if #sg>0 then
            Duel.BreakEffect()
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        end
    end

    -- Optional final step, independent of whether you revived a monster.
    -- The card does not specify an end-of-turn duration: the ATK loss
    -- lasts until a standard reset (such as the monster leaving the field).
    if Duel.IsExistingMatchingCard(s.galfilter,tp,LOCATION_GRAVE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.atkfilter,tp,0,LOCATION_MZONE,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
        local ag=Duel.SelectMatchingCard(tp,s.atkfilter,tp,0,LOCATION_MZONE,1,1,nil)
        local tc=ag:GetFirst()
        if tc then
            Duel.BreakEffect()
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_UPDATE_ATTACK)
            e2:SetValue(-1500)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e2)
        end
    end
end
