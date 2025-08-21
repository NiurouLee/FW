--[[
    显示BOSS 的大血条
]]
_class("BuffLogicShowBossHp", BuffLogicBase)
---@class BuffLogicShowBossHp:BuffLogicBase
BuffLogicShowBossHp = BuffLogicShowBossHp

function BuffLogicShowBossHp:Constructor(buffInstance, logicParam)
end

function BuffLogicShowBossHp:DoLogic(notify)
    local entityID = notify:GetNotifyEntity():GetID()
    local buffResult = BuffResultShowBossHp:New(entityID)
    return buffResult
end
