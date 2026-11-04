-- The Man Who Walks The Path Of Purple (Rush Duel)
-- Card ID: 190019007
local s,id=GetID()

function s.initial_effect(c)
    -- Effect: Name becomes Buster Blader & Fusion Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(id*16)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase()
end

-- Requirement: Send 1 card from your hand to the GY.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end

function s.filter2(c,e,tp,m,f,chkf)
    return c:IsType(TYPE_FUSION)
        and c:IsLevelAbove(8)
        and (not f or f(c))
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
        and c:CheckFusionMaterial(m,nil,chkf)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end

    -- This turn, this card's name becomes the Rush Duel Buster Blader.
    -- In the EDOPro Rush database that card is 160005000 and is aliased
    -- to the original Buster Blader name/passcode for named-material checks.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetValue(160005000)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)

    -- IMPORTANT: no forced material is supplied here.
    -- The player may choose the real Buster Blader from hand OR this card
    -- (after its name change), as long as the selected Fusion's procedure allows it.
    local chkf=tp
    local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsLocation,nil,LOCATION_HAND+LOCATION_MZONE)
    local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)

    local mg2=nil
    local sg2=nil
    local ce=Duel.GetChainMaterial(tp)
    if ce~=nil then
        local fgroup=ce:GetTarget()
        mg2=fgroup(ce,e,tp)
        local mf=ce:GetValue()
        sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
    end

    if sg1:GetCount()==0 and (sg2==nil or sg2:GetCount()==0) then return end
    if not Duel.SelectYesNo(tp,(id*16)+1) then return end

    local sg=sg1:Clone()
    if sg2~=nil then sg:Merge(sg2) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=sg:Select(tp,1,1,nil):GetFirst()
    if not tc then return end

    if sg1:IsContains(tc)
        and (sg2==nil or not sg2:IsContains(tc)
            or not Duel.SelectYesNo(tp,ce:GetDescription())) then
        -- nil = NO mandatory/forced Fusion Material.
        local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
        if not mat1 or #mat1==0 then return end
        tc:SetMaterial(mat1)
        Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
        Duel.BreakEffect()
        if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)>0 then
            tc:CompleteProcedure()
        end
    elseif ce then
        local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
        local fop=ce:GetOperation()
        fop(ce,e,tp,tc,mat2)
        tc:CompleteProcedure()
    end
end
