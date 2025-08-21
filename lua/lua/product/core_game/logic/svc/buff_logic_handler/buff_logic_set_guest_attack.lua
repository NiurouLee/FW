---将加buff的施法者的总攻击力，赋给buff持有者的基础攻击力
---@class BuffLogicSetGuestAttack:BuffLogicBase
_class("BuffLogicSetGuestAttack", BuffLogicBase)
BuffLogicSetGuestAttack = BuffLogicSetGuestAttack

function BuffLogicSetGuestAttack:Constructor(buffInstance, logicParam)
    self._rate = logicParam.rate or 1
end

function BuffLogicSetGuestAttack:DoLogic()
    local guestAttack = self._entity:BuffComponent():GetBuffValue("GuestAttack")
    if guestAttack == nil then
        Log.notice("Haven't guestAttack, SetGuestAttack Error!")
        return
    end
    self._buffLogicService:ChangeBaseAttack(self._entity, self:GetBuffSeq(), ModifyBaseAttackType.Attack, guestAttack*self._rate)
end

--重置
---@class BuffLogicResetGuestAttack:BuffLogicBase
_class("BuffLogicResetGuestAttack", BuffLogicBase)
BuffLogicResetGuestAttack = BuffLogicResetGuestAttack

function BuffLogicResetGuestAttack:Constructor(buffInstance, logicParam)
end

function BuffLogicResetGuestAttack:DoLogic()
    Log.notice("BuffLogicResetGuestAttack")
    self._buffLogicService:RemoveBaseAttack(self._entity, self:GetBuffSeq(), ModifyBaseAttackType.Attack)
end
