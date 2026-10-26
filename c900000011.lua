-- Mirror Barrier | card ID 900000011
-- Normal Trap; prototype for MDPro4 ocgcore (in-game behavior pending).
local s,id=GetID()
local MIRROR_SET=0x1f50
local PRISM_SET=0x1f51

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCondition(s.negcon)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)
end

-- In our custom set, all Mirror/Prism Slime monsters use these two setcodes.
function s.slimefilter(c,tp)
    return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
        and c:IsType(TYPE_MONSTER)
        and (c:IsSetCard(MIRROR_SET) or c:IsSetCard(PRISM_SET))
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    if not re or not Duel.IsChainNegatable(ev) then return false end
    -- Only card effects with a destruction operation can be negated here.
    local ex,g,ct,p,loc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
    if not ex then return false end
    if not Duel.IsExistingMatchingCard(s.slimefilter,tp,LOCATION_MZONE,0,1,nil,tp) then
        return false
    end
    -- If the threatening effect explicitly lists the cards it will destroy,
    -- require at least one of our Slime monsters to be among them.
    if g and #g>0 then
        return g:IsExists(s.slimefilter,1,nil,tp)
    end
    -- If no card group was specified, some effects (e.g. non-targeting
    -- destruction) only determine the victims at resolution. We allow the
    -- activation while a Slime is on our field; actual match needs playtesting.
    if p==tp and loc and loc~=0 then
        return (loc & LOCATION_MZONE)~=0
    end
    return true
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    local rc=re:GetHandler()
    if rc and rc:IsDestructable() and rc:IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,rc,1,0,0)
    end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    if Duel.NegateActivation(ev) and rc and rc:IsRelateToEffect(re) then
        Duel.Destroy(rc,REASON_EFFECT)
    end
end
