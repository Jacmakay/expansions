-- Getsuga Jujisho (190019109) -- Normal Spell
-- Activates with True Shikai, ORIGINAL Twin Realms Fusion or True Bankai.
local s,id=GetID()
local TRUE_SHIKAI=190019102
local ORIGINAL_FUSION=190019106
local TRUE_BANKAI=190019112
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE+CATEGORY_DECKDES)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
function s.fieldfilter(c)
    return c:IsFaceup() and c:IsCode(TRUE_SHIKAI,ORIGINAL_FUSION,TRUE_BANKAI)
end
function s.monfilter(c) return c:IsMonster() and c:IsDestructable() end
function s.stfilter(c) return c:IsSpellTrap() and c:IsDestructable() end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=2
            and Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_MZONE,0,1,nil)
    end
    Duel.DisableShuffleCheck()
    Duel.SendtoGrave(Duel.GetDecktopGroup(tp,2),REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.monfilter,tp,0,LOCATION_MZONE,1,nil)
            and Duel.IsExistingMatchingCard(s.stfilter,tp,0,LOCATION_SZONE,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,1-tp,LOCATION_ONFIELD)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local mg=Duel.GetMatchingGroup(s.monfilter,tp,0,LOCATION_MZONE,nil)
    local sg=Duel.GetMatchingGroup(s.stfilter,tp,0,LOCATION_SZONE,nil)
    if #mg==0 or #sg==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local m=mg:Select(tp,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local st=sg:Select(tp,1,1,nil)
    m:Merge(st)
    local ct=Duel.Destroy(m,REASON_EFFECT)
    if ct>0 then
        local bg=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:IsCode(TRUE_BANKAI) end,tp,LOCATION_MZONE,0,nil)
        for bc in bg:Iter() do
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_UPDATE_ATTACK)
            e2:SetValue(500*ct)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            bc:RegisterEffect(e2)
        end
    end
end
