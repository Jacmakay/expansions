-- Terminus - The Infinite Creator
-- Custom EDOPro Rush Duel boss monster
-- Card ID: 190019499
-- Level 12 / DIVINE / Creator God / Effect / ATK 3000 / DEF 3000
--
--  * At duel startup, Special Summon 1 copy of Terminus from each
--    player's Deck that contains it (before the first normal draw).
--  * While face-up, its controller cannot lose by deck-out or 0 LP.
--  * Cannot be destroyed by battle or card effects while on the field,
--    and cannot be returned to the hand, Deck or Extra Deck.
--  * Battle position cannot be changed, including by card effects;
--    cannot be flipped face-down while on the field.
--  * Permanently gains 500 ATK for each monster Normal/Special Summoned,
--    and 500 ATK each End Phase, while it remains face-up.
--  * Up to FIVE times per turn: create any non-Token Monster, Spell,
--    or Trap from installed card databases. Add it to your hand or
--    Extra Deck. Special Summon monsters if possible (+1000 ATK).
--
-- Uses the card-creation technique from Power of Creation (190019285)
-- and Dominus Emperor's Finality Creation (190019222).

local s,id=GetID()

function s.initial_effect(c)
    -- The startup effect must be global: ordinary card effects in the Deck
    -- cannot be relied upon to respond to EVENT_STARTUP from that zone.
    -- Register exactly once even when several copies of Terminus exist.
    if not s.startup_registered then
        s.startup_registered=true
        local ge=Effect.GlobalEffect()
        ge:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
        ge:SetCode(EVENT_STARTUP)
        ge:SetOperation(s.startup)
        Duel.RegisterEffect(ge,0)
    end

    -- Protect the controller from losing by deck-out while face-up.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(1,0)
    e1:SetCode(EFFECT_CANNOT_LOSE_DECK)
    c:RegisterEffect(e1)

    -- Protect the controller from losing when LP falls to 0.
    local e2=e1:Clone()
    e2:SetCode(EFFECT_CANNOT_LOSE_LP)
    c:RegisterEffect(e2)

    -- Indestructible by battle while Terminus is in a Monster Zone.
    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_SINGLE)
    e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e7:SetRange(LOCATION_MZONE)
    e7:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e7:SetValue(1)
    c:RegisterEffect(e7)

    -- Indestructible by card effects while Terminus is in a Monster Zone.
    local e8=e7:Clone()
    e8:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    c:RegisterEffect(e8)

    -- Neither player can return this Terminus to the Deck/Extra Deck.
    -- EFFECT_CANNOT_TO_DECK is a player-targeted field restriction;
    -- both sides are covered, but only Terminus is a prohibited target.
    local e9=Effect.CreateEffect(c)
    e9:SetType(EFFECT_TYPE_FIELD)
    e9:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e9:SetRange(LOCATION_MZONE)
    e9:SetCode(EFFECT_CANNOT_TO_DECK)
    e9:SetTargetRange(1,1)
    e9:SetTarget(s.decklimit)
    c:RegisterEffect(e9)

    -- Neither player can return this Terminus to the hand.
    -- Use the same player-targeted restriction as the Deck protection,
    -- scoped to this Terminus only (not to every monster on the field).
    local e10=e9:Clone()
    e10:SetCode(EFFECT_CANNOT_TO_HAND)
    c:RegisterEffect(e10)

    -- Permanently lock Terminus's battle position while on the field.
    -- Prevent manual changes, changes by card effects, and face-down turns.
    local e11=Effect.CreateEffect(c)
    e11:SetType(EFFECT_TYPE_SINGLE)
    e11:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
    e11:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
    c:RegisterEffect(e11)

    local e12=e11:Clone()
    e12:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
    c:RegisterEffect(e12)

    local e13=e11:Clone()
    e13:SetCode(EFFECT_CANNOT_TURN_SET)
    c:RegisterEffect(e13)

    -- Gain 500 ATK per Normal Summon (both players' monsters).
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetOperation(s.summonboost)
    c:RegisterEffect(e3)

    -- Gain 500 ATK per Special Summon (both players' monsters).
    local e4=e3:Clone()
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e4)

    -- Gain 500 ATK during EVERY End Phase.
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCode(EVENT_PHASE|PHASE_END)
    e5:SetCountLimit(1)
    e5:SetOperation(s.endboost)
    c:RegisterEffect(e5)

    -- [REQUIREMENT] During your Main Phase (up to five uses per turn).
    -- [EFFECT] Announce any non-Token Monster, Spell, or Trap in the
    -- installed CDBs. Add it to the hand/Extra Deck, and Special Summon
    -- monsters when possible.
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,0))
    e6:SetCategory(CATEGORY_ANNOUNCE|CATEGORY_TOHAND|CATEGORY_SPECIAL_SUMMON)
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCountLimit(5,id)
    e6:SetOperation(s.create)
    c:RegisterEffect(e6)
end

-- Prevent only the Terminus carrying this effect from being
-- returned to the hand, Main Deck or Extra Deck by either player.
function s.decklimit(e,c)
    return c==e:GetHandler()
end

-- Called exactly once by EVENT_STARTUP, for each player's Deck.
function s.startup(e,tp,eg,ep,ev,re,r,rp)
    for p=0,1 do
        if Duel.GetLocationCount(p,LOCATION_MZONE)>0 then
            local g=Duel.GetMatchingGroup(Card.IsCode,p,LOCATION_DECK,0,nil,id)
            local tc=g:GetFirst()
            if tc and tc:IsCanBeSpecialSummoned(e,0,p,true,true,POS_FACEUP_ATTACK) then
                Duel.SpecialSummon(tc,0,p,p,true,true,POS_FACEUP_ATTACK)
            end
        end
    end
end

-- This stat increase persists until Terminus leaves the field or turns
-- face-down. It is intentionally not reset at the End Phase.
function s.addatk(c,amount)
    if not c:IsFaceup() or not c:IsLocation(LOCATION_MZONE) then return end
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(amount)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD)
    c:RegisterEffect(e1)
end

function s.summonboost(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsFaceup() or not eg then return end
    s.addatk(c,500*#eg)
end

function s.endboost(e,tp,eg,ep,ev,re,r,rp)
    s.addatk(e:GetHandler(),500)
end

function s.haszone(tp,tc)
    if tc:IsLocation(LOCATION_EXTRA) then
        return Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0
    end
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end

function s.create(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end

    -- Display EDOPro's card-name chooser for Monsters, Spells or Traps
    -- from installed CDBs; exclude Token cards.
    local code=Duel.AnnounceCard(tp,
        TYPE_MONSTER|TYPE_SPELL|TYPE_TRAP,OPCODE_ISTYPE,
        TYPE_TOKEN,OPCODE_ISTYPE,OPCODE_NOT,OPCODE_AND)
    if not code or code==0 then return end

    local tc=Duel.CreateToken(tp,code)
    if not tc or not tc:IsType(TYPE_MONSTER|TYPE_SPELL|TYPE_TRAP)
        or tc:IsType(TYPE_TOKEN) then return end

    -- EDOPro redirects created Extra Deck monsters to the Extra Deck
    -- when SendtoHand is used, as in Dominus Emperor's script.
    if Duel.SendtoHand(tc,tp,REASON_EFFECT)==0 then return end
    if not tc:IsLocation(LOCATION_HAND|LOCATION_EXTRA) then return end
    if tc:IsLocation(LOCATION_HAND) then
        Duel.ConfirmCards(1-tp,tc)
    end

    -- Spells and Traps are finished: they are created and added to hand.
    -- Only monsters continue into the original Special Summon branch.
    if not tc:IsType(TYPE_MONSTER) then return end

    if not s.haszone(tp,tc) then return end
    if not tc:IsCanBeSpecialSummoned(e,0,tp,true,true,POS_FACEUP_ATTACK) then
        return
    end

    Duel.BreakEffect()
    if Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP_ATTACK)>0 then
        -- In addition to the 500 ATK from EVENT_SPSUMMON_SUCCESS.
        s.addatk(c,1000)
    end
end
