-- Voidvelg Chaos Emperor Dragon (190019027)
-- Custom Rush Duel | DARK / Galaxy / Ritual / Effect | Level 10
-- [REQUIREMENT] During a turn you Ritual Summoned this card.
-- [EFFECT] Send all cards on the field to the Graveyard, then you cannot
-- Special Summon monsters for the rest of this turn.
local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.tgcon)
    e1:SetTarget(s.tgtg)
    e1:SetOperation(s.tgop)
    c:RegisterEffect(e1)
end

function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- A Ritual Summon completed this turn (not a later revival by Eris).
    return c:IsSummonType(SUMMON_TYPE_RITUAL)
        and c:IsStatus(STATUS_SUMMON_TURN)
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
    if #g==0 then return end
    local ct=Duel.SendtoGrave(g,REASON_EFFECT)
    if ct<=0 then return end
    -- This is a lingering player restriction: it persists after this
    -- monster leaves the field, until the end of the turn.
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(e,c) return true end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
