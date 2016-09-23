--Dimension-Magica Darknova
function c101010400.initial_effect(c)
    --If this card was Spatial Summoned using "Starry-Eyes Spatial Dragon" as any of its Space Materials: You can target 1 of your banished "Dimension-Magica" monsters, except "Dimension-Magica Darknova"; add it to your hand. You can only use this effect of "Dimension-Magica Darknova" once per turn.
    local e1=Effect.CreateEffect(c)
    e:SetCategory(CATEGORY_TOHAND)
    e:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e:SetCode(EVENT_SPSUMMON_SUCCESS)
    e:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e:SetCountLimit(1,101010400)
    e:SetCondition(c101010400.thcon)
    e:SetTarget(c101010400.thtg)
    e:SetOperation(c101010400.thop)
    c:RegisterEffect(e1)
    --Once per turn: You can banish 1 other "Dimension-Magica" monster from your hand or field, then target 1 card your opponent controls; destroy it.
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1)
    e2:SetCost(c101010400.cost)
    e2:SetTarget(c101010400.destg)
    e2:SetOperation(c101010400.desop)
    c:RegisterEffect(e2)
    if not c101010400.global_check then
        c101010400.global_check=true
        local ge2=Effect.CreateEffect(c)
        ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge2:SetCode(EVENT_ADJUST)
        ge2:SetCountLimit(1)
        ge2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
        ge2:SetOperation(c101010400.check)
        Duel.RegisterEffect(ge2,0)
    end
end
c101010400.spatial=true
c101010400.alterf=  function(mc)
    return mc.spatial
end
c101010400.alterct=2
c101010400.alterop= function(e,tp,chk)
    local rc=e:GetLabelObject()
    if chk==0 then return rc:IsExists(c101010400.alfilter,1,nil,rc) end
    local mc=Duel.SelectMatchingCard(tp,c101010400.altfilter,tp,LOCATION_MZONE,0,1,1,rc:GetFirst(),rc:GetFirst():GetRace(),rc:GetFirst():GetAttribute())
    return mc:GetFirst()
end
function c101010400.check(e,tp,eg,ep,ev,re,r,rp)
    Duel.CreateToken(tp,500)
    Duel.CreateToken(1-tp,500)
end
function c101010400.alfilter(c,g)
    return c:IsFaceup() and c101010400.alterf(c) and c:IsAbleToRemove() and g:IsExists(c101010400.altfilter,1,c,c:GetRace(),c:GetAttribute())
end
function c101010400.altfilter(c,rc,at)
    return c:IsFaceup() and c:GetRace()==rc and c:GetAttribute()==at and c:IsAbleToRemove()
end
function c101010400.thcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return bit.band(c:GetSummonType(),0x7150)==0x7150 and c:GetMaterial():IsExists(Card.IsCode,1,nil,101010434)
end
function c101010400.filter(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0xa03) and c:IsAbleToHand() and not c:IsCode(101010400)
end
function c101010400.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(1-tp) and c101010400.filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(c101010400.filter,tp,LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,c101010400.filter,tp,LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c101010400.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    end
end
function c101010400.cfilter(c)
    return (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsType(TYPE_MONSTER) and c:IsSetCard(0xa03) and c:IsAbleToRemoveAsCost()
end
function c101010400.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.IsExistingMatchingCard(c101010400.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,c) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,c101010400.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,c)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c101010400.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsDestructable() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsDestructable,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,Card.IsDestructable,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c101010400.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end
