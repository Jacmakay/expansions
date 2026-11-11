-- U-T-W Los Daedalus
-- Card ID: 190019240
-- Custom EDOPro Rush Duel | WIND / Sea Serpent / Ritual / Effect
-- Level 11 | ATK 3800 / DEF 3000
--
-- [REQUIREMENT]
-- During the Main Phase you Ritual Summoned this card, send 1 face-up
-- Field Spell from your field to the Graveyard.
-- [EFFECT]
-- Destroy all other cards on the field.
--
-- NOTE: Ritual Summoning is performed by a separate Ritual Spell.
--       In Rush Duel, Ritual Monsters are placed in the Extra Deck.

local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- Must be your Main Phase of the same turn this card was Ritual Summoned.
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return Duel.GetTurnPlayer()==tp
        and Duel.IsMainPhase()
        and c:IsSummonType(SUMMON_TYPE_RITUAL)
        and c:IsStatus(STATUS_SPSUMMON_TURN)
end

-- A face-up Field Spell in your Field Zone, which can be sent as a cost.
function s.costfilter(c)
    return c:IsFaceup()
        and c:IsType(TYPE_FIELD)
        and c:IsAbleToGraveAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_FZONE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_FZONE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_COST)
    end
end

function s.otherfilter(c)
    return true
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    -- Includes both players' monsters and Spell/Traps, except this card.
    local g=Duel.GetMatchingGroup(s.otherfilter,tp,
        LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.otherfilter,tp,
        LOCATION_ONFIELD,LOCATION_ONFIELD,c)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end
