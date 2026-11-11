--Dominus Emperor's Finality Creation
--Custom EDOPro Rush Duel card
--Card ID: 190019222
--Level 10 / DARK / Celestial Warrior / Effect / ATK 3000 / DEF 2000

local s,id=GetID()

local DOMINUS_ID=190019091   --Emperor of Dominus ("Dominus Emperor")
local BLADE_ID=190019092     --Emperor's Finality Blade
local RULER_ID=190019093     --Proclaimed One True Ruler
s.listed_names={DOMINUS_ID,BLADE_ID,RULER_ID}

function s.initial_effect(c)
    --Special Summon from the hand by sending Emperor of Dominus
    --from your field to the Graveyard (not Tributing it).
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    --[REQUIREMENT] This card was Normal or Special Summoned this turn.
    --[EFFECT] Declare a Monster Card, create it, add it to the correct
    --location, optionally Special Summon it, restrict activations,
    --and lose 1000 LP at each End Phase for the rest of the Duel.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_ANNOUNCE|CATEGORY_TOHAND|CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.effcon)
    e2:SetOperation(s.effop)
    c:RegisterEffect(e2)
end

--The monster sent for the Special Summon must actually free a zone.
function s.spfilter(c,tp)
    return c:IsCode(DOMINUS_ID)
        and c:IsAbleToGraveAsCost()
        and Duel.GetMZoneCount(tp,c)>0
end

function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
    if #g==0 then return false end
    g:KeepAlive()
    e:SetLabelObject(g)
    return true
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=e:GetLabelObject()
    if not g then return end
    Duel.SendtoGrave(g,REASON_COST)
    g:DeleteGroup()
end

--Only on the turn the current copy of this card was Summoned.
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return Duel.GetTurnPlayer()==tp
        and (c:IsStatus(STATUS_SUMMON_TURN)
             or c:IsStatus(STATUS_SPSUMMON_TURN))
end

--The only legal activations during the restriction are:
-- (1) an effect of the *specific* created-and-Summoned card,
-- (2) Emperor of Dominus (Dominus Emperor),
-- (3) Emperor's Finality Blade,
-- (4) Proclaimed One True Ruler.
function s.actlimit(e,re,tp)
    local handler=re:GetHandler()
    if handler:IsCode(DOMINUS_ID,BLADE_ID,RULER_ID) then return false end
    local summoned=e:GetLabelObject()
    if summoned and handler==summoned then return false end
    return true
end

--Applies through the End Phase of the next turn.
function s.applylock(c,tp,summoned)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetTargetRange(1,0)
    if summoned then e1:SetLabelObject(summoned) end
    e1:SetValue(s.actlimit)
    e1:SetReset(RESET_PHASE|PHASE_END,2)
    Duel.RegisterEffect(e1,tp)
end

--1000 LP lost at each End Phase (including the current turn).
--No reset: it continues for the rest of the Duel, even if this card leaves.
--Duel.SetLP implements LP loss rather than damage.
function s.applylploss(c,tp)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE|PHASE_END)
    e1:SetCountLimit(1)
    e1:SetOperation(function(e,ep)
        Duel.SetLP(tp,math.max(0,Duel.GetLP(tp)-1000))
    end)
    Duel.RegisterEffect(e1,tp)
end

--A newly created Extra Deck monster may need an Extra Monster Zone
--(depending on the installed EDOPro/Rush Duel rules).
function s.haszone(tp,tc)
    if tc:IsLocation(LOCATION_EXTRA) then
        return Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0
    end
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    --Announce any monster in the installed card database except a Token.
    local code=Duel.AnnounceCard(tp,
        TYPE_MONSTER,OPCODE_ISTYPE,
        TYPE_TOKEN,OPCODE_ISTYPE,OPCODE_NOT,OPCODE_AND)
    if not code or code==0 then return end

    --Create a real copy of the announced card using its database passcode.
    local tc=Duel.CreateToken(tp,code)
    if not tc then return end

    --SendtoHand routes Extra Deck monsters to the Extra Deck in EDOPro.
    if Duel.SendtoHand(tc,tp,REASON_EFFECT)==0 then return end
    if not tc:IsLocation(LOCATION_HAND|LOCATION_EXTRA) then return end
    if tc:IsLocation(LOCATION_HAND) then
        Duel.ConfirmCards(1-tp,tc)
    end

    --Optional Special Summon of the exact newly created card.
    --nocheck/nolimit permit a custom Summon of otherwise restricted monsters.
    local summoned=nil
    if s.haszone(tp,tc)
        and tc:IsCanBeSpecialSummoned(e,0,tp,true,true,POS_FACEUP)
        and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.BreakEffect()
        if Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)>0 then
            summoned=tc
        end
    end

    --The restrictions and recurring LP loss apply even if the
    --player declines (or cannot perform) the optional Special Summon.
    s.applylock(c,tp,summoned)
    s.applylploss(c,tp)
end
