-- Terminal Re: The Crisis of Terminus
-- Rush Duel Normal Spell; card ID 190019171
local s,id=GetID()
local GOJO_REFORMED_ID=190019172 -- Gojo Reformed Agent of Terminus
-- Standard and Rush Duel IDs for the two named classic monsters:
local BUSTER_BLADER_IDS={78193831,160005000}
local DARK_MAGICIAN_IDS={46986414,160002000}

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
function s.spellfilter(c)
    return c:IsSpell() and c:IsAbleToDeckAsCost()
end
function s.trapfilter(c)
    return c:IsTrap() and c:IsAbleToDeckAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.spellfilter,tp,LOCATION_GRAVE,0,1,nil)
            and Duel.IsExistingMatchingCard(s.trapfilter,tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local a=Duel.SelectMatchingCard(tp,s.spellfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local b=Duel.SelectMatchingCard(tp,s.trapfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    a:Merge(b)
    Duel.SendtoDeck(a,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.listed(c)
    for _,code in ipairs(BUSTER_BLADER_IDS) do
        if c:ListsCodeAsMaterial(code) then return true end
    end
    for _,code in ipairs(DARK_MAGICIAN_IDS) do
        if c:ListsCodeAsMaterial(code) then return true end
    end
    return GOJO_REFORMED_ID~=0 and c:ListsCodeAsMaterial(GOJO_REFORMED_ID)
end
function s.spfilter(c,e,tp)
    return c:IsType(TYPE_FUSION) and s.listed(c)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK) end
end
