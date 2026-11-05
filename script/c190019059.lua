-- U-T-W Seraphim Fonix Mode Two
-- ID: 190019059 | Rush Duel custom Fusion monster
local s,id=GetID()
local HANDY_LADY=160006013
local HANDY_LADY_ALT=160022000

s.listed_names={HANDY_LADY,HANDY_LADY_ALT}

function s.initial_effect(c)
    c:EnableReviveLimit()
    -- "Handy Lady" (either artwork/ID) + 2 WIND monsters.
    -- Uses EDOPro's Fusion library, not the unavailable RD library.
    Fusion.AddProcMix(c,true,true,s.handyfilter,s.windfilter,s.windfilter)

    -- [REQUIREMENT] "Handy Lady" is in your GY.
    -- [EFFECT] Return opponent's Spell/Trap Zone cards to the hand,
    -- then gain 500 ATK per "Handy Lady" in your GY.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.handyfilter(c,fc,sumtype,tp)
    return c:IsCode(HANDY_LADY,HANDY_LADY_ALT)
end

function s.windfilter(c,fc,sumtype,tp)
    return c:IsAttribute(ATTRIBUTE_WIND)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.handyfilter,tp,LOCATION_GRAVE,0,1,nil)
end

function s.returnfilter(c)
    return c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local g=Duel.GetMatchingGroup(s.returnfilter,tp,0,LOCATION_SZONE,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.returnfilter,tp,0,LOCATION_SZONE,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
    end
    if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
    local ct=Duel.GetMatchingGroupCount(s.handyfilter,tp,LOCATION_GRAVE,0,nil)
    if ct==0 then return end
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(ct*500)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e2)
end
