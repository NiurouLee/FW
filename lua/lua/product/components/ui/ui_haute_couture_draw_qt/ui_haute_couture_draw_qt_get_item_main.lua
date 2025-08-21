require("ui_haute_couture_draw_get_item_base")

--时装get item Main
---@class UIHauteCoutureDraw_QT_GetItemMain : UIHauteCoutureDrawGetItemBase
_class("UIHauteCoutureDraw_QT_GetItemMain", UIHauteCoutureDrawGetItemBase)
UIHauteCoutureDraw_QT_GetItemMain = UIHauteCoutureDraw_QT_GetItemMain

function UIHauteCoutureDraw_QT_GetItemMain:Constructor()
end

function UIHauteCoutureDraw_QT_GetItemMain:OnShow(uiParams)
    self:InitWidgets()
    self:_OnValue()
end

function UIHauteCoutureDraw_QT_GetItemMain:InitWidgets()
    --通用Widgets初始化
    self:InitWidgetsBase()

    --个性化Widgets初始化
    self._title = self:GetUIComponent("UILocalizationText", "txt_title")
    self._pool = self:GetUIComponent("UISelectObjectPath", "pool")
    local itemInfo = self:GetUIComponent("UISelectObjectPath", "selectInfoPool")
    ---@type UISelectInfo
    self._selectInfo = itemInfo:SpawnObject("UISelectInfo")
    self._selectInfo:SetType(3)
    local detailObj = self._selectInfo:GetG3CustomPool()
    detailObj.dynamicInfoOfEngine:SetObjectName("UIHauteCoutureDraw_QT_GetItemCellDetail.prefab")
    ---@type UIHauteCoutureDraw_QT_GetItemCellDetail
    self._selectDetail = detailObj:SpawnObject("UIHauteCoutureDraw_QT_GetItemCellDetail")
end

function UIHauteCoutureDraw_QT_GetItemMain:_OnValue()
    --title
    local titleTex = self.controller.titleTex or StringTable.Get("str_senior_skin_draw_get_item_title")
    self._title:SetText(titleTex)

    local items = self.controller.items
    self._items = {}

    local sortItems = {}
    if noSort then
        sortItems = items
    else
        sortItems = self:GetModule(ItemModule):SortRoleAsset(items)
    end

    for i = 1, table.count(sortItems) do
        local ItemTempleate = Cfg.cfg_item[sortItems[i].assetid]
        if ItemTempleate then
            self._items[i] = {
                item_index = i,
                item_id = sortItems[i].assetid,
                item_count = sortItems[i].count,
                item_des = sortItems[i].des,
                award_type = sortItems[i].type,
                icon = ItemTempleate.Icon,
                item_name = ItemTempleate.Name,
                simple_desc = ItemTempleate.RpIntro,
                color = ItemTempleate.Color
            }
        end
    end

    if self._items and next(self._items) then
        self._pool:SpawnObjects("UIHauteCoutureDraw_QT_GetItemCell", #self._items)
        local pools = self._pool:GetAllSpawnList()
        for i = 1, #pools do
            local item = pools[i]
            local data = self._items[i]
            item:SetData(
                data,
                true,
                function(idx, pos)
                    self:ItemClick(idx, pos)
                end
            )
        end
    end
end

function UIHauteCoutureDraw_QT_GetItemMain:ItemClick(idx, pos)
    if self._selectInfo then
        self._selectDetail:SetData(self._items[idx])
        self._selectInfo:OnlyShow(pos)
    end
end

function UIHauteCoutureDraw_QT_GetItemMain:BgOnClick(go)
    if self.controller.callback then
        self.controller.callback()
    end
    self.controller:CloseDialog()
end
