-- Tides Servitor Bubble Reef
-- Card ID: 190019407
-- Rush Duel / WATER Cyberse Fusion Effect Monster
-- Fusion Materials: 2 WATER Cyberse monsters
-- Updated: use supported Project Ignis Fusion functions instead of undefined RD helpers.

local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Fusion Summon with 2 WATER Cyberse monsters.
    Fusion.AddProcFunRep(c,s.matfilter,2,true)
    -- Contact Fusion: shuffle the 2 face-up materials you control into the Deck.
    Fusion.AddContactProc(c,s.contactfilter,s.contactop,nil,nil,SUMMON_TYPE_FUSION)

    -- Remember if this monster was Special Summoned during your Main Phase.
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_SPSUMMON_SUCCESS)
    e0:SetOperation(s.regop)
    c:RegisterEffect(e0)

    -- [REQUIREMENT] During the Main Phase this card was Special Summoned,
    -- if you have at least 3 WATER Cyberse monsters in your GY.
    -- [EFFECT] Draw 1 card. You can then change the battle position of
    -- 1 opponent's monster. This card gains 2000 ATK until the End Phase.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DRAW|CATEGORY_POSITION|CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.matfilter(c,fc,sumtype,tp)
    return c:IsMonster() and c:IsRace(RACE_CYBERSE)
        and c:IsAttribute(ATTRIBUTE_WATER)
end

function s.contactfilter(tp)
    return Duel.GetMatchingGroup(s.contactmat,tp,LOCATION_MZONE,0,nil)
end

function s.contactmat(c)
    return c:IsFaceup() and s.matfilter(c)
        and c:IsAbleToDeckOrExtraAsCost()
end

function s.contactop(g,tp,c)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST|REASON_MATERIAL|REASON_FUSION)
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_MAIN1 then
        e:GetHandler():RegisterFlagEffect(id,
            RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
    end
end

function s.gyfilter(c)
    return c:IsMonster() and c:IsRace(RACE_CYBERSE)
        and c:IsAttribute(ATTRIBUTE_WATER)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCurrentPhase()==PHASE_MAIN1
        and e:GetHandler():GetFlagEffect(id)>0
        and Duel.GetMatchingGroupCount(s.gyfilter,tp,LOCATION_GRAVE,0,nil)>=3
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,LOCATION_DECK)
end

function s.posfilter(c)
    return c:IsMonster() and c:IsCanChangePosition()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- Draw first.
    if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end

    -- Changing an opponent's monster's battle position is optional.
    local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
    if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
        local tc=g:Select(tp,1,1,nil):GetFirst()
        if tc then
            local pos=tc:IsAttackPos() and POS_FACEUP_DEFENSE or POS_FACEUP_ATTACK
            Duel.ChangePosition(tc,pos)
        end
    end

    -- Gain 2000 ATK even if the position change was declined.
    local c=e:GetHandler()
    if c:IsFaceup() and c:IsRelateToEffect(e) then
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_UPDATE_ATTACK)
        e2:SetValue(2000)
        e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
        c:RegisterEffect(e2)
    end
end
