---@class UISortFilterItem : UICustomWidget
_class("UISortFilterItem", UICustomWidget)
UISortFilterItem = UISortFilterItem
--注释
function UISortFilterItem:Constructor()
    self.MaxCol = 4
    self._rowSortBtnPos = 
    {
        [1] = 82,
        [2] = 210,
        [3] = 338,
        [4] = 466
    }
end
function UISortFilterItem:OnShow(uiParams)
   
    self:GetComponents()

    -- ---@type UnityEngine.RectTransform
    -- local rect = self:GetUIComponent("RectTransform", "UpRightAnchor")
    -- local tran = uiParams[2]
    -- if tran then
    --     rect.position = Vector3(tran.position.x + 0.59, rect.position.y, 0)
    -- else
    --     rect.anchoredPosition = Vector2.zero
    -- end

    self._petModule = GameGlobal.GetModule(PetModule)
end

function UISortFilterItem:GetComponents()
    --排序
    self._sortsPool = self:GetUIComponent("UISelectObjectPath", "sortRowItem")
    --筛选
    self._propertiesPool = self:GetUIComponent("UISelectObjectPath", "attributeRowItem")
    self._typePool = self:GetUIComponent("UISelectObjectPath", "tagRowItem")
    self._powerPool = self:GetUIComponent("UISelectObjectPath", "influenceRowItem")

    self._scrollView = self:GetUIComponent("ScrollRect", "Scroll View")
    self._content = self:GetUIComponent("RectTransform", "Content")
    self._secondAttributeSelcetMark = self:GetGameObject("selectMarkImage")
    self._sortLayerPool = self:GetUIComponent("UISelectObjectPath", "sortLayerRoot")
    self._sortsPoolTrans = self:GetUIComponent("RectTransform", "sortRowItem")
    -- self._
    self._generalTrans = self:GetUIComponent("RectTransform", "general")
    self._generalPool = self:GetUIComponent("UISelectObjectPath", "generaRowItem")
    self._newObj = self:GetGameObject("generalNew")
end

function UISortFilterItem:SetData(sortType, sortOrder, filterParams, sortCfg, filterCfg, onChange, onClose)
    self._sortType = sortType
    self._sortOrder = sortOrder
    self._filterTable = filterParams
    self._sortListCfg = sortCfg
    self._filterCfg = filterCfg
    self._onChanged = onChange
    self._closeCallBack = onClose
    self:OnValue()
end

--元素格子占两个，特殊处理，grid布局改为vertical，并且动态设置每行的按钮坐标
function UISortFilterItem:SortBtnBySize()
    local c = table.count(self._sortPool)
    local totalCol = 1
    local currentCalCol = 1
    --先计算需要几行，生成行容器
    for i =1 , c do
        if currentCalCol > 4 then
            totalCol = totalCol + 1
            currentCalCol = 1
        end
        if self._sortPool[i].Type == PetSortType.Element then
            currentCalCol = currentCalCol + 2
        else
            currentCalCol = currentCalCol + 1

        end
    end
    self.sortLayer_All =  self._sortLayerPool:SpawnObjects("UiSortRowLayer", totalCol)
    local currentCol = 1
    local groupIndex = 1
    self:SetBtnGroupSizeInfo(self.sortLayer_All[groupIndex].view.gameObject)
    for i = 1, c do
        if currentCol > 4 then
            currentCol = 1
            groupIndex = groupIndex + 1
            self:SetBtnGroupSizeInfo(self.sortLayer_All[groupIndex].view.gameObject)
        end
        self:SetSortBtnItemTrans(self._sortBtns_all[i].view.gameObject , self.sortLayer_All[groupIndex].view.gameObject.transform , currentCol)
        if self._sortPool[i].Type == PetSortType.Element then
            currentCol = currentCol + 2 -- 元素占2格子
        else
            currentCol = currentCol + 1 -- 其他占1格子
        end
    end
end
--为每个的按钮刷一遍正确的坐标
function UISortFilterItem:SetSortBtnItemTrans(obj ,parent, index)
    obj.transform.parent = parent
    local rect = obj.transform:GetComponent("RectTransform")
    rect.anchorMax = Vector2(0, 1)
    rect.anchorMin = Vector2(0, 1)
    rect.pivot = Vector2(0.5, 0.5)
    local pos = Vector3(self._rowSortBtnPos[index] , 0 , 0)
    obj.transform.localPosition = pos
end
--注释
function UISortFilterItem:SetBtnGroupSizeInfo(obj)
    local trans = obj:GetComponent("RectTransform")
    trans.transform.parent = self._sortsPoolTrans.transform
end

function UISortFilterItem:OnValue()
    self._sortPool = {}
    self._secondAttributeSelectStatus = self._petModule.PetSortChooseSecondAttribute -- 是否选中副属性
    self._secondAttributeSelcetMark:SetActive(self._secondAttributeSelectStatus)
    --spawn排序
    for key, value in HelperProxy:GetInstance():pairsByKeys(self._sortListCfg) do
        table.insert(self._sortPool, value)
    end

    local c = table.count(self._sortPool)
    self._sortsPool:SpawnObjects("UISortBtnItem", c)
    ---@type UISortBtnItem[]
    self._sortBtns_all = self._sortsPool:GetAllSpawnList()
    for i = 1, c do
        self._sortBtns_all[i]:SetData(
            i,
            self._sortPool[i],
            self._sortType,
            self._sortOrder,
            function(idx)
                self:SortClick(idx)
            end,
            self._petModule.PetSortElementIndex
        )
    end
    self:SortBtnBySize()
    local filters = {
        [PetFilterTag.ShuXing] = {
            pool = self._propertiesPool,
            title = self:GetGameObject("att"),
            items = self._filterCfg[PetFilterTag.ShuXing]
        },
        [PetFilterTag.LeiXing] = {
            pool = self._typePool,
            title = self:GetGameObject("tag"),
            items = self._filterCfg[PetFilterTag.LeiXing]
        },
        [PetFilterTag.ShiLi] = {
            pool = self._powerPool,
            title = self:GetGameObject("influence"),
            items = self._filterCfg[PetFilterTag.ShiLi]
        },
        [PetFilterTag.General] = {
            pool = self._generalPool,
            title = self:GetGameObject("general"),
            items = self._filterCfg[PetFilterTag.General]
        }
    }

    ---@type table<number,UIFilterBtnItem>
    self._filterBtns = {}
    local onBtnClick = function(type, tag)
        self:OnFilterBtnClick(type, tag)
    end

    for tag, value in pairs(filters) do
        if value.items and #value.items > 0 then
            local count = #value.items
            value.pool:SpawnObjects("UIFilterBtnItem", count)
            local btns = value.pool:GetAllSpawnList()
            for i = 1, count do
                ---@type UIFilterBtnItem
                local btn = btns[i]
                local idx = #self._filterBtns + 1
                btn:SetData(value.items[i], self._filterTable, onBtnClick)
                self._filterBtns[idx] = btn
            end
            value.pool.dynamicInfoOfEngine.gameObject:SetActive(true)
            value.title:SetActive(true)
        else 
            value.pool.dynamicInfoOfEngine.gameObject:SetActive(false)
            value.title:SetActive(false)
        end
    end

    --======================================
    --检测有没有超出边界，打开关闭滑动
    UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self._content)
    self._isOpen = true
    if self._content.rect.size.y > self._scrollView:GetComponent("RectTransform").rect.size.y then
        self._scrollView.enabled = true
    else
        self._scrollView.enabled = false
    end
    self._newObj:SetActive(UISortFilterItem.GetNewFlagStatus() == 0)
end

--排序-点击
function UISortFilterItem:SortClick(idx)
    local tp = self._sortListCfg[idx].Type

    self:OnSortChanged(tp)

    --刷新排序按钮状态
    self:FlushSortBtns()
end

function UISortFilterItem:FlushSortBtns()
    for i = 1, table.count(self._sortBtns_all) do
        self._sortBtns_all[i]:Flush(self._sortType, self._sortOrder , self._petModule.PetSortElementIndex)
    end
end

function UISortFilterItem:FlushFilterBtns()
    for _, btn in ipairs(self._filterBtns) do
        btn:Flush(self._filterTable)
    end
end

function UISortFilterItem:OnFilterBtnClick(type, tag)
    self:OnFilterChanged(type, tag)
    --刷新筛选btn
    self:FlushFilterBtns()
    self:FlushFilterBtnRefine(type, tag)
end

function UISortFilterItem:OnSortChanged(type)
    if self._sortType == type then
        --顺序反转
        if self._sortOrder == PetSortOrder.Ascending then
            self._sortOrder = PetSortOrder.Descending
        elseif self._sortOrder == PetSortOrder.Descending then
            self._sortOrder = PetSortOrder.Ascending
        end
    else
        self._sortType = type
        self._sortOrder = PetSortOrder.Descending
    end
    self:NotifyChange()
end

function UISortFilterItem:OnFilterChanged(type, tag)
    for i = 1, #self._filterTable do
        if self._filterTable[i]._filter_type == type then
            table.remove(self._filterTable, i)
            self:NotifyChange()
            GameGlobal.EventDispatcher():Dispatch(GameEventType.OnPetFilterTypeChange,type,false)
            return
        end
    end
    local filterParam
    if tag then
        filterParam = PetFilterParam:New(type, tag)
    else
        filterParam = PetFilterParam:New(type)
    end
    table.insert(self._filterTable, filterParam)
    self:NotifyChange()
    GameGlobal.EventDispatcher():Dispatch(GameEventType.OnPetFilterTypeChange,type,true)
end

--刷新列表
function UISortFilterItem:NotifyChange()
    self._onChanged(self._sortType, self._sortOrder, self._filterTable)
end

function UISortFilterItem:bgOnClick()
    self:GetGameObject():SetActive(false)
    if self._closeCallBack then
        self._closeCallBack()
    end
end

function UISortFilterItem:selectMarkImageOnClick()
    if self._secondAttributeSelectStatus then
        self._secondAttributeSelectStatus = false
    else
        self._secondAttributeSelectStatus = true
    end
    self._petModule:SavePetSecondAttributeFilterParam(self._secondAttributeSelectStatus)
    self:NotifyChange()
    self._secondAttributeSelcetMark:SetActive(self._secondAttributeSelectStatus)
end
--清理所有筛选条件
function UISortFilterItem:ClearFilters()
    self._filterTable = {}
    self:FlushFilterBtns()
end
function UISortFilterItem:FlushFilterBtnRefine(type,tag)
    if type == PetFilterType.Refine then 
        UISortFilterItem.SetNewFlagStatus()
    end 
    self._newObj:SetActive(UISortFilterItem.GetNewFlagStatus() == 0)
end


function UISortFilterItem.SetNewFlagStatus()
    local roleModule = GameGlobal.GetModule(RoleModule)
    local pstId = roleModule:GetPstId()
    local key = pstId .. "UISortFilterItem:Refine"
    LocalDB.SetInt(key, 1)
end

function UISortFilterItem.GetNewFlagStatus()
    local roleModule = GameGlobal.GetModule(RoleModule)
    local pstId = roleModule:GetPstId()
    local key = pstId .. "UISortFilterItem:Refine"
    return LocalDB.GetInt(key, 0)
end

