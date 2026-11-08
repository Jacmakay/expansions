--Tides Servant Mandarin
--Card ID: 190019401
--Rush Duel
local s,id=GetID()

function s.initial_effect(c)
    --[REQUIREMENT] Send 1 Cyberse monster from your hand to the GY.
    --[EFFECT] Draw 1, then you can recover a Level 5 or lower
    --Cyberse monster if you have a Level 8 or higher Cyberse in your GY.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DRAW|CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

--Check that the requirement can be paid.
function s.costfilter(c)
    return c:IsMonster() and c:IsRace(RACE_CYBERSE)
        and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil)
    end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

--A Level 8 or higher Cyberse monster is in your GY.
function s.highfilter(c)
    return c:IsMonster() and c:IsRace(RACE_CYBERSE)
        and c:IsLevelAbove(8)
end

--A Level 5 or lower Cyberse monster can be recovered.
function s.handfilter(c)
    return c:IsMonster() and c:IsRace(RACE_CYBERSE)
        and c:IsLevelBelow(5) and c:IsAbleToHand()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    --Requirement (Rush Duel: performed at resolution).
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local cg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
    if #cg==0 or Duel.SendtoGrave(cg,REASON_COST)==0 then return end

    --Effect: draw exactly 1 card.
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    if Duel.Draw(p,d,REASON_EFFECT)==0 then return end

    --Then, optional GY recovery, provided the high-Level condition holds.
    if not Duel.IsExistingMatchingCard(s.highfilter,tp,LOCATION_GRAVE,0,1,nil) then return end
    if not Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.handfilter),tp,LOCATION_GRAVE,0,1,nil) then return end
    if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.handfilter),tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,tp,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,g)
    end
end
