--Will of Terminus
--Custom Rush Duel Ritual Spell
--Card ID: 190019423
--Ritual Summons "Harbinger of Infinity: Will of Terminus" (190019422)

local s,id=GetID()
local TERMINUS=190019422

function s.initial_effect(c)
    --Ritual Summon the Level 12 monster from your Extra Deck.
    --Use monsters from your hand and/or field whose total Levels are
    --at least the Ritual Monster's Level.
    --Rush Ritual materials are SENT to the GY (not Tributed).
    Ritual.AddProcGreater(c,s.ritualfilter,nil,nil,nil,
        s.sendmaterials,s.materialfilter,nil,LOCATION_EXTRA)
end

--Only the named Ritual Monster may be Ritual Summoned.
function s.ritualfilter(c)
    return c:IsCode(TERMINUS)
end

--Limit materials to monsters in your own hand or on your own field.
function s.materialfilter(c,e,tp)
    return c:IsMonster()
        and c:IsControler(tp)
        and c:IsLocation(LOCATION_HAND|LOCATION_MZONE)
        and c:IsAbleToGrave()
end

--Rush Ritual materials are sent to the Graveyard instead of released.
--The built-in Ritual helper handles legality, material selection,
--the Ritual Summon, and CompleteProcedure().
function s.sendmaterials(g,e,tp,eg,ep,ev,re,r,rp,rc)
    Duel.SendtoGrave(g,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
end
