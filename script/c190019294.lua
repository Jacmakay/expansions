--Domain Expansion Solaris Luminescent
--Custom EDOPro Rush Duel Field Spell - 190019294
local s,id=GetID()

function s.initial_effect(c)
    --[REQUIREMENT] Have a Level 10 monster in your Graveyard.
    --Activate the Field Spell (its activation does not Fusion Summon).
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.reqcon)
    c:RegisterEffect(e1)

    --[CONTINUOUS EFFECT] While this card remains face-up,
    --you can Fusion Summon using monsters on your field.
    --An Ignition Effect supplies the Fusion selection prompt;
    --no count limit, since the card says no once-per-turn limit.
    local e2=Fusion.CreateSummonEff(c,nil,s.matfilter)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCondition(s.reqcon)
    c:RegisterEffect(e2)
end

function s.reqfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsLevel(10)
end

function s.reqcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.reqfilter,tp,LOCATION_GRAVE,0,1,nil)
end

--Only your face-up monsters on the field may be used.
--Fusion.CreateSummonEff checks the summoned monster's own
--Fusion procedure and sends the selected materials to GY.
function s.matfilter(c)
    return c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
end
