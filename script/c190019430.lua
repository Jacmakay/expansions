--Terminus Jigen Baku
--Custom EDOPro Rush Duel card - ID: 190019430
--LIGHT / Level 1 / Divine-Beast / Effect
--[REQUIREMENT] Send this face-up card from your field to the GY.
--[EFFECT] Add 1 "Will of Terminus" or "Heart of Terminus"
--         from your GY to your hand.

local s,id=GetID()
local WILL_OF_TERMINUS=190019423
local HEART_OF_TERMINUS=190019411

s.listed_names={WILL_OF_TERMINUS,HEART_OF_TERMINUS}

function s.initial_effect(c)
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

--[REQUIREMENT] Send this card from your field to the Graveyard.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToGraveAsCost() end
    Duel.SendtoGrave(c,REASON_COST)
end

function s.thfilter(c)
    return c:IsCode(WILL_OF_TERMINUS,HEART_OF_TERMINUS)
        and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

--[EFFECT] Recover one of the two named Ritual Spells.
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local f=aux.NecroValleyFilter(s.thfilter)
    if not Duel.IsExistingMatchingCard(f,tp,LOCATION_GRAVE,0,1,nil) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,f,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,tp,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,g)
    end
end
