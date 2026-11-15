-- Veda's Samasara - Threefold Rewind
-- Custom EDOPro Rush Duel Normal Spell
-- Card ID: 190019446
-- EXPERIMENTAL: Attempts to recreate card zones and Life Points as they were
-- at the START OF THE TURN THREE TURNS AGO. This is NOT a true duel rewind.
-- The turn counter, turn player, phase, effect history, and other engine state
-- cannot be reset by a normal EDOPro card script.

local s,id=GetID()
local REWIND_TURNS=3
local TRACKED_LOCATIONS=LOCATION_DECK|LOCATION_HAND|LOCATION_MZONE
    |LOCATION_SZONE|LOCATION_GRAVE|LOCATION_REMOVED|LOCATION_EXTRA

function s.initial_effect(c)
    -- Rewind three turns when this Normal Spell resolves.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.actcon)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Register ONE global snapshot collector, shared by all copies.
    -- This must run from the beginning of the duel: placing the card
    -- into a deck before starting the duel initializes the card script.
    if not s.global_check then
        s.global_check=true
        s.history={}
        local ge=Effect.GlobalEffect()
        ge:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
        ge:SetCode(EVENT_PHASE_START+PHASE_DRAW)
        ge:SetOperation(s.remember_turn_start)
        Duel.RegisterEffect(ge,0)
    end
end

-- Save both players' LP and physical card positions once per turn.
-- A retained Group prevents the saved Card references from expiring.
function s.remember_turn_start(e,tp,eg,ep,ev,re,r,rp)
    local turn=Duel.GetTurnCount()
    local history=s.history
    if #history>0 and history[#history].turn==turn then return end

    local g=Duel.GetFieldGroup(0,TRACKED_LOCATIONS,TRACKED_LOCATIONS)
    g:KeepAlive()
    local snap={
        turn=turn,
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
    history[#history+1]=snap

    -- Current turn plus the previous three turn starts = four snapshots.
    while #history>REWIND_TURNS+1 do
        local old=table.remove(history,1)
        old.group:DeleteGroup()
    end
end

-- Only a snapshot exactly three turn numbers earlier is acceptable.
function s.get_rewind_snapshot()
    local wanted=Duel.GetTurnCount()-REWIND_TURNS
    if wanted<1 then return nil end
    for i=#s.history,1,-1 do
        if s.history[i].turn==wanted then
            return s.history[i]
        end
    end
    return nil
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id)==0
        and s.get_rewind_snapshot()~=nil
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
            Duel.SendtoDeck(tc,v.owner,SEQ_DECKBOTTOM,REASON_RULE)
        end
    end
end

local function restore_field_record(v,tp)
    local tc=v.card
    if v.location==LOCATION_MZONE then
        -- The exact recorded zone is requested, without replaying a summon.
        Duel.MoveToField(tc,tp,v.player,LOCATION_MZONE,v.position,true,1<<v.sequence)
    elseif v.location==LOCATION_SZONE then
        if v.sequence==5 and tc:IsType(TYPE_FIELD) then
            Duel.MoveToField(tc,tp,v.player,LOCATION_FZONE,v.position,true)
        else
            Duel.MoveToField(tc,tp,v.player,LOCATION_SZONE,v.position,true,1<<v.sequence)
        end
    end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local snap=s.get_rewind_snapshot()
    if not snap then return end
    -- Once per Duel for the activating player.
    Duel.RegisterFlagEffect(tp,id,0,0,1)
    Duel.DisableShuffleCheck()

    -- Remove current field cards and Main Deck contents so their saved
    -- positions can be reconstructed. These movements are not invisible:
    -- they can still trigger effects and may fail under engine rules.
    local field=Duel.GetFieldGroup(0,LOCATION_ONFIELD,LOCATION_ONFIELD)
    if #field>0 then
        Duel.SendtoGrave(field,REASON_RULE)
    end
    local decks=Duel.GetFieldGroup(0,LOCATION_DECK,LOCATION_DECK)
    if #decks>0 then
        Duel.SendtoGrave(decks,REASON_RULE)
    end

    -- Recreate hand, Graveyard, banished and Extra Deck membership.
    for _,v in ipairs(snap.cards) do
        restore_nonfield_record(v)
    end

    -- Reconstruct each Main Deck in recorded sequence (indices increase
    -- from the bottom). Sending top-first to the bottom keeps the order.
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

    -- Return field cards to their recorded zones and positions.
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

    -- Restore both players' recorded LP last.
    Duel.SetLP(0,snap.lp[0])
    Duel.SetLP(1,snap.lp[1])
end

-- LIMITATIONS:
-- * True time travel is not available: the turn count, player, phase, chain,
--   effect usage, once-per-turn flags and lingering effects are unchanged.
-- * Can only activate beginning on Turn 4, once a Turn 1 snapshot exists.
-- * The snapshot system must be initialized before Turn 1 begins.
-- * Maximum Mode, tokens, counters, attachments, equip targets, and altered
--   card properties may not reconstruct correctly.
-- * Restoring cards by sending them through the GY may reveal hidden cards,
--   cause additional effect triggers, or be prevented by other rules.
-- * Restoration is best effort: test in a local Rush Duel, not ranked play.
