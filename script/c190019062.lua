--Astro Gear Dark Golem
--Card ID: 190019062
local s,id=GetID()

local ANCIENT_GEAR_GOLEM=83104731
local ASTRO_GEAR_FUSION=190019063

function s.initial_effect(c)
    --[REQUIREMENT] Send 1 card from your hand to the Graveyard.
    --[EFFECT] This card's name becomes "Ancient Gear Golem" until the end
    --of this turn, then you can add 1 "Astro Gear Fusion" from your
    --Graveyard to your hand.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND)
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

function s.thfilter(c)
    return c:IsCode(ASTRO_GEAR_FUSION) and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetValue(ANCIENT_GEAR_GOLEM)
    e1:SetReset(RESETS_STANDARD_PHASE_END)
    c:RegisterEffect(e1)

    if not Duel.IsExistingMatchingCard(
        aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil
    ) then
        return
    end
    if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(
        tp,aux.NecroValleyFilter(s.thfilter),
        tp,LOCATION_GRAVE,0,1,1,nil
    )
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,g)
    end
end
