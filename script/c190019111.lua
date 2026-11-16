-- The Blade Is Me - Bankai Awakening (190019111) -- Rush Duel Ritual Spell
-- Summons True Bankai from the Extra Deck in DUEL_EXTRA_DECK_RITUAL mode.
local s,id=GetID()
local TRUE_SHIKAI=190019102
local TRUE_BANKAI=190019112
function s.initial_effect(c)
    -- The GY material is optional and may be used at most once;
    -- it is shuffled into the Deck instead of being Tributed.
    Ritual.AddProcGreater(c,s.ritfilter,12,nil,s.extrafil,s.extraop,
        nil,s.stage2,nil,s.forcedselection,nil,nil,s.ritlevel)
end
function s.ritfilter(c)
    return c:IsCode(TRUE_BANKAI)
end
function s.gyfilter(c)
    return c:IsCode(TRUE_SHIKAI) and c:IsMonster() and c:IsAbleToDeck()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
    return Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_GRAVE,0,nil)
end
function s.ritlevel(c,rc)
    -- Treat the optional GY True Shikai as exactly Level 8.
    if c:IsLocation(LOCATION_GRAVE) and c:IsCode(TRUE_SHIKAI) then return 8 end
    return c:GetRitualLevel(rc)
end
function s.forcedselection(e,tp,sg,rc)
    -- You may use no more than 1 True Shikai from GY.
    return sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=1
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,rc)
    local grave=mat:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
    local normal=mat-grave
    if #normal>0 then Duel.ReleaseRitualMaterial(normal) end
    if #grave>0 then
        Duel.SendtoDeck(grave,nil,SEQ_DECKSHUFFLE,
            REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
    end
end
function s.stage2(mat,e,tp,eg,ep,ev,re,r,rp,rc)
    -- +500 ATK only if True Shikai was recycled from the Graveyard.
    if not rc:IsFaceup() then return end
    local used_gy=mat:IsExists(function(c)
        return c:IsCode(TRUE_SHIKAI) and c:IsPreviousLocation(LOCATION_GRAVE)
    end,1,nil)
    if used_gy then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(500)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        rc:RegisterEffect(e1)
    end
end
