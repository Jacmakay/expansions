-- Flames of Time Core
-- EDOPro Rush Duel custom card: 190019245
-- Level 1 / FIRE / Pyro / Effect / 300 ATK / 300 DEF
-- [Requirement] Send 1 FIRE monster from your hand to the Graveyard.
-- [Effect] Draw 1 card. Then, if you have a Level 10 or higher Pyro
-- monster in your Graveyard, add 1 "True Flame Enjin" from your
-- Graveyard to your hand.
local s,id=GetID()
local TRUE_FLAME_ENJIN=190019251
s.listed_names={TRUE_FLAME_ENJIN}

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

-- [Requirement] Send exactly 1 FIRE monster from the hand to the GY.
function s.costfilter(c)
    return c:IsMonster() and c:IsAttribute(ATTRIBUTE_FIRE)
        and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.highpyrofilter(c)
    return c:IsMonster() and c:IsRace(RACE_PYRO) and c:IsLevelAbove(10)
end
function s.enjinfilter(c)
    return c:IsCode(TRUE_FLAME_ENJIN) and c:IsAbleToHand()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- The draw must succeed before applying the optional recovery clause.
    if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end

    -- Evaluate the condition after drawing; the sent FIRE monster
    -- can satisfy it if it is a Level 10+ Pyro monster.
    if not Duel.IsExistingMatchingCard(s.highpyrofilter,tp,LOCATION_GRAVE,0,1,nil) then
        return
    end
    local filter=aux.NecroValleyFilter(s.enjinfilter)
    if not Duel.IsExistingMatchingCard(filter,tp,LOCATION_GRAVE,0,1,nil) then
        return
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,filter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,g)
    end
end
