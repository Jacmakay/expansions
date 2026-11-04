--Astro Gear Fenrir Unbound
--Card ID: 190019065
local s,id=GetID()

local ASTRO_GEAR_FENRIR=190019064

function s.initial_effect(c)
    --Fusion Materials:
    --"Astro Gear Fenrir" + 2 EARTH Machine monsters
    c:EnableReviveLimit()
    Fusion.AddProcCodeFun(c,ASTRO_GEAR_FENRIR,s.matfilter,2,true,true)

    --[REQUIREMENT] The Main Phase you Fusion Summon this card,
    --shuffle 1 card from your opponent's field into the Deck.
    --[EFFECT] Then, this card can make up to 2 attacks on monsters
    --during this turn.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

--2 EARTH Machine monsters
function s.matfilter(c,fc,sumtype,tp)
    return c:IsAttribute(ATTRIBUTE_EARTH,fc,sumtype,tp)
        and c:IsRace(RACE_MACHINE,fc,sumtype,tp)
end

--Can only activate during the turn this card was Fusion Summoned.
--Ignition effects are activated during the Main Phase.
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_FUSION)
        and c:IsStatus(STATUS_SPSUMMON_TURN)
end

function s.costfilter(c)
    return c:IsAbleToDeckAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.costfilter,tp,0,LOCATION_ONFIELD,1,nil
        )
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(
        tp,s.costfilter,tp,0,LOCATION_ONFIELD,1,1,nil
    )
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end

    --This card can make 1 additional attack on a monster
    --for a maximum of 2 monster attacks this turn.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
    e1:SetValue(1)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
    c:RegisterEffect(e1)
end
