--
---@class UIMedalBgListController : UIController
_class("UIMedalBgListController", UIController)
UIMedalBgListController = UIMedalBgListController

function UIMedalBgListController:Constructor()
    ---@type UIMedalBgListData
    self.data = nil

    self._timeEvents = nil
    self.medalList = nil  --服务端勋章列表
    self.contentWidgets = nil
    self.curSelectMedalItem = nil --当前选中的勋章
    self.fadeTime = nil --淡化时间
    self.preRawImgName = nil  --上一个勋章板图片
    self._anim = nil 
    self.isFirst = nil
end

--初始化
function UIMedalBgListController:OnShow(uiParams)
    self.isFirst = true
    self.fadeTime = 0.5
    self.contentWidgets = {}
    self.medalList = {}
    self._timeEvents = {}
    self:InitWidget()
    self:GetMedalBoardVal()
    self:InitScrollView(self.data:GetSortMedals())
end

--获得勋章板数据
function  UIMedalBgListController:GetMedalBoardVal()
    local medalModule = GameGlobal.GetModule(MedalModule)
    --从服务端获取勋章板数据
    medalModule:Init()
    self.medalList = medalModule:GetMedalBoardVec()
    ---@type UIMedalBgListData
    self.data = UIMedalBgListData:New()

    self.data:Init(self.medalList)
    self.topInfo1:SetText(self.data:GetUnLockNum())
    local totalText = "/"..self.data:GetTotalNum()
    self.topInfo2:SetText(totalText) 
end

--获取ui组件
function UIMedalBgListController:InitWidget()
    self.topTitle = self:GetUIComponent("UILocalizationText", "topTitle")
    self.topInfo1 = self:GetUIComponent("UILocalizationText", "topInfo1")
    self.topInfo2 = self:GetUIComponent("UILocalizationText", "topInfo2")
    self.mainImg = self:GetUIComponent("RawImageLoader", "mainImg")
    self.mainRawImg = self:GetUIComponent("RawImage", "mainImg")
    self.preImg = self:GetUIComponent("RawImageLoader", "preImg")
    self.contentTitle = self:GetUIComponent("UILocalizationText", "contentTitle")
    self.contentInfo = self:GetUIComponent("UILocalizationText", "contentInfo")
    self.contentGet = self:GetUIComponent("RollingText", "contentGet")
    self.scrollViewContent = self:GetUIComponent("UISelectObjectPath", "scrollViewContent")
    self.contentGetParent = self:GetUIComponent("RectTransform", "contentGetParent")
    self._anim = self:GetUIComponent("Animation", "safeArea")
    
    local topButton = self:GetUIComponent("UISelectObjectPath", "topbtn")
    ---@type UICommonTopButton
    self.topButtonWidget = topButton:SpawnObject("UICommonTopButton")
    self.topButtonWidget:SetData(
        function()
            self._anim:Play("uieff_UIMedalBgListController_out")
            self:_LockAnim(167)
            GameGlobal.Timer():AddEvent(167,function()
                self:CloseDialog()
            end)
        end
    )
end

--初始化滑动列表
function UIMedalBgListController:InitScrollView(medalList)
    self.contentWidgets = self.scrollViewContent:SpawnObjects("UIMedalBgListItem",self.data:GetTotalNum())
    local index = 1

    for i,v in pairs(medalList) do
        self.contentWidgets[index]:SetData(v,
        function(item)
            self:OnMedalBgItemClicked(item)
        end)
        if v.medal_id == self.data:GetDefMedalID() then
            self.contentWidgets[index]:MedalBtnOnClick()
        end
        index = index + 1
    end
end

--勋章板按钮点击
function UIMedalBgListController:OnMedalBgItemClicked(item)
    self:_ReflashMedalList()
    local itemData = item:GetData()
    if self.curSelectMedalItem and self.curSelectMedalItem:GetID() == itemData.medal_id then
        return
    end
    
    if self.curSelectMedalItem then
        self.curSelectMedalItem:SetSelect(false)
    end
    self.curSelectMedalItem = item
    self.curSelectMedalItem:SetSelect(true)
    self:_ReflashRight(item)
end

--刷新左边按钮滑动列表
function UIMedalBgListController:_ReflashMedalList()
    for i,v in pairs(self.contentWidgets) do
        v:SetSelect(false)
    end
end

--点击勋章板刷新右边详情
--@param data 勋章板信息
function UIMedalBgListController:_ReflashRight(item)
    local medalData = self.data:GetMedalDataByID(item:GetID())
    if not medalData then
        Log.fatal("没找到该勋章板")
        return
    end
    if self.isFirst then
        self.isFirst = false
    else
        self._anim:Play("uieff_UIMedalBgListController_in2")
    end
    self:_FadeBoard(medalData.IconHD)
    local cfg = Cfg.cfg_item[medalData.ID]
    self.contentTitle:SetText(StringTable.Get(cfg.Name))
    self.contentInfo:SetText(StringTable.Get(cfg.RpIntro))
    self.contentGet:RefreshText(StringTable.Get(medalData.GetPathDesc))
    UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.contentGetParent)
end

--勋章板淡化
function UIMedalBgListController:_FadeBoard(IconHD)
    self.mainRawImg:DOFade(1,0)
    if self.preRawImgName then
        self.mainImg:LoadImage(self.preRawImgName)
        self.mainRawImg:DOFade(0,self.fadeTime)
    else
        self.mainRawImg:DOFade(0,0)
    end
    self.preImg:LoadImage(IconHD)
    self.preRawImgName = IconHD
end


function UIMedalBgListController:_LockAnim(timeLen)
    self:Lock("UIMedalBgListController_LockAnim")
    local te = GameGlobal.Timer():AddEvent(
        timeLen,
        function()
            self:UnLock("UIMedalBgListController_LockAnim")
        end
    )
    table.insert(self._timeEvents,te)
end