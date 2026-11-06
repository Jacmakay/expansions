-- Wota Zero Mode Destruction
-- Custom Rush Duel monster
-- Card ID: 190019068
-- Level 8 / DARK / Machine / Effect / ATK 3000 / DEF 0
-- [REQUIREMENT] Destroy 1 other card on your field.
-- [EFFECT] Destroy up to 2 opponent's monsters with ATK <= this card's ATK,
-- then you can Special Summon 1 Level 4 or lower Cyborg or Machine monster from your GY.

local s,id=GetID()

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY|CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- Any other card you control can fulfill the requirement.
function s.reqfilter(c)
    return c:IsDestructable()
end

-- Rush Duel requirements are checked on activation, then performed
-- at the beginning of the effect's operation.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.reqfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
    end
end

-- Only face-up opposing monsters have a currently known ATK.
function s.desfilter(c,atk)
    return c:IsFaceup() and c:IsMonster() and not c:IsMaximumModeSide()
        and c:GetAttack()<=atk and c:IsDestructable()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,1-tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spfilter(c,e,tp)
    return c:IsMonster() and c:IsLevelBelow(4)
        and c:IsRace(RACE_CYBORG|RACE_MACHINE)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    -- REQUIREMENT: Destroy exactly 1 other card on your field.
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local rg=Duel.SelectMatchingCard(tp,s.reqfilter,tp,LOCATION_ONFIELD,0,1,1,c)
    if #rg==0 or Duel.Destroy(rg,REASON_COST)==0 then return end

    -- EFFECT: Choose and destroy 1 or 2 eligible opposing monsters.
    if not c:IsFaceup() or not c:IsLocation(LOCATION_MZONE) then return end
    local atk=c:GetAttack()
    local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,atk)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local sg=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_MZONE,1,math.min(2,#g),nil,atk)
    if #sg==0 then return end
    Duel.HintSelection(sg)
    if Duel.Destroy(sg,REASON_EFFECT)==0 then return end

    -- THEN YOU CAN: Special Summon 1 Level 4 or lower Cyborg/Machine.
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local f=aux.NecroValleyFilter(s.spfilter)
    if not Duel.IsExistingMatchingCard(f,tp,LOCATION_GRAVE,0,1,nil,e,tp) then return end
    if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local spg=Duel.SelectMatchingCard(tp,f,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #spg>0 then
        Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP)
    end
end
