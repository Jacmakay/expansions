-- Endless Darkness Sage with Eyes of Purple
-- Custom EDOPro Rush Duel script - Card ID: 190019203
-- Level 4 / DARK / Spellcaster / Effect / ATK 1500 / DEF 0
--
-- [REQUIREMENT] Send the top 2 cards of your Deck to the Graveyard.
-- [EFFECT] Change the battle position of 1 monster your opponent controls.
-- Then, you can Fusion Summon 1 Galaxy, Dragon, High Dragon or Spellcaster
-- Fusion Monster, using monsters from your hand and/or field as material
-- and sending them to the Graveyard.

local s,id=GetID()

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DECKDES|CATEGORY_POSITION|CATEGORY_SPECIAL_SUMMON|CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1) -- Rush Duel: once per turn, per face-up copy
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- Send exactly two cards off the top as the Requirement.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=2
    end
    Duel.DisableShuffleCheck()
    Duel.SendtoGrave(Duel.GetDecktopGroup(tp,2),REASON_COST)
end

-- A battle-position change is possible on this opponent's monster.
function s.posfilter(c)
    return c:IsMonster() and c:IsCanChangePosition()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,1-tp,LOCATION_MZONE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

-- Only Galaxy / Dragon / High Dragon / Spellcaster Fusion Monsters.
function s.fusfilter(c,tp)
    return c:IsType(TYPE_FUSION)
        and c:IsRace(RACE_GALAXY|RACE_DRAGON|RACE_HIGHDRAGON|RACE_SPELLCASTER)
end

-- Default fusion materials: own hand and field, sent to the GY.
function s.matfilter(c,e,tp,chk)
    return c:IsMonster()
        and c:IsControler(tp)
        and c:IsLocation(LOCATION_HAND|LOCATION_MZONE)
        and c:IsAbleToGrave()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- Rush Duel selection: choose at resolution, without targeting.
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
    local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
    local tc=g:GetFirst()
    if not tc then return end
    Duel.HintSelection(g)

    -- Attack -> face-up Defense; face-up or face-down Defense -> Attack.
    -- The 4-argument form also handles a face-down Attack Position monster.
    if Duel.ChangePosition(tc,
        POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,
        POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)==0 then
        return
    end

    -- 'Then, you can': check Fusion Summon legality after changing position.
    -- The existing Fusion helper enforces the Fusion Monster's recipe,
    -- available zones and permitted hand/field material selection.
    local fusion_target=Fusion.SummonEffTG(s.fusfilter,s.matfilter)
    if not fusion_target(e,tp,eg,ep,ev,re,r,rp,0) then return end
    -- Add texts.str1 = "Fusion Summon a monster?" in your custom CDB.
    if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end

    Duel.BreakEffect()
    local fusion_operation=Fusion.SummonEffOP(s.fusfilter,s.matfilter)
    fusion_operation(e,tp,eg,ep,ev,re,r,rp)
end
