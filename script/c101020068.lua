--created by LionHeartKIng
--coded by Lyris
--Real Rights - Lycurgus
function c101020068.initial_effect(c)
	c:EnableReviveLimit()
	--cannot special summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.ritlimit)
	c:RegisterEffect(e0)
	--grave+banish
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,101020068)
	e3:SetCondition(c101020068.rmcon)
	e3:SetTarget(c101020068.rmtg)
	e3:SetOperation(c101020068.rmop)
	c:RegisterEffect(e3)
	--hand des
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c101020068.con)
	e1:SetTarget(c101020068.tg)
	e1:SetOperation(c101020068.op)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(c101020068.thtg)
	e2:SetOperation(c101020068.thop)
	c:RegisterEffect(e2)
end
function c101020068.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL
end
function c101020068.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2ea) and c:IsAbleToGrave()
end
function c101020068.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(c101020068.cfilter,tp,LOCATION_REMOVED,0,1,nil)
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local dg=Duel.SelectTarget(tp,c101020068.cfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	local rg=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,dg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,1,0,0)
end
function c101020068.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local g1=g:Filter(Card.IsControler,nil,tp)
	local g2=g:Filter(Card.IsLocation,nil,LOCATION_ONFIELD)
	if g1:GetCount()>0 and Duel.SendtoGrave(g1,REASON_EFFECT+REASON_RETURN)~=0 then
		Duel.Remove(g2,POS_FACEUP,REASON_EFFECT)
	end
end
function c101020068.con(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
function c101020068.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
function c101020068.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0,nil)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
function c101020068.thfilter(c)
	return c:IsSetCard(0x2ea) and c:GetCode()~=101020068 and c:IsAbleToHand()
end
function c101020068.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c101020068.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c101020068.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c101020068.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c101020068.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
