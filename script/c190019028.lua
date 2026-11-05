-- Advent of Chaos (190019028)
-- Custom Rush Duel Ritual Spell for Voidvelg Chaos Emperor Dragon.
-- Ritual Summons from the Extra Deck using Ritual Materials from
-- the hand and field whose total Levels are 10 or higher.
local s,id=GetID()

function s.initial_effect(c)
    -- The built-in procedure handles material selection, Ritual Summon
    -- (SUMMON_TYPE_RITUAL), and tc:CompleteProcedure().
    -- Force LOCATION_EXTRA for the Rush Duel Ritual Monster.
    -- Do not pass fixed level 11: use the monster's Level (10).
    Ritual.AddProcGreater(c,s.ritfilter,nil,nil,nil,nil,nil,nil,LOCATION_EXTRA)
end

function s.ritfilter(c)
    return c:IsCode(190019027)
end
