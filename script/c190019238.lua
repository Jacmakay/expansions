-- Greater Titan Gou: Seraphim Tetra Tsu
-- Custom EDOPro Rush Duel Fusion/Effect Monster
-- Card ID: 190019238
-- Level 12 / WIND / Sea Serpent / Fusion / Effect / ATK 4000 / DEF 2500
-- Materials: "Spirit of Gou" (190019235) + 4 WIND Sea Serpent monsters.
-- Passive: You cannot lose the Duel by Deck-out while this card is face-up.
-- [REQUIREMENT] During the turn this card was Special Summoned,
-- shuffle ALL cards from BOTH Graveyards into their owners' Decks.
-- [EFFECT] Gain 100 ATK per card shuffled; cannot be destroyed by card
-- effects until the end of your opponent's next turn. If 5+ WIND
-- Sea Serpents were shuffled, send the top 15 cards of your Deck to the
-- GY, then optionally equip WIND Sea Serpent Union monsters from your GY.

local s,id=GetID()
local SPIRIT_OF_GOU=190019235
s.listed_names={SPIRIT_OF_GOU}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Fusion material procedure: exactly Spirit of Gou plus four others.
    Fusion.AddProcMixN(c,true,true,SPIRIT_OF_GOU,1,s.fusionfilter,4)

    -- Continuous effect: while face-up, you cannot lose by Deck-out.
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e0:SetCode(EFFECT_CANNOT_LOSE_DECK)
    e0:SetRange(LOCATION_MZONE)
    e0:SetTargetRange(1,0)
    c:RegisterEffect(e0)

    -- Rush monster effect (once per turn per face-up copy).
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK|CATEGORY_ATKCHANGE|CATEGORY_DECKDES|CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- All generic Fusion materials must be WIND Sea Serpent monsters.
function s.fusionfilter(c,fc,sumtype,tp)
    return c:IsMonster() and c:IsAttribute(ATTRIBUTE_WIND)
        and c:IsRace(RACE_SEASERPENT)
end

-- Only in the turn this particular copy was Special Summoned.
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
        and e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN)
end

function s.windserpent(c)
    return c:IsMonster() and c:IsAttribute(ATTRIBUTE_WIND)
        and c:IsRace(RACE_SEASERPENT)
end

-- Shuffle ALL cards in BOTH Graveyards as the Requirement.
-- The Requirement cannot be paid if even one card cannot be returned.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetFieldGroup(tp,LOCATION_GRAVE,LOCATION_GRAVE)
    if chk==0 then
        return #g>0 and g:FilterCount(Card.IsAbleToDeckAsCost,nil)==#g
    end

    -- Remember which cards were WIND Sea Serpents before they moved.
    local windcards={}
    for tc in aux.Next(g) do
        if s.windserpent(tc) then
            windcards[tc]=true
        end
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local shuffled=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
    local actually_returned=Duel.GetOperatedGroup()
    local windcount=0
    if actually_returned then
        for tc in aux.Next(actually_returned) do
            if windcards[tc] and tc:IsLocation(LOCATION_DECK|LOCATION_EXTRA) then
                windcount=windcount+1
            end
        end
    end

    -- Encode the two counts in a single Effect label.
    -- 1000 is safely above ordinary deck sizes (including custom Rush decks).
    e:SetLabel(shuffled*1000+windcount)
end

-- Eligible Union monsters in YOUR GY (from the just-milled cards).
function s.unionfilter(c)
    return c:IsMonster() and c:IsType(TYPE_UNION)
        and c:IsAttribute(ATTRIBUTE_WIND)
        and c:IsRace(RACE_SEASERPENT)
end

-- Keep each equipped monster attached only to this copy of Gou.
function s.eqlimit(e,c)
    return c==e:GetLabelObject()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local value=e:GetLabel()
    local shuffled=math.floor(value/1000)
    local windcount=value%1000

    if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
    if shuffled<=0 then return end

    -- Gain 100 ATK for each card actually shuffled into a Deck/Extra Deck.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(100*shuffled)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
    c:RegisterEffect(e1)

    -- Effect-destruction immunity through the opponent's NEXT End Phase.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetValue(1)
    e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,2)
    c:RegisterEffect(e2)

    -- Optional additional sequence only after 5+ WIND Sea Serpents.
    if windcount<5 then return end
    Duel.BreakEffect()

    -- Send the top 15 of your Deck to the GY. If fewer remain,
    -- send those available rather than attempting to move nonexistent cards.
    local available=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
    local n=math.min(15,available)
    if n<=0 then return end
    if Duel.DiscardDeck(tp,n,REASON_EFFECT)<=0 then return end

    if not c:IsFaceup() or not c:IsLocation(LOCATION_MZONE)
        or not c:IsRelateToEffect(e) then return end

    -- Equip any number of eligible Union monsters, one at a time,
    -- until the player stops or runs out of Spell/Trap Zones.
    while Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.unionfilter),
            tp,LOCATION_GRAVE,0,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,1)) do

        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
        local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.unionfilter),
            tp,LOCATION_GRAVE,0,1,1,nil)
        local uc=sg:GetFirst()
        if not uc then break end
        if not Duel.Equip(tp,uc,c,true) then break end

        -- Equip-limit and Union-status effects allow the monster's
        -- own Union equip effects to function while equipped.
        local el=Effect.CreateEffect(uc)
        el:SetType(EFFECT_TYPE_SINGLE)
        el:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        el:SetCode(EFFECT_EQUIP_LIMIT)
        el:SetLabelObject(c)
        el:SetValue(s.eqlimit)
        el:SetReset(RESET_EVENT|RESETS_STANDARD)
        uc:RegisterEffect(el)

        local es=Effect.CreateEffect(uc)
        es:SetType(EFFECT_TYPE_SINGLE)
        es:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        es:SetCode(EFFECT_UNION_STATUS)
        es:SetReset(RESET_EVENT|RESETS_STANDARD)
        uc:RegisterEffect(es)
    end
end
