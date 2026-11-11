-- Gou the Abyss Knight
-- Custom EDOPro Rush Duel Fusion/Effect Monster
-- Card ID: 190019237
-- WIND / Sea Serpent / Fusion / Effect / Level 8 / ATK 3000 / DEF 1500
-- Fusion Materials: "Spirit of Gou" (190019235) + 1 WIND Sea Serpent monster
-- [REQUIREMENT] During the turn this card was Special Summoned,
-- shuffle 2 Level 4 or higher Sea Serpent monsters from your GY into the Deck.
-- [EFFECT] Gain 300 ATK for each Fusion Monster in your GY, then
-- become indestructible by card effects until the end of your opponent's next turn.

local s,id=GetID()
local SPIRIT_OF_GOU=190019235
s.listed_names={SPIRIT_OF_GOU}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Fusion Materials: "Spirit of Gou" + 1 WIND Sea Serpent monster.
    Fusion.AddProcMix(c,true,true,SPIRIT_OF_GOU,s.fusmatfilter)

    -- Once per turn, in the turn this card was Special Summoned.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK|CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.fusmatfilter(c,fc,sumtype,tp)
    return c:IsMonster()
        and c:IsAttribute(ATTRIBUTE_WIND)
        and c:IsRace(RACE_SEASERPENT)
end

-- STATUS_SPSUMMON_TURN refers to this copy's Special Summon this turn.
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN)
        and Duel.GetTurnPlayer()==tp
end

function s.costfilter(c)
    return c:IsMonster()
        and c:IsRace(RACE_SEASERPENT)
        and c:IsLevelAbove(4)
        and c:IsAbleToDeckAsCost()
end

-- [REQUIREMENT] Shuffle exactly 2 eligible monsters from your GY into your Deck.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,2,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,2,2,nil)
    if #g==2 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
    end
end

function s.fusionfilter(c)
    return c:IsMonster() and c:IsType(TYPE_FUSION)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end

    -- Count Fusion Monsters remaining in your GY after paying the Requirement.
    local ct=Duel.GetMatchingGroupCount(s.fusionfilter,tp,LOCATION_GRAVE,0,nil)
    if ct>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(ct*300)
        -- No duration is printed for the ATK gain, so it lasts while this
        -- face-up copy remains on the field (and can stack on later turns).
        e1:SetReset(RESET_EVENT|RESETS_STANDARD)
        c:RegisterEffect(e1)
    end

    -- Cannot be destroyed by card effects until the end of the
    -- opponent's next turn.  RESET_OPPO_TURN makes the reset wait
    -- for the opponent's End Phase rather than this turn's End Phase.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetValue(1)
    e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END|RESET_OPPO_TURN,1)
    c:RegisterEffect(e2)
end
