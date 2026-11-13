-- Soul of the Dragon Harbinger
-- Custom EDOPro Rush Duel Effect Monster
-- Card ID: 190019281
-- DARK / Wyrm / Level 4 / ATK 1500 / DEF 1500
--
-- [REQUIREMENT]
-- Send 1 Level 9 Wyrm monster from your hand to the Graveyard.
-- [EFFECT]
-- Draw 1 card. Then, if you have 2 Level 9 monsters with
-- different Attributes in your Graveyard, add 1 Wyrm monster
-- from your Graveyard to your hand.

local s,id=GetID()

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DRAW|CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- Exactly 1 Level 9 Wyrm monster in your hand must be sent to the GY.
function s.costfilter(c)
    return c:IsMonster()
        and c:IsRace(RACE_WYRM)
        and c:IsLevel(9)
        and c:IsAbleToGraveAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.costfilter,tp,LOCATION_HAND,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(
        tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_COST)
    end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsPlayerCanDraw(tp,1)
    end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.lv9filter(c)
    return c:IsMonster() and c:IsLevel(9)
end

-- The two Level 9 monsters must have different Attributes.
function s.differentattributes(tp)
    local g=Duel.GetMatchingGroup(s.lv9filter,tp,LOCATION_GRAVE,0,nil)
    if #g<2 then return false end
    for tc in aux.Next(g) do
        if g:IsExists(s.otherattr,1,tc,tc:GetAttribute()) then
            return true
        end
    end
    return false
end

function s.otherattr(c,attribute)
    return c:GetAttribute()~=attribute
end

function s.thfilter(c)
    return c:IsMonster()
        and c:IsRace(RACE_WYRM)
        and c:IsAbleToHand()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- Draw first, then check the current GY (including the sent cost).
    if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
    if not s.differentattributes(tp) then return end

    local f=aux.NecroValleyFilter(s.thfilter)
    if not Duel.IsExistingMatchingCard(
        f,tp,LOCATION_GRAVE,0,1,nil) then
        return
    end

    -- The recovery is mandatory when the stated condition is met.
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(
        tp,f,tp,LOCATION_GRAVE,0,1,1,nil)
    local tc=g:GetFirst()
    if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,tc)
    end
end
