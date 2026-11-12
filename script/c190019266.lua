-- Timaeus X Legendary Dragon of the Cosmos
-- EDOPro Rush Duel custom card - ID 190019266
-- Fusion Materials: "Timaeus X" + "Timaeus X the Legendary Knight"
-- Compatibility fix: no external RD helper library is required.
local s,id=GetID()
local TIMAEUS_X=190019264
local LEGENDARY_KNIGHT=190019265
s.listed_names={TIMAEUS_X,LEGENDARY_KNIGHT}

function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,false,false,TIMAEUS_X,LEGENDARY_KNIGHT)

    -- [REQUIREMENT] During the Main Phase of the turn this card was
    -- Special Summoned, pay 800 LP.
    -- [EFFECT] Draw 1 card, then gain ATK based on cards in both GYs.
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DRAW+CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    -- Ignition effects are only usable during your Main Phase.
    -- The status is automatically cleared when that turn ends.
    return Duel.GetTurnPlayer()==tp
        and e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,800) end
    Duel.PayLPCost(tp,800)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.grave_monster(c)
    return c:IsType(TYPE_MONSTER)
        and c:IsRace(RACE_WARRIOR+RACE_DRAGON+RACE_SPELLCASTER)
end

function s.grave_spell(c)
    return c:IsType(TYPE_SPELL)
end

function s.timaeus_x(c)
    return c:IsCode(TIMAEUS_X)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local p,ct=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    if Duel.Draw(p,ct,REASON_EFFECT)==0 then return end

    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end

    -- 200 ATK per Warrior/Dragon/Spellcaster monster in either GY.
    local count=Duel.GetMatchingGroupCount(s.grave_monster,
        tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
    local gain=200*count

    -- If either GY contains "Timaeus X", also gain 100 ATK
    -- per Spell Card in either GY.
    if Duel.IsExistingMatchingCard(s.timaeus_x,
            tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) then
        local spells=Duel.GetMatchingGroupCount(s.grave_spell,
            tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
        gain=gain+100*spells
    end
    if gain<=0 then return end

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(gain)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e2)
end
