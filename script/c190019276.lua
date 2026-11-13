-- Voidvelg God From Another World
-- Custom EDOPro Rush Duel Fusion / Effect Monster
-- Card ID: 190019276
-- Level 12 / DARK / Galaxy / Fusion / Effect
-- ATK 4000 / DEF 2500
--
-- Fusion Materials:
--   "Voidvelg Requiem" (160010025)
--   1 Ritual Monster
--   "War God Soul" (190019275)
--
-- Can be Contact Fusion Summoned by shuffling the three face-up
-- materials from your Monster Zone into their owners' Decks.
--
-- [CONTINUOUS EFFECT]
-- Gains 300 ATK per DARK Galaxy monster or Ritual Monster in your GY.
-- Cannot be destroyed by card effects.
-- Can attack each monster the opponent controls once each.

local s,id=GetID()

local VOIDVELG_REQUIEM=160010025
local WAR_GOD_SOUL=190019275
s.listed_names={VOIDVELG_REQUIEM,WAR_GOD_SOUL}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Three required material slots; no Fusion substitutions.
    Fusion.AddProcMix(c,false,false,
        VOIDVELG_REQUIEM,s.ritualfilter,WAR_GOD_SOUL)

    -- Alternative Rush Duel Contact Fusion from your face-up field.
    Fusion.AddContactProc(c,s.contactgroup,s.contactop,
        nil,nil,SUMMON_TYPE_FUSION)

    -- Continuous ATK: +300 for each qualifying card in your GY.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)

    -- Cannot be destroyed by card effects.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- Can attack all monsters the opponent controls, once each.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_ATTACK_ALL)
    e3:SetValue(1)
    c:RegisterEffect(e3)
end

-- Any Ritual Monster is valid for the middle material slot.
function s.ritualfilter(c,fc,sumtype,tp)
    return c:IsType(TYPE_RITUAL)
end

-- For Rush Duel Contact Fusion, all materials must be face-up on
-- your own field and able to return to the Deck or Extra Deck.
function s.contactfilter(c)
    return c:IsFaceup()
        and c:IsMonster()
        and c:IsAbleToDeckOrExtraAsCost()
end

function s.contactgroup(tp)
    return Duel.GetMatchingGroup(
        s.contactfilter,tp,LOCATION_MZONE,0,nil)
end

-- Shuffle Contact Fusion materials into their owners' Decks.
-- Extra Deck monsters return to their Extra Deck instead.
function s.contactop(g,tp,fc)
    fc:SetMaterial(g)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,
        REASON_COST|REASON_MATERIAL|REASON_FUSION)
end

-- Count a qualifying monster once, even if it matches both conditions.
function s.atkfilter(c)
    return c:IsMonster() and (
        (c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_GALAXY))
        or c:IsType(TYPE_RITUAL))
end

function s.atkval(e,c)
    local tp=e:GetHandlerPlayer()
    return Duel.GetMatchingGroupCount(
        s.atkfilter,tp,LOCATION_GRAVE,0,nil)*300
end
