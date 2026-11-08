--Infinity Duza
--Card ID: 190019413
--Rush Duel
local s,id=GetID()

function s.initial_effect(c)
    --[REQUIREMENT] Send the top 3 cards of your Deck to the GY.
    --[EFFECT] Add 1 Level 11 or lower LIGHT/DARK Machine/Fiend
    --monster from your GY to your hand.
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

-- Send the top 3 cards to the GY as the Rush requirement.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsPlayerCanDiscardDeckAsCost(tp,3)
    end
    Duel.DiscardDeck(tp,3,REASON_COST)
end

-- "LIGHT or DARK Machine or Fiend" means either attribute
-- AND either race (not just one matching pair).
function s.filter(c)
    return c:IsMonster()
        and c:IsLevelBelow(11)
        and c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK)
        and c:IsRace(RACE_MACHINE|RACE_FIEND)
        and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        -- The requirement can place a valid monster in the GY,
        -- so a match need not exist there before it is paid.
        return true
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil) then
        return
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),
        tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,tp,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,g)
    end
end
