-- Harbinger of Tides Heart of Terminus
-- Custom EDOPro Rush Duel card - ID: 190019410
-- WATER / Level 12 / Cyberse / Ritual / Effect
-- ATK 5000 / DEF 3000
--
-- [REQUIREMENT] Shuffle 4 cards from your GY into your Deck.
-- [EFFECT] While this card remains face-up, your opponent cannot
-- Special Summon Level 11 or lower monsters in Attack Position.
-- Until the end of your opponent's next turn, this card cannot be
-- destroyed by card effects or returned to the Extra Deck by card effects.
-- This card cannot be destroyed by battle with Level 11 or lower monsters.

local s,id=GetID()

function s.initial_effect(c)
    -- A separate Ritual Spell / summon procedure Ritual Summons this monster.
    c:EnableReviveLimit()

    -- [REQUIREMENT] Shuffle 4 cards from your GY into the Deck.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.costfilter(c)
    return c:IsAbleToDeckAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,4,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,4,4,nil)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

-- Restrict Level 11 or lower monsters to Defense Position when
-- the opponent Special Summons them. Do not block Special Summoning itself.
-- The engine may check both Attack and Defense positions together, so
-- EFFECT_CANNOT_SPECIAL_SUMMON would wrongly prohibit both positions.
function s.defposfilter(e,c,sump,sumtype,sumpos,targetp,se)
    return c:IsMonster() and c:HasLevel() and c:IsLevelBelow(11)
end

function s.battlefilter(e)
    local bc=e:GetHandler():GetBattleTarget()
    return bc~=nil and bc:HasLevel() and bc:IsLevelBelow(11)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end

    -- Restriction is active only while this monster stays face-up.
    -- For affected monsters, the allowed Special Summon positions are
    -- face-up or face-down Defense; Level 12+ monsters are unrestricted.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0,1)
    e1:SetTarget(s.defposfilter)
    e1:SetValue(POS_DEFENSE)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_DISABLE)
    c:RegisterEffect(e1)

    -- Battle protection also remains while this monster is face-up.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetValue(s.battlefilter)
    e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_DISABLE)
    c:RegisterEffect(e2)

    -- 2 End Phases: your current turn's End Phase, then your
    -- opponent's next End Phase. These effects also stop if this
    -- monster leaves the field or has its effects negated.
    local reset=RESET_EVENT|RESETS_STANDARD|RESET_DISABLE|RESET_PHASE|PHASE_END
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetValue(1)
    e3:SetReset(reset,2)
    c:RegisterEffect(e3)

    -- Stop effect-based returns to the Deck / Extra Deck.
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EFFECT_CANNOT_TO_DECK)
    e4:SetValue(1)
    e4:SetReset(reset,2)
    c:RegisterEffect(e4)

    -- Extra Deck monsters may be returned there by an effect that
    -- says 'return to the hand', so block that route as well.
    local e5=e4:Clone()
    e5:SetCode(EFFECT_CANNOT_TO_HAND)
    c:RegisterEffect(e5)
end
