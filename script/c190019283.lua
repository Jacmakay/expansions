-- Liberator Versailles
-- Custom EDOPro Rush Duel monster
-- Card ID: 190019283
-- Level 8 / DARK / Reptile / Effect / ATK 3000 / DEF 0
--
-- You can Tribute Summon this card by Tributing exactly 1 Reptile monster.
-- [REQUIREMENT] Shuffle 1 Reptile monster from your GY into your Deck.
-- [EFFECT] Choose 1 face-up monster your opponent controls;
-- that monster loses 2000 ATK.

local s,id=GetID()

function s.initial_effect(c)
    -- Alternative one-Reptile Tribute Summon (the usual 2-Tribute
    -- Summon option remains available).
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_SUMMON_PROC)
    e1:SetCondition(s.otcon)
    e1:SetOperation(s.otop)
    e1:SetValue(SUMMON_TYPE_TRIBUTE)
    c:RegisterEffect(e1)

    -- Rush Duel monster effect (once per turn for this face-up copy).
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_ATKCHANGE|CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.cost)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end

-- Exactly 1 Reptile monster is used for this alternative Tribute Summon.
function s.relfilter(c)
    return c:IsMonster() and c:IsRace(RACE_REPTILE)
end
function s.otcon(e,c,minc)
    if c==nil then return true end
    local mg=Duel.GetTributeGroup(c):Filter(s.relfilter,nil)
    return (minc or 0)<=1 and Duel.CheckTribute(c,1,1,mg)
end
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
    local mg=Duel.GetTributeGroup(c):Filter(s.relfilter,nil)
    local sg=Duel.SelectTribute(tp,c,1,1,mg)
    c:SetMaterial(sg)
    Duel.Release(sg,REASON_SUMMON|REASON_MATERIAL)
end

-- Shuffle a Reptile monster from your GY as the activation requirement.
function s.costfilter(c)
    return c:IsMonster() and c:IsRace(RACE_REPTILE)
        and c:IsAbleToDeckAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.costfilter,tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(
        tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
    end
end

-- Only face-up opposing monsters have a current ATK to reduce.
function s.atkfilter(c)
    return c:IsFaceup() and c:IsMonster()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.atkfilter,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,1-tp,-2000)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectMatchingCard(
        tp,s.atkfilter,tp,0,LOCATION_MZONE,1,1,nil)
    local tc=g:GetFirst()
    if not tc then return end
    Duel.HintSelection(g)

    -- No end-of-turn reset is specified on the card. The reduction
    -- persists while this monster remains in its current face-up state.
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(-2000)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD)
    tc:RegisterEffect(e1)
end
