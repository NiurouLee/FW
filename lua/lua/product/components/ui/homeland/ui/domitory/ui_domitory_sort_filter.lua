---@class UIDomitorySortFilter : UICustomWidget
_class("UIDomitorySortFilter", UICustomWidget)
UIDomitorySortFilter = UIDomitorySortFilter
--注释
function UIDomitorySortFilter:Constructor()
    self.MaxCol = 4
    self._rowSortBtnPos = {
        [1] = 82,
        [2] = 210,
        [3] = 338,
        [4] = 466
    }
end
function UIDomitorySortFilter:OnShow(uiParams)
    self:GetComponents()

    -- ---@type UnityEngine.RectTransform
    -- local rect = self:GetUIComponent("RectTransform", "UpRightAnchor")
    -- local tran = uiParams[2]
    -- if tran then
    --     rect.position = Vector3(tran.position.x + 0.59, rect.position.y, 0)
    -- else
    --     rect.anchoredPosition = Vector2.zero
    -- end
end

function UIDomitorySortFilter:GetComponents()
    --排序
    self._sortsPool = self:GetUIComponent("UISelectObjectPath", "sortRowItem")
    --筛选
    self._propertiesPool = self:GetUIComponent("UISelectObjectPath", "attributeRowItem")
    self._typePool = self:GetUIComponent("UISelectObjectPath", "tagRowItem")
    self._powerPool = self:GetUIComponent("UISelectObjectPath", "influenceRowItem")

    self._scrollView = self:GetUIComponent("ScrollRect", "Scroll View")
    self._content = self:GetUIComponent("RectTransform", "Content")
    self._secondAttributeSelcetMark = self:GetUIComponent("Button", "secondaryToggle")
    self._sortLayerPool = self:GetUIComponent("UISelectObjectPath", "sortLayerRoot")
    self._sortsPoolTrans = self:GetUIComponent("RectTransform", "sortRowItem")
    -- self._
end

function UIDomitorySortFilter:SetData(sortType, sortOrder, filterParams, sortCfg, filterCfg, onChange, onClose)
    self._isShow = true
    self._sortType = sortType
    self._sortOrder = sortOrder
    self._filterTable = filterParams
    self._sortListCfg = sortCfg
    self._filterCfg = filterCfg
    self._onChanged = onChange
    self._closeCallBack = onClose
    self:OnValue()
end

--注释
function UIDomitorySortFilter:SetBtnGroupSizeInfo(obj)
    local trans = obj:GetComponent("RectTransform")
    trans.transform.parent = self._sortsPoolTrans.transform
end

function UIDomitorySortFilter:OnValue()
    self._secondAttributeSelectStatus = UIPetSortContext.Instance:ShowViceElement() -- 是否选中副属性
    self._secondAttributeSelcetMark.interactable = not self._secondAttributeSelectStatus
    self._sortPool = {}
    --spawn排序
    local elementIdx = -1
    for i, value in ipairs(self._sortListCfg) do
        table.insert(self._sortPool, value)
        if value.Type == PetSortType.Element then
            if i % 2 == 0 then
                Log.exception("属性占据两个格子，必须在奇数索引")
                return
            end
            elementIdx = i
        end
    end
    table.insert(self._sortPool, {}) --属性占据两个格子
    local c = #self._sortPool
    if elementIdx > 0 then
        c = c + 1
    end
    self._sortsPool:SpawnObjects("UIDomitorySortBtn2", c)
    ---@type table<number,UIDomitorySortBtn2>
    self._sortBtns_all = self._sortsPool:GetAllSpawnList()
    local index = 1
    for i = 1, c do
        if i == elementIdx + 1 then
            self._sortBtns_all[i]:SetData(nil, {}, nil, nil, nil, nil)
        else
            self._sortBtns_all[i]:SetData(
                index,
                self._sortPool[index],
                self._sortType,
                self._sortOrder,
                function(idx)
                    self:SortClick(idx)
                end,
                UIPetSortContext.Instance:CurElement()
            )
            index = index + 1
        end
    end
    -- self:SortBtnBySize()
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
        }
    }

    ---@type table<number,UIDomitoryFilterBtn>
    self._filterBtns = {}
    local onBtnClick = function(type, tag)
        self:OnFilterBtnClick(type, tag)
    end

    for tag, value in pairs(filters) do
        if value.items and #value.items > 0 then
            local count = #value.items
            value.pool:SpawnObjects("UIDomitoryFilterBtn", count)
            local btns = value.pool:GetAllSpawnList()
            for i = 1, count do
                ---@type UIDomitoryFilterBtn
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
    if self._content.rect.size.y > self._scrollView:GetComponent("RectTransform").rect.size.y then
        self._scrollView.enabled = true
    else
        self._scrollView.enabled = false
    end
end

--排序-点击
function UIDomitorySortFilter:SortClick(idx)
    local tp = self._sortListCfg[idx].Type

    self:OnSortChanged(tp)

    --刷新排序按钮状态
    self:FlushSortBtns()
end

function UIDomitorySortFilter:FlushSortBtns()
    for i = 1, table.count(self._sortBtns_all) do
        self._sortBtns_all[i]:Flush(self._sortType, self._sortOrder, UIPetSortContext.Instance:CurElement())
    end
end

function UIDomitorySortFilter:FlushFilterBtns()
    for _, btn in ipairs(self._filterBtns) do
        btn:Flush(self._filterTable)
    end
end

function UIDomitorySortFilter:OnFilterBtnClick(type, tag)
    self:OnFilterChanged(type, tag)
    --刷新筛选btn
    self:FlushFilterBtns()
end

function UIDomitorySortFilter:OnSortChanged(type)
    if type == PetSortType.Element then
        local element = UIPetSortContext.Instance:CurElement()
        if element == ElementType.ElementType_Blue then
            self._sortType = PetSortType.WaterFirst
        elseif element == ElementType.ElementType_Red then
            self._sortType = PetSortType.FireFirst
        elseif element == ElementType.ElementType_Green then
            self._sortType = PetSortType.SenFirst
        elseif element == ElementType.ElementType_Yellow then
            self._sortType = PetSortType.ElectricityFirst
        end
        self._sortOrder = PetSortOrder.Descending --默认降序
    else
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
    end
    self:NotifyChange()
end

function UIDomitorySortFilter:OnFilterChanged(type, tag)
    for i = 1, #self._filterTable do
        if self._filterTable[i]._filter_type == type then
            table.remove(self._filterTable, i)
            self:NotifyChange()
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
end

--刷新列表
function UIDomitorySortFilter:NotifyChange()
    self._onChanged(self._sortType, self._sortOrder, self._filterTable)
end

function UIDomitorySortFilter:BgOnClick()
    self._isShow = false
    self:GetGameObject():SetActive(false)
    if self._closeCallBack then
        self._closeCallBack()
    end
end

function UIDomitorySortFilter:SelectMarkImageOnClick()
    self._secondAttributeSelectStatus = not self._secondAttributeSelectStatus
    self._secondAttributeSelcetMark.interactable = not self._secondAttributeSelectStatus
    UIPetSortContext.Instance:SetViceElement(self._secondAttributeSelectStatus)
    self:NotifyChange()
end

--清理所有筛选条件
function UIDomitorySortFilter:ClearFilters()
    self._filterTable = {}
    self:FlushFilterBtns()
end

function UIDomitorySortFilter:IsShow()
    return self._isShow
end
