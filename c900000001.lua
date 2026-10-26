
-- Mirror Slime - Blue
-- Card ID: 900000001

local s,id=GetID()

function s.initial_effect(c)
    -- Effect 1: Swap ATK and DEF on summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetTarget(s.swaptg)
    e1:SetOperation(s.swapop)
    c:RegisterEffect(e1)

    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    -- Effect 2: Grant effect when used as Fusion Material
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCondition(s.matcon)
    e3:SetOperation(s.matop)
    c:RegisterEffect(e3)
end

-- Effect 1
function s.swapfilter(c)
    return c:IsFaceup()
        and c:GetAttack()>=0
        and c:GetDefense()>=0
end

function s.swaptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        return chkc:IsControler(1-tp)
            and chkc:IsLocation(LOCATION_MZONE)
            and s.swapfilter(chkc)
    end
    if chk==0 then
        return Duel.IsExistingTarget(
            s.swapfilter,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(
        tp,s.swapfilter,tp,0,LOCATION_MZONE,1,1,nil)
end

function s.applyswap(c)
    local atk=c:GetAttack()
    local def=c:GetDefense()
    if atk<0 or def<0 then return end

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_ATTACK_FINAL)
    e1:SetValue(def)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
    e2:SetValue(atk)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e2)
end

function s.swapop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e)
        or not tc:IsFaceup() then return end

    s.applyswap(tc)

    local c=e:GetHandler()
    if c:IsFaceup() and c:IsRelateToEffect(e) then
        s.applyswap(c)
    end
end

-- Effect 2: Fusion Material bonus
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local fc=c:GetReasonCard()
    return (r&REASON_FUSION)~=0
        and fc~=nil
        and fc:IsType(TYPE_FUSION)
        and fc:IsSetCard(0x1f50)
end

function s.matop(e,tp,eg,ep,ev,re,r,rp)
    local fc=e:GetHandler():GetReasonCard()
    if not fc then return end
    -- King Rainbow Slime now owns a built-in, material-gated copy of this
    -- bonus. Do not dynamically register a duplicate Quick Effect on King.
    -- Other Slime Fusion Monsters, including Prism Slime Knight, still
    -- receive Blue's original granted Quick Effect as before.
    if fc:IsCode(900000010) then return end

    local e1=Effect.CreateEffect(fc)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1)
    e1:SetTarget(s.reducetg)
    e1:SetOperation(s.reduceop)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    fc:RegisterEffect(e1)
end

function s.reducefilter(c)
    return c:IsFaceup() and c:IsAttackAbove(0)
end

function s.reducetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        return chkc:IsControler(1-tp)
            and chkc:IsLocation(LOCATION_MZONE)
            and s.reducefilter(chkc)
    end
    if chk==0 then
        return Duel.IsExistingTarget(
            s.reducefilter,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(
        tp,s.reducefilter,tp,0,LOCATION_MZONE,1,1,nil)
end

function s.reduceop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local fc=e:GetHandler()
    if not tc or not tc:IsRelateToEffect(e)
        or not tc:IsFaceup() or not fc:IsFaceup() then
        return
    end

    local def=fc:GetDefense()
    if def<=0 then return end

    local e1=Effect.CreateEffect(fc)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(-def)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
end
