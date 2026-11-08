--Tides Servitor Argonaught
--Rush Duel - Custom Card
--Card ID: 190019406
local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    --Fusion Materials: 2 WATER Cyberse monsters
    Fusion.AddProcFunRep(c,s.matfilter,2,true)
    --Contact Fusion: shuffle the 2 materials from your field into the Deck
    Fusion.AddContactProc(c,s.contactfilter,s.contactop,nil,nil,SUMMON_TYPE_FUSION,nil,false)

    --Record that this card was Special Summoned during your Main Phase
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_SPSUMMON_SUCCESS)
    e0:SetOperation(s.regop)
    c:RegisterEffect(e0)

    --[REQUIREMENT] Special Summoned this Main Phase; 3+ WATER Cyberse in your GY
    --[EFFECT] Opponent cannot activate cards from their Spell/Trap Zones
    --         this turn; this card gains 2000 ATK until the End Phase.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.matfilter(c,fc,sumtype,tp)
    return c:IsMonster() and c:IsAttribute(ATTRIBUTE_WATER)
        and c:IsRace(RACE_CYBERSE)
end

function s.contactfilter(tp)
    return Duel.GetMatchingGroup(s.contactmat,tp,LOCATION_MZONE,0,nil)
end

function s.contactmat(c)
    return c:IsFaceup() and c:IsMonster()
        and c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_CYBERSE)
        and c:IsAbleToDeckOrExtraAsCost()
end

function s.contactop(g,tp,c)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST|REASON_MATERIAL|REASON_FUSION)
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_MAIN1 then
        e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
    end
end

function s.gyfilter(c)
    return c:IsMonster() and c:IsAttribute(ATTRIBUTE_WATER)
        and c:IsRace(RACE_CYBERSE)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCurrentPhase()==PHASE_MAIN1
        and e:GetHandler():GetFlagEffect(id)>0
        and Duel.GetMatchingGroupCount(s.gyfilter,tp,LOCATION_GRAVE,0,nil)>=3
end

--Block the activation of Spell/Trap cards already in the opponent's S/T Zones
function s.aclimit(e,re,tp)
    return re:IsHasType(EFFECT_TYPE_ACTIVATE)
        and re:GetActivateLocation()==LOCATION_SZONE
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    --Lingering restriction: lasts for the remainder of the turn
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetTargetRange(0,1)
    e1:SetValue(s.aclimit)
    e1:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e1,tp)

    --2000 ATK until the end of this turn
    if c:IsFaceup() and c:IsRelateToEffect(e) then
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_UPDATE_ATTACK)
        e2:SetValue(2000)
        e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
        c:RegisterEffect(e2)
    end
end
