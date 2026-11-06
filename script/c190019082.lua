--Harbinger of Tyranny and Trickery
--Custom Rush Duel Fusion / Effect Monster
--Card ID: 190019082
--Fusion Materials: "Princess Cosmos the Trickster" + 4 Galaxy monsters with 900 ATK
local s,id=GetID()
local PRINCESS_COSMOS=160216046
local COSMOS_JEST=160017058

function s.initial_effect(c)
    --Fusion procedure
    c:EnableReviveLimit()
    Fusion.AddProcMixN(c,true,true,PRINCESS_COSMOS,1,s.matfilter,4)

    --[REQUIREMENT] During the turn this card was Special Summoned,
    --shuffle 1 "Jest of the Cosmos Princess" from your GY into the Deck.
    --[EFFECT] Destroy all cards your opponent controls.
    --This turn, you can attack with only 1 monster.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK|CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

s.named_material={PRINCESS_COSMOS}
s.listed_names={COSMOS_JEST}

function s.matfilter(c,scard,sumtype,tp)
    return c:IsRace(RACE_GALAXY,scard,sumtype,tp) and c:IsAttack(900)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsSummonPhaseMain() and c:IsStatus(STATUS_SPSUMMON_TURN)
end

function s.jestfilter(c)
    return c:IsCode(COSMOS_JEST) and c:IsAbleToDeckOrExtraAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.jestfilter),tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.jestfilter),tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0
    end
    local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end

    --Track the first monster to declare an attack this turn.
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(s.attacklimit)
    e1:SetReset(RESET_PHASE|PHASE_END)
    e1:SetLabel(0)
    Duel.RegisterEffect(e1,tp)

    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_ATTACK_ANNOUNCE)
    e2:SetOperation(s.recordattack)
    e2:SetLabelObject(e1)
    e2:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e2,tp)
end

function s.attacklimit(e,c)
    local fid=e:GetLabel()
    return fid~=0 and c:GetFieldID()~=fid
end

function s.recordattack(e,tp,eg,ep,ev,re,r,rp)
    local attacker=Duel.GetAttacker()
    local restriction=e:GetLabelObject()
    if attacker and attacker:IsControler(e:GetHandlerPlayer())
       and restriction:GetLabel()==0 then
        restriction:SetLabel(attacker:GetFieldID())
    end
end
