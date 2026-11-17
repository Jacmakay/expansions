-- HMPH! I Am All Futures!! | 190019496
-- Experimental auto-resolving Normal Spell in EDOPro Rush Duel.
-- [REQUIREMENT] If your LP fall to 0, automatically resolve from
-- your hand, Deck, or GY before the Duel ends.
-- [EFFECT] Special Summon "Transcend Dragon: Destroyer of All Beings"
-- from the Extra Deck or create the actual (non-Token) Fusion card from
-- the card database; halve your opponent's LP, then gain the LP lost.
--
-- IMPORTANT: The Dragon's actual database ID was NOT supplied. If known,
-- set DESTROYER_ID below to its ID. Until then, selection is constrained
-- by its stated stats: DIVINE / Galaxy / Level 12 / Fusion / 5000/4000.
-- Engine limitation: EVENT_ADJUST plus CANNOT_LOSE_LP is a best-effort
-- workaround, NOT literal Spell activation in a chain at 0 LP.
local s,id=GetID()
local DESTROYER_ID=0 -- Replace 0 with the real ID when the Dragon is in your CDB.
if DESTROYER_ID~=0 then s.listed_names={DESTROYER_ID} end
s.running={}
function s.initial_effect(c)
    if not s.global_registered then
        s.global_registered=true
        for p=0,1 do
            local who=p
            -- Temporary survival window for this auto-trigger effect.
            local e1=Effect.GlobalEffect()
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
            e1:SetCode(EFFECT_CANNOT_LOSE_LP)
            e1:SetTargetRange(1,0)
            e1:SetCondition(function(e) return s.protect(who) end)
            Duel.RegisterEffect(e1,who)
        end
        local ge=Effect.GlobalEffect()
        ge:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
        ge:SetCode(EVENT_ADJUST)
        ge:SetOperation(s.check)
        Duel.RegisterEffect(ge,0)
    end
    -- No normal activation effect: this is an automatic effect only.
end
function s.hascard(p)
    return Duel.IsExistingMatchingCard(Card.IsCode,p,
        LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,id)
end
function s.protect(p)
    return s.running[p]
        or (Duel.GetFlagEffect(p,id)==0 and s.hascard(p))
end
function s.bossfilter(c)
    if DESTROYER_ID~=0 then return c:IsCode(DESTROYER_ID) end
    return c:IsType(TYPE_FUSION) and c:IsRace(RACE_GALAXY)
        and c:IsAttribute(ATTRIBUTE_DIVINE) and c:IsLevel(12)
        and c:GetBaseAttack()==5000 and c:GetBaseDefense()==4000
end
function s.getboss(e,p)
    local ex=Duel.GetMatchingGroup(s.bossfilter,p,LOCATION_EXTRA,0,nil)
    if #ex>0 then
        Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(p,s.bossfilter,p,LOCATION_EXTRA,0,1,1,nil)
        return sg:GetFirst()
    end
    -- "Duel.CreateToken" is EDOPro's create-an-existing-card method;
    -- it creates the announced real Fusion card, not a Token monster.
    local code
    if DESTROYER_ID~=0 then
        code=DESTROYER_ID
    else
        code=Duel.AnnounceCard(p,
            TYPE_MONSTER,OPCODE_ISTYPE,
            TYPE_TOKEN,OPCODE_ISTYPE,OPCODE_NOT,OPCODE_AND)
    end
    if not code or code==0 then return nil end
    local tc=Duel.CreateToken(p,code)
    if not tc or tc:IsType(TYPE_TOKEN) or not s.bossfilter(tc) then return nil end
    if Duel.SendtoHand(tc,p,REASON_EFFECT)==0 then return nil end
    if not tc:IsLocation(LOCATION_EXTRA) then return nil end
    return tc
end
function s.haszone(p,tc)
    if tc:IsLocation(LOCATION_EXTRA) then
        return Duel.GetLocationCountFromEx(p,p,nil,tc)>0
    end
    return Duel.GetLocationCount(p,LOCATION_MZONE)>0
end
function s.perform(e,p)
    -- Take one copy from Hand/Deck/GY as the auto-activating Spell.
    local sg=Duel.GetMatchingGroup(Card.IsCode,p,
        LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,nil,id)
    local sc=sg:GetFirst()
    if not sc then return end
    if not sc:IsLocation(LOCATION_GRAVE) then
        Duel.SendtoGrave(sc,REASON_EFFECT)
    end
    local tc=s.getboss(e,p)
    if not tc or not s.haszone(p,tc) then return end
    if not tc:IsCanBeSpecialSummoned(e,0,p,true,true,POS_FACEUP_ATTACK) then return end
    if Duel.SpecialSummon(tc,0,p,p,true,true,POS_FACEUP_ATTACK)==0 then return end
    tc:CompleteProcedure()
    local op=1-p
    local old=Duel.GetLP(op)
    local new=math.floor(old/2)
    local lost=old-new
    Duel.SetLP(op,new)
    if lost>0 then Duel.Recover(p,lost,REASON_EFFECT) end
end
function s.check(e,tp,eg,ep,ev,re,r,rp)
    for p=0,1 do
        if Duel.GetLP(p)<=0 and Duel.GetFlagEffect(p,id)==0
            and s.hascard(p) and not s.running[p] then
            s.running[p]=true
            -- Used once; if the summon fails the player can lose normally.
            Duel.RegisterFlagEffect(p,id,0,0,1)
            s.perform(e,p)
            s.running[p]=false
        end
    end
end
