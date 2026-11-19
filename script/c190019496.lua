-- HMPH! I Am All Futures!!
-- EDOPro Rush Duel custom | Normal Spell | Card ID 190019496
-- Automatic special effect from hand, Deck or GY when your LP reaches 0.
-- This implements a custom rule, not a standard Spell activation chain.
local s,id=GetID()
local DRAGON=190019497
s.listed_names={DRAGON}

function s.initial_effect(c)
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
            ge:SetOperation(s.try_auto_activate)
            Duel.RegisterEffect(ge,0)
        end
    end
end

function s.find_spell(p)
    return Duel.GetFirstMatchingCard(Card.IsCode,p,
        LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,nil,id)
end

function s.pending_lp_protection(e)
    local p=e:GetOwnerPlayer()
    return s.find_spell(p)~=nil and Duel.GetLocationCount(p,LOCATION_MZONE)>0
end

function s.find_or_create_dragon(p)
    local tc=Duel.GetFirstMatchingCard(Card.IsCode,p,LOCATION_EXTRA,0,nil,DRAGON)
    if tc then return tc end
    -- Creating a *real* Fusion card from outside the duel, not a Token monster.
    local created=Duel.CreateToken(p,DRAGON)
    if not created or not created:IsMonster() or not created:IsType(TYPE_FUSION) then
        return nil
    end
    if Duel.SendtoHand(created,p,REASON_EFFECT)==0 then return nil end
    if not created:IsLocation(LOCATION_EXTRA) then return nil end
    return created
end

function s.try_auto_activate(e,tp,eg,ep,ev,re,r,rp)
    for p=0,1 do
        if Duel.GetLP(p)>0 then s.zero_handled[p]=nil end
        if Duel.GetLP(p)<=0 and not s.zero_handled[p] then
            local spell=s.find_spell(p)
            if spell and Duel.GetLocationCount(p,LOCATION_MZONE)>0 then
                s.zero_handled[p]=true
                local dragon=s.find_or_create_dragon(p)
                if dragon and Duel.GetLocationCountFromEx(p,p,nil,dragon)>0
                    and dragon:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,p,true,true,POS_FACEUP_ATTACK) then
                    Duel.Hint(HINT_CARD,p,id)
                    if Duel.SpecialSummon(dragon,SUMMON_TYPE_FUSION,p,p,true,true,POS_FACEUP_ATTACK)>0 then
                        dragon:CompleteProcedure()
                        if not spell:IsLocation(LOCATION_GRAVE) then
                            Duel.SendtoGrave(spell,REASON_EFFECT)
                        end
                        local opp=1-p
                        local old=Duel.GetLP(opp)
                        local new=math.ceil(old/2)
                        Duel.SetLP(opp,new)
                        local drained=old-new
                        if drained>0 then Duel.Recover(p,drained,REASON_EFFECT) end
                    else
                        s.zero_handled[p]=nil
                    end
                else
                    s.zero_handled[p]=nil
                end
            end
        end
    end
end
