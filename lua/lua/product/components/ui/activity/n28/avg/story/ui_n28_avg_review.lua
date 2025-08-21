---@class UIN28AVGReview:UIController
_class("UIN28AVGReview", UIController)
UIN28AVGReview = UIN28AVGReview

function UIN28AVGReview:Constructor()
    self.mCampaign = GameGlobal.GetModule(CampaignModule)
    self.data = self.mCampaign:GetN28AVGData()
    self._storyManager = self.data:StoryManager()
end

function UIN28AVGReview:OnShow(uiParams)
    ---@type UIDynamicScrollView 剧情回看列表
    self._dialogReviewScrollView = self:GetUIComponent("UIDynamicScrollView", "sv")

    self:Flush()
end

function UIN28AVGReview:OnHide()
end

function UIN28AVGReview:Flush()
    self._dialogReviewScrollView:InitListView(
        0,
        function(scrollview, index)
            return self:_OnGetReviewDialogItem(scrollview, index)
        end
    )
    self._dialogReviewScrollView.mOnDragingAction = function()
        self._reviewDragged = true
    end

    local dialogRecord = self._storyManager:GetDialogRecord()
    self._dialogReviewScrollView:SetListItemCount(#dialogRecord, true)
    self._dialogReviewScrollView:MovePanelToItemIndex(#dialogRecord - 1, 0)
end
--回看列表填充内容回调方法
---@param scrollview UIDynamicScrollView 剧情回看列表
function UIN28AVGReview:_OnGetReviewDialogItem(scrollview, index)
    local dialogRecord = self._storyManager:GetDialogRecord()
    local item = scrollview:NewListViewItem("RowItem")
    local rowPool = self:GetUIComponentDynamic("UISelectObjectPath", item.gameObject)
    if item.IsInitHandlerCalled == false then
        item.IsInitHandlerCalled = true
        rowPool:SpawnObjects("UIN28AVGReviewItem", 1)
    end
    local luaIndex = index + 1
    if #dialogRecord >= luaIndex then
        ---@type UIN28AVGReviewItem[]
        local rowList = rowPool:GetAllSpawnList()
        local itemWidget = rowList[1]
        local speakerName = dialogRecord[luaIndex][1]
        local content = dialogRecord[luaIndex][2]
        local isPlayer = false
        if dialogRecord[luaIndex][4] then
            isPlayer = true
        end
        itemWidget:Flush(speakerName, content,isPlayer,function()
            self:ImgCloseOnClick()
        end)
        UIHelper.RefreshLayout(item:GetComponent("RectTransform"))
        return item
    else
        return nil
    end
end

--region OnClick
function UIN28AVGReview:ImgCloseOnClick(go)
    self:CloseDialog()
end
--endregion
