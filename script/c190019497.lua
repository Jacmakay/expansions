-- Transcend Dragon: Destroyer of All Beings
-- EDOPro Rush Duel custom | card ID 190019497
-- DIVINE / Level 12 / Galaxy / Fusion / Effect / ATK 5000 / DEF 4000
-- Special 0-LP trigger is a custom rule implemented by a global listener.
-- The two still-unknown *material IDs* must be entered below to enable
-- ordinary Fusion Summoning. The 0-LP and All Futures paths don't need them.

local s,id=GetID()
local TERMINUS_BLADE=190019214
local TERMINUS_DRAGON=0 -- TODO: replace with the actual numeric ID
local TERMINUS_AZALEA=0 -- TODO: replace with the actual numeric ID
local ALL_FUTURES=190019496
s.listed_names={TERMINUS_BLADE,ALL_FUTURES}

function s.initial_effect(c)
    c:EnableReviveLimit()
    if TERMINUS_DRAGON~=0 and TERMINUS_AZALEA~=0 then
        Fusion.AddProcMix(c,false,false,TERMINUS_DRAGON,TERMINUS_BLADE,TERMINUS_AZALEA)
    end

    -- Global 0-LP fallback: automatically summon from the Extra Deck.
    -- If All Futures is ready to resolve, it gets priority instead.
    if not s.global_registered then
        s.global_registered=true
        s.zero_handled={}
        for p=0,1 do
            local protect=Effect.GlobalEffect()
            protect:SetType(EFFECT_TYPE_FIELD)
            protect:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
            protect:SetCode(EFFECT_CANNOT_LOSE_LP)
            protect:SetTargetRange(1,0)
            protect:SetCondition(s.pending_lp_protection)
            Duel.RegisterEffect(protect,p)
        end
        for _,ev in ipairs({EVENT_ADJUST,EVENT_DAMAGE,EVENT_PAY_LPCOST}) do
            local ge=Effect.GlobalEffect()
            ge:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
            ge:SetCode(ev)
            ge:SetOperation(s.try_zero_summon)
            Duel.RegisterEffect(ge,0)
        end
    end

    -- Cannot lose from 0 LP while this monster is face-up.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(1,0)
    e1:SetCode(EFFECT_CANNOT_LOSE_LP)
    c:RegisterEffect(e1)

    -- Opponent's card effects cannot destroy this face-up monster.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetValue(s.immune_to_opponent_destruction)
    c:RegisterEffect(e2)

    -- Effectively unlimited attacks against monsters during the Battle Phase.
    -- EDOPro uses a numeric allowance rather than Lua infinity.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
    e3:SetValue(9999)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(e4)

    -- On destroying an opposing monster in battle, summon it face-down
    -- to its original controller's field to permit another attack.
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
    e5:SetCode(EVENT_BATTLE_DESTROYING)
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetCondition(s.battle_condition)
    e5:SetTarget(s.battle_target)
    e5:SetOperation(s.battle_operation)
    c:RegisterEffect(e5)

    -- [REQUIREMENT] LP = 0; mill 3 from both Decks.
    -- [EFFECT] Revive up to 3 monsters from opponent GY face-down
    -- on the opponent's field; gain 500 ATK each for this turn.
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,0))
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCategory(CATEGORY_DECKDES|CATEGORY_SPECIAL_SUMMON|CATEGORY_ATKCHANGE)
    e6:SetCountLimit(1)
    e6:SetCost(s.mill_cost)
    e6:SetTarget(s.revive_target)
    e6:SetOperation(s.revive_operation)
    c:RegisterEffect(e6)
end

function s.immune_to_opponent_destruction(e,re,rp)
    return rp==1-e:GetHandlerPlayer()
end

function s.extra_dragon(p)
    return Duel.GetFirstMatchingCard(Card.IsCode,p,LOCATION_EXTRA,0,nil,id)
end

function s.has_extra_space(p,tc)
    return tc and Duel.GetLocationCountFromEx(p,p,nil,tc)>0
end

function s.all_futures_ready(p)
    return Duel.IsExistingMatchingCard(Card.IsCode,p,
        LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,ALL_FUTURES)
        and Duel.GetLocationCount(p,LOCATION_MZONE)>0
end

function s.pending_lp_protection(e)
    local p=e:GetOwnerPlayer()
    local tc=s.extra_dragon(p)
    return tc~=nil and s.has_extra_space(p,tc)
end

-- One automatic summon per transition to 0 LP; re-arms after recovery.
function s.try_zero_summon(e,tp,eg,ep,ev,re,r,rp)
    for p=0,1 do
        if Duel.GetLP(p)>0 then s.zero_handled[p]=nil end
        if Duel.GetLP(p)<=0 and not s.zero_handled[p] then
            local tc=s.extra_dragon(p)
            if tc and s.has_extra_space(p,tc) and not s.all_futures_ready(p) then
                s.zero_handled[p]=true
                Duel.Hint(HINT_CARD,p,id)
                if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,p,p,true,true,POS_FACEUP_ATTACK)>0 then
                    tc:CompleteProcedure()
                else
                    s.zero_handled[p]=nil
                end
            end
        end
    end
end

function s.battle_condition(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    return c:IsRelateToBattle() and bc~=nil
        and bc:IsMonster() and bc:IsLocation(LOCATION_GRAVE)
        and bc:IsPreviousControler(1-tp)
end

function s.battle_target(e,tp,eg,ep,ev,re,r,rp,chk)
    local bc=e:GetHandler():GetBattleTarget()
    if chk==0 then
        return bc~=nil and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
            and bc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp)
    end
    bc:CreateEffectRelation(e)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,1-tp,LOCATION_GRAVE)
end

function s.battle_operation(e,tp,eg,ep,ev,re,r,rp)
    local bc=e:GetHandler():GetBattleTarget()
    if not bc or not bc:IsRelateToEffect(e)
        or Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
    Duel.SpecialSummon(bc,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
end

function s.mill_cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLP(tp)==0
            and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
            and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=3
    end
    Duel.DiscardDeck(tp,3,REASON_COST)
    Duel.DiscardDeck(1-tp,3,REASON_COST)
end

function s.revive_filter(c,e,tp)
    return c:IsMonster()
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp)
end

function s.revive_target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,1-tp,LOCATION_GRAVE)
end

function s.revive_operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local space=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
    if space<=0 then return end
    local pool=Duel.GetMatchingGroup(s.revive_filter,tp,0,LOCATION_GRAVE,nil,e,tp)
    local n=math.min(3,space,#pool)
    if n<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=pool:Select(tp,1,n,nil)
    local count=0
    for tc in aux.Next(sg) do
        if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
            and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp)
            and Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE) then
            count=count+1
        end
    end
    Duel.SpecialSummonComplete()
    if count>0 and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) then
        local atk=Effect.CreateEffect(c)
        atk:SetType(EFFECT_TYPE_SINGLE)
        atk:SetCode(EFFECT_UPDATE_ATTACK)
        atk:SetValue(500*count)
        atk:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
        c:RegisterEffect(atk)
    end
end
