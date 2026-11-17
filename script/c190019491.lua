-- Terminus Limitless Resurrection | 190019491
-- Normal Spell
-- [REQUIREMENT] Shuffle 1 Spell and 1 Monster from your GY into your Deck.
-- [EFFECT] Special Summon "Gojo Reformed Agent of Terminus" (190019172)
-- from your GY. It gains 9999 ATK and neither player takes battle damage
-- from battles involving that summoned monster.
local s,id=GetID()
local GOJO=190019172
s.listed_names={GOJO}
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCategory(CATEGORY_TODECK|CATEGORY_SPECIAL_SUMMON|CATEGORY_ATKCHANGE)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end
function s.spellfilter(c)
    return c:IsSpell() and c:IsAbleToDeckOrExtraAsCost()
end
function s.monsterfilter(c,onegojo)
    return c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
        and (not onegojo or not c:IsCode(GOJO))
end
function s.gojofilter(c,e,tp)
    return c:IsCode(GOJO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local count=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,GOJO)
    local onegojo=count<=1
    if chk==0 then
        return count>0
            and Duel.IsExistingMatchingCard(s.spellfilter,tp,LOCATION_GRAVE,0,1,nil)
            and Duel.IsExistingMatchingCard(s.monsterfilter,tp,LOCATION_GRAVE,0,1,nil,onegojo)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local sg=Duel.SelectMatchingCard(tp,s.spellfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local mg=Duel.SelectMatchingCard(tp,s.monsterfilter,tp,LOCATION_GRAVE,0,1,1,nil,onegojo)
    sg:Merge(mg)
    Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.gojofilter),tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.damagecon(e)
    local c=e:GetHandler()
    return Duel.GetAttacker()==c or Duel.GetAttackTarget()==c
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local f=aux.NecroValleyFilter(s.gojofilter)
    if not Duel.IsExistingMatchingCard(f,tp,LOCATION_GRAVE,0,1,nil,e,tp) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,f,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if not tc or Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)==0 then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(9999)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD)
    tc:RegisterEffect(e1)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(1,1)
    e2:SetCondition(s.damagecon)
    tc:RegisterEffect(e2)
end
