-- Encounter: Cyclops Barrage
-- Custom EDOPro Rush Duel Normal Spell
-- Card ID: 190019274
--
-- [REQUIREMENT]
-- You control an EARTH monster or a DARK Galaxy monster.
-- [EFFECT]
-- Monsters currently face-up on your field can attack twice this turn.

local s,id=GetID()

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- The required monster must be face-up, since Attribute and Type
-- cannot be verified on a face-down monster you control.
function s.reqfilter(c)
    return c:IsFaceup() and c:IsMonster()
        and (c:IsAttribute(ATTRIBUTE_EARTH)
            or (c:IsAttribute(ATTRIBUTE_DARK)
                and c:IsRace(RACE_GALAXY)))
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.reqfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Snapshot only the monsters that are face-up when the Spell resolves.
    -- Monsters summoned or flipped face-up later do not gain this effect.
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    for tc in aux.Next(g) do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EXTRA_ATTACK)
        e1:SetValue(1) -- one additional attack: two attacks total
        e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
        tc:RegisterEffect(e1)
    end
end
