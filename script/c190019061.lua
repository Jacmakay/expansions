--Astro Gear Hound
--Card ID: 190019061
local s,id=GetID()

function s.initial_effect(c)
    --[REQUIREMENT] The turn you Normal Summon this card, if you have
    --an EARTH Machine monster in your GY.
    --[EFFECT] Add 1 EARTH Machine monster from your GY to your hand,
    --then you can Fusion Summon 1 EARTH Machine Fusion Monster using
    --monsters from your hand or field as material.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND|CATEGORY_SPECIAL_SUMMON|CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

--EARTH Machine monster
function s.thfilter(c)
    return c:IsMonster()
        and c:IsAttribute(ATTRIBUTE_EARTH)
        and c:IsRace(RACE_MACHINE)
        and c:IsAbleToHand()
end

--This card must have been Normal Summoned this turn.
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_NORMAL)
        and c:IsStatus(STATUS_SUMMON_TURN)
        and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
    --The Fusion Summon is optional and is checked again after the monster
    --has actually been added to the hand.
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

--Only EARTH Machine Fusion Monsters can be Fusion Summoned.
function s.fusfilter(c,tp)
    return c:IsAttribute(ATTRIBUTE_EARTH)
        and c:IsRace(RACE_MACHINE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    --Add 1 EARTH Machine monster from the GY to the hand.
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
    local tc=g:GetFirst()
    if not tc then return end
    if Duel.SendtoHand(tc,nil,REASON_EFFECT)==0 or not tc:IsLocation(LOCATION_HAND) then
        return
    end
    Duel.ConfirmCards(1-tp,tc)

    --Then you can Fusion Summon 1 EARTH Machine Fusion Monster.
    --Fusion.SummonEffTG/OP use EDOPro's standard Fusion procedure and
    --Duel.GetFusionMaterial(), which normally supplies monsters from the
    --hand and Monster Zone and sends selected materials to the GY.
    local fustg=Fusion.SummonEffTG(s.fusfilter)
    if fustg(e,tp,eg,ep,ev,re,r,rp,0)
        and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        local fusop=Fusion.SummonEffOP(s.fusfilter)
        fusop(e,tp,eg,ep,ev,re,r,rp)
    end
end
