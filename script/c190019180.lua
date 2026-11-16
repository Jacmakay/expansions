-- Vergil The Alpha and Omega of Terminus
-- Custom EDOPro Rush Duel card -- ID 190019180
local s,id=GetID()
local TERMINUS_BLADE=190019214
local MORE_POWER=190019182
s.listed_names={TERMINUS_BLADE,MORE_POWER}

function s.initial_effect(c)
    -- [REQUIREMENT] Send 1 card from your hand to the GY.
    -- [EFFECT] Send 1 face-up Level 8 or lower opposing monster to the GY.
    -- Then optionally Special Summon Terminus Blade from hand/GY;
    -- if Summoned, optionally recover You need More power from GY.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.costfilter(c)
    return c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end

function s.sendfilter(c)
    return c:IsFaceup() and c:IsLevelBelow(8) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.sendfilter,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_MZONE)
end
function s.spfilter(c,e,tp)
    return c:IsCode(TERMINUS_BLADE)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.thfilter(c)
    return c:IsCode(MORE_POWER) and c:IsAbleToHand()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.sendfilter,tp,0,LOCATION_MZONE,1,1,nil)
    local tc=g:GetFirst()
    if not tc or Duel.SendtoGrave(tc,REASON_EFFECT)==0 then return end
    if not tc:IsLocation(LOCATION_GRAVE) then return end

    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
        or not Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp)
        or not Duel.SelectEffectYesNo(tp,e:GetHandler()) then
        return
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
    local sc=sg:GetFirst()
    if not sc or Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)==0 then return end

    if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
        and Duel.SelectEffectYesNo(tp,e:GetHandler()) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local hg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
        if #hg>0 then
            Duel.SendtoHand(hg,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,hg)
        end
    end
end
