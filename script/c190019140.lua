-- Drums of Liberation
-- Custom Rush Duel card; ID 190019140
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end
function s.first(c,fc)
    return c:IsFaceup() and c:IsLevel(8) and c:IsRace(RACE_WARRIOR)
        and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToGrave()
        and c:IsCanBeFusionMaterial(fc,SUMMON_TYPE_FUSION)
end
function s.second(c,fc,first)
    if c==first or not c:IsCode(190019121) then return false end
    if c:IsLocation(LOCATION_MZONE) then
        return c:IsFaceup() and c:IsAbleToGrave()
            and c:IsCanBeFusionMaterial(fc,SUMMON_TYPE_FUSION)
    end
    return c:IsLocation(LOCATION_GRAVE) and c:IsAbleToDeck()
        and c:IsCanBeFusionMaterial(fc,SUMMON_TYPE_FUSION)
end
function s.fcfilter(c,e,tp)
    return c:IsCode(190019127) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end
function s.canpair(tp,fc,first,second)
    local mat=Group.FromCards(first,second)
    return Duel.GetLocationCountFromEx(tp,tp,mat,fc)>0
end
function s.haspair(tp,fc)
    local g1=Duel.GetMatchingGroup(s.first,tp,LOCATION_MZONE,0,nil,fc)
    for a in aux.Next(g1) do
        local g2=Duel.GetMatchingGroup(s.second,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil,fc,a)
        for b in aux.Next(g2) do
            if s.canpair(tp,fc,a,b) then return true end
        end
    end
    return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local g=Duel.GetMatchingGroup(s.fcfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
        return g:IsExists(s.haspairfilter,1,nil,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.haspairfilter(fc,tp) return s.haspair(tp,fc) end
function s.operation(e,tp)
    local g=Duel.GetMatchingGroup(s.fcfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
    local fg=g:Filter(s.haspairfilter,nil,tp)
    if #fg==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local fc=fg:Select(tp,1,1,nil):GetFirst()
    if not fc then return end
    local g1=Duel.GetMatchingGroup(s.first,tp,LOCATION_MZONE,0,nil,fc)
    local feasible=g1:Filter(function(first,fc,tp)
        local g2=Duel.GetMatchingGroup(s.second,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil,fc,first)
        return g2:IsExists(function(second,tp,fc,first) return s.canpair(tp,fc,first,second) end,1,nil,tp,fc,first)
    end,nil,fc,tp)
    if #feasible==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
    local first=feasible:Select(tp,1,1,nil):GetFirst()
    local g2=Duel.GetMatchingGroup(s.second,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil,fc,first)
    local valid=g2:Filter(function(second,tp,fc,first) return s.canpair(tp,fc,first,second) end,nil,tp,fc,first)
    if #valid==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
    local second=valid:Select(tp,1,1,nil):GetFirst()
    if not second then return end
    local mat=Group.FromCards(first,second)
    if Duel.GetLocationCountFromEx(tp,tp,mat,fc)<=0 then return end
    Duel.SetFusionMaterial(mat)
    local first_ok=Duel.SendtoGrave(first,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)>0
    local second_ok=false
    if second:IsLocation(LOCATION_GRAVE) then
        second_ok=Duel.SendtoDeck(second,nil,SEQ_DECKBOTTOM,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)>0
    else
        second_ok=Duel.SendtoGrave(second,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)>0
    end
    if not first_ok or not second_ok then return end
    if Duel.SpecialSummon(fc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP_ATTACK)>0 then
        fc:CompleteProcedure()
    end
end
