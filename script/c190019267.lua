-- Over Limit Transmigration
-- Custom EDOPro Rush Duel Ritual Spell
-- Card ID: 190019267
--
-- [REQUIREMENT]
-- Have a WIND Warrior or DARK Dragon monster in your GY;
-- pay 1200 LP.
-- [EFFECT]
-- Ritual Summon 1 WIND Warrior or DARK Dragon Ritual Monster
-- from your Extra Deck by sending monsters from your hand/field
-- to the GY as material. Their combined Levels must equal or
-- exceed the Ritual Monster's Level, without extra materials.

local s,id=GetID()

function s.initial_effect(c)
    -- Uses the same Extra Deck Ritual procedure as Maximum Chaos Ritual.
    local e1=Ritual.CreateProc({
        handler=c,
        lvtype=RITPROC_GREATER,
        filter=s.ritfilter,
        matfilter=s.matfilter,
        requirementfunc=s.matlevel,
        extraop=s.sendmat,
        location=LOCATION_EXTRA,
        sumpos=POS_FACEUP
    })
    e1:SetCost(s.cost)
    c:RegisterEffect(e1)
end

-- Either a WIND Warrior or a DARK Dragon (matching pairs).
function s.typefilter(c)
    return c:IsMonster()
        and ((c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_WARRIOR))
          or (c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON)))
end

-- The matching monster must already be in your GY at activation.
-- It is not removed or used as Ritual Material by this card.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.CheckLPCost(tp,1200)
            and Duel.IsExistingMatchingCard(s.typefilter,tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.PayLPCost(tp,1200)
end

-- Summon only a matching Ritual Monster from your Extra Deck.
function s.ritfilter(c)
    return c:IsType(TYPE_RITUAL) and s.typefilter(c)
end

-- Materials may come from your hand and/or your Monster Zones.
function s.matfilter(c,e,tp)
    return c:IsMonster()
        and c:IsControler(tp)
        and c:IsLocation(LOCATION_HAND|LOCATION_MZONE)
        and c:GetLevel()>0
        and c:IsAbleToGrave()
end

-- Compare the materials' current Levels to the Ritual Monster's Level.
function s.matlevel(c,rc)
    return c:GetLevel()
end

-- Rush Duel Ritual materials are sent to the GY, not Tributed.
function s.sendmat(g,e,tp,eg,ep,ev,re,r,rp,rc)
    Duel.SendtoGrave(g,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
end
