---@class BTConditionManager : Singleton
---@field BuildBTAnd function
---@field BuildBTOr function
---@field IsSatisfyAnd function
---@field IsSatisfyOr function
_class("BTConditionManager", Singleton)
BTConditionManager = BTConditionManager

function BTConditionManager:Constructor()
end

---@param btConditionType BTConditionType
-- function BTConditionManager:BuildConditionTree(btConditionType)
--     local enumKey = GetEnumKey(btConditionType)
--     local funcName = "BuildConditionTree" .. enumKey
--     local func = self[funcName]
--     if func then
--         local bt = func()
--         return bt
--     else
--         Log.warn("### no function names:", funcName)
--     end
-- end

---@param node BehaviourNode
function BTConditionManager:NewBehaviourTree(node)
    local bt = BehaviourTree:New(node)
    return bt
end

---@param conbditionNode ConditionNode
function BTConditionManager:BuildBTSingle(conbditionNode)
    local bt = self:NewBehaviourTree(conbditionNode)
    return bt
end
---@param conbditionNodes ConditionNode[]
function BTConditionManager:BuildBTAnd(conbditionNodes)
    local sNode = SequenceNode:New(conbditionNodes)
    local bt = self:NewBehaviourTree(sNode)
    return bt
end
---@param conbditionNodes ConditionNode[]
function BTConditionManager:BuildBTOr(conbditionNodes)
    local sNode = SelectorNode:New(conbditionNodes)
    local bt = self:NewBehaviourTree(sNode)
    return bt
end

---@param bt BehaviourTree
function BTConditionManager:IsSatisfy(bt)
    if self:IsBTSuccess(bt) then
        return true
    end
    return false
end

---@param bt BehaviourTree
function BTConditionManager:IsBTSuccess(bt)
    local root = bt.root
    root:Visit()
    local b = false
    if root.status == BTState.SUCCESS then
        b = true
    end
    root:Reset()
    return b
end
