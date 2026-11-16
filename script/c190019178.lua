-- Sophia Ex Cosmo Harbinger of Rebirth
-- ID: 190019178 | Level 12 DARK Fairy / Ritual / Effect | 4000 ATK / 4000 DEF
-- Rush Duel Ritual Monster: TYPE_MONSTER + TYPE_EFFECT + TYPE_RITUAL = 161.
-- In Rush Duel mode, Ritual Monsters are kept in the Extra Deck.
-- Ritual Summoned from the Extra Deck
-- by "The Cosmo Harbingers Schemes" (190019179).
local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Cannot be destroyed by card effects.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- Cannot be returned to the Extra Deck from the field by card effects.
    -- While in the Monster Zone, the core's CANNOT_TO_DECK effect also
    -- blocks other "return to Deck" attempts (the stronger safeguard).
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_CANNOT_TO_DECK)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- Rush Duel Main Phase effect; once per Duel across all copies.
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TODECK+CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
    e3:SetCondition(s.condition)
    e3:SetTarget(s.target)
    e3:SetOperation(s.operation)
    c:RegisterEffect(e3)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_RITUAL)
        and c:GetTurnID()==Duel.GetTurnCount()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,PLAYER_ALL,
        LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsFaceup() or not c:IsLocation(LOCATION_MZONE) then return end

    -- Keep track of cards that began on the field so the ATK boost only
    -- counts those, not cards from either player's hand or Graveyard.
    local fg=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
    fg:RemoveCard(c)
    local rg=fg:Clone()
    rg:Merge(Duel.GetFieldGroup(tp,LOCATION_HAND+LOCATION_GRAVE,
                                      LOCATION_HAND+LOCATION_GRAVE))
    if #rg==0 then return end

    -- Every eligible card goes to its owner's Deck or Extra Deck.
    Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)

    local returned=0
    for tc in aux.Next(fg) do
        if tc:IsLocation(LOCATION_DECK) or tc:IsLocation(LOCATION_EXTRA) then
            returned=returned+1
        end
    end
    if returned==0 then return end
    if not c:IsFaceup() or not c:IsLocation(LOCATION_MZONE) then return end

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(returned*500)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e1)
end
