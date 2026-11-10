-- Sineater Fairy
-- Custom Rush Duel card
-- Card ID: 190019253
local s,id=GetID()

function s.initial_effect(c)
    -- [REQUIREMENT] Send 1 DARK, Fiend, Spellcaster, or Fairy monster
    -- from your hand to the Graveyard.
    -- [EFFECT] Draw 1 card. If the sent monster was Level 6,
    -- draw 1 additional card.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.costfilter(c)
    return c:IsMonster()
        and (c:IsAttribute(ATTRIBUTE_DARK)
            or c:IsRace(RACE_FIEND|RACE_SPELLCASTER|RACE_FAIRY))
        and c:IsAbleToGraveAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
    local tc=g:GetFirst()
    local level6=tc and tc:IsLevel(6)
    local sent=Duel.SendtoGrave(g,REASON_COST)
    -- Record whether the Level 6 monster actually reached the Graveyard.
    e:SetLabel(sent>0 and tc:IsLocation(LOCATION_GRAVE) and level6 and 1 or 0)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,LOCATION_DECK)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.Draw(tp,1,REASON_EFFECT)>0 and e:GetLabel()==1 then
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end
