-- Dakki, Servant of Frost | 190019463
-- WATER / Zombie / Level 2 / 1000 ATK / 0 DEF
-- [REQUIREMENT] You control a face-up Level 5 or higher WATER Zombie.
-- [EFFECT] Draw 2 cards, then send 1 card from your hand to the GY.
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCategory(CATEGORY_DRAW|CATEGORY_TOGRAVE)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end
function s.faceupfilter(c)
    return c:IsFaceup() and c:IsLevelAbove(5)
        and c:IsRace(RACE_ZOMBIE) and c:IsAttribute(ATTRIBUTE_WATER)
end
function s.condition(e,tp)
    return Duel.IsExistingMatchingCard(s.faceupfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.discardfilter(c)
    return c:IsAbleToGrave()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.Draw(tp,2,REASON_EFFECT)~=2 then return end
    if not Duel.IsExistingMatchingCard(s.discardfilter,tp,LOCATION_HAND,0,1,nil) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.discardfilter,tp,LOCATION_HAND,0,1,1,nil)
    if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
end
