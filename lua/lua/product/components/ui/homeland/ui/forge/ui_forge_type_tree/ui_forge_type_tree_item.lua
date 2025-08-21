---@class UIForgeTypeTreeItem:UICustomWidget
_class("UIForgeTypeTreeItem", UICustomWidget)
UIForgeTypeTreeItem = UIForgeTypeTreeItem

function UIForgeTypeTreeItem:Constructor()
    self.mHomeland = GameGlobal.GetModule(HomelandModule)
    self.data = self.mHomeland:GetForgeData()

    ---@type Quaternion
    self.quaternionArrow = Quaternion.identity
    self._landBtn = nil
end

function UIForgeTypeTreeItem:OnShow()
    ---@type UnityEngine.UI.Image
    self.bg = self:GetUIComponent("Image", "bg")
    ---@type UILocalizationText
    self.txt = self:GetUIComponent("UILocalizationText", "txt")
    self.goArrow = self:GetGameObject("imgArrow")
    ---@type UnityEngine.RectTransform
    self.rectArrow = self:GetUIComponent("RectTransform", "imgArrow")
    ---@type UnityEngine.UI.Image
    self.imgArrow = self:GetUIComponent("Image", "imgArrow")
    self.goChildren = self:GetGameObject("children")
    self.goChildren:SetActive(false)
    ---@type UICustomWidgetPool
    self.poolChildren = self:GetUIComponent("UISelectObjectPath", "children")
    ---@type UnityEngine.RectTransform
    self.line = self:GetUIComponent("RectTransform", "line")

    ---@type UnityEngine.U2D.SpriteAtlas
    self.atlas = self:GetAsset("UIHomelandBuildInfo.spriteatlas", LoadType.SpriteAtlas)

    self:AttachEvent(GameEventType.HomelandForgeFoldFilter, self.FoldFilter)
end
function UIForgeTypeTreeItem:OnHide()
    self:DetachEvent(GameEventType.HomelandForgeFoldFilter, self.FoldFilter)
end

---@param id number ForgeFilter的id
function UIForgeTypeTreeItem:Init(id)
    self.id = id
    local f = self.data:GetForgeFilterById(id)
    self.txt:SetText(f.name)
    if f:HasChildren() then
        local len = table.count(f.children)
        self.poolChildren:SpawnObjects("UIForgeTypeTreeItemChild", len)
        ---@type UIForgeTypeTreeItemChild[]
        local uis = self.poolChildren:GetAllSpawnList()
        for i, ui in ipairs(uis) do
            ui:Init(id, f.children[i].id)
            if f.children[i].id == 403 then
                if not self._landBtn then
                    self._landBtn = ui
                end
            end
        end
        self.goArrow:SetActive(true)
    else
        self.goArrow:SetActive(false)
    end
    self.line:SetAsLastSibling()
end

function UIForgeTypeTreeItem:FoldFilter(id)
    local f = self.data:GetForgeFilterById(self.id)
    if id == self.id then
        if f:HasChildren() then
            if self.goChildren.activeInHierarchy then
                self.goChildren:SetActive(false)
                self:FlushArrow(true)
            else
                self.goChildren:SetActive(true)
                self:FlushArrow(false)
            end
        end
        self.bg.sprite = self.atlas:GetSprite("N17_produce_btn_classify_1")
    else
        if f:HasChildren() then
            self:FlushArrow(true)
        end
        self.goChildren:SetActive(false)
        self.bg.sprite = self.atlas:GetSprite("N17_produce_btn_classify_2")
    end
end

function UIForgeTypeTreeItem:FlushArrow(isUp)
    if isUp then
        self.quaternionArrow:SetEuler(0, 0, 0) --上
        self.rectArrow.localRotation = self.quaternionArrow
        self.imgArrow.color = Color(0.6, 0.6, 0.6)
    else
        self.quaternionArrow:SetEuler(0, 0, 180) --下
        self.rectArrow.localRotation = self.quaternionArrow
        self.imgArrow.color = Color(0.97, 0.79, 0.49) --(248, 201, 124)
    end
end

function UIForgeTypeTreeItem:bgOnClick(go)
    GameGlobal.EventDispatcher():Dispatch(GameEventType.HomelandForgeFoldFilter, self.id)
    local f = self.data:GetForgeFilterById(self.id)
    if not f:HasChildren() then
        self.data.filter = self.id
        self.data:FilterList()
        GameGlobal.EventDispatcher():Dispatch(GameEventType.ShowHideListSequence, true)
        GameGlobal.EventDispatcher():Dispatch(GameEventType.HomelandForgeUpdateList)
    end
end

function UIForgeTypeTreeItem:GetLandBtn()
    return self._landBtn:GetGameObject("bg")
end
