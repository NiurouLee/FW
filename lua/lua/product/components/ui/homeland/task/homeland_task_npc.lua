---@class HomelandTaskNPC:Object
_class("HomelandTaskNPC", Object)
HomelandTaskNPC = HomelandTaskNPC

---@enum TaskNpcType
local TaskNpcType = {
    Role = 1, -- 指定资源角色
    Pet = 2, -- 光灵
}
_enum("TaskNpcType", TaskNpcType)

---@enum TaskNpcPetSkinType
local TaskNpcPetSkinType = {
    Base = 1, -- 基础皮肤
    Player = 2, -- 玩家当前设置皮肤
    Appointed = 3, -- 指定皮肤
}
_enum("TaskNpcPetSkinType", TaskNpcPetSkinType)

---@param homelandClient HomelandClient
function HomelandTaskNPC:Constructor(cfg, homelandClient)
    self.npcID = cfg.Id
    self.cfg = cfg
    self.homelandClient = homelandClient
    self.interactPointManager = homelandClient:InteractPointManager()
    self.taskManager = homelandClient:GetHomelandTaskManager()
    ---@type HomelandtraceManager
    self._homelandPetManager = self.homelandClient:PetManager()
    self.npcType = cfg.Type

    ---@type HomeTaskItem
    self.task = nil
    ---@type number
    self.chatID = nil

    ---@type table<number, ResRequest>
    self.resReqList = {}
    ---@type UnityEngine.Transform
    self.transform = nil
    ---@type UnityEngine.Animation
    self.npcAnim = nil
    ---@type Vector3
    self.position = Vector3.zero
    if self.npcType == TaskNpcType.Pet then
        self:InitPet()
    else
        self:InitRole()
    end

    ---@type HomeBuilding -- 唯一父建筑
    self._holdBuilding = nil 
end

function HomelandTaskNPC:InitPet()
    local resName = self.cfg.PetId .. ".prefab"
    if self.cfg.PetSkinType == TaskNpcPetSkinType.Appointed then
        Log.fatal("暂不支持指定皮肤")
    elseif self.cfg.PetSkinType == TaskNpcPetSkinType.Player then
        local pet = GameGlobal.GetModule(PetModule):GetPetByTemplateId(self.cfg.PetId)
        if pet then
            resName = pet:GetPetPrefab()
        end
        if  self._homelandPetManager:HasPet(self.cfg.PetId) then 
            local pet = self._homelandPetManager:GetPet(self.cfg.PetId)
            GameGlobal.EventDispatcher():Dispatch(GameEventType.OnHomeInteractFollow, false, pet)
        end 
    elseif self.cfg.PetSkinType == TaskNpcPetSkinType.Base then
        --do nothing
    end

    local petReq = ResourceManager:GetInstance():SyncLoadAsset(resName, LoadType.GameObject)
    local petAirPrefab = HelperProxy:GetInstance():GetPetAnimatorControllerName(resName,
        PetAnimatorControllerType.Aircraft)
    local petAnimReq = ResourceManager:GetInstance():SyncLoadAsset(petAirPrefab, LoadType.GameObject)
    local petHomePrefab = HelperProxy:GetInstance():GetPetAnimatorControllerName(resName,
        PetAnimatorControllerType.Homeland)
    local petHomelandAnimReq = ResourceManager:GetInstance():SyncLoadAsset(petHomePrefab, LoadType.GameObject)

    table.insert(self.resReqList, petReq)
    table.insert(self.resReqList, petAnimReq)
    table.insert(self.resReqList, petHomelandAnimReq)

    local petGameObject = petReq.Obj
    petGameObject:SetActive(true)

    self.transform = petGameObject.transform
    self.transform:SetParent(self.homelandClient:SceneManager():RuntimeRootTrans())
    local rootTrans = self.transform:Find("Root")
    local root = rootTrans.gameObject
    
    --隐藏武器
    for i = 0, rootTrans.childCount - 1 do
        local child = rootTrans:GetChild(i)
        if string.find(child.name, "weapon") then
            child.gameObject:SetActive(false)
        end
    end

    local animator = root:GetComponent(typeof(UnityEngine.Animator))
    if animator then
        UnityEngine.Object.Destroy(animator) --局内用Animator，销毁
    end
    ---@type UnityEngine.Animation
    local petAnim = root:AddComponent(typeof(UnityEngine.Animation))

    local aircraftAnimation = petAnimReq.Obj:GetComponent("Animation")
    local clips = HelperProxy:GetInstance():GetAllAnimationClip(aircraftAnimation)
    for i = 0, clips.Length - 1 do
        if clips[i] == nil then
            Log.error("Pet animation is null:", self._petID, ", index:", i)
        else
            petAnim:AddClip(clips[i], clips[i].name)
        end
    end

    local homelandAnimation = petHomelandAnimReq.Obj:GetComponent("Animation")
    clips = HelperProxy:GetInstance():GetAllAnimationClip(homelandAnimation)
    for i = 0, clips.Length - 1 do
        if clips[i] == nil then
            Log.error("Pet animation is null:", self._petID, ", index:", i)
        else
            petAnim:AddClip(clips[i], clips[i].name)
        end
    end

    petAnim.clip = aircraftAnimation.clip
    petAnim:Play(HomelandPetAnimName.Stand)

    self.npcAnim = petAnim

    self.taskManager:AddNpcOccupyingPet(self.cfg.PetId)
end

function HomelandTaskNPC:InitRole()
    local rolePrefab = self.cfg.Res
    local roleReq = ResourceManager:GetInstance():SyncLoadAsset(rolePrefab, LoadType.GameObject)

    table.insert(self.resReqList, roleReq)

    local roleGameObject = roleReq.Obj
    roleGameObject:SetActive(true)
    self.transform = roleGameObject.transform
    self.transform:SetParent(self.homelandClient:SceneManager():RuntimeRootTrans())
    local root = self.transform:Find("Root").gameObject
    local roleAnim = root:GetComponent(typeof(UnityEngine.Animation))

    --roleAnim:Play(HomelandPetAnimName.Stand)

    self.npcAnim = roleAnim
end

function HomelandTaskNPC:Destroy()
    self:ResetInteractPoint()

    for _, req in ipairs(self.resReqList) do
        req:Dispose()
    end

    self.resReqList = {}

    if self.npcType == TaskNpcType.Pet then
        self.taskManager:RemoveNpcOccupyingPet(self.cfg.PetId)
    end

    if self._onTalkCheck then
        GameGlobal.EventDispatcher():RemoveCallbackListener(GameEventType.OnTalkCheck, self._onTalkCheck)
        self._onTalkCheck = nil
    end

    if self._onUIHomePetInteractTaskClose then
        GameGlobal.EventDispatcher():RemoveCallbackListener(GameEventType.OnUIHomePetInteractTaskClose,
            self._onUIHomePetInteractTaskClose)
        self._onUIHomePetInteractTaskClose = nil
    end
end

---@param task HomeTaskItem
function HomelandTaskNPC:SetTask(task)
    self.task = task

    self._onTalkCheck = GameHelper:GetInstance():CreateCallback(self.OnTalkCheck, self)
    GameGlobal.EventDispatcher():AddCallbackListener(GameEventType.OnTalkCheck, self._onTalkCheck)

    -- self._onApplicationQuit = GameHelper:GetInstance():CreateCallback(self.ApplicationQuit,self)
    -- GameGlobal.EventDispatcher():AddCallbackListener(GameEventType.ApplicationQuit, self._onApplicationQuit)

    -- Npc 对话关闭
    self._onUIHomePetInteractTaskClose = GameHelper:GetInstance():CreateCallback(self.OnUIHomePetInteractTaskClose, self)
    GameGlobal.EventDispatcher():AddCallbackListener(GameEventType.OnUIHomePetInteractTaskClose,
        self._onUIHomePetInteractTaskClose)
end

function HomelandTaskNPC:OnTalkCheck(checkNpcId, chatId, talkId)
    if checkNpcId ~= self.npcID then
        return
    end
    local conditionInfo = self.task:GetConditionInfo()
    if conditionInfo.FinishType == FinishConditionEnum.Dialog then
        if self.checkchatId == chatId and self.checktalkId == talkId then
            self.task:StartSubmitTaskImmediatelyCoro()
        end
    end

    if conditionInfo.FinishType == FinishConditionEnum.PetSearch then
        if self.task:CheckPetSearch() and self.checkchatId == chatId and self.checktalkId == talkId then
            self.task:StartSubmitTaskImmediatelyCoro()
        end
    end

    if conditionInfo.FinishType == FinishConditionEnum.PetNeed then
        if self.task:CheckPetNeed() and self.checkchatId == chatId and self.checktalkId == talkId then
            self.task:StartSubmitTaskImmediatelyCoro()
        end
    end
end

function HomelandTaskNPC:OnUIHomePetInteractTaskClose(checkNpcId, chatId, talkId)
    if self.npcID ~= checkNpcId then
        return
    end
    local conditionInfo = self.task:GetConditionInfo()
    if conditionInfo.FinishType == FinishConditionEnum.Dialog then
        if self.checkchatId == chatId and self.checktalkId == talkId then
            self.task:GetRewardsImmediately(self)
        end
    end
    if conditionInfo.FinishType == FinishConditionEnum.PetSearch then
        -- self.task:CheckPetSearch() and
        if self.checkchatId == chatId and self.checktalkId == talkId then
            self.task:GetRewardsImmediately(self)
        end
    end
    if conditionInfo.FinishType == FinishConditionEnum.PetNeed then
        --self.task:CheckPetNeed() and
        if self.checkchatId == chatId and self.checktalkId == talkId then
            self.task:GetRewardsImmediately(self)
        end
    end
end

function HomelandTaskNPC:ApplicationQuit(talkId)
    local conditionInfo = self.task:GetConditionInfo()
    if conditionInfo.FinishType == FinishConditionEnum.Dialog then
        -- self.task:SubmitTask(true, self
    end
end

function HomelandTaskNPC:SetParent(parent)
    self.transform:SetParent(parent)
end

function HomelandTaskNPC:SetHoldBuilding(building)
    self._holdBuilding = building
end

function HomelandTaskNPC:SetLocation(x, y, z, rotationY,isLocal)
    local vec = Vector3(x, y, z)
    if isLocal then
        self.transform.localPosition = vec
        self.transform.localEulerAngles = Vector3(0, rotationY, 0)
        self.position = self.transform.position
        self.eulerAngles = self.transform.eulerAngles
    else 
        self.transform.position = vec
        self.transform.eulerAngles = Vector3(0, rotationY, 0)
        self.position = self.transform.position
        self.eulerAngles = self.transform.eulerAngles
    end
    if not self.navMeshAgent then
        self.navMeshAgent = self.transform.gameObject:AddComponent(typeof(UnityEngine.AI.NavMeshAgent))
        self.navMeshAgent.agentTypeID = HelperProxy:GetInstance():GetNavAgentID(AircraftNavAgent.Normal)
        self.navMeshAgent.avoidancePriority = 30
        self.navMeshAgent.radius = 0.2
        self.navMeshAgent.areaMask = 1
    end
    
    local hit, navMeshHit = UnityEngine.AI.NavMesh.SamplePosition(self.transform.position, nil, 10, 1)
    if hit then
        self.transform.position = navMeshHit.position
        self.navMeshAgent.enabled = false
        self.navMeshAgent.enabled = true
    end
    --end

    self.npcAnim:Play(HomelandPetAnimName.Stand)
    self.position = self.transform.position

    local navMeshObstacle = self.transform.gameObject:GetComponent(typeof(UnityEngine.AI.NavMeshObstacle))
    if navMeshObstacle then
        navMeshObstacle.enabled = false
    end
end

function HomelandTaskNPC:SetChatID(chatID)
    self.chatID = chatID
end

function HomelandTaskNPC:SetCheckTalkID(chatId, talkId)
    self.checkchatId = chatId
    self.checktalkId = talkId
end

function HomelandTaskNPC:InitInteract()
    self:RefreshInteractPoint()
end

function HomelandTaskNPC:SetVisible(visible)
    if self.transform then
        self.transform.gameObject:SetActive(visible)
    end

    if visible then
        --if not self.navMeshAgent.isOnNavMesh then
        local hit, navMeshHit = UnityEngine.AI.NavMesh.SamplePosition(self.transform.position, nil, 10, 1)
        if hit then
            self.transform.position = navMeshHit.position
            self.navMeshAgent.enabled = false
            self.navMeshAgent.enabled = true
        end
        --end

        self.npcAnim:Play(HomelandPetAnimName.Stand)
        self.position = self.transform.position
    end
end

--- ===================================== 交互点相关 ===========================================
function HomelandTaskNPC:GetInteractPosition()
    return self.transform.position
end

function HomelandTaskNPC:GetName()
    return StringTable.Get(self.cfg.Name)
end

function HomelandTaskNPC:RefreshInteractPoint()
    if self.interactPoint then
        self.interactPointManager:RemoveBuildInteractPoint(self.interactPoint)
    end
    self.interactPoint = self.interactPointManager:AddBuildInteractPoint(self, nil, InteractPointType.TaskNpc)
end

function HomelandTaskNPC:ResetInteractPoint()
    if not self.interactPoint then
        return
    end
    if self.interactPoint then
        self.interactPointManager:RemoveBuildInteractPoint(self.interactPoint)
    end
end

---@param pointType InteractPointType
function HomelandTaskNPC:Interact()
    local custom = {
        [FinishConditionEnum.PetInteraction] = self.Interact_PetInteraction,
        [FinishConditionEnum.NpcInteraction] = self.Interact_NpcInteraction
    }
    local conditionInfo = self.task:GetConditionInfo()
    local func = custom[conditionInfo.FinishType]
    if func then
        func(self, conditionInfo)
        if conditionInfo.FinishType == FinishConditionEnum.PetInteraction and 
            self.npcID == conditionInfo.ChatTargetId[1] then
            return
        end
    end

    --[[
    --对话结束还原朝向
    local callback = function()
        if self.eulerAngles then
            self.transform:DORotate(self.eulerAngles, 0.1)
        end
    end
    ]]

    --单纯对话
    if self.chatID then
        local args = { self.npcID, self.checkchatId, self.checktalkId }
        if conditionInfo.FinishType == FinishConditionEnum.PetSearch or
            conditionInfo.FinishType == FinishConditionEnum.PetNeed then
            local item, itemcount = self.task:GetCheckItem()
            args[4] = item
            args[5] = itemcount
        end
        GameGlobal.UIStateManager():ShowDialog("UIHomePetInteract", self, nil, self.chatID, args)
    end
end

function HomelandTaskNPC:Interact_PetInteraction(conditionInfo)
    if self.npcID == conditionInfo.ChatTargetId[1] then
        --转向主角
        local charTrans = self.homelandClient:CharacterManager():GetCharacterTransform()
        local toward = charTrans.position - self.transform.position
        toward.y = 0
        self.transform:DORotate(Quaternion.LookRotation(toward).eulerAngles, 0.1)

        self.task:SubmitTask(true, self)
    end
end

function HomelandTaskNPC:Interact_NpcInteraction(conditionInfo)
    if self.npcID == conditionInfo.ChatTargetId[1] then
        local id = conditionInfo.FinishEffectId
        GameGlobal.UIStateManager():ShowDialog(
            "UIHomelandTaskFinishEffect",
            id,
            self.transform, -- 用于 npc 转向 mc
            self.transform.position, -- 用于 mc 转向目标位置
            function()
                self.task:SubmitTask(true, self)
            end
        )
    end
end

function HomelandTaskNPC:GetInteractRedStatus(pointType, index)
    return false
end

--- =================================================================================


--- ===================================== 通用剧情相关 ===========================================
function HomelandTaskNPC:AgentTransform()
    return self.transform
end

function HomelandTaskNPC:GetRotation()
    return self.transform.rotation
end

function HomelandTaskNPC:SetRotation(rotation)
    self.transform.rotation = rotation
end

function HomelandTaskNPC:PetName()
    return StringTable.Get(self.cfg.Name)
end

function HomelandTaskNPC:GetBody(face)
    if self.npcType == TaskNpcType.Pet then
        local lFace
        if face then
            lFace = face
        else
            lFace = "Norm"
        end
        local icon = ""
        local tid = self.cfg.PetId
        local skinid = Cfg.cfg_pet[tid].SkinId

        if self.cfg.PetSkinType == TaskNpcPetSkinType.Appointed then
            Log.fatal("暂不支持指定皮肤")
        elseif self.cfg.PetSkinType == TaskNpcPetSkinType.Player then
            local pet = GameGlobal.GetModule(PetModule):GetPetByTemplateId(self.cfg.PetId)
            if pet then
                skinid = pet:GetSkinId()
            end
        elseif self.cfg.PetSkinType == TaskNpcPetSkinType.Base then
            -- do nothing
        end

        local cfg = Cfg.cfg_home_pet_story_face[skinid]
        if cfg then
            icon = cfg[lFace]
            if not icon then
                icon = ""
                Log.error("###[HomelandTaskNPC] icon is nil ! id --> ", skinid, ",_face --> ", lFace)
            end
        else
            icon = "base_icon_" .. tid
            Log.error("###[HomelandTaskNPC] cfg is nil ! id --> ", skinid)
        end
        return icon
    else
        return self.cfg.ResIcon
    end
end

function HomelandTaskNPC:PlayAnimAndReturnTime(animName)
    local time = 0
    local clip = self.npcAnim:GetClip(animName)
    if clip then
        time = clip.length
    end
    self.npcAnim:CrossFade(animName, 0.2)
    return time
end

--- =================================================================================
function HomelandTaskNPC:GetPetConfig()
    return self.cfg
end
--临时处理
function HomelandTaskNPC:PlayBubble()
    return 0
end

--临时处理
function HomelandTaskNPC:NpcID()
    return self.npcID
end

--临时处理
function HomelandTaskNPC:PetID()
    return self.cfg.PetId
end
--临时处理
function HomelandTaskNPC:GetTask()
    return self.task
end


