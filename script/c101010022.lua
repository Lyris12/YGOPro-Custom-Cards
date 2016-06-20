--サイバネティック・セージ
local id,ref=GIR()
function ref.start(c)
--pendulum summon
	aux.AddPendulumProcedure(c)
	--Activate
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_ACTIVATE)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetOperation(ref.activate)
	c:RegisterEffect(e5)
	--spell effect
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1)
	e4:SetValue(ref.value)
	c:RegisterEffect(e4)
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetRange(LOCATION_PZONE)
	e6:SetCondition(ref.sscon)
	e6:SetTarget(ref.sstg)
	e6:SetOperation(ref.ssop)
	c:RegisterEffect(e6)
	--maintain (Monster)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(ref.mtcon)
	e1:SetOperation(ref.mtop)
	c:RegisterEffect(e1)
	--redirect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e2:SetCondition(ref.recon)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)
	--damage conversion
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_REVERSE_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,0)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
function ref.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function ref.mtop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CheckLPCost(tp,1500) then
		Duel.PayLPCost(tp,1500)
	else
		Duel.Destroy(e:GetHandler(),REASON_RULE)
	end
end
function ref.recon(e)
	return e:GetHandler():IsLocation(LOCATION_MZONE)
end
function ref.filter1(c)
	return (c:IsSetCard(0x93) or c:IsSetCard(0x94)) and c:IsAbleToHand() and c:GetCode()~=101010048
end
function ref.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(ref.filter1,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(101010048,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function ref.value(e,c)
	return c:IsSetCard(0x93) and c:IsControler(e:GetHandlerPlayer()) and c:IsReason(REASON_BATTLE)
end
function ref.sscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetActivityCount(Duel.GetTurnPlayer(),ACTIVITY_NORMALSUMMON)==0 and Duel.GetActivityCount(Duel.GetTurnPlayer(),ACTIVITY_ATTACK)==0
end
function ref.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function ref.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
function ref.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.Destroy(c,REASON_EFFECT)==0 or ft<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,ref.spfilter,tp,LOCATION_REMOVED,0,1,ft,nil,e,tp)
	if g:GetCount()==0 then return end
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	Duel.BreakEffect()
	local dg=Duel.GetMatchingGroup(ref.desfilter,tp,LOCATION_ONFIELD,0,nil)
	Duel.Remove(dg,POS_FACEUP,REASON_EFFECT)
end
