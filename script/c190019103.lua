-- The Man Who Called Himself Zangetsu (190019103)
-- DARK / Warrior / Level 4 / 1200 ATK / 1000 DEF
-- NOTE: No nonexistent "Blood Chains" card is referenced.
local s,id=GetID()
local BORN=190019100
local TRUE_SHIKAI=190019102
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=2 end
    Duel.DisableShuffleCheck()
    Duel.SendtoGrave(Duel.GetDecktopGroup(tp,2),REASON_COST)
end
function s.thfilter(c)
    return c:IsCode(BORN,TRUE_SHIKAI) and c:IsAbleToHand()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
