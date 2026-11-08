--Infinity Servitor Alditia
--Custom Rush Duel card - ID: 190019419
--Fusion Materials: "Infinity Seed" + 1 LIGHT/DARK Machine or Fiend monster

local s,id=GetID()
local INFINITY_SEED=190019412
--The card image says "Cosmic Team". This uses the previously supplied
--"Cosmic Tag Team" ID; change it if "Cosmic Team" is a different card.
local COSMIC_TEAM=190019224

function s.initial_effect(c)
    c:EnableReviveLimit()

    --Fusion Materials: Infinity Seed + 1 LIGHT/DARK Machine or Fiend.
    Fusion.AddProcMix(c,false,true,INFINITY_SEED,s.matfilter)

    --Contact Fusion by returning the 2 face-up materials on your field
    --to the Deck (or Extra Deck, if applicable).
    Fusion.AddContactProc(c,s.contactfilter,s.contactop,nil,nil,SUMMON_TYPE_FUSION,nil,false)

    --Mark the turn in which this card was Special Summoned in the Main Phase.
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_SPSUMMON_SUCCESS)
    e0:SetOperation(s.regop)
    c:RegisterEffect(e0)

    --[REQUIREMENT] During the Main Phase this card was Special Summoned.
    --[EFFECT] Destroy 1 opponent's Spell/Trap, then add 1 Cosmic Team
    --from your GY to your hand.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY|CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

--Additional Fusion Material (no Attribute/Race restriction on Infinity Seed).
function s.matfilter(c,fc,sumtype,tp)
    return c:IsMonster()
        and c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK)
        and c:IsRace(RACE_MACHINE|RACE_FIEND)
end

function s.contactmat(c)
    return c:IsFaceup() and c:IsMonster()
        and c:IsAbleToDeckOrExtraAsCost()
end

function s.contactfilter(tp)
    return Duel.GetMatchingGroup(s.contactmat,tp,LOCATION_MZONE,0,nil)
end

function s.contactop(g,tp,c)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,
        REASON_COST|REASON_MATERIAL|REASON_FUSION)
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetCurrentPhase()==PHASE_MAIN1 then
        c:RegisterFlagEffect(id,
            RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
    end
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCurrentPhase()==PHASE_MAIN1
        and e:GetHandler():GetFlagEffect(id)>0
end

function s.desfilter(c)
    return c:GetSequence()~=5 and c:IsDestructable()
end

function s.thfilter(c)
    return c:IsCode(COSMIC_TEAM) and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.desfilter,
            tp,0,LOCATION_SZONE,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_SZONE)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    --Destroy an opponent's card in a Spell & Trap Zone.
    if not Duel.IsExistingMatchingCard(s.desfilter,
        tp,0,LOCATION_SZONE,1,nil) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local dg=Duel.SelectMatchingCard(tp,s.desfilter,
        tp,0,LOCATION_SZONE,1,1,nil)
    if #dg==0 or Duel.Destroy(dg,REASON_EFFECT)==0 then return end

    --Then recover the specified card if it is in your GY.
    local thfilter=aux.NecroValleyFilter(s.thfilter)
    if not Duel.IsExistingMatchingCard(thfilter,
        tp,LOCATION_GRAVE,0,1,nil) then return end
    Duel.BreakEffect()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local hg=Duel.SelectMatchingCard(tp,thfilter,
        tp,LOCATION_GRAVE,0,1,1,nil)
    if #hg>0 and Duel.SendtoHand(hg,tp,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,hg)
    end
end
