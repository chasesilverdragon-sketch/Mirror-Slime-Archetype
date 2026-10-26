-- Prism Mirror Coat | custom card #900000015
-- Equip Spell. MDPro4 / ocgcore Lua prototype; in-game behavior untested.
local s,id=GetID()
-- The six original colored Mirror Slimes. The shared archetype setcode is
-- intentionally NOT used because it also belongs to other Slime cards.
function s.ismirror(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER)
        and c:IsCode(900000001,900000002,900000003,900000004,900000005,900000006)
end
function s.initial_effect(c)
    -- Activate the Equip Spell by targeting your own face-up Mirror Slime.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetTarget(s.eqtg)
    e1:SetOperation(s.eqop)
    c:RegisterEffect(e1)

    -- Equip limit: can only stay attached to a colored Mirror Slime.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EQUIP_LIMIT)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetValue(s.eqlimit)
    c:RegisterEffect(e2)

    -- Once per turn, copy a face-up opponent monster's DEF as ATK and ATK as DEF
    -- onto the equipped Mirror Slime until the End Phase.
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1) -- once per face-up copy of the Equip Spell
    e3:SetTarget(s.sttg)
    e3:SetOperation(s.stop)
    c:RegisterEffect(e3)
end
function s.eqlimit(e,c)
    return s.ismirror(c)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp)
            and s.ismirror(chkc)
    end
    if chk==0 then
        return Duel.IsExistingTarget(s.ismirror,tp,LOCATION_MZONE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,s.ismirror,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and s.ismirror(tc)
        and c:IsRelateToEffect(e) then
        Duel.Equip(tp,c,tc)
    end
end
function s.targetfilter(c)
    return c:IsFaceup() and c:GetAttack()>=0 and c:GetDefense()>=0
end
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
            and s.targetfilter(chkc)
    end
    local ec=e:GetHandler():GetEquipTarget()
    if chk==0 then
        return ec and s.ismirror(ec)
            and Duel.IsExistingTarget(s.targetfilter,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.targetfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.stop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsFaceup() or not c:IsLocation(LOCATION_SZONE) then return end
    local ec=c:GetEquipTarget()
    local tc=Duel.GetFirstTarget()
    if not (ec and s.ismirror(ec) and tc and tc:IsRelateToEffect(e)
        and s.targetfilter(tc)) then return end
    -- Snapshot the opponent monster's current stats on resolution.
    local atk,def=tc:GetAttack(),tc:GetDefense()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_ATTACK_FINAL)
    e1:SetValue(def)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    ec:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
    e2:SetValue(atk)
    ec:RegisterEffect(e2)
end
-- Rule behavior: Equip Spells are destroyed when the equipped monster leaves
-- the field; no separate trigger is necessary for the final sentence.
