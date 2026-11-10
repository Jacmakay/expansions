-- Enjin the Final Flame of Time
-- Rush Duel / EDOPro (Project Ignis)
-- 190019246 is assumed to be the card ID of "Spirit of Enjin".
-- 190019252 is the card ID of "Enjin the Final Flame of Time".
-- Script filename: c190019252.lua.
local s,id=GetID()
local SPIRIT_OF_ENJIN=190019246

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Fusion materials: "Spirit of Enjin" + 4 Maximum monsters.
    Fusion.AddProcMixN(c,false,false,SPIRIT_OF_ENJIN,1,s.maxfilter,4)
    -- Alternate: 1 Maximum monster in Maximum Mode counts as all 4.
    -- Only the center is selected: Maximum Mode side pieces cannot
    -- normally be used as Fusion Material in EDOPro's Rush scripts.
    Fusion.AddProcMix(c,false,false,SPIRIT_OF_ENJIN,s.maxmodefilter)

    -- Remember whether a Maximum Mode center was used as material.
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_MATERIAL_CHECK)
    e0:SetValue(s.matcheck)
    e0:SetLabel(0)
    c:RegisterEffect(e0)

    -- Protect the controller from losing due to 0 LP only while this
    -- monster is face-up in the Monster Zone. This is continuously checked
    -- and stops applying if Enjin is flipped face-down or leaves the field.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_LOSE_LP)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.lpcon)
    e1:SetTargetRange(1,0)
    c:RegisterEffect(e1)

    -- [Requirement] Set your LP to 0.
    -- [Effect] Destroy all other cards; summon 3 from opponent's GY.
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY|CATEGORY_SPECIAL_SUMMON|CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.cost)
    e2:SetLabelObject(e0)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)

    -- Each monster this card destroys by battle: recover 1000 LP.
    -- Use the standard battle-destroying check to avoid relying on a
    -- battle-target status that may have been cleared by this event.
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_RECOVER)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_BATTLE_DESTROYING)
    e3:SetCondition(aux.bdcon)
    e3:SetTarget(s.rectg)
    e3:SetOperation(s.recop)
    c:RegisterEffect(e3)
end

s.listed_names={SPIRIT_OF_ENJIN}

function s.maxfilter(c)
    return c:IsType(TYPE_MAXIMUM) and not c:IsMaximumModeSide()
end

function s.maxmodefilter(c)
    return c:IsType(TYPE_MAXIMUM) and c:IsMaximumModeCenter()
end

function s.wasmaxmaterial(c)
    return c:IsMaximumModeCenter() or c:WasMaximumModeCenter()
end

function s.matcheck(e,c)
    local mg=c:GetMaterial()
    e:SetLabel(mg and mg:IsExists(s.wasmaxmaterial,1,nil) and 1 or 0)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLP(tp)>0 end
    Duel.SetLP(tp,0) -- Not a normal LP payment: full LP payments are illegal.
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
    g:RemoveCard(e:GetHandler())
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,1-tp,LOCATION_GRAVE)
end

function s.spfilter(c,e,tp)
    return c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK,1-tp)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end

    local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
    g:RemoveCard(c)
    if #g==0 or Duel.Destroy(g,REASON_EFFECT)==0 then return end
    Duel.BreakEffect()

    -- The Rush field has 3 monster zones per player, so the revived
    -- opponents' monsters are placed on their owner's field.
    if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<3 then return end
    local sg=Duel.GetMatchingGroup(s.spfilter,tp,0,LOCATION_GRAVE,nil,e,tp)
    if #sg<3 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    sg=sg:Select(tp,3,3,nil)
    if #sg~=3 then return end
    local ct=Duel.SpecialSummon(sg,0,tp,1-tp,false,false,POS_FACEUP_ATTACK)
    if ct==0 then return end

    -- Set ATK to 0 only if Maximum Mode was used as Fusion Material.
    if e:GetLabelObject():GetLabel()==0 then return end
    for tc in aux.Next(sg) do
        if tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) and tc:IsControler(1-tp) then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_ATTACK_FINAL)
            e1:SetValue(0)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD)
            tc:RegisterEffect(e1)
        end
    end
end

-- EFFECT_CANNOT_LOSE_LP (unlike a permanent player flag) is active only
-- while this source effect is available.  No effect is registered on the
-- player, so it disappears as soon as Enjin is no longer face-up.
function s.lpcon(e)
    local c=e:GetHandler()
    return c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
end

function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end

function s.recop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Recover(tp,1000,REASON_EFFECT)
end
