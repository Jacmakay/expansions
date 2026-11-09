-- Heart of Terminus
-- Custom EDOPro Rush Duel Ritual Spell
-- Card ID: 190019411
-- Ritual Summons "Harbinger of Tides Heart of Terminus" (190019410)
-- from the Extra Deck using Cyberse monsters from your hand or field.
-- Material Levels must total at least the Ritual Monster's Level (12).
-- Materials are SENT to the GY, not Tributed.

local s,id=GetID()
local HARBINGER_OF_TIDES=190019410

function s.initial_effect(c)
    -- Ritual Summon the named monster from your Extra Deck.
    -- Use the regular Ritual procedure, but require Cyberse materials
    -- and send them to the Graveyard instead of Tributing them.
    Ritual.AddProcGreater(c,s.ritualfilter,nil,nil,nil,
        s.sendmaterials,s.matfilter,nil,LOCATION_EXTRA)
end

s.listed_names={HARBINGER_OF_TIDES}

function s.ritualfilter(c)
    return c:IsCode(HARBINGER_OF_TIDES)
end

-- Only Cyberse monsters owned by the activating player, in their
-- hand or Monster Zones, that can be sent to the Graveyard.
function s.matfilter(c,e,tp)
    return c:IsMonster()
        and c:IsRace(RACE_CYBERSE)
        and c:IsControler(tp)
        and c:IsLocation(LOCATION_HAND|LOCATION_MZONE)
        and c:IsAbleToGrave()
end

-- Called by the Ritual helper once the required materials are selected.
-- The helper sets them as the Ritual Monster's materials and performs
-- the Ritual Special Summon from the Extra Deck afterward.
function s.sendmaterials(g,e,tp,eg,ep,ev,re,r,rp,rc)
    Duel.SendtoGrave(g,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
end
