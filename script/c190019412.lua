--Infinity Seed
--Card ID: 190019412
--Rush Duel
local s,id=GetID()

function s.initial_effect(c)
    --Continuous Effect: Cannot be destroyed by battle with
    --a monster that has 3000 or less ATK.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(s.indval)
    c:RegisterEffect(e1)

    --Continuous Effect: You take no battle damage
    --from battles involving this card.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e2:SetValue(1)
    c:RegisterEffect(e2)
end

function s.indval(e)
    local bc=e:GetHandler():GetBattleTarget()
    return bc~=nil and bc:GetAttack()<=3000
end
