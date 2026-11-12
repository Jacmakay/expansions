--The Luminescent One
--Custom EDOPro Rush Duel card - 190019288
--Fusion target: Nozett The Ultimate Soul (190019289)
local s,id=GetID()
local ULTIMATE_SOUL=190019289

function s.initial_effect(c)
    -- The named Fusion recipe for 190019289 supplies its material requirements.

    --[REQUIREMENT] Send 1 Level 10 monster from your hand to the GY.
    --[EFFECT] Draw 1 card, then Fusion Summon "Nozett The Ultimate Soul"
    --using this face-up monster and exactly 1 other monster from hand/field.
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1) -- Rush Duel activation
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.costfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsLevel(10)
        and c:IsAbleToGraveAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.fusfilter(c)
    return c:IsCode(ULTIMATE_SOUL) and c:IsType(TYPE_FUSION)
end

-- Fusion materials may be this face-up card and one other from hand/field.
function s.matfilter(c,e,tp,chk)
    return c:IsType(TYPE_MONSTER)
        and c:IsAbleToGrave()
        and (c:IsLocation(LOCATION_HAND)
            or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup()))
end

function s.mandatory(e,tp,eg,ep,ev,re,r,rp,chk)
    return e:GetHandler()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
    local hc=e:GetHandler()
    if not hc:IsRelateToEffect(e) or not hc:IsFaceup()
        or not hc:IsLocation(LOCATION_MZONE) then return end
    -- One drawn monster may be used as the second Fusion material.
    if s.fusion_tg(e,tp,eg,ep,ev,re,r,rp,0) then
        s.fusion_op(e,tp,eg,ep,ev,re,r,rp)
    end
end

s.fusion_tg=Fusion.SummonEffTG(s.fusfilter,s.matfilter,nil,nil,s.mandatory,nil,2)
s.fusion_op=Fusion.SummonEffOP(s.fusfilter,s.matfilter,nil,nil,s.mandatory,nil,2)
