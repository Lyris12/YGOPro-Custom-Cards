--Flame Flight - Roost
function c101010574.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--When a "Flame Flight" monster is returned to the Deck or hand, place 1 Roost counter on this card.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCondition(c101010574.ccon)
	e1:SetOperation(c101010574.cop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_TO_DECK)
	c:RegisterEffect(e2)
	--Once per turn, you can remove 1 Roost counter from this card to target 1 "Flame Flight" monster from your Hand or Graveyard; Declare 1 Type or Attribute. Change the Attribute or Type of the target monster until the End Phase.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c101010574.cost)
	e3:SetOperation(c101010574.op)
	c:RegisterEffect(e3)
	--on-destroy
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c101010574.con)
	e4:SetTarget(c101010574.tg)
	e4:SetOperation(c101010574.mop)
	c:RegisterEffect(e4)
end
function c101010574.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xa88)
end
function c101010574.ccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c101010574.filter,1,nil)
end
function c101010574.cop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x106,1)
end
function c101010574.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard and e:GetHandler():IsCanRemoveCounter(tp,0x106,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x106,1,REASON_COST)
	e:SetLabelObject(Duel.SelectMatchingCard(tp,c101010574.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil):GetFirst())
end
function c101010574.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	local opt=Duel.SelectOption(tp,aux.Stringid(101010574,0),aux.Stringid(101010574,1))
	if opt==1 then
		local at=Duel.AnnounceAttribute(tp,1,0xff)
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e5:SetReset(RESET_PHASE+PHASE_END)
		e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e5:SetValue(at)
		tc:RegisterEffect(e5)
	else
		local rc=Duel.AnnounceRace(tp,1,0xffffff)
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e5:SetReset(RESET_PHASE+PHASE_END)
		e5:SetCode(EFFECT_CHANGE_RACE)
		e5:SetValue(rc)
		tc:RegisterEffect(e5)
	end
end
function c101010574.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetCounter(0x106)
	e:SetLabel(ct)
	return c:IsReason(REASON_DESTROY) and ct>0
end
function c101010574.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=e:GetLabel()
	if chkc then return not chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,1,nil) end
	Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,1,ct,nil)
end
function c101010574.mop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
end
