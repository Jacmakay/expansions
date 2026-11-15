-- The Blade is Me
-- Rush Duel Ritual Spell
-- Card ID: 190019108
-- Ritual Summons "Faded Memory From Afar - Mugetsu" (190019107)

local s,id=GetID()

local MUGETSU=190019107

function s.initial_effect(c)
	-- [REQUIREMENT] None.
	--
	-- [EFFECT]
	-- Ritual Summon 1 "Faded Memory From Afar - Mugetsu".
	-- Use monsters from your hand and/or field whose total Levels are 11 or more.
	--
	-- Project Ignis's Ritual helper automatically uses LOCATION_EXTRA
	-- in Rush Duel because DUEL_MODE_RUSH includes DUEL_EXTRA_DECK_RITUAL.
	Ritual.AddProcGreater(c,s.ritfilter,11)
end

function s.ritfilter(c)
	return c:IsCode(MUGETSU)
end
