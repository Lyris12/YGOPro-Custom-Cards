--created & coded by Lyris
--
function c101010250.initial_effect(c)
--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c101010250.atkcon)
	e1:SetValue(400)
	c:RegisterEffect(e1)
	--change code
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(101010250,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,101010250)
	e2:SetCost(c101010250.cost)
	e2:SetOperation(c101010250.cdop)
	c:RegisterEffect(e2)
	--code
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_CODE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetValue(70095154)
	c:RegisterEffect(e3)
	local e0=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_CODE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_GRAVE)
	e0:SetValue(101010250)
	c:RegisterEffect(e0)
end
function c101010250.atkcon(e)
	local phase=Duel.GetCurrentPhase()
	return (phase==PHASE_DAMAGE or phase==PHASE_DAMAGE_CAL)
	and Duel.GetAttacker()==e:GetHandler()
end
function c101010250.costfilter(c)
	return c:IsType(TYPE_SPELL) and not c:IsPublic()
end
function c101010250.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c101010250.costfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,c5373478.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	e:SetLabelObject(g:GetFirst())
end
function c101010250.cdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
	e1:SetValue(101010250)
	c:RegisterEffect(e1)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_CODE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
	e0:SetValue(70095154)
	c:RegisterEffect(e0)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c101010250.actop)
	e2:SetLabelObject(e:GetLabelObject())
	e2:SetReset(RESET_EVENT+0x1fe0000)
	c:RegisterEffect(e2)
end
function c101010250.actop(e,tp,eg,ep,ev,re,r,rp)
	local ae=e:GetLabelObject():GetActivateEffect()
	local ftg=ae:GetTarget()
	if ae:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	end
	if ftg then
		ftg(e,tp,eg,ep,ev,re,r,rp,chk)
		else return
	end
	local fop=ae:GetOperation()
	fop(e,tp,eg,ep,ev,re,r,rp)
	e:Reset()
end
