-- Prism Slime Knight (development prototype for MDPro4/ocgcore)
-- Custom ID 900000019 | LIGHT | Aqua / Fusion / Pendulum / Effect
-- Level 7 | ATK 2400 / DEF 2000 | Scale 4
-- Requires one Mirror Slime and one Prism Scale Slime monster as materials.
-- 0x1f50 = Mirror Slime / Slime Fusions, 0x1f51 = Prism family.
-- NOTE:  In-game execution has not yet been validated.
local s,id,o=GetID()
-- Effect count identifiers must not contain the core's once-per-Duel flag bits.
local cid=0x0f000000+(id-900000000)*16
local SET_MIRROR=0x1f50
local SET_PRISM=0x1f51
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Fusion and Pendulum procedures modeled after official Fusion/Pendulum cards.
    -- MDPro4 local helpers (rather than Project Ignis namespaces).
    aux.AddFusionProcMix(c,false,true,s.fusmirror,s.fusscale)
    aux.EnablePendulumAttribute(c,false)

    -- PENDULUM effect 1: recycle Mirror Slime from GY or banishment.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_PZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,cid)
    e1:SetTarget(s.pthtg)
    e1:SetOperation(s.pthop)
    c:RegisterEffect(e1)

    -- PENDULUM effect 2: if a Slime Fusion is Fusion Summoned, go face-up to the Extra Deck.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOEXTRA)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_PZONE)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,cid+1)
    e2:SetCondition(s.toexcon)
    e2:SetTarget(s.toextg)
    e2:SetOperation(s.toexop)
    c:RegisterEffect(e2)

    -- MONSTER effect 1: Fusion Summon => search a Prism Spell/Trap.
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    -- Soft once per turn: each separately Fusion Summoned copy may search.
    e3:SetCountLimit(1)
    e3:SetCondition(s.fuscon)
    e3:SetTarget(s.spelltg)
    e3:SetOperation(s.spellop)
    c:RegisterEffect(e3)

    -- MONSTER effect 2: quick target 1 face-up monster, reduce its ATK by 800,
    -- and gain 800 ATK if the target's ATK actually dropped.
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,3))
    e4:SetCategory(CATEGORY_ATKCHANGE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCountLimit(1)
    e4:SetTarget(s.atktg)
    e4:SetOperation(s.atkop)
    c:RegisterEffect(e4)

    -- MONSTER effect 3: Fusion Summoned Knight destroyed by opponent's effect
    -- => search a Prism monster. Pendulum Monsters go face-up to Extra when destroyed.
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,4))
    e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_DESTROYED)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCountLimit(1,cid+4)
    e5:SetCondition(s.dcon)
    e5:SetTarget(s.monstg)
    e5:SetOperation(s.monsop)
    c:RegisterEffect(e5)
end
function s.fusmirror(c,fc,sumtype,tp)
    return c:IsFusionSetCard(SET_MIRROR) and c:IsFusionType(TYPE_MONSTER)
end
function s.fusscale(c,fc,sumtype,tp)
    return c:IsFusionCode(900000007,900000008) and c:IsFusionType(TYPE_MONSTER)
end
function s.pthfilter(c)
    return c:IsSetCard(SET_MIRROR) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.pthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.pthfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(aux.NecroValleyFilter(s.pthfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(s.pthfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
end
function s.pthop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsAbleToHand() then
        if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then Duel.ConfirmCards(1-tp,tc) end
    end
end
function s.slimefusion(c)
    return c:IsType(TYPE_FUSION) and c:IsSetCard(SET_MIRROR)
        and c:IsSummonType(SUMMON_TYPE_FUSION)
end
function s.toexcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.slimefusion,1,nil)
end
function s.toextg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_PZONE) end
    Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,tp,0)
end
function s.toexop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_PZONE) then
        Duel.SendtoExtraP(c,tp,REASON_EFFECT)
    end
end
function s.fuscon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.spellfilter(c)
    return c:IsSetCard(SET_PRISM)
        and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.spelltg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spellfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.spellop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.spellfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then Duel.ConfirmCards(1-tp,g) end
end
function s.atkfilter(c,e)
    return c:IsFaceup() and c:GetAttack()>0 and c:IsCanBeEffectTarget(e)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.atkfilter(chkc,e) end
    if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsFaceup() or not tc:IsRelateToEffect(e) then return end
    local a0=tc:GetAttack()
    if a0<=0 then return end
    local ec=Effect.CreateEffect(c)
    ec:SetType(EFFECT_TYPE_SINGLE)
    ec:SetCode(EFFECT_UPDATE_ATTACK)
    ec:SetValue(-800)
    ec:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(ec)
    -- Engine-side ATK is updated before checking whether the reduction happened.
    Duel.AdjustInstantly(tc)
    if tc:GetAttack()<a0 and c:IsFaceup() and c:IsRelateToEffect(e) then
        local ec2=Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetCode(EFFECT_UPDATE_ATTACK)
        ec2:SetValue(800)
        ec2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(ec2)
    end
end
function s.dcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_MZONE)
        and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_EFFECT)
        and rp==1-tp and c:IsSummonType(SUMMON_TYPE_FUSION)
end
function s.monfilter(c)
    return c:IsSetCard(SET_PRISM) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.monstg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.monfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.monsop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.monfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then Duel.ConfirmCards(1-tp,g) end
end
