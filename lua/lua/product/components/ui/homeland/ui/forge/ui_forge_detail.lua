---@class UIForgeDetail:UIController
_class("UIForgeDetail", UIController)
UIForgeDetail = UIForgeDetail

function UIForgeDetail:Constructor()
    self.mHomeland = GameGlobal.GetModule(HomelandModule)
    self.data = self.mHomeland:GetForgeData()
end

function UIForgeDetail:OnShow(uiParams)
    ---@type RawImageLoader
    self.imgIcon = self:GetUIComponent("RawImageLoader", "imgIcon")
    ---@type UnityEngine.UI.Image
    self.imgQuality = self:GetUIComponent("Image", "imgQuality")
    ---@type UILocalizationText
    self.txtName = self:GetUIComponent("UILocalizationText", "txtName")
    ---@type UILocalizationText
    self.txtSize = self:GetUIComponent("UILocalizationText", "txtSize")
    ---@type UILocalizationText
    self.txtLiveable = self:GetUIComponent("UILocalizationText", "txtLiveable")
    ---@type UILocalizationText
    self.txtOwn = self:GetUIComponent("UILocalizationText", "txtOwn")
    ---@type UILocalizationText
    self.txtPlace = self:GetUIComponent("UILocalizationText", "txtPlace")
    ---@type UILocalizationText
    self.txtExp = self:GetUIComponent("UILocalizationText", "txtExp")
    ---@type UILocalizationText
    self.txtCostTime = self:GetUIComponent("UILocalizationText", "txtCostTime")
    self.lock = self:GetGameObject("lock")
    self.forge = self:GetGameObject("forge")
    ---@type UICustomWidgetPool
    self.costLock = self:GetUIComponent("UISelectObjectPath", "costLock")
    ---@type UICustomWidgetPool
    self.costForge = self:GetUIComponent("UISelectObjectPath", "costForge")
    ---@type UnityEngine.UI.Button
    self.btnForge = self:GetUIComponent("Button", "btnForge")
    self.canForgeCount = self:GetGameObject("canForgeCount")
    ---@type UILocalizationText
    self.txtBtnForge = self:GetUIComponent("UILocalizationText", "txtBtnForge")
    ---@type UILocalizationText
    self.txtCanForgeCount = self:GetUIComponent("UILocalizationText", "txtCanForgeCount")

    self.forgeCount = self:GetUIComponent("UILocalizationText", "forgeCount")
    self.forgeCountParent = self:GetGameObject("forgeCountParent")
    self.sealIcon = self:GetUIComponent("Image", "sealIcon")

    self.id = uiParams[1] or 0 --ForgeInfoItem的id
    self:Flush()
end
function UIForgeDetail:OnHide()
    self.imgIcon:DestoryLastImage()
end

function UIForgeDetail:Flush()
    ---@type ForgeInfoItem
    local item = self.data:GetForgeInfoItemById(self.id)
    if item.unlocked then --已解锁
        self.lock:SetActive(false)
        self.forge:SetActive(true)
        local len = table.count(item.forgeCosts)
        self.costForge:SpawnObjects("UIItemHomeland", len)
        ---@type UIItemHomeland[]
        local uis = self.costForge:GetAllSpawnList()
        for i, ui in ipairs(uis) do
            local ra = item.forgeCosts[i]
            ui:Flush(ra, nil)
            ui:TxtCountRedIfNotEnough(ra.count)
        end
        self:FlushForge(item)
    else
        self.lock:SetActive(true)
        self.forge:SetActive(false)
        local len = table.count(item.unlockCosts)
        self.costLock:SpawnObjects("UIItemHomeland", len)
        ---@type UIItemHomeland[]
        local uis = self.costLock:GetAllSpawnList()
        for i, ui in ipairs(uis) do
            local ra = item.unlockCosts[i]
            ui:Flush(ra, nil)
            ui:TxtCountRedIfNotEnough(ra.count)
        end
    end
    self:FlushInfo(item)
end
---@param item ForgeInfoItem
function UIForgeDetail:FlushForge(item)
    local canCount, max = self.data:GetCanForgeCountAndMax(item)
    if max <= -1 then
        self.canForgeCount:SetActive(false)
    else
        self.canForgeCount:SetActive(true)
        self.txtCanForgeCount:SetText(canCount .. "/" .. max)
        if canCount > 0 then
            self.btnForge.interactable = true
            self.txtBtnForge:SetText(StringTable.Get("str_homeland_forge_detail_order"))
        else
            self.btnForge.interactable = false
            self.txtBtnForge:SetText(StringTable.Get("str_homeland_forge_can_forge_count_max"))
        end
    end
end
---@param item ForgeInfoItem
function UIForgeDetail:FlushInfo(item)
    self.imgIcon:LoadImage(item.icon)
    self.txtName:SetText(
        StringTable.Get(
            "str_homeland_forge_detail_name",
            StringTable.Get("str_homeland_quality_" .. item.quality),
            item.name
        )
    )
    self.imgQuality.color = UIForgeData.qualityColors[item.quality]
    self.txtSize:SetText(item.size.x .. "*" .. item.size.y)
    self.txtLiveable:SetText(item.livableValue)
    local curCount, placedCount = UIForgeData.GetOwnPlaceCount(item.id)
    self.txtOwn:SetText(StringTable.Get("str_homeland_forge_detail_own", curCount))
    self.txtPlace:SetText(StringTable.Get("str_homeland_forge_detail_place", placedCount))
    local s = UIForge.GetTimestampStr(item.forgeSecond, self.data.strsWillGetable)
    self.txtCostTime:SetText(s)

    if self.data:IsUnforged(item.id) then
        self.txtExp.gameObject:SetActive(true)
        self.txtExp:SetText(StringTable.Get("str_homeland_forge_first_exp", item.firstExp))
    end

    self.forgeCount:SetText("×" .. item.forgeCount)
    self.forgeCountParent:SetActive(item.forgeCount > 1)

    local atlas = self:GetAsset("UIHomelandBuildInfo.spriteatlas", LoadType.SpriteAtlas)
    if item.forgeCount > 1 then
        self.sealIcon.sprite = atlas:GetSprite("N17_produce_icon_seal2")
    else
        self.sealIcon.sprite = atlas:GetSprite("N17_produce_icon_seal")
    end
end

function UIForgeDetail:btnCloseOnClick(go)
    self:CloseDialog()
end

function UIForgeDetail:btnUnlockOnClick(go)
    self:StartTask(
        function(TT)
            local key = "CancelForgeUnlockTask"
            self:Lock(key)
            local item = self.data:GetForgeInfoItemById(self.id)
            local res, unlock_architecture_list = self.mHomeland:HandleUnlock(TT, item.id)
            if UIForgeData.CheckCode(res:GetResult()) then
                self.data:InitList(unlock_architecture_list)
                GameGlobal.EventDispatcher():Dispatch(GameEventType.HomelandForgeUpdateList)
                ToastManager.ShowHomeToast(StringTable.Get("str_homeland_forge_unlock_success", item.name))
                GameGlobal.EventDispatcher():Dispatch(GameEventType.RefreshInteractUI)
                self:CloseDialog()
            end
            self:UnLock(key)
        end,
        self
    )
end

function UIForgeDetail:btnForgeOnClick(go)
    local s = self.data:Get1stIdleSequence()
    if not s then
        ToastManager.ShowHomeToast(StringTable.Get("str_homeland_forge_error_101"))
        return
    end
    self:StartTask(
        function(TT)
            local key = "CancelForgeTask"
            self:Lock(key)
            local item = self.data:GetForgeInfoItemById(self.id)
            local res, forge_list = self.mHomeland:HandleForge(TT, item.id, s.index)
            if UIForgeData.CheckCode(res:GetResult()) then
                ToastManager.ShowHomeToast(StringTable.Get("str_homeland_forge_start_forge", item.name)) --开始制造XXX
                self.data:InitSequence(forge_list)
                GameGlobal.EventDispatcher():Dispatch(GameEventType.HomelandForgeUpdateSequence)
                GameGlobal.EventDispatcher():Dispatch(GameEventType.HomelandForgeUpdateList)
            end
            self:UnLock(key)
            self:CloseDialog()
        end,
        self
    )
end
