-- Neo Blue-Eyes Hyper Ultimate Dragon
-- Custom EDOPro Rush Duel Fusion / Effect Monster
-- Card ID: 190019207
-- Level 12 / LIGHT / Dragon / Fusion / Effect / ATK 4500 / DEF 3800
-- Fusion Materials:
--   "Blue-Eyes White Dragon"
-- + "Ultimecia the Titan of Endless Darkness"
-- + 1 LIGHT Dragon monster
--
-- [REQUIREMENT] None.
-- [EFFECT] Add 1 "Maximum Chaos Ritual" or "Reversal Technique Ultimas"
-- from your GY to your hand, then this card can make up to 3 attacks
-- on monsters and gains 500 ATK for each LIGHT Dragon monster in
-- your GY this turn.

local s,id=GetID()

local BLUE_EYES_WHITE_DRAGON=89631139
local ULTIMECIA=190019201
local MAXIMUM_CHAOS_RITUAL=190019209
-- Confirmed card ID for Reversal Technique Ultimas.
local REVERSAL_TECHNIQUE_ULTIMAS=190019208

s.listed_names={BLUE_EYES_WHITE_DRAGON,ULTIMECIA,
    MAXIMUM_CHAOS_RITUAL,REVERSAL_TECHNIQUE_ULTIMAS}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Exactly three Fusion Materials: the two named monsters
    -- and one additional LIGHT Dragon monster.
    Fusion.AddProcMix(c,true,true,
        BLUE_EYES_WHITE_DRAGON,ULTIMECIA,s.lightdragon)

    -- Rush Duel [REQUIREMENT]: None.
    -- Once per turn per face-up copy.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND|CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- Third Fusion Material.
function s.lightdragon(c,fc,sumtype,tp)
    return c:IsMonster() and c:IsAttribute(ATTRIBUTE_LIGHT)
        and c:IsRace(RACE_DRAGON)
end

-- The only Spells that can be recovered.
function s.thfilter(c)
    return c:IsAbleToHand()
        and c:IsCode(MAXIMUM_CHAOS_RITUAL,REVERSAL_TECHNIQUE_ULTIMAS)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),
            tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.atkfilter(c)
    return c:IsMonster() and c:IsAttribute(ATTRIBUTE_LIGHT)
        and c:IsRace(RACE_DRAGON)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    -- Add exactly one of the two named Spells from your GY to your hand.
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),
        tp,LOCATION_GRAVE,0,1,1,nil)
    local tc=g:GetFirst()
    if not tc or Duel.SendtoHand(tc,nil,REASON_EFFECT)==0 then return end
    Duel.ConfirmCards(1-tp,tc)

    -- "Then": only grant these bonuses after successful recovery.
    if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end

    -- One standard monster attack + two extra monster attacks = up to 3.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
    e2:SetValue(2)
    e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
    c:RegisterEffect(e2)

    -- Count LIGHT Dragon monsters in your GY at effect resolution.
    local ct=Duel.GetMatchingGroupCount(s.atkfilter,
        tp,LOCATION_GRAVE,0,nil)
    if ct>0 then
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_UPDATE_ATTACK)
        e3:SetValue(ct*500)
        e3:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
        c:RegisterEffect(e3)
    end
end
