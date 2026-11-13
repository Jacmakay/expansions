-- Eto Cal Venos
-- Custom EDOPro Rush Duel card
-- Card ID: 190019284
-- Level 9 / DARK / Reptile / Fusion / Effect / ATK 3300 / DEF 0
-- Fusion Materials: "Liberator Versailles" + 1 Reptile monster
-- This card can be Contact Fusioned.
-- [REQUIREMENT] None.
-- [EFFECT] Special Summon 1 DARK Reptile monster from your Graveyard.

local s,id=GetID()
local LIBERATOR_VERSAILLES=190019283
s.listed_names={LIBERATOR_VERSAILLES}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Normal Fusion Summon: "Liberator Versailles" + 1 Reptile monster.
    Fusion.AddProcMix(c,false,true,LIBERATOR_VERSAILLES,s.matfilter)

    -- Rush Duel Contact Fusion: shuffle the two face-up materials you
    -- control into their owners' Decks/Extra Decks (without "Fusion").
    Fusion.AddContactProc(c,s.contactgroup,s.contactop,nil,nil,SUMMON_TYPE_FUSION)

    -- [REQUIREMENT] None.
    -- [EFFECT] Special Summon 1 DARK Reptile monster from your GY.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
end

function s.matfilter(c,fc,sumtype,tp)
    return c:IsRace(RACE_REPTILE)
end

function s.contactfilter(c)
    return c:IsFaceup() and c:IsAbleToDeckOrExtraAsCost()
end

function s.contactgroup(tp)
    return Duel.GetMatchingGroup(s.contactfilter,tp,LOCATION_MZONE,0,nil)
end

function s.contactop(g,tp,fc)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST|REASON_MATERIAL|REASON_FUSION)
end

function s.spfilter(c,e,tp)
    return c:IsMonster() and c:IsAttribute(ATTRIBUTE_DARK)
        and c:IsRace(RACE_REPTILE)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
