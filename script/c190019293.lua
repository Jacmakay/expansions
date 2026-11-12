--Luminescent Soul the Sage Solaris
--Custom Rush Duel card: 190019293
local s,id=GetID()

--Cards that can be recovered by the effect
s.domain_code=190019294 --Domain Expansion Solaris Luminescent
s.magic_code=190019295  --Ultimate Soul Magic

function s.initial_effect(c)
    --Normal Summon without Tributing while you control a Level 10 monster.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SUMMON_PROC)
    e1:SetCondition(s.ntcon)
    c:RegisterEffect(e1)

    --Destroy 1 card you control, recover a named Spell,
    --then optionally revive a Level 10 LIGHT monster if an S/T was destroyed.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    -- SetCountLimit(1,id) enforces the same-name once-per-turn requirement.
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end

function s.lvfilter(c)
    return c:IsFaceup() and c:IsLevel(10)
end

function s.ntcon(e,c,minc)
    if c==nil then return true end
    local tp=c:GetControler()
    return minc==0
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.thfilter(c)
    return c:IsCode(s.domain_code,s.magic_code) and c:IsAbleToHand()
end

function s.namedfieldfilter(c)
    return c:IsCode(s.domain_code,s.magic_code)
        and c:IsType(TYPE_SPELL|TYPE_TRAP)
        and c:IsDestructable()
end

--If neither named card is already in the GY, the destroyed card
--must be one of them so that the mandatory recovery can resolve.
function s.desfilter(c,hasgrave)
    return c:IsDestructable()
        and (hasgrave or s.namedfieldfilter(c))
end

function s.spfilter(c,e,tp)
    return c:IsType(TYPE_MONSTER)
        and c:IsLevel(10)
        and c:IsAttribute(ATTRIBUTE_LIGHT)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local hasgrave=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,hasgrave)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local hasgrave=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,hasgrave)
    local tc=g:GetFirst()
    if not tc then return end

    local destroyed_spelltrap=tc:IsType(TYPE_SPELL|TYPE_TRAP)
    if Duel.Destroy(g,REASON_EFFECT)==0 then return end

    --A named Spell destroyed above is now eligible to recover.
    if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local hg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
        if #hg>0 and Duel.SendtoHand(hg,nil,REASON_EFFECT)>0 then
            Duel.ConfirmCards(1-tp,hg)
        end
    end

    --The bonus is optional and only if a Spell/Trap was destroyed.
    if destroyed_spelltrap
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
        and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,
            aux.NecroValleyFilter(s.spfilter),tp,
            LOCATION_GRAVE,0,1,1,nil,e,tp)
        if #sg>0 then
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
        end
    end
end
