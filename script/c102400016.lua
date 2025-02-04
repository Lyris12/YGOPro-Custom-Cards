--created by Lyris
--インライトメント・アルティマ ケースト
local s,id,o=GetID()
function s.initial_effect(c)
	--Cannot be Normal Summoned/Set. Must first be Special Summoned (from your hand) by Tributing 2 "Inlightened" monsters, including at least 1 "Inlightened Kay'est Tail". You take no battle damage from direct attacks. If your "Inlightened" monster battles, after damage calculation: Inflict 800 damage to your opponent for each Spell/Trap they control, also send as many Spells/Traps they control to the GY as possible, then if you attacked directly, banish all Spells/Traps from their GY. You can only control 1 "Inlightened Ultima" monster.
	c:EnableReviveLimit()
	aux.AddCodeList(c,id-9)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetCondition(s.condition)
	c:RegisterEffect(e2)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLED)
	e4:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE)
	e4:SetDescription(1100)
	e4:SetTarget(s.sgtg)
	e4:SetOperation(s.sgop)
	c:RegisterEffect(e4)
	c:SetUniqueOnField(1,0,aux.FilterBoolFunction(Card.IsSetCard,0x1da6),LOCATION_MZONE)
end
function s.spfilter(c,g,ft,tp)
	if c:IsControler(tp) and c:GetSequence()<5 then ft=ft+1 end
	return c:IsCode(id-9) and (c:IsControler(tp) or c:IsFaceup())
		and (ft>0 or g:IsExists(s.mzfilter,1,c,tp))
end
function s.mzfilter(c,tp)
	return c:IsControler(tp) and c:GetSequence()<5
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetReleaseGroup(tp):Filter(Card.IsSetCard,nil,0xda6)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return ft>-2 and #rg>1 and rg:IsExists(s.spfilter,1,nil,rg,ft,tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetReleaseGroup(tp):Filter(Card.IsSetCard,nil,0xda6)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g1=rg:FilterSelect(tp,s.spfilter,1,1,nil,rg,ft,tp)
	local tc=g1:GetFirst()
	if tc:IsControler(tp) and tc:GetSequence()<5 then ft=ft+1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	if ft>0 then
		local g2=rg:Select(tp,1,1,tc)
		g1:Merge(g2)
	else
		local g2=rg:FilterSelect(tp,s.mzfilter,1,1,tc,tp)
		g1:Merge(g2)
	end
	Duel.Release(g1,REASON_COST)
end
function s.condition(e)
	return Duel.GetAttackTarget()==nil
end
function s.sgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*800)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
function s.sgop(e,tp,eg,ep,ev,re,r,rp)
	local dir=Duel.GetAttackTarget()==nil
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	local ct=Duel.SendtoGrave(g,REASON_EFFECT)
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsType),tp,0,LOCATION_GRAVE,nil,TYPE_SPELL+TYPE_TRAP)
	if ct>0 and #sg>0 and dir then
		Duel.BreakEffect()
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
