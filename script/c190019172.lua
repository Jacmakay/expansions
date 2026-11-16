-- Gojo Reformed Agent of Terminus
-- Custom EDOPro Rush Duel | Card ID 190019172
-- DARK / Level 4 / Spellcaster / Effect | ATK 1800 / DEF 1800
--
-- [REQUIREMENT] You may send 1 OTHER face-up monster you control to
-- the GY to enable the monster-creation part of this effect. That
-- monster-creation option may only be used once per Duel.
-- [EFFECT] Return 1 face-up monster your opponent controls to its
-- owner's hand. Then, you may destroy 1 opponent's Spell/Trap.
-- If you paid the monster-creation requirement, you may also choose
-- a real Level 8 or lower monster from the loaded card databases,
-- create it, and Special Summon it in face-up Defense Position,
-- ignoring its Summoning conditions.
--
-- Uses the same Duel.AnnounceCard / Duel.CreateToken mechanism
-- as Terminus (190019499). No actual Token monster is summoned.
local s,id=GetID()

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND|CATEGORY_DESTROY|CATEGORY_TOGRAVE
        |CATEGORY_SPECIAL_SUMMON|CATEGORY_ANNOUNCE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    -- Rush Duel: once per turn for this card, but the bounce/destroy
    -- remains usable on later turns after creation was used.
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.otherfaceup(c,sc)
    return c~=sc and c:IsFaceup() and c:IsType(TYPE_MONSTER)
        and c:IsAbleToGraveAsCost()
end

function s.bouncefilter(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.destroyfilter(c)
    return c:IsSpellTrap() and c:IsDestructable()
end

-- The printed Requirement only applies when the player chooses to
-- use the once-per-Duel creation option. It is optional otherwise.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    e:SetLabel(0)
    local sc=e:GetHandler()
    if Duel.GetFlagEffect(tp,id)>0 then return end
    if not Duel.IsExistingMatchingCard(s.otherfaceup,tp,LOCATION_MZONE,0,1,sc,sc) then
        return
    end
    -- Prompt: pay the extra monster-creation requirement?
    if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.otherfaceup,tp,LOCATION_MZONE,0,1,1,sc,sc)
    if #g>0 and Duel.SendtoGrave(g,REASON_COST)>0 then
        e:SetLabel(1)
        -- No reset: this player's creation option is used for the Duel.
        Duel.RegisterFlagEffect(tp,id,0,0,1)
    end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.bouncefilter,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_MZONE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_SZONE)
    if e:GetLabel()==1 then
        Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
    end
end

function s.haszone(tp,tc)
    if tc:IsLocation(LOCATION_EXTRA) then
        return Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0
    end
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end

-- Card-name selection can filter monsters and exclude Tokens, but
-- its announce opcodes cannot test a card's Level. Therefore validate
-- the selected real card afterward and permit another attempt.
function s.choosecreated(tp)
    for i=1,5 do
        local code=Duel.AnnounceCard(tp,
            TYPE_MONSTER,OPCODE_ISTYPE,
            TYPE_TOKEN,OPCODE_ISTYPE,OPCODE_NOT,OPCODE_AND)
        if not code or code==0 then return nil end
        local tc=Duel.CreateToken(tp,code)
        if tc and tc:IsType(TYPE_MONSTER) and not tc:IsType(TYPE_TOKEN)
            and tc:GetLevel()>=1 and tc:GetLevel()<=8 then
            return tc
        end
        -- Unsupported choice: Level 9+, Rank/Link-only monster, etc.
        -- The player may choose a different card (up to five attempts).
    end
    return nil
end

function s.create(e,tp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local tc=s.choosecreated(tp)
    if not tc then return end

    -- Same creation approach as Terminus: created cards are inserted
    -- into the hand, or automatically redirected to the Extra Deck.
    if Duel.SendtoHand(tc,tp,REASON_EFFECT)==0 then return end
    if not tc:IsLocation(LOCATION_HAND|LOCATION_EXTRA) then return end
    if tc:IsLocation(LOCATION_HAND) then
        Duel.ConfirmCards(1-tp,tc)
    end
    if not s.haszone(tp,tc) then return end
    if not tc:IsCanBeSpecialSummoned(e,0,tp,true,true,POS_FACEUP_DEFENSE) then
        return
    end
    Duel.BreakEffect()
    Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP_DEFENSE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- The first part of the effect must resolve before the optional
    -- destruction and creation portions can follow.
    if not Duel.IsExistingMatchingCard(s.bouncefilter,tp,0,LOCATION_MZONE,1,nil) then
        return
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectMatchingCard(tp,s.bouncefilter,tp,0,LOCATION_MZONE,1,1,nil)
    if #g==0 or Duel.SendtoHand(g,nil,REASON_EFFECT)==0 then return end

    if Duel.IsExistingMatchingCard(s.destroyfilter,tp,0,LOCATION_SZONE,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local dg=Duel.SelectMatchingCard(tp,s.destroyfilter,tp,0,LOCATION_SZONE,1,1,nil)
        if #dg>0 then Duel.Destroy(dg,REASON_EFFECT) end
    end

    if e:GetLabel()==1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        s.create(e,tp)
    end
end
