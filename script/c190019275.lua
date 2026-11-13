-- War God Soul
-- Card ID: 190019275
-- Custom EDOPro Rush Duel monster
-- DARK / Galaxy / Effect / Level 4 / ATK 1600 / DEF 0

local s,id=GetID()
local VOIDVELG_REQUIEM=160010025

function s.initial_effect(c)
    -- [REQUIREMENT] Send 1 DARK Galaxy monster from your hand or field
    -- to the Graveyard.
    -- [EFFECT] Draw 1 card. Then, if "Voidvelg Requiem" is in your GY,
    -- you can Special Summon it in face-up Defense Position.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DRAW|CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- A DARK Galaxy monster in your hand or on your field,
-- which can be sent to the GY as the requirement.
-- This card can itself be sent from the field.
function s.costfilter(c)
    return c:IsMonster()
        and c:IsAttribute(ATTRIBUTE_DARK)
        and c:IsRace(RACE_GALAXY)
        and c:IsAbleToGraveAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.costfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(
        tp,s.costfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_COST)
    end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsPlayerCanDraw(tp,1)
    end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
    Duel.SetPossibleOperationInfo(
        0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spfilter(c,e,tp)
    return c:IsCode(VOIDVELG_REQUIEM)
        and c:IsCanBeSpecialSummoned(
            e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end

    -- Summoning Requiem is optional, and only after drawing.
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

    local f=aux.NecroValleyFilter(s.spfilter)
    if not Duel.IsExistingMatchingCard(
        f,tp,LOCATION_GRAVE,0,1,nil,e,tp) then
        return
    end

    if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        return
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(
        tp,f,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(
            g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
    end
end
