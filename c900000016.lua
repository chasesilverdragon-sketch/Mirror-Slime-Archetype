-- Prism Reflection (ID 900000016)
-- Quick-Play Spell: switch the ATK/DEF of EACH targeted monster until End Phase.
-- Development prototype for the MDPro4 ocgcore engine. In-game testing required.
local s,id=GetID()

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Restrict our own target to the six colored Mirror Slimes.
-- LINK monsters cannot be selected since they have no DEF to swap.
function s.mfilter(c,e)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER)
        and c:IsCode(900000001,900000002,900000003,900000004,900000005,900000006)
        and c:GetAttack()>=0 and c:GetDefense()>=0
        and c:IsCanBeEffectTarget(e)
end
function s.ofilter(c,e)
    return c:IsFaceup() and c:GetAttack()>=0 and c:GetDefense()>=0
        and c:IsCanBeEffectTarget(e)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        return chkc:IsLocation(LOCATION_MZONE)
            and ((chkc:IsControler(tp) and s.mfilter(chkc,e))
                or (chkc:IsControler(1-tp) and s.ofilter(chkc,e)))
    end
    if chk==0 then
        return Duel.IsExistingTarget(s.mfilter,tp,LOCATION_MZONE,0,1,nil,e)
            and Duel.IsExistingTarget(s.ofilter,tp,0,LOCATION_MZONE,1,nil,e)
    end
    -- Select separately, then register BOTH cards as targets of this activation.
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local mg=Duel.SelectMatchingCard(tp,s.mfilter,tp,LOCATION_MZONE,0,1,1,nil,e)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local og=Duel.SelectMatchingCard(tp,s.ofilter,tp,0,LOCATION_MZONE,1,1,nil,e)
    mg:Merge(og)
    Duel.SetTargetCard(mg)
    Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,mg,2,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,mg,2,0,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Read actual Chain targets using the MDPro4-supported API.
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    if not g then return end
    g=g:Filter(Card.IsRelateToEffect,nil,e)
    for tc in aux.Next(g) do
        if tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE)
            and tc:GetAttack()>=0 and tc:GetDefense()>=0 then
            -- EFFECT_SWAP_AD swaps this monster's current ATK and DEF.
            -- It does NOT exchange the two monsters' ATK values with each other.
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SWAP_AD)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
        end
    end
end
