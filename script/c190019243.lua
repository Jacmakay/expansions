--Ridge Off! Void Striker Devour
--Custom Rush Duel Spell - 190019243
local s,id=GetID()

function s.initial_effect(c)
    --[REQUIREMENT] Have a DARK Dragon monster in your Graveyard.
    --[EFFECT] Fusion Summon a Level 9 or higher High Dragon monster,
    --shuffling materials from your field and/or GY into their owners' Decks.
    local e1=RD.CreateFusionEffect(c,
        s.matfilter,s.spfilter,s.exfilter,
        LOCATION_GRAVE,0,nil,RD.FusionToDeck)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    c:RegisterEffect(e1)
end

--Requirement: at least 1 DARK Dragon monster in your GY.
function s.reqfilter(c)
    return c:IsType(TYPE_MONSTER)
        and c:IsAttribute(ATTRIBUTE_DARK)
        and c:IsRace(RACE_DRAGON)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.reqfilter,tp,LOCATION_GRAVE,0,1,nil)
end

--Ordinary Fusion material pool: face-up monsters on your field only.
--The hand cannot be used as a material source for this card.
function s.matfilter(c)
    return c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
        and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end

--Extra Fusion material pool: monsters in your Graveyard.
function s.exfilter(c)
    return c:IsType(TYPE_MONSTER)
        and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end

--The Fusion Monster must be a Level 9+ High Dragon.
function s.spfilter(c)
    return c:IsType(TYPE_FUSION)
        and c:IsLevelAbove(9)
        and c:IsRace(RACE_HIGHDRAGON)
end
