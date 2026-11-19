-- Eight Handled Sword Divergent Sila Divine General Mahoraga
-- 190019173 | DARK Level 12 Fairy / Ritual / Effect | 4000 ATK / 3000 DEF
-- Written for Project Ignis / modern EDOPro Rush Duel (Extra Deck Rituals).
-- Counter ID must match the Ritual Spell c190019174.lua.
local s,id=GetID()
local COUNTER_ADAPTATION=0x0B73

function s.initial_effect(c)
    c:EnableReviveLimit()
    c:EnableCounterPermit(COUNTER_ADAPTATION)

    -- Opponent's effects that would return this Ritual Monster to the Deck /
    -- Extra Deck do not affect it.  Category-based check is used here so the
    -- protection only applies to opponent's card effects, not your own.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetValue(s.eximmval)
    c:RegisterEffect(e1)

    -- Opponent's card effects cannot change its battle position.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
    e2:SetValue(s.posval)
    c:RegisterEffect(e2)

    -- Cannot be destroyed by battle with a monster with less than 9999 ATK.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetValue(s.batindval)
    c:RegisterEffect(e3)

    -- Cannot be destroyed by the opponent's card effects.
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e4:SetValue(function(e,re,rp) return rp==1-e:GetHandlerPlayer() end)
    c:RegisterEffect(e4)

    -- 1 Adaptation Counter after each battle it survives.
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_BATTLED)
    e5:SetCondition(s.batcon)
    e5:SetOperation(s.addct)
    c:RegisterEffect(e5)

    -- 1 Adaptation Counter when an opponent's targeting effect resolves on it.
    -- NOTE: EDOPro has no universal 'effect was applied to this card' event;
    -- non-targeting effects are not generically detectable with this hook.
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCode(EVENT_CHAIN_SOLVED)
    e6:SetCondition(s.targetedcon)
    e6:SetOperation(s.addct)
    c:RegisterEffect(e6)

    -- +500 ATK for each Adaptation Counter, up to 3.
    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_SINGLE)
    e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e7:SetRange(LOCATION_MZONE)
    e7:SetCode(EFFECT_UPDATE_ATTACK)
    e7:SetValue(function(e) return e:GetHandler():GetCounter(COUNTER_ADAPTATION)*500 end)
    c:RegisterEffect(e7)

    -- 1+ Counter: Piercing battle damage.
    local e8=Effect.CreateEffect(c)
    e8:SetType(EFFECT_TYPE_SINGLE)
    e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e8:SetRange(LOCATION_MZONE)
    e8:SetCode(EFFECT_PIERCE)
    e8:SetCondition(s.piercecon)
    c:RegisterEffect(e8)

    -- 2+ Counters: up to two attacks against monsters per Battle Phase.
    local e9=Effect.CreateEffect(c)
    e9:SetType(EFFECT_TYPE_SINGLE)
    e9:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e9:SetRange(LOCATION_MZONE)
    e9:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
    e9:SetValue(s.extraatkval)
    c:RegisterEffect(e9)

    -- 3 Counters: Built-in Match Winner when a lethal direct attack occurs.
    -- The separate EVENT_BATTLE_DAMAGE trigger below implements the broader
    -- custom rule (any positive battle damage), winning the current Duel.
    local e10=Effect.CreateEffect(c)
    e10:SetType(EFFECT_TYPE_SINGLE)
    e10:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e10:SetRange(LOCATION_MZONE)
    e10:SetCode(EFFECT_MATCH_KILL)
    e10:SetCondition(s.matchcon)
    c:RegisterEffect(e10)

    -- 3 Counters: if this card inflicts ANY battle damage, win this Duel.
    -- EDOPro's standard engine cannot force MSG_MATCH_KILL for nonlethal or
    -- piercing battle damage, so the Match victory still needs a core hook.
    local e11=Effect.CreateEffect(c)
    e11:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e11:SetCode(EVENT_BATTLE_DAMAGE)
    e11:SetCondition(s.damagecon)
    e11:SetOperation(s.damageop)
    c:RegisterEffect(e11)

    -- Rush Duel main-phase effect (once per turn, only Ritual Summon turn).
    local e12=Effect.CreateEffect(c)
    e12:SetCategory(CATEGORY_POSITION+CATEGORY_DESTROY)
    e12:SetType(EFFECT_TYPE_IGNITION)
    e12:SetRange(LOCATION_MZONE)
    e12:SetCountLimit(1)
    e12:SetCondition(s.fieldcon)
    e12:SetTarget(s.fieldtg)
    e12:SetOperation(s.fieldop)
    c:RegisterEffect(e12)
end

function s.eximmval(e,re)
    return re and re:GetHandlerPlayer()~=e:GetHandlerPlayer()
        and re:IsHasCategory(CATEGORY_TODECK)
end

function s.posval(e,re)
    if re and re:GetHandlerPlayer()~=e:GetHandlerPlayer() then
        return POS_FACEUP+POS_FACEDOWN
    end
    return 0
end

function s.batindval(e,c)
    local self=e:GetHandler()
    local a=Duel.GetAttacker()
    local t=Duel.GetAttackTarget()
    local other=nil
    if a==self then other=t
    elseif t==self then other=a end
    return other~=nil and other:GetAttack()<9999
end

function s.addct(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
        and c:GetCounter(COUNTER_ADAPTATION)<3 then
        c:AddCounter(COUNTER_ADAPTATION,1)
    end
end

function s.batcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
        and (Duel.GetAttacker()==c or Duel.GetAttackTarget()==c)
        and c:GetCounter(COUNTER_ADAPTATION)<3
end

function s.targetedcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not re or rp~=1-tp or not c:IsFaceup()
        or c:GetCounter(COUNTER_ADAPTATION)>=3 then return false end
    local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
    return tg~=nil and tg:IsContains(c)
end

function s.piercecon(e)
    return e:GetHandler():GetCounter(COUNTER_ADAPTATION)>=1
end

function s.extraatkval(e)
    return e:GetHandler():GetCounter(COUNTER_ADAPTATION)>=2 and 1 or 0
end

function s.matchcon(e)
    return e:GetHandler():GetCounter(COUNTER_ADAPTATION)>=3
end

function s.damagecon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
        and c:GetCounter(COUNTER_ADAPTATION)>=3
        and ep==1-tp and ev>0
end

function s.damageop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Win(tp,id)
end

function s.fieldcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_RITUAL)
        and c:IsStatus(STATUS_SPSUMMON_TURN)
end

function s.fieldtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,0,1-tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,1-tp,LOCATION_ONFIELD)
end

function s.posfilter(c)
    return c:IsFaceup() and c:IsCanChangePosition()
end

function s.fieldop(e,tp,eg,ep,ev,re,r,rp)
    -- Choosing 0 targets is legal ('up to 2').
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
    local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,0,LOCATION_MZONE,0,2,nil)
    for tc in g:Iter() do
        if tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) then
            if tc:IsAttackPos() then
                Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
            elseif tc:IsDefensePos() then
                Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
            end
        end
    end
    -- All cards on the opponent's field are destroyed, even if no positions
    -- were changed (as specified by the currently agreed card text).
    local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
    if #dg>0 then Duel.Destroy(dg,REASON_EFFECT) end
end
