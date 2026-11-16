-- True Bankai Blood Chained Ichigo (190019115)
-- DARK / Warrior / Level 12 / Fusion / 4500 ATK / 3500 DEF
-- Contact Fusion: True Shikai + Old Man Zangetsu + White Zangetsu.
local s,id=GetID()
local TRUE_SHIKAI=190019102
local OLD_MAN=190019103
local WHITE=190019104
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,false,true,TRUE_SHIKAI,OLD_MAN,WHITE)
    Fusion.AddContactProc(c,s.contactmat,s.contactop,nil,nil,SUMMON_TYPE_FUSION)
    -- Continuous: cannot be destroyed by opponent's card effects.
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e0:SetValue(s.indval)
    c:RegisterEffect(e0)
    -- First time each turn that this monster would be destroyed by battle,
    -- it is not destroyed.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    e1:SetCountLimit(1)
    e1:SetValue(s.indct)
    c:RegisterEffect(e1)
    -- Shuffle 2 Warrior monsters from GY; chain-bind up to 2 monsters;
    -- gain 500 ATK for each chosen monster and attack monsters up to 3 times.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.cost)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end
function s.contactmat(tp)
    return Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
end
function s.contactop(g,tp,c)
    c:SetMaterial(g)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_MATERIAL+REASON_FUSION)
end
function s.indval(e,re,rp)
    return rp~=e:GetHandlerPlayer()
end
function s.indct(e,re,r,rp)
    return (r&REASON_BATTLE)~=0
end
function s.costfilter(c)
    return c:IsMonster() and c:IsRace(RACE_WARRIOR) and c:IsAbleToDeckAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,2,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,2,2,nil)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.bindfilter(c)
    return c:IsFaceup()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.bindfilter,tp,0,LOCATION_MZONE,nil)
    local ct=0
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local sg=g:Select(tp,1,math.min(2,#g),nil)
        ct=#sg
        for tc in sg:Iter() do
            -- Restrictions stay through the opponent's next End Phase.
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CANNOT_ATTACK)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
            tc:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
            tc:RegisterEffect(e2)
        end
    end
    if c:IsFaceup() and c:IsRelateToEffect(e) then
        if ct>0 then
            local e3=Effect.CreateEffect(c)
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_UPDATE_ATTACK)
            e3:SetValue(500*ct)
            e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            c:RegisterEffect(e3)
        end
        -- Up to three attacks against monsters (two additional attacks).
        local e4=Effect.CreateEffect(c)
        e4:SetType(EFFECT_TYPE_SINGLE)
        e4:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
        e4:SetValue(2)
        e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e4)
    end
end
