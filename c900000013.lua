-- Mirror Reversal | card ID 900000013
-- Counter Trap; prototype for MDPro4 ocgcore. Needs in-game validation.
-- This implementation uses the Chain's declared destruction targets/info.
local s,id=GetID()
-- Effect count identifiers must not contain the core's once-per-Duel flag bits.
local cid=0x0f000000+(id-900000000)*16
local MIRROR_SET=0x1f50

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCondition(s.negcon)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    e1:SetCountLimit(1,cid+EFFECT_COUNT_CODE_OATH)
    c:RegisterEffect(e1)
end

function s.mirrorfilter(c,tp)
    -- "Mirror Slime" cards, not Prism Slimes and not all "Slime" cards.
    return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD)
        and c:IsSetCard(MIRROR_SET)
end

function s.threatcount(tp,ev)
    local ex,dg,ct,p,loc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
    if not ex then return 0 end
    if dg and #dg>0 then
        return dg:FilterCount(s.mirrorfilter,nil,tp)
    end
    -- Some effects list targets but no destruction group in operation info.
    local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
    if tg and #tg>0 then
        return tg:FilterCount(s.mirrorfilter,nil,tp)
    end
    -- Effects without specified targets may declare the affected player's
    -- on-field cards only, e.g. mass destruction. This is an approximation.
    if (p==tp or p==PLAYER_ALL) and loc and (loc & LOCATION_ONFIELD)~=0 then
        local n=Duel.GetMatchingGroupCount(s.mirrorfilter,tp,LOCATION_ONFIELD,0,nil,tp)
        return n
    end
    return 0
end

function s.oppfilter(c)
    return c:IsDestructable()
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and Duel.IsChainDisablable(ev)
        and s.threatcount(tp,ev)>0
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local n=s.threatcount(tp,ev)
    if chk==0 then return n>0 end
    e:SetLabel(n)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
    if Duel.IsExistingMatchingCard(s.oppfilter,tp,0,LOCATION_ONFIELD,1,nil) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,n,1-tp,LOCATION_ONFIELD)
    end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.NegateEffect(ev) then return end
    local n=e:GetLabel()
    local g=Duel.GetMatchingGroup(s.oppfilter,tp,0,LOCATION_ONFIELD,nil)
    if n<=0 or #g==0 then return end
    n=math.min(n,#g)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local sg=Duel.SelectMatchingCard(tp,s.oppfilter,tp,0,LOCATION_ONFIELD,0,n,nil)
    if #sg>0 then Duel.Destroy(sg,REASON_EFFECT) end
end
