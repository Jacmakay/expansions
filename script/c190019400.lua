--Harbinger Crystal Heart
--Card ID: 190019400
--Rush Duel

local s,id=GetID()

function s.initial_effect(c)
    --Add 1 Level 10 or higher WATER Cyberse
    --monster from your GY to your hand
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

--Requirement: Send the top 2 cards
--of your Deck to the GY
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsPlayerCanDiscardDeckAsCost(tp,2)
    end
end

--Level 10 or higher WATER Cyberse monster
function s.filter(c)
    return c:IsMonster()
        and c:IsLevelAbove(10)
        and c:IsAttribute(ATTRIBUTE_WATER)
        and c:IsRace(RACE_CYBERSE)
        and c:IsAbleToHand()
end

--Check activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.filter,tp,LOCATION_GRAVE,0,1,nil
        )
    end
    Duel.SetOperationInfo(
        0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE
    )
end

--Resolve the requirement and effect
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    --Requirement
    if Duel.DiscardDeck(tp,2,REASON_COST)~=2 then
        return
    end

    --Effect
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(
        tp,aux.NecroValleyFilter(s.filter),
        tp,LOCATION_GRAVE,0,1,1,nil
    )

    local tc=g:GetFirst()
    if tc then
        Duel.SendtoHand(tc,tp,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    end
end
