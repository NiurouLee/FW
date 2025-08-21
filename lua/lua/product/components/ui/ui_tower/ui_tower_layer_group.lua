---@class UITowerLayerGroup : UICustomWidget
_class("UITowerLayerGroup", UICustomWidget)
UITowerLayerGroup = UITowerLayerGroup
function UITowerLayerGroup:OnShow(uiParams)
    self:InitWidget()
end
function UITowerLayerGroup:InitWidget()
    --generated--
    ---@type RawImageLoader
    self.bg = self:GetUIComponent("RawImageLoader", "bg")
    self.bgObj = self:GetGameObject("bg")
    ---@type UICustomWidgetPool
    self.point1 = self:GetUIComponent("UISelectObjectPath", "point1")
    ---@type UICustomWidgetPool
    self.point2 = self:GetUIComponent("UISelectObjectPath", "point2")
    ---@type UICustomWidgetPool
    self.point3 = self:GetUIComponent("UISelectObjectPath", "point3")
    ---@type UICustomWidgetPool
    self.point4 = self:GetUIComponent("UISelectObjectPath", "point4")
    ---@type UICustomWidgetPool
    self.point5 = self:GetUIComponent("UISelectObjectPath", "point5")
    --generated end--

    self.line1 = self:GetUIComponent("RectTransform", "line1")
    self.line2 = self:GetUIComponent("RectTransform", "line2")
    self.line3 = self:GetUIComponent("RectTransform", "line3")
    self.line4 = self:GetUIComponent("RectTransform", "line4")
    self.line5 = self:GetUIComponent("RectTransform", "line5")
end
function UITowerLayerGroup:SetData(
    groupIdx,
    groupCfg,
    layerStart,
    layerCfg,
    nextGroupFirstPos,
    curLayer,
    passAll,
    curSelect,
    onSelect)
    local cfg = groupCfg[groupIdx]
    -- if cfg.Type > 4 then
    --     self.bgObj:SetActive(false)
    -- else
    --     self.bgObj:SetActive(true)
    -- end
    local posCfg = Cfg.cfg_tower_layer_position[cfg.Pos]
    self.bg:LoadImage(cfg.Bg)
    local l_lastValueLayerNum = nil
    for i = 1, 5 do
        local point = self["point" .. i]
        local pointCfg = posCfg["Pos" .. i]
        local rect = point.dynamicInfoOfEngine.gameObject:GetComponent(typeof(UnityEngine.RectTransform))
        local pos = Vector2(pointCfg[1], pointCfg[2])
        rect.anchoredPosition = pos
        
        if not layerCfg[layerStart + i] then
            local line = self["line" .. i]
            line.gameObject:SetActive(false)
        else
            ---@type UITowerLayerItem
            local item = point:SpawnObject("UITowerLayerItem")
            item:SetData(pointCfg[3], layerCfg[layerStart + i], curLayer, passAll, curSelect, onSelect)
            l_lastValueLayerNum = i

            if layerCfg[layerStart + i + 1] == nil then
                local line = self["line" .. i]
                line.gameObject:SetActive(false)
            else
                local to = nil
                if i == 5 then
                    if nextGroupFirstPos == nil then
                        --最后一组的最后一个点不连线
                        self.line5.gameObject:SetActive(false)
                    else
                        self.line5.gameObject:SetActive(true)
                        to = nextGroupFirstPos
                    end
                else
                    local lastCfg = posCfg["Pos" .. (i + 1)]
                    to = Vector2(lastCfg[1], lastCfg[2])
                    local line = self["line" .. i]
                    line.gameObject:SetActive(true)
                end
                if to then
                    local delta = to - pos
                    local rot = Quaternion.FromToRotation(Vector3.right, Vector3(delta.x, delta.y, 0))
                    local line = self["line" .. i]
                    line.rotation = rot
                    line.sizeDelta = Vector2(Vector2.Distance(pos, to), line.sizeDelta.y)
                    line.anchoredPosition = pos
                end
            end

            
        end
        
    end
end
