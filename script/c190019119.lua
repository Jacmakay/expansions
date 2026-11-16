-- New Memory: What's This Bankai Thing
-- Rush Duel Normal Spell; card ID 190019119
local s,id=GetID()

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
function s.filter(c)
    return c:IsMonster() and c:HasLevel() and c:GetLevel()>0
end
function s.paircheck(g,e,tp)
    if #g~=2 then return false end
    local a=g:GetFirst()
    local b=g:GetNext()
    if a:GetLevel()==b:GetLevel() or a:GetRace()~=b:GetRace()
        or a:GetAttribute()~=b:GetAttribute() then return false end
    local low=a:GetLevel()<b:GetLevel() and a or b
    local high=a:GetLevel()>b:GetLevel() and a or b
    return low:IsAbleToDeck() and high:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and g:CheckSubGroup(s.paircheck,2,2,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil)
    if not g:CheckSubGroup(s.paircheck,2,2,e,tp) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
    local sg=g:SelectSubGroup(tp,s.paircheck,false,2,2,e,tp)
    if not sg or #sg~=2 then return end
    local a=sg:GetFirst()
    local b=sg:GetNext()
    local low=a:GetLevel()<b:GetLevel() and a or b
    local high=a:GetLevel()>b:GetLevel() and a or b
    if Duel.SendtoDeck(low,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
    if high:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and high:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) then
        Duel.BreakEffect()
        Duel.SpecialSummon(high,0,tp,tp,false,false,POS_FACEUP_ATTACK)
    end
end
