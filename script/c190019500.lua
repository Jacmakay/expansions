-- Power Of creation
-- Card ID: 190019285
-- Custom Normal Spell for EDOPro
local s,id=GetID()

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND|CATEGORY_TOEXTRA|CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Open the card-name selector, including aliases and Tokens.
    local code=Duel.AnnounceCard(tp,{OPCODE_ALLOW_ALIASES,OPCODE_ALLOW_TOKENS})
    if not code or code==0 then return end

    -- Construct a copy of the named card, even if it was not in either Deck.
    local tc=Duel.CreateToken(tp,code)
    if not tc then return end

    -- Tokens cannot be placed in the hand or Extra Deck.
    if tc:IsType(TYPE_TOKEN) then
        if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
            Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP_ATTACK)
        end
        return
    end

    -- Fusion, Synchro, Xyz, and Link monsters belong in the Extra Deck.
    if tc:IsType(TYPE_EXTRA) then
        Duel.SendtoDeck(tc,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
        return
    end

    -- Ordinary monsters, Spells, and Traps go to your hand.
    if Duel.SendtoHand(tc,tp,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,tc)
    end
end
