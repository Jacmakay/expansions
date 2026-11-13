-- Ridge Off! Void Striker Devour
-- Custom EDOPro Rush Duel Spell (190019243)
local s,id=GetID()

function s.initial_effect(c)
    -- [REQUIREMENT] Have a DARK Dragon in your Graveyard.
    -- [EFFECT] Fusion Summon a Level 9+ High Dragon Fusion Monster,
    -- shuffling its materials from your field and/or GY into their owners' Decks.
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_FUSION_SUMMON|CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.reqfilter(c)
    return c:IsMonster() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.reqfilter,tp,LOCATION_GRAVE,0,1,nil)
end

function s.matfilter(c)
    return c:IsMonster() and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
        and (c:IsLocation(LOCATION_GRAVE)
            or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup()))
end

function s.getmaterials(tp)
    local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil)
    local gy=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.matfilter),tp,LOCATION_GRAVE,0,nil)
    mg:Merge(gy)
    return mg
end

function s.fusfilter(c,e,tp,mg)
    return c:IsType(TYPE_FUSION) and c:IsRace(RACE_HIGHDRAGON)
        and c:IsLevelAbove(9)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
        and c:CheckFusionMaterial(mg,nil,tp)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local mg=s.getmaterials(tp)
        return Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local mg=s.getmaterials(tp)
    local fg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg)
    if #fg==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=fg:Select(tp,1,1,nil):GetFirst()
    if not tc then return end
    local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,tp)
    if #mat==0 then return end
    tc:SetMaterial(mat)
    if Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,
        REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)~= #mat then return end
    Duel.BreakEffect()
    if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)>0 then
        tc:CompleteProcedure()
    end
end
