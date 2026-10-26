-- Mirror Slime - Brown (development script, not in-game tested)
-- Card ID: 900000002 | EARTH/Aqua/Effect | Level 3 | ATK 1000 / DEF 1500
local s,id=GetID()
-- Effect count identifiers must not contain the core's once-per-Duel flag bits.
local cid=0x0f000000+(id-900000000)*16
local SET_MIRROR=0x1f50
function s.initial_effect(c)
    -- Normal or Special Summon: grant a face-up non-Link monster 1000 DEF
    -- through the end of the activating player's opponent's next turn.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DEFCHANGE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,cid)
    e1:SetTarget(s.deftg)
    e1:SetOperation(s.defop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    -- If used as material for a Slime Fusion Monster, grant battle protection.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCondition(s.matcon)
    e3:SetOperation(s.matop)
    c:RegisterEffect(e3)
end
function s.deffilter(c,e)
    return c:IsFaceup() and not c:IsType(TYPE_LINK) and c:GetDefense()>=0
        and c:IsCanBeEffectTarget(e)
end
function s.deftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.deffilter(chkc,e) end
    if chk==0 then
        return Duel.IsExistingTarget(s.deffilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.deffilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e)
    Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,g,1,0,1000)
end
function s.defop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_DEFENSE)
    e1:SetValue(1000)
    -- Only count the opponent's End Phases. If activated during their turn,
    -- the current End Phase must not count as their *next* turn.
    local opp_end_phases=Duel.GetTurnPlayer()==tp and 1 or 2
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,opp_end_phases)
    tc:RegisterEffect(e1)
end
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
    local rc=e:GetHandler():GetReasonCard()
    return (r&REASON_FUSION)~=0 and rc and rc:IsType(TYPE_FUSION) and rc:IsSetCard(SET_MIRROR)
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
    local rc=e:GetHandler():GetReasonCard()
    if not rc then return end
    -- Prevent one battle destruction per turn. Persistent while Fusion remains face-up.
    local e1=Effect.CreateEffect(rc)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    e1:SetCountLimit(1)
    e1:SetValue(s.battleval)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    rc:RegisterEffect(e1,true)
end
function s.battleval(e,re,r,rp)
    return (r&REASON_BATTLE)~=0
end
