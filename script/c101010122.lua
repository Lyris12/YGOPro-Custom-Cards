--クリアー・セラフィム
local id,ref=GIR()
function ref.start(c)
--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--recover
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetTarget(ref.rectg)
	e2:SetOperation(ref.recop)
	c:RegisterEffect(e2)
end
function ref.filter(c)
	return not (c:IsAttribute(ATTRIBUTE_EARTH) or c:IsAttribute(ATTRIBUTE_WATER) or c:IsAttribute(ATTRIBUTE_FIRE) or c:IsAttribute(ATTRIBUTE_WIND) or c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK) or c:IsAttribute(ATTRIBUTE_DEVINE))
end
function ref.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(ref.filter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return Duel.GetTurnPlayer()==tp and ct>0 end
	Duel.SetTargetPlayer(tp)
	local rec=ct*500
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
function ref.recop(e,tp,eg,ep,ev,re,r,rp)
	local rec=Duel.GetMatchingGroupCount(ref.filter,tp,LOCATION_MZONE,0,nil)*500
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Recover(p,rec,REASON_EFFECT)
end
