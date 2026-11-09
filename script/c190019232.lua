-- Equilibrium Ritual (Rush Duel)
-- Custom card ID: 190019232
-- Ritual Summons "Madness of Equilibrium" (190019231).
-- [REQUIREMENT] None.
-- [EFFECT] Ritual Summon "Madness of Equilibrium" using monsters from
-- the hand and/or field whose combined Levels are 10 or more, without
-- using more monsters than necessary.
--
-- In Rush Duels, Ritual Monsters are Ritual Summoned from the Extra Deck.
-- The Project Ignis Ritual helper detects DUEL_EXTRA_DECK_RITUAL,
-- selects legal materials, sends/releases them, and completes the summon.

local s,id=GetID()
s.listed_names={190019231}

function s.initial_effect(c)
    Ritual.AddProcGreater(c,s.ritualfilter,10)
end

function s.ritualfilter(c)
    return c:IsCode(190019231)
end
