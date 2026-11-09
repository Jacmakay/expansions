-- Dystopia of Equilibrium
-- EDOPro custom Rush Duel card -- ID: 190019228
-- [REQUIREMENT] Send the top 2 cards of your Deck to the Graveyard.
-- [EFFECT] Change the battle position of 1 monster your opponent controls,
--          then you can add 1 "Maiden of Equilibrium" from your GY to your hand.

local s,id=GetID()
local MAIDEN_ID=190019227
s.listed_names={MAIDEN_ID}

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DECKDES|CATEGORY_POSITION|CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.posfilter(c)
    return c:IsMonster() and c:IsCanChangePosition()
end

function s.thfilter(c)
    return c:IsCode(MAIDEN_ID) and c:IsMonster() and c:IsAbleToHand()
end

-- Rush Duel requirement: validate here, perform at the start of resolution.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=2
            and Duel.IsPlayerCanDiscardDeckAsCost(tp,2)
    end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,2,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,1-tp,LOCATION_MZONE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- [REQUIREMENT] Mill exactly 2 cards.
    if not Duel.IsPlayerCanDiscardDeckAsCost(tp,2) then return end
    if Duel.DiscardDeck(tp,2,REASON_COST)~=2 then return end

    -- [EFFECT] Choose 1 opponent's monster (non-targeting in Rush Duel).
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
    local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
    local tc=g:GetFirst()
    if not tc then return end
    Duel.HintSelection(g)

    -- Attack -> face-up Defense; Defense / set -> face-up Attack.
    if Duel.ChangePosition(tc,
        POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,
        POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)==0 then
        return
    end

    -- Optional recovery; Maiden may have been milled by the requirement.
    if not Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil) then
        return
    end
    if not Duel.SelectEffectYesNo(tp,e:GetHandler()) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
    if #sg>0 and Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,sg)
    end
end
