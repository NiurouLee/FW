--
---@class UIHomeStorehouseGiftItem : UICustomWidget
_class("UIHomeStorehouseGiftItem", UICustomWidget)
UIHomeStorehouseGiftItem = UIHomeStorehouseGiftItem
--初始化
function UIHomeStorehouseGiftItem:OnShow(uiParams)
    self:InitWidget()
    self:AttachEvent(GameEventType.HomeStorehouseGiftItemOnSelect, self._OnSelectChanged)
end
--获取ui组件
function UIHomeStorehouseGiftItem:InitWidget()
    --generated--
    ---@type UnityEngine.GameObject
    self.root = self:GetGameObject("root")
    ---@type UICustomWidgetPool
    self.item = self:GetUIComponent("UISelectObjectPath", "item")
    ---@type UnityEngine.GameObject
    self.selector = self:GetGameObject("selector")
    --generated end--
    self._empty = self:GetGameObject("empty")
end
--设置数据
---@param data Item
function UIHomeStorehouseGiftItem:SetData(idx, data, curSelect, showEmpty)
    self._idx = idx
    if data then
        local tplID = data:GetTemplateID()
        local itemHome = self.item:SpawnObject("UIItemHomeland")
        local asset = RoleAsset:New()
        asset.assetid = tplID
        asset.count = data:GetCount()
        ---@type UIHomelandModule
        local uiModule = GameGlobal.GetUIModule(HomelandModule)
        local buildMng = uiModule:GetClient():BuildManager()
        local isBuilding = Cfg.cfg_item_architecture[tplID] ~= nil
        if isBuilding then
            asset.count = buildMng:GetBuildCount(tplID)
        end

        itemHome:Flush(asset)
        self._selected = self._idx == curSelect
        self.selector:SetActive(self._selected)
        self.root:SetActive(true)
        self._empty:SetActive(false)
    else
        self.root:SetActive(false)
        self._empty:SetActive(showEmpty)
    end
end
--按钮点击
function UIHomeStorehouseGiftItem:AreaOnClick(go)
    if self._selected then
        return
    end
    GameGlobal.EventDispatcher():Dispatch(GameEventType.HomeStorehouseGiftItemOnSelect, self._idx)
end

function UIHomeStorehouseGiftItem:_OnSelectChanged(idx)
    if self._idx == idx and not self._selected then
        self.selector:SetActive(true)
        self._selected = true
    elseif self._idx ~= idx and self._selected then
        self.selector:SetActive(false)
        self._selected = false
    end
end
