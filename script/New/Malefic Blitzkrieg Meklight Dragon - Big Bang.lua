--Malefic Blitzkrieg Dragon - Big Bang
function c101010263.initial_effect(c)
	c:EnableReviveLimit()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c101010263.spcon)
	e1:SetOperation(c101010263.spop)
	c:RegisterEffect(e1)
	--only 1 can exists
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	e2:SetCondition(c101010263.excon)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,1)
	e4:SetCode(EFFECT_CANNOT_SUMMON)
	e4:SetTarget(c101010263.sumlimit)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	c:RegisterEffect(e6)
	--selfdes
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EVENT_ADJUST)
	e7:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) local f1=Duel.GetFieldCard(tp,LOCATION_SZONE,5) local f2=Duel.GetFieldCard(tp,LOCATION_SZONE,5) if ((f1==nil or f1:IsFacedown()) and (f2==nil or f2:IsFacedown())) or e:GetLabelObject():GetLabel()==0 then Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT) e:GetLabelObject():SetLabel(5) end end)
	c:RegisterEffect(e7)
	local eb=e7:Clone()
	eb:SetCode(EVENT_CHAIN_SOLVED)
	c:RegisterEffect(eb)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetCode(EFFECT_SELF_DESTROY)
	e8:SetRange(LOCATION_MZONE)
	e8:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e8:SetTarget(c101010263.destarget)
	c:RegisterEffect(e8)
	--spson
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e9:SetCode(EFFECT_SPSUMMON_CONDITION)
	e9:SetValue(aux.FALSE)
	c:RegisterEffect(e9)
	--cannot announce
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e0:SetTargetRange(LOCATION_MZONE,0)
	e0:SetTarget(c101010263.antarget)
	c:RegisterEffect(e0)
	--grave immune
	local ea=Effect.CreateEffect(c)
	ea:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	ea:SetCode(EFFECT_SEND_REPLACE)
	ea:SetLabel(5)
	ea:SetTarget(c101010263.reptg)
	c:RegisterEffect(ea)
	local lv=Effect.CreateEffect(c)
	lv:SetType(EFFECT_TYPE_SINGLE)
	lv:SetCode(EFFECT_CHANGE_LEVEL)
	lv:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	lv:SetRange(LOCATION_MZONE)
	lv:SetLabelObject(ea)
	e7:SetLabelObject(ea)
	eb:SetLabelObject(ea)
	lv:SetValue(function(e) return e:GetLabelObject():GetLabel() end)
	c:RegisterEffect(lv)
end
function c101010263.sumlimit(e,c)
	return c:IsSetCard(0x23)
end
function c101010263.exfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x23)
end
function c101010263.excon(e)
	return Duel.IsExistingMatchingCard(c101010263.exfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function c101010263.spfilter(c)
	return c:IsCode(101010085) and c:IsAbleToRemoveAsCost()
end
function c101010263.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c101010263.spfilter,c:GetControler(),LOCATION_EXTRA,0,1,nil)
		and not Duel.IsExistingMatchingCard(c101010263.exfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function c101010263.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=Duel.GetFirstMatchingCard(c101010263.spfilter,tp,LOCATION_EXTRA,0,nil)
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
end
function c101010263.destarget(e,c)
	return c:IsSetCard(0x23) and c:GetFieldID()>e:GetHandler():GetFieldID()
end
function c101010263.antarget(e,c)
	return c~=e:GetHandler()
end
function c101010263.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsLocation(LOCATION_MZONE) and c:GetDestination()==LOCATION_GRAVE end
	if c:GetFlagEffect(201010263)==0 then
		local e9=Effect.CreateEffect(c)
		e9:SetType(EFFECT_TYPE_SINGLE)
		e9:SetCode(EFFECT_CHANGE_LEVEL)
		e9:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e9:SetRange(LOCATION_MZONE)
		e9:SetValue(function(e) local djn=e:GetLabelObject():GetLabel() if djn~=0 then return djn end return 1 end)
		e9:SetReset(RESET_EVENT+0x1fe0000)
		e9:SetLabelObject(e)
		c:RegisterEffect(e9)
		c:RegisterFlagEffect(201010263,RESET_EVENT+0x1fe0000,0,1)
	end
	e:SetLabel(e:GetLabel()-1)
	return true
end
