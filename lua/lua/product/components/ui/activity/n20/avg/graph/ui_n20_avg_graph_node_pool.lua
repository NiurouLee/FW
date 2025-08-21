---@class UIN20AVGGraphNodePool:UICustomWidget
_class("UIN20AVGGraphNodePool", UICustomWidget)
UIN20AVGGraphNodePool = UIN20AVGGraphNodePool

function UIN20AVGGraphNodePool:Constructor()
    self.mCampaign = GameGlobal.GetModule(CampaignModule)
    self.data = self.mCampaign:GetN20AVGData()
end

function UIN20AVGGraphNodePool:OnShow()
    self.go = self:GetGameObject()
    ---@type UnityEngine.RectTransform
    self.rt = self.go:GetComponent(typeof(UnityEngine.RectTransform))
    UICommonHelper:GetInstance():RectTransformAnchor2Left(self.rt)
    self.root = self:GetGameObject("root")
    ---@type UICustomWidgetPool
    self.poolNormal = self:GetUIComponent("UISelectObjectPath", "normal")
    ---@type UICustomWidgetPool
    self.poolEnd = self:GetUIComponent("UISelectObjectPath", "end")
    ---@type UICustomWidgetPool
    self.poolHide = self:GetUIComponent("UISelectObjectPath", "hide")
    self.goNormal = self:GetGameObject("normal")
    self.goNormal:SetActive(false)
    self.goEnd = self:GetGameObject("end")
    self.goEnd:SetActive(false)
    self.goHide = self:GetGameObject("hide")
    self.goHide:SetActive(false)
end
function UIN20AVGGraphNodePool:OnHide()
end

---@param id  number 结点id
---@param endId number 结局id
function UIN20AVGGraphNodePool:Flush(id, endId)
    self.node = self.data:GetNodeById(id)
    if IsUnityEditor() then
        self.go.name = self.node.id .. self.node.title
    end
    if self.node:IsHide() then
        if self.node:IsSatisfyVisible() then
            self.root:SetActive(true)
            self:FlushPos()
            self.goNormal:SetActive(false)
            self.goEnd:SetActive(false)
            self.goHide:SetActive(true)
            ---@type UIN20AVGGraphNodeHide
            self.hide = self.poolHide:SpawnObject("UIN20AVGGraphNodeHide")
            self.hide:Flush(id)
            self.hide:FlushCurPos(endId)
        else
            self.root:SetActive(false)
        end
    else
        local state = self.node:State()
        if state then
            self.root:SetActive(true)
            self:FlushPos()
            self.goHide:SetActive(false)
            if self.node:IsEnd() and state ~= AVGStoryNodeState.CantPlay then
                self.goNormal:SetActive(false)
                self.goEnd:SetActive(true)
                ---@type UIN20AVGGraphNodeEnd
                self.ending = self.poolEnd:SpawnObject("UIN20AVGGraphNodeEnd")
                self.ending:Flush(id)
                self.ending:FlushCurPos(endId)
            else
                self.goNormal:SetActive(true)
                self.goEnd:SetActive(false)
                ---@type UIN20AVGGraphNodeNormal
                self.normal = self.poolNormal:SpawnObject("UIN20AVGGraphNodeNormal")
                self.normal:Flush(id)
                self.normal:FlushCurPos(endId)
            end
        else
            self.root:SetActive(false)
        end
    end
end
function UIN20AVGGraphNodePool:FlushPos()
    self.rt.anchoredPosition = self.node.pos
end

--region OnClick
function UIN20AVGGraphNodePool:normalOnClick(go)
    self:CheckShowDialogUIN20AVGNodeDetails(go)
end
function UIN20AVGGraphNodePool:endOnClick(go)
    self:CheckShowDialogUIN20AVGNodeDetails(go)
end
function UIN20AVGGraphNodePool:hideOnClick(go)
    self:StartTask(
        function(TT)
            if self.node:IsHideNew() then
                local key = "UIN20AVGGraphNodeOnClickNode"
                self:Lock(key)
                local nodeId = self.node.id
                local avgStoryMissionInfo = AVGStoryMissionInfo:New() --请求更新隐藏结点的New标记时，隐藏结点肯定没打过，N20AVGData:GetServerNodeDataByNodeId(nodeId)肯定返回nil，所以直接New一个AVGStoryMissionInfo即可
                avgStoryMissionInfo.mission_id = nodeId
                avgStoryMissionInfo.new_mark = false --New标记取消
                avgStoryMissionInfo.end_formation_info = AVGStoryFormationInfo:New()
                local hp, strategies = self.node:StartData()
                avgStoryMissionInfo.end_formation_info.leader_hp = hp
                avgStoryMissionInfo.end_formation_info.teammate_affinity = strategies
                local com = self.data:GetComponentAVG()
                local res = AsyncRequestRes:New()
                local ret = com:HandleUpdateNodeData(TT, res, avgStoryMissionInfo) ---【请求】更新结点New标记
                if N20AVGData.CheckCode(res) then
                    self.data:Update()
                    self.hide:FlushNew()
                    GameGlobal.EventDispatcher():Dispatch(GameEventType.AVGFlushNewRed)
                end
                self:UnLock(key)
            end
            self:ShowDialogUIN20AVGNodeDetails(go)
        end,
        self
    )
end
function UIN20AVGGraphNodePool:CheckShowDialogUIN20AVGNodeDetails(go)
    local state = self.node:State()
    if state == AVGStoryNodeState.CantPlay then
        return
    end
    self:ShowDialogUIN20AVGNodeDetails(go)
end
function UIN20AVGGraphNodePool:ShowDialogUIN20AVGNodeDetails(go)
    self:ShowDialog("UIN20AVGNodeDetails", self.node.id)
end
--endregion

function UIN20AVGGraphNodePool:GetWidgetHide()
    return self.hide
end
