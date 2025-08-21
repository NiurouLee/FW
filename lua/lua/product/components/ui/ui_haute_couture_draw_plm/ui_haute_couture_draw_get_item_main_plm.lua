--时装get item Main
---@class UIHauteCoutureDrawGetItemMainPLM : UIHauteCoutureDrawGetItemBase
_class("UIHauteCoutureDrawGetItemMainPLM", UIHauteCoutureDrawGetItemBase)
UIHauteCoutureDrawGetItemMainPLM = UIHauteCoutureDrawGetItemMainPLM

function UIHauteCoutureDrawGetItemMainPLM:Constructor()

end

function UIHauteCoutureDrawGetItemMainPLM:OnShow(uiParams)
    self:InitWidgets()
    self:_OnValue()
end

function UIHauteCoutureDrawGetItemMainPLM:InitWidgets()
   --通用Widgets初始化
    self:InitWidgetsBase()

    --个性化Widgets初始化
    self._title = self:GetUIComponent("UILocalizationText","txt_title")
    self._pool = self:GetUIComponent("UISelectObjectPath","pool")
    local itemInfo = self:GetUIComponent("UISelectObjectPath","selectInfoPool")
    ---@type UISelectInfo
    self._selectInfo = itemInfo:SpawnObject("UISelectInfo")
    self._selectInfo:SetType(3)
    local detailObj = self._selectInfo:GetG3CustomPool()
    detailObj.dynamicInfoOfEngine:SetObjectName("UIHauteCoutureDrawGetItemCellDetailPLM.prefab")
    ---@type UIHauteCoutureDrawGetItemCellDetailPLM
    self._selectDetail = detailObj:SpawnObject("UIHauteCoutureDrawGetItemCellDetailPLM")
    self._eff = self:GetGameObject("eff")
    self._eff2 = self:GetGameObject("eff2")
    self._eff.layer = 10
    self._eff2.layer = 10
end

function UIHauteCoutureDrawGetItemMainPLM:_OnValue()

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
        self._pool:SpawnObjects("UIHauteCoutureDrawGetItemCellPLM",#self._items)
        local pools = self._pool:GetAllSpawnList()
        for i = 1, #pools do
            local item = pools[i]
            local data = self._items[i]
            item:SetData(data, true, function(idx,pos)
                self:ItemClick(idx,pos)
            end)
        end
    end
end

function UIHauteCoutureDrawGetItemMainPLM:ItemClick(idx, pos)
    if self._selectInfo then
        self._selectDetail:SetData(self._items[idx])
        self._selectInfo:OnlyShow(pos)
    end
end

function UIHauteCoutureDrawGetItemMainPLM:BgOnClick(go)
    if self.controller.callback then
        self.controller.callback()
    end
    self.controller:CloseDialog()
end


