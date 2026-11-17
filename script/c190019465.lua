-- Tsukahagi, Servant of Frost | 190019465
-- WATER / Zombie / Level 2 / 0 ATK / 2000 DEF
-- [REQUIREMENT] Send the top 3 cards of your Deck to the GY.
-- [EFFECT] Add 1 WATER Zombie from your GY to your hand. Then you may
-- reduce 1 face-up opposing monster's ATK by 500 this turn.
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCategory(CATEGORY_DECKDES|CATEGORY_TOHAND|CATEGORY_ATKCHANGE)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,3) end
    Duel.DiscardDeck(tp,3,REASON_COST)
end
function s.thfilter(c)
    return c:IsMonster() and c:IsAttribute(ATTRIBUTE_WATER)
        and c:IsRace(RACE_ZOMBIE) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    -- The 3 cards sent for the Requirement are eligible to be added.
    if chk==0 then return true end
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.atkfilter(c)
    return c:IsFaceup() and c:IsMonster()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local f=aux.NecroValleyFilter(s.thfilter)
    if not Duel.IsExistingMatchingCard(f,tp,LOCATION_GRAVE,0,1,nil) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,f,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g==0 or Duel.SendtoHand(g,nil,REASON_EFFECT)==0 then return end
    Duel.ConfirmCards(1-tp,g)
    if not Duel.IsExistingMatchingCard(s.atkfilter,tp,0,LOCATION_MZONE,1,nil)
        or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local ag=Duel.SelectMatchingCard(tp,s.atkfilter,tp,0,LOCATION_MZONE,1,1,nil)
    local tc=ag:GetFirst()
    if not tc or not tc:IsFaceup() then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(-500)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
    tc:RegisterEffect(e1)
end
