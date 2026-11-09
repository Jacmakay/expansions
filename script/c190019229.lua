-- Absolution of Equilibrium
-- Custom EDOPro Rush Duel monster
-- Card ID: 190019229
-- [REQUIREMENT] Send 1 card from your hand to the Graveyard.
-- [EFFECT] Add 1 "Equilibrium Ritual" (190019232) or
--          "Equilibrium of Serenity" (190019233) from your GY to your hand,
--          then, if you control a monster with equal ATK and DEF,
--          destroy 1 card in your opponent's Spell & Trap Zone.

local s,id=GetID()
local RITUAL_ID=190019232
local SERENITY_ID=190019233
s.listed_names={RITUAL_ID,SERENITY_ID}

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND|CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1) -- Once per turn, per face-up copy (Rush Duel)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.handfilter(c)
    return c:IsAbleToGraveAsCost()
end

function s.recfilter(c)
    return c:IsCode(RITUAL_ID,SERENITY_ID) and c:IsAbleToHand()
end

-- Allows activation when the recovery card is in the GY,
-- or when a copy in hand could be sent by the requirement and recovered.
function s.possiblehandfilter(c)
    return c:IsCode(RITUAL_ID,SERENITY_ID)
        and c:IsAbleToGraveAsCost()
end

function s.eqfilter(c)
    return c:IsFaceup() and c:IsMonster()
        and c:GetAttack()==c:GetDefense()
end

function s.desfilter(c)
    return c:IsDestructable()
end

-- Rush Duel [REQUIREMENT]: check availability here;
-- perform the actual send at the start of effect resolution.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.handfilter,tp,LOCATION_HAND,0,1,nil)
    end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.recfilter),
                    tp,LOCATION_GRAVE,0,1,nil)
            or Duel.IsExistingMatchingCard(s.possiblehandfilter,
                    tp,LOCATION_HAND,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_SZONE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- [REQUIREMENT] Send one card from hand to the Graveyard.
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local hg=Duel.SelectMatchingCard(tp,s.handfilter,tp,LOCATION_HAND,0,1,1,nil)
    local hc=hg:GetFirst()
    if not hc then return end
    if Duel.SendtoGrave(hg,REASON_COST)~=1 then return end
    if not hc:IsLocation(LOCATION_GRAVE) then return end

    -- [EFFECT] Add one of the two named cards from your GY to your hand.
    if not Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.recfilter),
            tp,LOCATION_GRAVE,0,1,nil) then
        return
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.recfilter),
        tp,LOCATION_GRAVE,0,1,1,nil)
    if #sg==0 or Duel.SendtoHand(sg,nil,REASON_EFFECT)==0 then return end
    Duel.ConfirmCards(1-tp,sg)

    -- Then, if you control a face-up monster whose ATK equals its DEF,
    -- destroy one card in your opponent's Spell & Trap Zone.
    if not Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_MZONE,0,1,nil)
        or not Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_SZONE,1,nil) then
        return
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local dg=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_SZONE,1,1,nil)
    if #dg>0 then
        Duel.HintSelection(dg)
        Duel.Destroy(dg,REASON_EFFECT)
    end
end
