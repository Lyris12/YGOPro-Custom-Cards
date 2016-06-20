--F・HEROダイハードガル
local id,ref=GIR()
function ref.start(c)
--set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_TRAP)
	c:RegisterEffect(e1)
	--activate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(101010170,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE+EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(ref.actcon)
	e2:SetTarget(ref.acttg)
	e2:SetOperation(ref.act)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(101010170,1))
	e3:SetCode(EVENT_CHAINING)
	c:RegisterEffect(e3)
	local g=Group.CreateGroup()
	g:KeepAlive()
	--spsummon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(101010170,2))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(ref.sptg)
	e5:SetOperation(ref.spop)
	e5:SetLabelObject(g)
	c:RegisterEffect(e5)
	--spsummon
	if not ref.global_check then
		ref.global_check=true
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_TO_GRAVE)
		e4:SetOperation(ref.operation)
		Duel.RegisterEffect(e4,0)
		e4:SetLabelObject(g)
	end
end
function ref.dfilter(c,tp)
	return c:IsReason(REASON_DESTROY)
		and c:IsSetCard(0x9008) and c:GetPreviousControler()==tp
end
function ref.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(ref.dfilter,nil,tp)
	if g:GetCount()==0 then return end
	local sg=e:GetLabelObject()
	local c=e:GetHandler()
	if c:GetFlagEffect(101010170)==0 then
		sg:Clear()
		c:RegisterFlagEffect(101010170,RESET_EVENT+0x3fe0000+RESET_PHASE+PHASE_MAIN1+RESET_SELF_TURN,0,1)
	end
	sg:Merge(g)
end
function ref.filter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_DESTROY) and c:GetCode()~=101010170
end
function ref.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(101010170)~=0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and e:GetLabelObject():IsExists(ref.filter,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(101010170,3))
	local g=e:GetLabelObject():FilterSelect(tp,ref.filter,1,1,nil)
	Duel.SetTargetCard(g)
end
function ref.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc then
		Duel.SSet(tp,tc)
		Duel.ConfirmCards(1-tp,tc)
		tc:RegisterFlagEffect(101010170,RESET_EVENT+0x1fe0000,0,1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e2:SetTargetRange(LOCATION_SZONE,0)
		e2:SetCountLimit(1,101010170)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
	end
end
function ref.actcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_SET_TURN) or e:GetHandler():GetFlagEffect(101010170)~=0
end
function ref.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function ref.actfilter(c)
	return c:IsSetCard(0x9008) and c:IsType(TYPE_MONSTER) and c:GetCode()~=101010170
end
function ref.act(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		if ev~=0 then
			local ef=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_EFFECT)
			if ef~=nil and ef:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then Card.ReleaseEffectRelation(c,ef) end
		end
		ref.after(e,tp)
	end
end
function ref.after(e,tp)
	local g=Duel.GetMatchingGroup(ref.actfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(101010170,3))
		local tc=g:Select(tp,1,1,nil)
		Duel.SSet(tp,tc)
		Duel.ConfirmCards(1-tp,tc)
	end
end