-- Yoko The Servant of Fear
-- Custom EDOPro Rush Duel Effect Monster
-- Card ID: 190019425
-- The Lord of Fear Descends: 190019429
-- [REQUIREMENT] Change this card to face-down Defense Position.
-- [EFFECT] Add 1 "The Lord of Fear Descends" FROM YOUR GRAVEYARD to your hand.
-- Then, if you have a Level 10 or higher Zombie or Spellcaster monster in
-- your Graveyard, change 1 monster on your opponent's field to
-- face-down Defense Position.

local s,id=GetID()
local LORD_OF_FEAR_DESCENDS=190019429

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_POSITION)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- [REQUIREMENT] Set Yoko itself face-down as the cost.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return c:IsFaceup() and c:IsCanTurnSet()
    end
    Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
end

-- The only card that can be recovered; strictly from the Graveyard.
function s.thfilter(c)
    return c:IsCode(LORD_OF_FEAR_DESCENDS) and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

-- Level 10+ Zombie or Spellcaster in your Graveyard.
function s.bigfilter(c)
    return c:IsMonster() and c:IsLevelAbove(10)
        and c:IsRace(RACE_ZOMBIE+RACE_SPELLCASTER)
end

function s.posfilter(c)
    return c:IsFaceup() and c:IsCanTurnSet()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- Never search the Deck or hand; recover only from the Graveyard.
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),
        tp,LOCATION_GRAVE,0,1,1,nil)
    if #g==0 then return end
    if Duel.SendtoHand(g,nil,REASON_EFFECT)==0 then return end
    Duel.ConfirmCards(1-tp,g)

    -- Perform the second part only when the Graveyard condition is met.
    if not Duel.IsExistingMatchingCard(s.bigfilter,tp,LOCATION_GRAVE,0,1,nil) then
        return
    end
    if not Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil) then
        return
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
    local pg=Duel.SelectMatchingCard(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
    if #pg>0 then
        Duel.ChangePosition(pg,POS_FACEDOWN_DEFENSE)
    end
end
