--created by Discord \ LeonDuvall
--Kyrie, YC.Org Naval Gear Admiral
local s,id,o=GetID()
function s.initial_effect(c)
	--U-When this card is activated: You can place 1 "Naval Gear" or "YC.Org" monster from your hand or GY in your Spell & Trap Card Zone as a Continuous Spell. If you Link Summon a "Naval Gear" or "YC.Org" monster: You can tribute 1 other "YC.Org" or "Naval Gear" Spell you control; Special Summon 1 "Naval Gear" or "YC.Org" monster from your Deck to a zone that monster points to. You can only use each effect of "Kyrie, YC.Org Naval Gear Admiral" once per turn.
	--M-If this card is used as Link Material for the Link Summon of a "Naval Gear" or "YC.Org" Link Monster: You can activate this card in your Pendulum Zone. You can only use this effect of "Kyrie, YC.Org Naval Gear Admiral" once per turn.
	if not aux.PendulumChecklist then
		aux.PendulumChecklist=0
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge1:SetOperation(aux.PendulumReset)
		Duel.RegisterEffect(ge1,0)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1163)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC_G)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(aux.PendCondition())
	e1:SetOperation(aux.PendOperation())
	e1:SetValue(SUMMON_TYPE_PENDULUM)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(1160)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetTarget(s.target)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_LEAVE_GRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetCountLimit(1,id+100)
	e4:SetCondition(s.pzcon)
	e4:SetTarget(s.pztg)
	e4:SetOperation(s.pzop)
	c:RegisterEffect(e4)
end
function s.tffilter(c)
	return c:IsSetCard(0x96b,0x700) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.GetFlagEffect(tp,id)<=0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		e:SetCategory(CATEGORY_LEAVE_GRAVE)
		e:SetOperation(s.activate)
		if Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_GRAVE,0,1,nil) then
			Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
		end
	else
		e:SetCategory(0)
		e:SetOperation(nil)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tffilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return #eg==1 and ec:IsFaceup() and ec:IsSetCard(0x96b,0x700) and ec:IsSummonType(SUMMON_TYPE_LINK) and ec:GetSummonPlayer()==tp
end
function s.cfilter(c,e,tp,ft,ec)
	local ok=false
	for p=0,1 do
		local zone=ec:GetLinkedZone(p)&0xff
		ok=ok or Duel.GetLocationCount(p,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
	end
	return ((c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and (ft>0 or (c:IsControler(tp) and (c:GetSequence()<5 and (ok or ec:GetLinkedGroup():IsContains(c)))))) or c:IsLocation(LOCATION_SZONE) and ft>0) and (c:IsControler(tp) or c:IsFaceup())
		and c:IsType(TYPE_SPELL) and c:IsSetCard(0x96b,0x700)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,e,tp,ft,eg:GetFirst()) end
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,e,tp,ft,eg:GetFirst())
	Duel.Release(g,REASON_COST)
end
function s.spfilter3(c,e,tp,ec)
	if not c:IsSetCard(0x96b,0x700) then return false end
	local ok=false
	for p=0,1 do
		local zone=ec:GetLinkedZone(p)&0xff
		ok=ok or (Duel.GetLocationCount(p,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,p,zone))
	end
	return ok
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c,ec=e:GetHandler(),eg:GetFirst()
	local zone={}
	zone[0]=ec:GetLinkedZone(0)
	zone[1]=ec:GetLinkedZone(1)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter3,tp,LOCATION_DECK,0,1,nil,e,tp,ec) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c,ec=e:GetHandler(),eg:GetFirst()
	if not c:IsRelateToEffect(e) or not ec:IsRelateToEffect(e) or ec:IsFacedown() then return end
	local zone={}
	local flag={}
	for p=0,1 do
		zone[p]=ec:GetLinkedZone(p)&0xff
		local _,flag_tmp=Duel.GetLocationCount(p,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone[p])
		flag[p]=(~flag_tmp)&0x7f
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter3,tp,LOCATION_DECK,0,1,1,nil,e,tp,ec)
	local sc=g:GetFirst()
	if sc then
		local ava_zone=0
		for p=0,1 do
			if sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,p,zone[p]) then
				ava_zone=ava_zone|(flag[p]<<(p==tp and 0 or 16))
			end
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
		local sel_zone=Duel.SelectDisableField(tp,1,LOCATION_MZONE,LOCATION_MZONE,0x00ff00ff&(~ava_zone))
		local sump=0
		if sel_zone&0xff>0 then
			sump=tp
		else
			sump=1-tp
			sel_zone=sel_zone>>16
		end
		Duel.SpecialSummon(sc,0,tp,sump,false,false,POS_FACEUP_DEFENSE,sel_zone)
	end
end
function s.pzcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	return r&REASON_LINK>0 and rc and rc:IsFaceup() and rc:IsType(TYPE_LINK) and rc:IsSetCard(0x96b,0x700)
end
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	e:SetCategory(0)
	if chk==0 then return c:GetActivateEffect():IsActivatable(tp) and not c:IsForbidden() and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,0)) end
	if c:IsLocation(LOCATION_GRAVE) then
		e:SetCategory(CATEGORY_LEAVE_GRAVE)
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not ((Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,0))) then return end
	Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	local te=tc:GetActivateEffect()
	local tep=tc:GetControler()
	local cost=te:GetCost()
	if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
end
