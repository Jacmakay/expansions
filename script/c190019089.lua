--U-T-S Final Shift Destruction
--Custom Rush Duel Fusion / Effect Monster
--Card ID: 190019089
--Fusion Materials: 4 Level 9 monsters
local s,id=GetID()

function s.initial_effect(c)
    --Fusion Summon: 4 Level 9 monsters
    c:EnableReviveLimit()
    Fusion.AddProcMixN(c,true,true,s.matfilter,4)

    --[REQUIREMENT] Your LP are 3000 or lower.
    --[EFFECT] Destroy all cards on the field, then you can
    --Special Summon exactly 3 Level 1 monsters from your GY.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY|CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.matfilter(c,scard,sumtype,tp)
    return c:IsLevel(9)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetLP(tp)<=3000
end

function s.spfilter(c,e,tp)
    return c:IsMonster() and c:IsLevel(1)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    --Destroy every card on both fields, including this Fusion Monster.
    local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
    if #g==0 or Duel.Destroy(g,REASON_EFFECT)==0 then return end

    --"Then": the optional Summon is available only if at least one
    --card was destroyed and there are 3 legal monsters and 3 free zones.
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<3
        or not Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,3,nil,e,tp) then
        return
    end
    if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,3,3,nil,e,tp)
    if #sg==3 then
        Duel.BreakEffect()
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
    end
end
