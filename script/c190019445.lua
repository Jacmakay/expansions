-- One-Turn Rewind
-- Custom EDOPro / Rush Duel Normal Spell
-- Card ID: 190019445
-- WARNING: This is a best-effort physical board/zone snapshot restoration,
-- NOT a true engine rewind. See notes below.

local s,id=GetID()

local TRACKED_LOCATIONS=LOCATION_DECK|LOCATION_HAND|LOCATION_MZONE|LOCATION_SZONE
    |LOCATION_GRAVE|LOCATION_REMOVED|LOCATION_EXTRA

function s.initial_effect(c)
    -- Activate: restore a snapshot from the START of the preceding turn.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.actcon)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Keep recording even while the Spell is in the Deck or hand.
    -- Register one global watcher for all copies of this card.
    if not s.global_check then
        s.global_check=true
        local ge=Effect.GlobalEffect()
        ge:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
        ge:SetCode(EVENT_PHASE_START+PHASE_DRAW)
        ge:SetOperation(s.remember_turn_start)
        Duel.RegisterEffect(ge,0)
    end
end

-- Save LP, the exact physical cards, their zones and their positions.
-- Retain their group to keep Card objects available across turns.
function s.remember_turn_start(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(0,TRACKED_LOCATIONS,TRACKED_LOCATIONS)
    g:KeepAlive()

    local snap={
        turn=Duel.GetTurnCount(),
        lp={[0]=Duel.GetLP(0),[1]=Duel.GetLP(1)},
        group=g,
        cards={}
    }
    for tc in aux.Next(g) do
        snap.cards[#snap.cards+1]={
            card=tc,
            location=tc:GetLocation(),
            player=tc:GetControler(),
            owner=tc:GetOwner(),
            sequence=tc:GetSequence(),
            position=tc:GetPosition()
        }
    end

    -- Only keep two snapshots alive: current and immediately prior turn.
    if s.previous and s.previous.group then
        s.previous.group:DeleteGroup()
    end
    s.previous=s.current
    s.current=snap
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
    return s.previous~=nil and Duel.GetTurnCount()>1
        and Duel.GetFlagEffect(tp,id)==0
end

local function restore_nonfield_record(v)
    local tc=v.card
    local loc=v.location
    local p=v.player
    if loc==LOCATION_GRAVE then
        if not tc:IsLocation(LOCATION_GRAVE) then
            Duel.SendtoGrave(tc,REASON_RULE,p)
        end
    elseif loc==LOCATION_HAND then
        if not tc:IsLocation(LOCATION_HAND) or tc:GetControler()~=p then
            Duel.SendtoHand(tc,p,REASON_RULE)
        end
    elseif loc==LOCATION_REMOVED then
        if not tc:IsLocation(LOCATION_REMOVED) then
            Duel.Remove(tc,v.position,REASON_RULE,p)
        end
    elseif loc==LOCATION_EXTRA then
        if not tc:IsLocation(LOCATION_EXTRA) then
            -- Extra Deck monsters return to Extra via SendtoDeck.
            Duel.SendtoDeck(tc,v.owner,SEQ_DECKBOTTOM,REASON_RULE)
        end
    end
end

local function restore_field_record(v,tp)
    local tc=v.card
    local loc=v.location
    if loc==LOCATION_MZONE then
        -- Force the recorded zone; this does NOT re-create Summon history.
        Duel.MoveToField(tc,tp,v.player,LOCATION_MZONE,v.position,true,1<<v.sequence)
    elseif loc==LOCATION_SZONE then
        if v.sequence==5 and tc:IsType(TYPE_FIELD) then
            Duel.MoveToField(tc,tp,v.player,LOCATION_FZONE,v.position,true)
        else
            Duel.MoveToField(tc,tp,v.player,LOCATION_SZONE,v.position,true,1<<v.sequence)
        end
    end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local snap=s.previous
    if not snap then return end

    -- Prevent repeated replays of the effect by the same player.
    Duel.RegisterFlagEffect(tp,id,0,0,1)
    Duel.DisableShuffleCheck()

    -- Free all field slots before reconstructing the earlier field.
    -- RULE movements are used to minimize normal card-effect interactions.
    local field=Duel.GetFieldGroup(0,LOCATION_ONFIELD,LOCATION_ONFIELD)
    if #field>0 then
        Duel.SendtoGrave(field,REASON_RULE)
    end

    -- Empty both Main Decks into the GY temporarily. This is required to
    -- attempt to reconstruct the old draw order. This can expose cards.
    local decks=Duel.GetFieldGroup(0,LOCATION_DECK,LOCATION_DECK)
    if #decks>0 then
        Duel.SendtoGrave(decks,REASON_RULE)
    end

    -- Restore Graveyards / hands / banished cards / Extra Deck membership.
    for _,v in ipairs(snap.cards) do
        restore_nonfield_record(v)
    end

    -- Rebuild Main Decks from original card identities and order.
    -- In EDOPro, deck sequence 0 is bottom and the highest is top.
    -- Add each recorded card from top to bottom using SEQ_DECKBOTTOM.
    for p=0,1 do
        local old_deck={}
        for _,v in ipairs(snap.cards) do
            if v.location==LOCATION_DECK and v.player==p then
                old_deck[#old_deck+1]=v
            end
        end
        table.sort(old_deck,function(a,b) return a.sequence>b.sequence end)
        for _,v in ipairs(old_deck) do
            Duel.SendtoDeck(v.card,p,SEQ_DECKBOTTOM,REASON_RULE)
        end
    end

    -- Rebuild monsters first, then Spell/Trap cards in their old slots.
    for _,v in ipairs(snap.cards) do
        if v.location==LOCATION_MZONE then
            restore_field_record(v,tp)
        end
    end
    for _,v in ipairs(snap.cards) do
        if v.location==LOCATION_SZONE then
            restore_field_record(v,tp)
        end
    end

    -- LP restoration last, after any consequences of card movement.
    Duel.SetLP(0,snap.lp[0])
    Duel.SetLP(1,snap.lp[1])
end

-- KNOWN LIMITATIONS:
-- * The real turn number, turn player, phase, and actions cannot be reversed.
-- * This cannot reverse chains, once-per-turn counters, summon history,
--   lingering effects, counters, or previously used activations.
-- * Tokens/Maximum Mode, equip relations, Xyz materials, custom zones,
--   facedown-banished positions, and changed card properties may not restore.
-- * Transferring the contents of the Deck through the GY may reveal cards
--   or cause additional events; engine restrictions may block movements.
-- * Test in a local custom duel. This is not a full save-state system.
