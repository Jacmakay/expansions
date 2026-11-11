-- Spirit of Gou
-- Custom EDOPro Rush Duel effect monster
-- Card ID: 190019235
-- Level 4 / WIND / Sea Serpent / Effect / ATK 1300 / DEF 1500
--
-- [REQUIREMENT] Send 1 Spell/Trap Card from your hand to the Graveyard.
-- [EFFECT] Fusion Summon 1 WIND Sea Serpent Fusion Monster,
-- shuffling the appropriate Fusion Materials from your field and/or
-- Graveyard into the Deck (or Extra Deck, as appropriate).

local s,id=GetID()

function s.initial_effect(c)
    -- Use the EDOPro Fusion helper to honor the selected Fusion Monster's
    -- listed material requirements and Fusion Summoning restrictions.
    local e1=Fusion.CreateSummonEff({
        handler=c,
        fusfilter=s.fusfilter,
        matfilter=s.matfilter,
        extrafil=s.extrafil,
        extraop=Fusion.ShuffleMaterial
    })
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1) -- Rush Duel: once per turn per face-up copy
    e1:SetCost(s.cost)
    c:RegisterEffect(e1)
end

-- Send exactly 1 Spell/Trap from the hand as the Requirement.
function s.costfilter(c)
    return c:IsSpellTrap() and c:IsAbleToGraveAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_COST)
    end
end

-- Only WIND Sea Serpent Fusion Monsters may be summoned.
function s.fusfilter(c,tp)
    return c:IsType(TYPE_FUSION)
        and c:IsAttribute(ATTRIBUTE_WIND)
        and c:IsRace(RACE_SEASERPENT)
end

-- The default material pool may include the hand, so explicitly
-- exclude hand cards. Materials on your field must be shuffleable.
function s.matfilter(c,e,tp,chk)
    return c:IsMonster()
        and c:IsLocation(LOCATION_MZONE)
        and c:IsControler(tp)
        and c:IsAbleToDeck()
end

-- Also allow materials from your GY.
function s.gyfilter(c)
    return c:IsMonster() and c:IsAbleToDeck()
end

function s.extrafil(e,tp,mg)
    return Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_GRAVE,0,nil)
end
