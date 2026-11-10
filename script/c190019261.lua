-- Sineater Synch Rate 100 Percent!
-- Custom EDOPro Rush Duel Ritual Spell
-- Card ID: 190019261
-- Ritual Summons @Singularity Sineater Firewall Dragon (190019260)
local s,id=GetID()
local FIREWALL_DRAGON=190019260

function s.initial_effect(c)
    -- [EFFECT] Ritual Summon Firewall Dragon from the Extra Deck.
    -- RITPROC_GREATER enforces the "no more monsters than necessary"
    -- rule when the sum of the materials' Levels is 11 or greater.
    local e1=Ritual.CreateProc({
        handler=c,
        lvtype=RITPROC_GREATER,
        filter=s.ritfilter,
        lv=11,
        matfilter=s.matfilter,
        extraop=s.sendmat,
        location=LOCATION_EXTRA,
        requirementfunc=s.matlevel,
        sumpos=POS_FACEUP_ATTACK
    })
    -- [REQUIREMENT] A Fairy and a Spellcaster in your Graveyard.
    e1:SetCondition(s.condition)
    c:RegisterEffect(e1)
end
s.listed_names={FIREWALL_DRAGON}

function s.reqfilter(c,race)
    return c:IsMonster() and c:IsRace(race)
end

-- The Fairy and Spellcaster must be two different monsters.
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local fg=Duel.GetMatchingGroup(s.reqfilter,tp,LOCATION_GRAVE,0,nil,RACE_FAIRY)
    local sg=Duel.GetMatchingGroup(s.reqfilter,tp,LOCATION_GRAVE,0,nil,RACE_SPELLCASTER)
    for fc in fg:Iter() do
        if sg:IsExists(aux.TRUE,1,fc) then
            return true
        end
    end
    return false
end

function s.ritfilter(c)
    return c:IsCode(FIREWALL_DRAGON)
end

-- Only Fiend, Fairy or Spellcaster monsters in your hand or on your field.
function s.matfilter(c,e,tp)
    return c:IsMonster()
        and c:IsControler(tp)
        and c:IsLocation(LOCATION_HAND|LOCATION_MZONE)
        and c:IsRace(RACE_FIEND|RACE_FAIRY|RACE_SPELLCASTER)
        and c:GetLevel()>0
        and c:IsAbleToGrave()
end

-- Use their current Levels, as specified on the card.
function s.matlevel(c,rc)
    return c:GetLevel()
end

-- This card sends the materials to the GY; it does NOT Tribute them.
-- The Ritual helper sets the chosen cards as the summoned monster's material.
function s.sendmat(mat,e,tp,eg,ep,ev,re,r,rp,rc)
    Duel.SendtoGrave(mat,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
end
