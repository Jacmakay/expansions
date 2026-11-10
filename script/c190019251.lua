-- True Flame Enjin
-- Custom EDOPro Rush Duel Ritual Spell
-- Provisional Spell card ID: 190019251
-- Ritual Summons "Salamandus Flames of Time" (190019250) from the Extra Deck.
-- Materials: monsters from your hand/field whose total Levels are 11 or higher;
-- do not use more monsters than necessary.
-- [Requirement] None.
local s,id=GetID()

s.listed_names={190019250}

function s.initial_effect(c)
    -- The standard Rush Ritual helper handles:
    --  * selecting the Ritual Monster from the Extra Deck
    --  * selecting materials whose total Levels are at least 11
    --  * preventing extra, unnecessary materials
    --  * sending the materials to the Graveyard for the Ritual Summon
    --  * recording those materials with SetMaterial, so Salamandus can
    --    check whether a Fusion or Maximum Monster was used.
    local e1=Ritual.CreateProc({
        handler=c,
        lvtype=RITPROC_GREATER,
        filter=s.ritualfilter,
        lv=11,
        matfilter=s.matfilter,
        location=LOCATION_EXTRA
    })
    c:RegisterEffect(e1)
end

function s.ritualfilter(c)
    return c:IsCode(190019250)
end

function s.matfilter(c,e,tp)
    return c:IsLocation(LOCATION_HAND|LOCATION_MZONE)
        and c:IsControler(tp)
end
