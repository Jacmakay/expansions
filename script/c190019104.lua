-- White Zangetsu - The True Blade (190019104)
-- DARK / Warrior / Level 7 / 2300 ATK / 1800 DEF
local s,id=GetID()
local TRUE_SHIKAI=190019102
local TRUE_BANKAI=190019112
function s.initial_effect(c)
    -- Special Summon from HAND ONLY while you control face-up True Shikai.
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_HAND)
    e0:SetCondition(s.spcon)
    c:RegisterEffect(e0)
    -- Recycle a Warrior, +500 ATK this turn; optionally count as Level 12
    -- Ritual Material for the Ritual Summon of TRUE BANKAI this turn.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end
function s.shikaifilter(c)
    return c:IsFaceup() and c:IsCode(TRUE_SHIKAI)
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.shikaifilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.costfilter(c)
    return c:IsMonster() and c:IsRace(RACE_WARRIOR) and c:IsAbleToDeckAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.ritlev(e,rc)
    -- Only the specified Level 12 Ritual Monster gets the level substitution.
    if rc and rc:IsCode(TRUE_BANKAI) then return 12 end
    return e:GetHandler():GetLevel()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(500)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)
    if Duel.IsExistingMatchingCard(s.shikaifilter,tp,LOCATION_MZONE,0,1,nil) then
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_RITUAL_LEVEL)
        e2:SetValue(s.ritlev)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e2)
    end
end
