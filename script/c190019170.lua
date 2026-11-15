-- Perfect Ryu Force
-- Card ID: 190019170
-- Rush Duel Normal Spell
--
-- [REQUIREMENT] None.
-- [EFFECT] Send 1 face-up monster you control to the GY, then Fusion
-- Summon 1 Fusion Monster from your Extra Deck that could use that
-- monster as a Fusion Material. The sent monster counts as the
-- entire Fusion Material requirement.
--
-- Compatible with the Rush Duel "RD" Fusion library.
-- Named materials: read from the Fusion Monster's .material table.
-- Generic materials: on the Fusion Monster, define a
-- "perfect_ryu_force_filter" callback (see installation note).
-- This card intentionally bypasses the NORMAL material-count check,
-- not unrelated Special Summon restrictions.

local s,id=GetID()

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Does this face-up monster match at least one of the Fusion Monster's
-- material slots? (It will replace the ENTIRE requirement once chosen.)
function s.matches_material(fc,mat)
    -- RD.AddFusionProcedure stores specifically named materials here.
    local named=fc.material
    if type(named)=="table" then
        for code,listed in pairs(named) do
            if listed and type(code)=="number" and mat:IsFusionCode(code) then
                return true
            end
        end
    end

    -- Generic requirements cannot reliably be recovered from the
    -- Fusion procedure; compatible custom Fusions expose a predicate.
    local fn=fc.perfect_ryu_force_filter
    if type(fn)=="function" then
        return fn(mat,fc)==true
    end
    return false
end

-- The chosen material has to be usable, and leaving the field must
-- make room for the Fusion Monster (including Extra Deck zone rules).
function s.fusion_filter(fc,e,tp,mat)
    return fc:IsType(TYPE_FUSION)
        and mat:IsCanBeFusionMaterial(fc,SUMMON_TYPE_FUSION)
        and s.matches_material(fc,mat)
        and Duel.GetLocationCountFromEx(tp,tp,mat,fc)>0
        and fc:IsCanBeSpecialSummoned(
            e,SUMMON_TYPE_FUSION,tp,false,false,POS_FACEUP)
end

function s.material_filter(c,e,tp)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER)
        and c:IsAbleToGrave()
        and not c:IsImmuneToEffect(e)
        and Duel.IsExistingMatchingCard(
            s.fusion_filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.material_filter,tp,LOCATION_MZONE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- 1. Choose one FACE-UP monster on your field.
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local mg=Duel.SelectMatchingCard(
        tp,s.material_filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
    local mat=mg:GetFirst()
    if not mat then return end

    -- 2. Choose a Fusion that contains at least one matching material.
    local fg=Duel.GetMatchingGroup(
        s.fusion_filter,tp,LOCATION_EXTRA,0,nil,e,tp,mat)
    if #fg==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=fg:Select(tp,1,1,nil)
    local fc=sg:GetFirst()
    if not fc then return end

    -- 3. Record JUST this one monster as the complete Fusion material.
    fc:SetMaterial(Group.FromCards(mat))

    -- 4. Send that monster to the GY as Fusion Material by card effect.
    if Duel.SendtoGrave(mat,
        REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)==0
        or not mat:IsLocation(LOCATION_GRAVE) then
        return
    end

    -- 5. Perform an actual Fusion Summon from the Extra Deck.
    Duel.BreakEffect()
    if Duel.GetLocationCountFromEx(tp,tp,nil,fc)<=0 then return end
    if Duel.SpecialSummon(fc,SUMMON_TYPE_FUSION,
        tp,tp,false,false,POS_FACEUP)>0 then
        fc:CompleteProcedure()
    end
end
