-- Transam Diskarma Linac (Rush Duel)
-- Note: Ensure your cards.cdb entry matches:
-- Attribute = LIGHT (1), Race = GALAXY (0x4000000), Level = 11, ATK = 3000, DEF = 1600
local s,id=GetID()
function s.initial_effect(c)
    -- Must set Revive Limit for Ritual Monsters
    c:EnableReviveLimit()
    
    -- [REQUIREMENT] During the turn it was Ritual Summoned, send top card of Deck to GY.
    -- [EFFECT] Opponent's face-up monsters lose ATK / Gains multi-attacks.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
    
    -- Global listener to log the precise material card count upon its summon
    if not s.global_check then
        s.global_check=true
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
        ge1:SetOperation(s.regop)
        Duel.RegisterEffect(ge1,0)
    end
end

-- Tracks and flags the number of material monsters utilized
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local c=eg:GetFirst()
    if c and c:IsSummonType(SUMMON_TYPE_RITUAL) then
        local mg=c:GetMaterial()
        local mat_count=#mg
        if mat_count>0 then
            c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,mat_count)
        end
    end
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
    Duel.DiscardDeck(tp,1,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Retrieve the stored material count
    local mat_count=c:GetFlagEffectLabel(id) or 0
    if mat_count==0 then return end

    -- [EFFECT] Opponent's monsters lose [materials x 1000] ATK
    local tg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    if #tg>0 then
        for tc in aux.Next(tg) do
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(-mat_count * 1000)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
        end
    end

    -- This card can attack monsters equal to the number of materials
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
        e2:SetValue(mat_count-1) 
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e2)
    end
end
