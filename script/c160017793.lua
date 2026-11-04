-- OuTerverSe Majestic Ritual (Rush Duel)
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- ID linkage to Majesty of OuTerverSe
s.target_monster=160017792 

-- Strict Rush Duel Material rule: Cannot use more monsters than necessary to reach Level 11
function s.rescon(sg,e,tp,mg)
    local total_level=sg:GetSum(Card.GetLevel)
    if total_level<11 then return false end
    
    -- If removing any single monster keeps the total >= 11, excess materials are being used
    for tc in aux.Next(sg) do
        if total_level-tc:GetLevel()>=11 then return false end
    end
    return true
end

function s.spfilter(c,e,tp)
    return c:IsCode(s.target_monster) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        -- RUSH DUEL: Checked from the Extra Deck
        local tc=Duel.GetFirstMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
        if not tc then return false end
        local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
        return aux.SelectUnselectGroup(mg,e,tp,1,#mg,s.rescon,0)
    end
    -- RUSH DUEL: Target destination is the Extra Deck
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- RUSH DUEL: Pulled from the Extra Deck
    local tc=Duel.GetFirstMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
    if not tc then return end
    
    local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    local sg=aux.SelectUnselectGroup(mg,e,tp,1,#mg,s.rescon,1,tp,HINTMSG_TOGRAVEYARD)
    if #sg>0 then
        tc:SetMaterial(sg)
        local mat_count=#sg
        if Duel.SendtoGrave(sg,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)>0 then
            Duel.BreakEffect()
            -- RUSH DUEL: Special Summoning destination set to tp (Extra Deck logic)
            if Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)>0 then
                tc:CompleteProcedure()
                
                -- Additional effect if exactly 1 monster was sent to the GY
                if mat_count==1 then
                    local c=e:GetHandler()
                    
                    -- Cannot be destroyed by opponent's card effects
                    local e1=Effect.CreateEffect(c)
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
                    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
                    e1:SetValue(aux.indoval)
                    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                    tc:RegisterEffect(e1)
                    
                    -- Inflicts Piercing battle damage
                    local e2=Effect.CreateEffect(c)
                    e2:SetType(EFFECT_TYPE_SINGLE)
                    e2:SetCode(EFFECT_PIERCE)
                    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
                    tc:RegisterEffect(e2)
                end
            end
        end
    end
end
