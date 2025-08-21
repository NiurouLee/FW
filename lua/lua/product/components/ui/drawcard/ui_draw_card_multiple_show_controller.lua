---@class UIDrawCardMultipleShowController:UIController
_class("UIDrawCardMultipleShowController", UIController)
UIDrawCardMultipleShowController = UIDrawCardMultipleShowController

function UIDrawCardMultipleShowController:Constructor()
    self.star2effBehind = {
        [4] = "uieff_cardshow_bg_purple.prefab",
        [5] = "uieff_cardshow_bg_gold.prefab",
        [6] = "uieff_cardshow_bg_orange.prefab"
    }
    self.star2effBg = {
        [4] = "uieff_cardshow_bgCanvas_purple.prefab",
        [5] = "uieff_cardshow_bgCanvas_gold.prefab",
        [6] = "uieff_cardshow_bgCanvas_orange.prefab"
    }
end

function UIDrawCardMultipleShowController:OnShow(uiParams)
    --ui相机后处理
    local uiCam = GameGlobal.UIStateManager():GetControllerCamera("UIDrawCardMultipleShowController")
    ---@type UnityEngine.H3DPostProcessing.PostProcessing
    local post = uiCam.gameObject:AddComponent(typeof(UnityEngine.H3DPostProcessing.PostProcessing))
    local postAsset = self:GetAsset("Test_Post_Chouka.asset", LoadType.Asset)
    post.profile = postAsset
    self._cameraPost = post
    --打开HDR，
    uiCam.allowHDR = true
    self._uiCamera = uiCam

    self._petModule = self:GetModule(PetModule)

    ---@type UIDrawCardViewData
    self.data = uiParams[1]
    --cards
    local cards = self.data:GetCards()

    if #cards ~= 10 then
        Log.exception("多抽结果不是10张：", #cards)
    end

    --音效
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.DrawCard_shilian)
    self._itemsCard = {}
    ---@type UIDrawCardViewData
    self.itemPool = self:GetGameObject("items")
    self.itemColorPool = self:GetGameObject("itemsColor")
    self.itemsEff = self:GetGameObject("itemsEff")
    self._effTargetPos = self:GetUIComponent("Transform", "effTargetPos")

    --LoadBgEff 最高星特效
    self._bgEffRoot = self:GetUIComponent("Transform", "bgeff")
    local maxStar = self.data:GetMaxStar()
    self.maxStarId = self.data:GetMaxStarId()

    ---@type GambleModule
    self.gambleModule = self:GetModule(GambleModule)
    self.gambleModule:Context():SetMaxStarPetId(maxStar, self.maxStarId)

    local effBgName = self.star2effBg[maxStar]
    if effBgName then
        local bgeff = self:GetAsset(effBgName, LoadType.GameObject)
        bgeff.transform:SetParent(self._bgEffRoot, false)
        bgeff:SetActive(true)
    else
        Log.fatal("###drawcard -- the load eff is nil ! [self.star2effBg] star --> ", maxStar)
    end

    local colorGo_Table = {}
    local colorRow_Table = {}

    ---@type UnityEngine.Transform
    local itemsColorTr = self.itemColorPool.transform
    for i = 1, itemsColorTr.childCount do
        local row = itemsColorTr:GetChild(i - 1)

        table.insert(colorRow_Table, row.gameObject)

        for j = 1, row.childCount do
            local color = row:GetChild(j - 1).gameObject

            table.insert(colorGo_Table, color)
        end
    end

    local cardGo_Table = {}
    local cardRow_Table = {}
    ---@type UnityEngine.Transform
    local itemsCardTr = self.itemPool.transform
    for i = 1, itemsCardTr.childCount do
        local row = itemsCardTr:GetChild(i - 1)
        table.insert(cardRow_Table, row.gameObject)

        for j = 1, row.childCount do
            local card = row:GetChild(j - 1).gameObject

            table.insert(cardGo_Table, card)
        end
    end

    self._effGo_Table = {}
    local effRow_Table = {}

    ---@type UnityEngine.Transform
    local itemsEffTr = self.itemsEff.transform
    for i = 1, itemsEffTr.childCount do
        local row = itemsEffTr:GetChild(i - 1)
        table.insert(effRow_Table, row.gameObject)
        for j = 1, row.childCount do
            local eff = row:GetChild(j - 1).gameObject
            table.insert(self._effGo_Table, eff)
        end
    end
    -------------------------------------------------------------------------------

    --row 多抽数量必定是10，不用再考虑其他情况
    -- if #cards <= 5 then
    --     colorRow_Table[2]:SetActive(false)
    --     cardRow_Table[2]:SetActive(false)
    --     effRow_Table[2]:SetActive(false)

    --     local tr
    --     tr = colorRow_Table[1].gameObject:GetComponent("RectTransform")
    --     tr.anchoredPosition = Vector2(tr.anchoredPosition.x, 0)
    --     tr = cardRow_Table[1].gameObject:GetComponent("RectTransform")
    --     tr.anchoredPosition = Vector2(tr.anchoredPosition.x, 0)
    --     tr = effRow_Table[1].gameObject:GetComponent("RectTransform")
    --     tr.anchoredPosition = Vector2(tr.anchoredPosition.x, 0)
    -- end
    --color
    self._eff_color_Tab = {}
    self._eff_color_Tab[4] = {}
    self._eff_color_Tab[5] = {}
    self._eff_color_Tab[6] = {}

    for i = 1, table.count(colorGo_Table) do
        local g = colorGo_Table[i]
        g:SetActive(true)
        local id = cards[i].assetid
        local cfg_pet = Cfg.cfg_pet[id]
        local star = cfg_pet.Star
        if star > 3 then
            local effName = self.star2effBehind[star]
            local eff = ResourceManager:GetInstance():SyncLoadAsset(effName, LoadType.GameObject)
            local value = {}
            value.star = star
            value.eff = eff
            value.root = g
            table.insert(self._eff_color_Tab[star], value)
        end
    end
    --card
    for i = 1, table.count(cardGo_Table) do
        local g = cardGo_Table[i]
        local view = UIDrawCardMultipleShowItem:New()
        local uiview = g:GetComponent(typeof(UIView))
        view:SetData(
            i,
            cards[i].assetid,
            uiview,
            function(idx)
                return self:CheckNewPet(idx)
            end
        )
        self._itemsCard[i] = view
        g:SetActive(true)
    end
    -------------------------------------------------------------------------------
    --播视频
    ---@type UnityEngine.Video.VideoPlayer
    local player = self:GetUIComponent("VideoPlayer", "Light")
    local url = HelperProxy:GetInstance():GetVideoUrl("uieff_Card_Mult.mp4")
    player.url = url
    player:Prepare()
    self._videoTimer =
        GameGlobal.Timer():AddEvent(
        670,
        function()
            player:Play()
            self._videoTimer = nil
        end
    )
    -------------------------------------------------------------------------------
    self.canClose = false
    --时间一定要超过协程等待的时间（注意）
    local delayTime = Cfg.cfg_drawcard_value[1].Value

    self.delayTimer =
        GameGlobal.Timer():AddEvent(
        delayTime,
        function()
            self.canClose = true
            self.delayTimer = nil
        end
    )

    self._audio = AudioHelperController.PlayRequestedUISound(CriAudioIDConst.Drawcard_mul_show)
    self:StartTask(self.ShowEffTask, self)
end
function UIDrawCardMultipleShowController:ShowEffTask(TT)
    YIELD(TT, 1300)
    local idx = 6
    for i = 1, 3 do
        if #self._eff_color_Tab[idx] > 0 then
            for j = 1, #self._eff_color_Tab[idx] do
                local obj = self._eff_color_Tab[idx][j].eff.Obj
                local root = self._eff_color_Tab[idx][j].root
                obj.transform:SetParent(root.transform, false)
                obj:SetActive(true)
            end
            YIELD(TT, 50)
        end
        idx = idx - 1
    end
end

function UIDrawCardMultipleShowController:CheckNewPet(idx)
    return self.data:IsNewPet(idx)
end

function UIDrawCardMultipleShowController:OnHide()
    if self.delayTimer then
        GameGlobal.Timer():CancelEvent(self.delayTimer)
        self.delayTimer = nil
    end
    if self._videoTimer then
        GameGlobal.Timer():CancelEvent(self._videoTimer)
        self._videoTimer = nil
    end
    for i = 1, #self._itemsCard do
        self._itemsCard[i]:OnHide()
    end
    for key, value in pairs(self._eff_color_Tab) do
        for k, v in pairs(value) do
            v.eff:Dispose()
        end
    end

    UnityEngine.Object.Destroy(self._cameraPost)
    self._uiCamera.allowHDR = false
    UIBgmHelper.PlayMainBgm()
    AudioHelperController.StopUISound(self._audio)
end

function UIDrawCardMultipleShowController:MaskOnClick()
    if self.canClose then
        self:Lock("UIDrawCardMultipleShowController:MaskOnClick")
        self:StartTask(self._OnMaskOnClick, self)
    end
end

function UIDrawCardMultipleShowController:_OnMaskOnClick(TT)
    for i = 1, #self._effGo_Table do
        local g = self._effGo_Table[i]
        local effStar = g.transform:GetChild(0)
        effStar.gameObject:SetActive(not self:CheckNewPet(i))
        effStar:DOMove(self._effTargetPos.position, 0.4):OnComplete(
            function()
                effStar.gameObject:SetActive(false)
            end
        )
    end
    YIELD(TT, 400)
    self:UnLock("UIDrawCardMultipleShowController:MaskOnClick")

    local items = self.data:GetItems()
    if items and #items > 0 then
        self:ShowDialog(
            "UIGetItemController",
            items,
            function()
                AudioHelperController.UnpauseBGM()
                -- self:SwitchState(UIStateType.UIDrawCard)
                --self:SwitchState(UIStateType.UIDrawCardController)
                self:Manager():CloseAllDialogOverLayerWithName("UIDrawCardController")
                GameGlobal.EventDispatcher():Dispatch(GameEventType.RefreshRecuitUIView)
            end
        )
    else
        AudioHelperController.UnpauseBGM()
        -- self:SwitchState(UIStateType.UIDrawCard)
        --self:SwitchState(UIStateType.UIDrawCardController)
        self:Manager():CloseAllDialogOverLayerWithName("UIDrawCardController")
        GameGlobal.EventDispatcher():Dispatch(GameEventType.RefreshRecuitUIView)
    end
end
