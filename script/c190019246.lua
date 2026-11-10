--Spirit of Enjin
--Custom Rush Duel card / EDOPro
--Card ID: 190019246
local s,id=GetID()

function s.initial_effect(c)
    --[Requirement] Send 1 Spell or Trap from your hand to the GY.
    --[Effect] Fusion Summon 1 FIRE Fusion Monster using monsters in
    --your GY as material, shuffling those monsters into the Deck.
    local e1=Fusion.CreateSummonEff(c,{
        fusfilter=s.fusfilter,
        matfilter=s.nofieldmat,
        extrafil=s.extramat,
        extraop=Fusion.ShuffleMaterial
    })
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    c:RegisterEffect(e1)
end

--The requirement must be paid from the hand, not from the field.
function s.costfilter(c)
    return c:IsSpellTrap() and c:IsAbleToGraveAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end

--The Fusion Monster must have the FIRE Attribute.
function s.fusfilter(c,tp)
    return c:IsAttribute(ATTRIBUTE_FIRE)
end

--Do not use ordinary field/hand Fusion materials.
function s.nofieldmat(c,e,tp,chk)
    return false
end

--Only monsters that can be shuffled into the Deck/Extra Deck
--from your own Graveyard can be selected as materials.
function s.matfilter(c)
    return c:IsMonster() and c:IsAbleToDeck()
end
function s.extramat(e,tp,mg)
    return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE,0,nil)
end
