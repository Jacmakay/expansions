-- Ifinity Servitor Vagrada
-- Custom EDOPro Rush Duel card - ID: 190019420
-- Fusion Materials: "Infinity Seed" + 2 LIGHT or DARK Machine or Fiend monsters

local s,id=GetID()
local INFINITY_SEED=190019412

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- 1 "Infinity Seed" + 2 LIGHT/DARK Machine or Fiend monsters.
    Fusion.AddProcMixN(c,false,true,INFINITY_SEED,1,s.matfilter,2)

    -- Contact Fusion: shuffle the 3 face-up materials from your field
    -- into the Deck (Extra Deck for applicable materials).
    Fusion.AddContactProc(c,s.contactfilter,s.contactop,
        nil,nil,SUMMON_TYPE_FUSION,nil,false)

    -- Remember whether this copy was Special Summoned this Main Phase.
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_SPSUMMON_SUCCESS)
    e0:SetOperation(s.regop)
    c:RegisterEffect(e0)

    -- [REQUIREMENT] This card was Special Summoned during this Main Phase.
    -- [EFFECT] Destroy 1 opponent's monster; then you can return
    -- 1 LIGHT/DARK Machine or Fiend monster from your GY to your hand.
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

-- The generic material must satisfy BOTH the Attribute and Type filters.
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
    return c:IsMonster() and c:IsDestructable()
end

function s.thfilter(c)
    return c:IsMonster()
        and c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK)
        and c:IsRace(RACE_MACHINE|RACE_FIEND)
        and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.desfilter,
            tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsExistingMatchingCard(s.desfilter,
        tp,0,LOCATION_MZONE,1,nil) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local dg=Duel.SelectMatchingCard(tp,s.desfilter,
        tp,0,LOCATION_MZONE,1,1,nil)
    if #dg==0 or Duel.Destroy(dg,REASON_EFFECT)==0 then return end

    -- Recovering a monster is optional, but only after destruction.
    local thfilter=aux.NecroValleyFilter(s.thfilter)
    if not Duel.IsExistingMatchingCard(thfilter,
        tp,LOCATION_GRAVE,0,1,nil) then return end
    if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local hg=Duel.SelectMatchingCard(tp,thfilter,
        tp,LOCATION_GRAVE,0,1,1,nil)
    if #hg>0 and Duel.SendtoHand(hg,tp,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,hg)
    end
end
