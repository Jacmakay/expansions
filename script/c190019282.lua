-- Over Limit Acnologia Hypernova
-- Custom EDOPro Rush Duel Fusion / Effect Monster
-- Card ID: 190019282
-- DARK / Wyrm / Fusion / Effect / Level 12 / ATK 4500 / DEF 3500
--
-- Fusion Materials:
--   "Soul of the Dragon Harbinger" (190019281)
--   + 4 other Wyrm monsters
--
-- [REQUIREMENT] During the Main Phase in which this card was Fusion Summoned.
-- [EFFECT] Shuffle all cards on the field into their owners' Decks.
-- Then Special Summon 1 Wyrm monster from your GY in face-up Attack Position.
-- If it is "Soul of the Dragon Harbinger", it gains 3000 ATK and cannot
-- be destroyed by card effects until the end of your opponent's turn.

local s,id=GetID()
local SOUL_OF_DRAGON_HARBINGER=190019281
s.listed_names={SOUL_OF_DRAGON_HARBINGER}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Exactly five materials: one named monster and four Wyrms.
    -- The named material is not also counted as one of the four.
    Fusion.AddProcMixN(c,false,false,
        SOUL_OF_DRAGON_HARBINGER,1,s.wyrmfilter,4)

    -- Rush Duel: during the Main Phase in which this was Fusion Summoned.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK|CATEGORY_SPECIAL_SUMMON|CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.wyrmfilter(c,fc,sumtype,tp)
    return c:IsRace(RACE_WYRM,fc,sumtype,tp)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return Duel.GetTurnPlayer()==tp
        and Duel.IsMainPhase()
        and c:IsSummonType(SUMMON_TYPE_FUSION)
        and c:IsStatus(STATUS_SPSUMMON_TURN)
end

function s.spfilter(c,e,tp)
    return c:IsMonster()
        and c:IsRace(RACE_WYRM)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,
            tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
            and Duel.IsExistingMatchingCard(
                aux.NecroValleyFilter(s.spfilter),
                tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,
        tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- Include both players' cards and Hypernova itself.
    -- Extra Deck monsters return to the Extra Deck automatically.
    local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,
        tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    if #g==0 then return end
    if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then
        return
    end

    -- Resolve the second part after the field has been shuffled away.
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local f=aux.NecroValleyFilter(s.spfilter)
    if not Duel.IsExistingMatchingCard(f,tp,LOCATION_GRAVE,0,1,nil,e,tp) then
        return
    end

    Duel.BreakEffect()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.SelectMatchingCard(tp,f,tp,LOCATION_GRAVE,
        0,1,1,nil,e,tp):GetFirst()
    if not tc then return end
    if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)==0 then
        return
    end

    if not tc:IsCode(SOUL_OF_DRAGON_HARBINGER) then return end

    -- In your Main Phase, two End Phases cover the rest of your turn
    -- and the opponent's following turn. Standard resets apply early
    -- if Soul leaves the field or is flipped face-down.
    local reset=RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(3000)
    e2:SetReset(reset,2)
    tc:RegisterEffect(e2)

    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetValue(1)
    e3:SetReset(reset,2)
    tc:RegisterEffect(e3)
end
