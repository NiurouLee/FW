--材料音效标识
---@class SeasonSceneLayerMaterial:SeasonSceneLayerBase
_class("SeasonSceneLayerMaterial", SeasonSceneLayerBase)
SeasonSceneLayerMaterial = SeasonSceneLayerMaterial

function SeasonSceneLayerMaterial:Constructor(sceneRoot)
    self._flag = {}
    self._flag[SeasonMapMaterial.Metal] = "metal"
    self._flag[SeasonMapMaterial.Stone] = "stone"
    ---@type UnityEngine.Transform[]
    self._materials = {}
    self._materialLayer = self._sceneRootTransform:Find(SeasonSceneLayer.SoundMaterial)
    self:_CacheMaterial()
end

function SeasonSceneLayerMaterial:Dispose()
    table.clear(self._materials)
    table.clear(self._renderers)
end

function SeasonSceneLayerMaterial:UnLock(zoneMask, zoneID2Animation)
end

function SeasonSceneLayerMaterial:_CacheMaterial()
    if self._materialLayer then
        local childCount = self._materialLayer.childCount
        if childCount > 0 then
            for i = 0, childCount - 1 do
                ---@type UnityEngine.Transform
                local child = self._materialLayer:GetChild(i)
                if child then
                    local mt = self:_GetMaterialType(child.name)
                    if not self._materials[mt] then
                        self._materials[mt] = {}
                    end
                    table.insert(self._materials[mt], child)
                end
            end
        end
    end
end

function SeasonSceneLayerMaterial:_GetMaterialType(name)
    for key, value in pairs(self._flag) do
        if string.find(name, value) then
            return key
        end
    end
    return SeasonMapMaterial.Default
end

---@param gameObject UnityEngine.GameObject
---@return SeasonMapMaterial
function SeasonSceneLayerMaterial:GetMapMaterial(gameObject)
    if gameObject then
        for key, transforms in pairs(self._materials) do
            for _, transform in pairs(transforms) do
                if transform == gameObject.transform then
                    return key
                end
            end
        end
    end
    return SeasonMapMaterial.Default
end