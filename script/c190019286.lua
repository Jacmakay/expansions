--The Beginning - The First Endbringer
--Rush Duel / Normal Spell
local s,id=GetID()

function s.initial_effect(c)
    --Send 1 LIGHT monster from hand or field; revive 1 FIRE monster with +500 ATK
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

--Requirement: The LIGHT monster must be in hand or face-up on your field.
function s.costfilter(c)
    return c:IsMonster() and c:IsAttribute(ATTRIBUTE_LIGHT)
        and c:IsAbleToGraveAsCost()
        and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end

--Effect: A FIRE monster in your GY that can be Special Summoned.
function s.spfilter(c,e,tp)
    return c:IsMonster() and c:IsAttribute(ATTRIBUTE_FIRE)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end

--Rush Duel requirements are performed in the activation operation.
--The cost function checks whether the requirement can be paid.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil)
    end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        --If your field is full, sending a LIGHT monster from the field
        --can free a Monster Zone for the Special Summon.
        return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
            and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
                or Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil))
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    --[REQUIREMENT] Send 1 LIGHT monster from hand or field to the GY.
    --On a full field you must choose a field monster to free a zone.
    local loc=LOCATION_HAND|LOCATION_MZONE
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
        loc=LOCATION_MZONE
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,loc,0,1,1,nil)
    if #g==0 or Duel.SendtoGrave(g,REASON_COST)==0 then return end

    --[EFFECT] Special Summon 1 FIRE monster from the GY face-up in Attack Position.
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=sg:GetFirst()
    if not tc then return end
    if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)==0 then return end

    --The Special Summoned monster gains 500 ATK (no turn limit stated).
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(500)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD)
    tc:RegisterEffect(e1)
end
