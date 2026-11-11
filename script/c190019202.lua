-- Endless Chaos Maximum Blue-Eyes Spirit
-- Custom EDOPro Rush Duel card / ID: 190019202
-- Level 1 / DARK / Dragon / Effect / ATK 900 / DEF 900
--
-- While face-up on the field or in the GY, this card's name becomes
-- "Blue-Eyes White Dragon".
-- [REQUIREMENT] Send 1 Galaxy, Dragon, or Spellcaster monster from
-- your hand to the GY.
-- [EFFECT] Draw 1 card. Then, if the monster sent for the Requirement
-- was a Level 4 Galaxy or a Level 8 LIGHT Dragon, you can Special
-- Summon that monster from your GY in face-up Defense Position.

local s,id=GetID()
local BLUE_EYES_WHITE_DRAGON=89631139

function s.initial_effect(c)
    -- Change the name while face-up in the Monster Zone and in the GY.
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetCode(EFFECT_CHANGE_CODE)
    e0:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
    e0:SetValue(BLUE_EYES_WHITE_DRAGON)
    c:RegisterEffect(e0)

    -- Rush Duel: once per turn for each face-up copy.
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

-- An eligible monster in the hand, able to go to the GY as a cost.
function s.costfilter(c)
    return c:IsMonster()
        and c:IsRace(RACE_GALAXY|RACE_DRAGON|RACE_SPELLCASTER)
        and c:IsAbleToGraveAsCost()
end

-- Only the EXACT monster sent for this Requirement can be revived.
function s.revivequalifies(c)
    return (c:IsLevel(4) and c:IsRace(RACE_GALAXY))
        or (c:IsLevel(8) and c:IsAttribute(ATTRIBUTE_LIGHT)
            and c:IsRace(RACE_DRAGON))
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
    local tc=g:GetFirst()
    if not tc then return end

    -- Save the card itself, and whether it met the Level/Type/Attribute
    -- test in the hand, before any name/type changes in the Graveyard.
    e:SetLabelObject(tc)
    e:SetLabel(s.revivequalifies(tc) and 1 or 0)
    Duel.SendtoGrave(tc,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsPlayerCanDraw(tp,1)
    end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- The draw is mandatory.
    if Duel.Draw(tp,1,REASON_EFFECT)~=1 then return end
    if e:GetLabel()~=1 then return end

    local tc=e:GetLabelObject()
    if not tc or not tc:IsLocation(LOCATION_GRAVE)
        or not tc:IsControler(tp)
        or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
        or not tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) then
        return
    end

    -- Optional revival of the monster sent as this card's Requirement.
    -- Custom CDB: texts.str1 = "Special Summon the monster you sent?"
    if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
    Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
