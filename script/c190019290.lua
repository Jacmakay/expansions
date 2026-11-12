--Luminescent Soul Grey
--Custom EDOPro Rush Duel card - 190019290
local s,id=GetID()

--Some Rush Duel packages use RACE_HYDRAGON for High Dragon.
local HIGH_DRAGON=RACE_HYDRAGON or RACE_HIGHDRAGON

function s.initial_effect(c)
    -- Name-wide count limit is handled by SetCountLimit(1,id).

    --If you control a Level 7 or lower monster, Normal Summon
    --this card without Tributing (requires an open Monster Zone).
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SUMMON_PROC)
    e0:SetCondition(s.ntcon)
    c:RegisterEffect(e0)

    --[REQUIREMENT] You have not activated "Luminescent Soul Grey"
    --this turn.
    --[EFFECT] Special Summon a listed Type in face-up Attack Position;
    --then optionally destroy an opponent's highest-ATK monster.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
end

function s.lvfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsLevelBelow(7)
end

function s.ntcon(e,c,minc)
    if c==nil then return true end
    local tp=c:GetControler()
    return minc==0
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return true -- SetCountLimit(1,id) already enforces the restriction
end

function s.spfilter(c,e,tp)
    return c:IsType(TYPE_MONSTER)
        and (c:IsRace(RACE_DRAGON)
            or (HIGH_DRAGON and c:IsRace(HIGH_DRAGON))
            or c:IsRace(RACE_SPELLCASTER)
            or c:IsRace(RACE_MAGICALKNIGHT)
            or c:IsRace(RACE_GALAXY))
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetMZoneCount(tp)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetMZoneCount(tp)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),
        tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    local summoned=0
    if #sg>0 then
        summoned=Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_ATTACK)
    end
    if summoned<=0 then return end

    --Only face-up monsters have a publicly known ATK.
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    if #g==0 then return end
    if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end

    --If two or more monsters tie for highest ATK, choose one.
    local highest=g:GetMaxGroup(Card.GetAttack)
    if not highest or #highest==0 then return end
    local sg=highest
    if #highest>1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        sg=highest:Select(tp,1,1,nil)
    end
    Duel.Destroy(sg,REASON_EFFECT)
end
