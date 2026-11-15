-- Harbinger of Tides - Heart of Eternal Terminus
-- CARD ID 190019409
-- Level 12 / WATER / Cyberse / Fusion / Effect / ATK 5500 / DEF 4000
-- Materials: "Harbinger of Tides Heart of Terminus" + 2 WATER Cyberse monsters
-- Test implementation: simulates a forced clash with effect damage/destruction.
local s,id=GetID()
local HEART=190019410
s.listed_names={HEART}

function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Exactly 1 named Heart plus 2 OTHER WATER Cyberse monsters.
    Fusion.AddProcMix(c,false,true,HEART,s.matfilter,s.matfilter)
    -- Contact Fusion using 3 face-up monsters, returning them to Deck/Extra Deck.
    Fusion.AddContactProc(c,s.contactgroup,s.contactop,nil,nil,SUMMON_TYPE_FUSION)

    -- Remember Special Summon during our Main Phase.
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_SPSUMMON_SUCCESS)
    e0:SetOperation(s.recordsummon)
    c:RegisterEffect(e0)

    -- Once per turn, on the turn this monster was Special Summoned:
    -- Shuffle 5 cards from GY into Deck; make 2 opposing monsters clash.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY|CATEGORY_DAMAGE|CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.clashcondition)
    e1:SetCost(s.clashcost)
    e1:SetTarget(s.clashtarget)
    e1:SetOperation(s.clashoperation)
    c:RegisterEffect(e1)

    -- Opponent's Level 11 or lower monsters cannot be Special Summoned in attack position.
    -- Uses position forcing, so defense-position summons remain legal.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0,1)
    e2:SetTarget(s.positionfilter)
    e2:SetValue(POS_DEFENSE)
    c:RegisterEffect(e2)

    -- Cannot be destroyed by battle with Level 11 or lower monsters.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetValue(s.battleprotect)
    c:RegisterEffect(e3)

    -- Cannot be returned to hand/Deck/Extra Deck by an opponent's card effect.
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_CANNOT_TO_DECK)
    e4:SetValue(1)
    c:RegisterEffect(e4)
    local e5=e4:Clone()
    e5:SetCode(EFFECT_CANNOT_TO_HAND)
    c:RegisterEffect(e5)
end

function s.matfilter(c,fc,sumtype,tp)
    return c:IsMonster() and c:IsAttribute(ATTRIBUTE_WATER)
        and c:IsRace(RACE_CYBERSE) and not c:IsCode(HEART)
end
function s.contactmat(c)
    return c:IsFaceup() and c:IsAbleToDeckOrExtraAsCost()
        and (c:IsCode(HEART) or s.matfilter(c))
end
function s.contactgroup(tp)
    return Duel.GetMatchingGroup(s.contactmat,tp,LOCATION_MZONE,0,nil)
end
function s.contactop(g,tp,c)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST|REASON_MATERIAL|REASON_FUSION)
end

function s.recordsummon(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_MAIN1 then
        e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
    end
end
function s.clashcondition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCurrentPhase()==PHASE_MAIN1 and e:GetHandler():GetFlagEffect(id)>0
end
function s.recyclefilter(c)
    return c:IsAbleToDeckAsCost()
end
function s.clashcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.recyclefilter,tp,LOCATION_GRAVE,0,5,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.recyclefilter,tp,LOCATION_GRAVE,0,5,5,nil)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.clashfilter(c)
    return c:IsFaceup() and c:IsAttackPos() and c:IsMonster() and c:GetAttack()>=0
end
function s.clashtarget(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.clashfilter,tp,0,LOCATION_MZONE,2,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.clashoperation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.clashfilter,tp,0,LOCATION_MZONE,nil)
    if #g<2 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local sg=g:Select(tp,2,2,nil)
    local a=sg:GetFirst()
    local b=sg:GetNext()
    if not a or not b then return end
    local aa=math.max(0,a:GetAttack())
    local ba=math.max(0,b:GetAttack())
    local difference=math.abs(aa-ba)
    local destroyed=0
    -- This is EFFECT destruction, not real battle destruction.
    if aa>ba then
        destroyed=Duel.Destroy(b,REASON_EFFECT)
    elseif ba>aa then
        destroyed=Duel.Destroy(a,REASON_EFFECT)
    else
        destroyed=Duel.Destroy(sg,REASON_EFFECT)
    end
    -- Custom ruling: opponent takes the difference as EFFECT damage.
    if difference>0 then Duel.Damage(1-tp,difference,REASON_EFFECT) end
    if destroyed>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
        local boost=Effect.CreateEffect(c)
        boost:SetType(EFFECT_TYPE_SINGLE)
        boost:SetCode(EFFECT_UPDATE_ATTACK)
        boost:SetValue(500*destroyed)
        boost:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
        c:RegisterEffect(boost)
    end
end
function s.positionfilter(e,c,sump,sumtype,sumpos,targetp,se)
    return c:IsMonster() and c:HasLevel() and c:IsLevelBelow(11)
end
function s.battleprotect(e)
    local other=e:GetHandler():GetBattleTarget()
    return other~=nil and other:HasLevel() and other:IsLevelBelow(11)
end
