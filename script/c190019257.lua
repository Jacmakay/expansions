-- Sineater Ultima Fusion
-- Custom Rush Duel Spell - RD/KP27-EN060
-- Card ID: 190019257
local s,id=GetID()

function s.initial_effect(c)
    -- Fusion Summon a Level 10+ Fiend or Spellcaster Fusion Monster,
    -- shuffling materials from your field and/or GY into their owners' Decks.
    local e1=Fusion.CreateSummonEff({
        handler=c,
        fusfilter=s.fusfilter,
        matfilter=s.matfilter,
        extrafil=s.extrafil,
        extraop=Fusion.ShuffleMaterial
    })
    -- [REQUIREMENT] A Fairy and a Spellcaster monster in your GY.
    e1:SetCondition(s.condition)
    c:RegisterEffect(e1)
end

-- Check for a monster of the specified Type in the GY.
function s.reqfilter(c,race)
    return c:IsMonster() and c:IsRace(race)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.reqfilter,tp,LOCATION_GRAVE,0,1,nil,RACE_FAIRY)
        and Duel.IsExistingMatchingCard(s.reqfilter,tp,LOCATION_GRAVE,0,1,nil,RACE_SPELLCASTER)
end

-- The Fusion Monster must be Level 10 or higher and Fiend/Spellcaster.
function s.fusfilter(c,tp)
    return c:IsLevelAbove(10) and c:IsRace(RACE_FIEND|RACE_SPELLCASTER)
end

-- Use only monsters on your field (not cards in your hand).
-- Facedown field monsters are permitted because the supplied text
-- does not explicitly restrict materials to face-up monsters.
function s.matfilter(c,e,tp,chk)
    return c:IsLocation(LOCATION_MZONE) and c:IsMonster() and c:IsAbleToDeck()
end

-- You can additionally use eligible monsters in your GY.
function s.grmatfilter(c)
    return c:IsMonster() and c:IsAbleToDeck()
end
function s.extrafil(e,tp,mg)
    return Duel.GetMatchingGroup(s.grmatfilter,tp,LOCATION_GRAVE,0,nil)
end
