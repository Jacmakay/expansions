-- Maximum Violet Paladin
local s,id=GetID()

function s.initial_effect(c)
    -- "Buster Blader" + 1 Level 8 or lower Dragon monster
    c:EnableReviveLimit()

    -- Named material instead of a custom IsCode filter.
    -- EDOPro's Fusion helper uses IsSummonCode here, which supports the
    -- Rush Buster Blader alias/name-change behavior and also populates
    -- c.material for Elemental HERO Prisma (Rush).
    Fusion.AddProcMix(c,true,true,78193831,s.dragonfilter)

    -- During the turn this card was Fusion Summoned:
    -- Destroy 1 opponent's monster, then gain its ATK until End Phase.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.descon)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)
end

function s.dragonfilter(c,fc,sumtype,tp)
    return c:IsRace(RACE_DRAGON)
        and c:HasLevel()
        and c:GetLevel()<=8
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_FUSION)
        and c:IsStatus(STATUS_SPSUMMON_TURN)
end

function s.desfilter(c)
    return c:IsMonster() and c:IsDestructable()
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    local atk=tc:GetAttack()
    if atk<0 then atk=0 end

    if Duel.Destroy(tc,REASON_EFFECT)>0
        and c:IsFaceup()
        and c:IsRelateToEffect(e)
        and atk>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(atk)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    end
end
