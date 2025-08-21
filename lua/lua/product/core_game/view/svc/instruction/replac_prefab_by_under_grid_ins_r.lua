--[[
    变身的逻辑与表现
]]
---@class ReplacePrefabByUnderGridInstruction:BaseInstruction
_class("ReplacePrefabByUnderGridInstruction", BaseInstruction)
ReplacePrefabByUnderGridInstruction = ReplacePrefabByUnderGridInstruction

function ReplacePrefabByUnderGridInstruction:Constructor(paramList)
    self._redPrefab = paramList["redPrefab"]
    self._yellowPrefab = paramList["yellowPrefab"]
    self._bluePrefab = paramList["bluePrefab"]
    self._greenPrefab = paramList["greenPrefab"]
end

function ReplacePrefabByUnderGridInstruction:GetCacheResource()
    local t = {}
    if self._redPrefab then
        table.insert(t, { self._redPrefab, 1 })
    end
    if self._yellowPrefab then
        table.insert(t, { self._yellowPrefab, 1 })
    end
    if self._bluePrefab then
        table.insert(t, { self._bluePrefab, 1 })
    end
    if self._greenPrefab then
        table.insert(t, { self._greenPrefab, 1 })
    end
    return t
end

---@param  casterEntity Entity
function ReplacePrefabByUnderGridInstruction:DoInstruction(TT, casterEntity, phaseContext)
    local e = casterEntity
    if casterEntity:HasSuperEntity() and casterEntity:EntityType():IsSkillHolder() then
        ---@type SuperEntityComponent
        local cSuperEntity = casterEntity:SuperEntityComponent()
        e = cSuperEntity:GetSuperEntity()
    end
    ---@type Vector2
    local gridPos = e:GetRenderGridPosition()
    self._world = e:GetOwnerWorld()
    ---@type UtilDataServiceShare
    local utilDataSvc = self._world:GetService("UtilData")
    local pieceType = utilDataSvc:GetPieceType(gridPos)
    local resPath
    if pieceType == PieceType.Blue then
        resPath = self._bluePrefab
    elseif pieceType == PieceType.Red then
        resPath = self._redPrefab
    elseif pieceType == PieceType.Green then
        resPath = self._greenPrefab
    elseif pieceType == PieceType.Yellow then
        resPath = self._yellowPrefab
    else
        resPath = self._bluePrefab
    end
    ---资源相同则不替换
    if e:Asset():GetResPath() ~= resPath then
        e:ReplaceAsset(NativeUnityPrefabAsset:New(resPath, true))
    end
end
