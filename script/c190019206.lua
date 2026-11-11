-- Maximum Purple Transcend Dragon
-- Custom EDOPro Rush Duel Fusion / Effect Monster
-- Card ID: 190019206
-- Level 11 / DARK / High Dragon / Fusion / Effect / ATK 4000 / DEF 2500
-- Fusion Materials:
--   "Ultimecia the Titan of Endless Darkness" (190019201)
-- + "Jupiter the God From Another World" (190019200)
-- + 1 LIGHT Dragon monster
-- Can also be Contact Fusion Summoned using those face-up materials
-- from your field, shuffling them into their owners' Decks.
-- [REQUIREMENT] During the Main Phase in which this card was Special Summoned.
-- [EFFECT] Change all opposing monsters to face-up Defense Position.
-- Then, this card can attack monsters up to 3 times this turn, with piercing.

local s,id=GetID()
local ULTIMECIA=190019201
local JUPITER=190019200
s.listed_names={ULTIMECIA,JUPITER}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Proper Fusion materials: Ultimecia + Jupiter + one LIGHT Dragon.
    Fusion.AddProcMix(c,true,true,ULTIMECIA,JUPITER,s.lightdragon)

    -- Contact Fusion using the same three named/filtered materials.
    -- Only face-up monsters on your field are eligible, and the materials
    -- are shuffled into the Deck (or returned to the Extra Deck).
    Fusion.AddContactProc(c,s.contactfilter,s.contactop,
        nil,nil,SUMMON_TYPE_FUSION,nil,false)

    -- Mark the Main Phase in which this card is Special Summoned.
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_SPSUMMON_SUCCESS)
    e0:SetOperation(s.regop)
    c:RegisterEffect(e0)

    -- Rush Duel: each face-up copy can activate this effect once per turn.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_POSITION)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- The third material must be a LIGHT Dragon monster.
function s.lightdragon(c,fc,sumtype,tp)
    return c:IsMonster() and c:IsAttribute(ATTRIBUTE_LIGHT)
        and c:IsRace(RACE_DRAGON)
end

function s.contactmat(c)
    return c:IsMonster() and c:IsFaceup()
        and c:IsAbleToDeckOrExtraAsCost()
end
function s.contactfilter(tp)
    return Duel.GetMatchingGroup(s.contactmat,tp,LOCATION_MZONE,0,nil)
end
function s.contactop(g,tp,c)
    c:SetMaterial(g)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,
        REASON_COST|REASON_MATERIAL|REASON_FUSION)
end

-- The activation window ends with the Main Phase; it does not reopen
-- in a later Main Phase unless this copy is Special Summoned again.
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_MAIN1 then
        e:GetHandler():RegisterFlagEffect(id,
            RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
    end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
        and Duel.GetCurrentPhase()==PHASE_MAIN1
        and e:GetHandler():GetFlagEffect(id)>0
end

function s.posfilter(c)
    return c:IsMonster() and not c:IsPosition(POS_FACEUP_DEFENSE)
        and c:IsCanChangePosition()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil)
    end
    local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,POS_FACEUP_DEFENSE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
    if #g==0 then return end

    -- "Then": only grant the combat effects if at least one opponent's
    -- monster was successfully changed to face-up Defense Position.
    if Duel.ChangePosition(g,POS_FACEUP_DEFENSE)==0 then return end
    if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end

    -- One normal monster attack + two additional monster attacks.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
    e1:SetValue(2)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
    c:RegisterEffect(e1)

    -- All battle damage from attacks into Defense Position pierces.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_PIERCE)
    e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
    c:RegisterEffect(e2)
end
