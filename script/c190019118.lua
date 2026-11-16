-- New Memory That Idiot Sage
-- Rush Duel Normal Spell; card ID 190019118
local s,id=GetID()
local SHINIGAMI_ID=190019100
local BANKAI_SAGE_ID=190019197 -- Ichigo Bankai Sage Mode

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
function s.matfilter(c)
    return c:IsCode(SHINIGAMI_ID) and c:IsAbleToGraveAsCost()
end
function s.fusfilter(c,e,tp)
    return BANKAI_SAGE_ID~=0 and c:IsCode(BANKAI_SAGE_ID) and c:IsType(TYPE_FUSION)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false,POS_FACEUP_ATTACK)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
    local tc=g:GetFirst()
    e:SetLabelObject(tc)
    Duel.SendtoGrave(tc,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return BANKAI_SAGE_ID~=0
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local mat=e:GetLabelObject()
    if not mat or not mat:IsLocation(LOCATION_GRAVE)
        or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.fusfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    local fc=g:GetFirst()
    if not fc then return end
    -- Custom one-card Fusion: the sent Shinigami is all required materials.
    local mg=Group.FromCards(mat)
    fc:SetMaterial(mg)
    if Duel.SpecialSummon(fc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP_ATTACK)>0 then
        fc:CompleteProcedure()
    end
end
