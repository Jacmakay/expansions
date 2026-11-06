-- Einreilia Zero
-- Custom EDOPro Rush Duel Fusion Monster
-- Card ID: 190019069
-- Level 10 / LIGHT / Cyborg / Fusion / Effect
-- ATK 3600 / DEF 1500
-- Fusion Materials: "Einreilia Servitor Of Parabellum" (190019039)
--                 + 1 Level 8 Machine monster
-- Can be Contact Fusioned using face-up monsters on your field.
-- [REQUIREMENT] During the turn this card was Special Summoned,
--               send 1 Machine monster from your hand to the GY.
-- [EFFECT] Destroy 1 card your opponent controls, then this card
--          can attack monsters up to 3 times this turn.

local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Normal Rush Duel Fusion materials.
    Fusion.AddProcMix(c,false,true,190019039,s.matfilter)

    -- Rush Duel Contact Fusion: shuffle the 2 face-up materials
    -- from your Monster Zone into their owners' Decks.
    Fusion.AddContactProc(c,s.contactgroup,s.contactop,nil,nil,SUMMON_TYPE_FUSION,nil,false)

    -- Once per turn, only during the turn this monster was Special Summoned.
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

-- The second Fusion Material must be a Level 8 Machine monster.
function s.matfilter(c,fc,sumtype,tp)
    return c:IsRace(RACE_MACHINE) and c:IsLevel(8)
end

-- Contact Fusion uses face-up monsters you control only.
function s.contactfilter(c)
    return c:IsFaceup() and c:IsMonster()
        and c:IsAbleToDeckOrExtraAsCost()
end

function s.contactgroup(tp)
    return Duel.GetMatchingGroup(s.contactfilter,tp,LOCATION_MZONE,0,nil)
end

function s.contactop(g,tp,c)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,
        REASON_COST|REASON_MATERIAL|REASON_FUSION)
end

-- This effect can only be activated during the turn the card was
-- Special Summoned (including a Fusion or Contact Fusion Summon).
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_SPECIAL)
        and c:GetTurnID()==Duel.GetTurnCount()
end

function s.handfilter(c)
    return c:IsMonster() and c:IsRace(RACE_MACHINE)
        and c:IsAbleToGraveAsCost()
end

-- [REQUIREMENT] Send exactly 1 Machine monster from your hand to the GY.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.handfilter,tp,LOCATION_HAND,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.handfilter,tp,LOCATION_HAND,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_COST)
    end
end

-- Any destructible card on the opponent's field can be selected.
function s.desfilter(c)
    return c:IsDestructable()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
    if #g==0 then return end
    Duel.HintSelection(g)

    -- "Then": the opponent's card must actually be destroyed
    -- before the extra monster attacks are granted.
    if Duel.Destroy(g,REASON_EFFECT)==0 then return end
    if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end

    -- One normal attack + 2 additional attacks on monsters = up to 3.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
    e1:SetValue(2)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
    c:RegisterEffect(e1)
end
