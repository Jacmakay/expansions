-- Encounter: Void War Flash Step
-- Custom EDOPro Rush Duel Normal Spell
-- Card ID: 190019279
--
-- [REQUIREMENT]
-- Send 1 EARTH monster or 1 DARK Galaxy monster from your field to the GY.
-- [EFFECT]
-- Special Summon 1 EARTH monster or 1 DARK Galaxy monster with the
-- same Attribute as the sent monster and 2500 or less ATK from your GY
-- in face-up Attack Position.

local s,id=GetID()

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- EARTH monsters can be any Type. DARK monsters must be Galaxy-Type.
function s.typefilter(c)
    return c:IsMonster()
        and (c:IsAttribute(ATTRIBUTE_EARTH)
            or (c:IsAttribute(ATTRIBUTE_DARK)
                and c:IsRace(RACE_GALAXY)))
end

function s.spfilter(c,e,tp,att)
    return s.typefilter(c)
        and c:IsAttribute(att)
        and c:GetAttack()>=0 and c:GetAttack()<=2500
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end

-- Monster to send from your field for the requirement.
function s.reqfilter(c)
    return s.typefilter(c) and c:IsAbleToGraveAsCost()
end

-- An eligible field monster can pay the requirement if there is an
-- appropriate monster already in the GY, or if that field monster
-- can itself be revived after being sent to the GY.
function s.costfilter(c,e,tp)
    if not s.reqfilter(c) then return false end
    local att=c:GetAttribute()
    local gyfilter=aux.NecroValleyFilter(s.spfilter)
    return Duel.IsExistingMatchingCard(gyfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,att)
        or (c:GetAttack()>=0 and c:GetAttack()<=2500
            and not c:IsType(TYPE_TOKEN)
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK))
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.costfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(
        tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if not tc then return end

    -- Preserve the Attribute while the monster is on the field.
    -- The monster just sent is also allowed as a revival choice.
    local att=tc:GetAttribute()
    Duel.SendtoGrave(tc,REASON_COST)
    e:SetLabel(att)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.costfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local att=e:GetLabel()
    if att==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

    local f=aux.NecroValleyFilter(s.spfilter)
    if not Duel.IsExistingMatchingCard(
        f,tp,LOCATION_GRAVE,0,1,nil,e,tp,att) then
        return
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(
        tp,f,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,att)
    local tc=g:GetFirst()
    if tc then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)
    end
end
