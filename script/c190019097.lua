-- I Will Rule (Rush Duel)
-- Card ID: 190019097
-- Ritual Summons Dominus Emperor Form: Greater Titan (190019096)
local s,id=GetID()
local GREATER_TITAN_ID=190019096

function s.initial_effect(c)
    -- Ritual Summon Greater Titan from the Extra Deck.
    -- Send Ritual Materials from hand/field to the GY; their Levels must total 9.
    Ritual.AddProcEqual(c,s.ritfilter,9,nil,nil,s.sendmat,nil,nil,LOCATION_EXTRA)
end

function s.ritfilter(c)
    return c:IsCode(GREATER_TITAN_ID)
end

function s.sendmat(g,e,tp,eg,ep,ev,re,r,rp,rc)
    Duel.SendtoGrave(g,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
end
