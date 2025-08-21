---入住界面星灵Item的prefab
---@class UIAircraftEnterBuildPetPrefab : UICustomWidget
_class("UIAircraftEnterBuildPetPrefab", UICustomWidget)
UIAircraftEnterBuildPetPrefab = UIAircraftEnterBuildPetPrefab

function UIAircraftEnterBuildPetPrefab:OnShow(uiParams)
    --选中
    self._multi = self:GetGameObject("multi")

    ---@type RawImageLoader
    self._drawIcon = self:GetUIComponent("RawImageLoader", "drawIcon")

    ---@type UILocalizationText
    self._nameText = self:GetUIComponent("UILocalizationText", "name")
    self._enDown = self:GetUIComponent("UILocalizationText", "enDown")

    ---@type UISelectObjectPath
    self._skills = self:GetUIComponent("UISelectObjectPath", "skills")

    --工作状态
    self._roomTypeText = self:GetUIComponent("UILocalizationText", "roomTypeText")
    self._roomTypeGo = self:GetGameObject("roomTypeGo")
    self._roomTypeRect = self:GetUIComponent("RectTransform", "roomTypeGo")

    self._stars = self:GetUIComponent("UISelectObjectPath", "stars")
    ---@type UnityEngine.U2D.SpriteAtlas
    self.atlasProperty = self:GetAsset("Property.spriteatlas", LoadType.SpriteAtlas)
    ---@type UnityEngine.UI.Image
    self._element = self:GetUIComponent("Image", "element")

    self._sp = self:GetGameObject("sp")
    self._spTex = self:GetUIComponent("RollingText", "spTex")

    self:AttachEvent(GameEventType.AircraftEnterClearPetList, self.AircraftEnterClearPetList)
end

--清空选择
function UIAircraftEnterBuildPetPrefab:AircraftEnterClearPetList(pstid)
    self._multi:SetActive(pstid == self._pstid)
end

--赋值
function UIAircraftEnterBuildPetPrefab:OnValue()
    --工作状态
    self:GetWorkState()

    --立绘
    self._drawIcon:LoadImage(self._pet:GetPetAircraftBody(PetSkinEffectPath.BODY_INTO_AIRCRAFT_AIRBODY))

    local cfg_pet_element = Cfg.cfg_pet_element {}

    self._element.sprite =
        self.atlasProperty:GetSprite(
        UIPropertyHelper:GetInstance():GetColorBlindSprite(cfg_pet_element[self._pet:GetPetFirstElement()].Icon)
    )

    --名字
    ---@type UILocalizationText
    self._nameText:SetText(StringTable.Get(self._pet:GetPetName()))

    --MSG19965	【需测试】入驻界面与入驻信息界面内容信息统一
    --隐藏英文名
    -- self._enDown:SetText(StringTable.Get(self._pet:GetPetEnglishName()))

    --星星
    local petStar = self._pet:GetPetStar()
    local petAwake = self._pet:GetPetAwakening()
    self._stars:SpawnObjects("UIAircraftEnterBuildStarItem", petStar)
    local stars = self._stars:GetAllSpawnList()
    for i = 1, #stars do
        local sprite = nil
        if i <= petAwake then
            sprite = self._sprite_xing_1
        else
            sprite = self._sprite_xing_2
        end
        stars[i]:SetData(sprite)
    end

    --工作技能
    local len = table.count(self._skillState)
    self._skills:SpawnObjects("UIAircraftPetWorkSkillPrefab", len)
    local pools = self._skills:GetAllSpawnList()
    for i = 1, len do
        pools[i]:SetData(i, self._skillState[i], self._currentRoomType)
    end

    self:AircraftEnterClearPetList(self._currid)

    self:Sp()
end
function UIAircraftEnterBuildPetPrefab:Sp()
    --获取所有的已入住的星灵
    if self._spPet then
        self._sp:SetActive(true)
        local tex = StringTable.Get("str_aircraft_sp_enter_tex", StringTable.Get(self._spPet:GetPetName()))
        self._spTex:RefreshText(tex)
    else
        self._sp:SetActive(false)
    end
end
function UIAircraftEnterBuildPetPrefab:GetWorkState()
    if not self._room then
        self._roomTypeGo:SetActive(false)
    else
        self._roomTypeGo:SetActive(true)
        local roomtype = self._room:GetRoomType()

        self._roomTypeText:SetText(StringTable.Get(self._room:GetRoomName()))
    end
end

---@param petInfo Pet 星灵类
function UIAircraftEnterBuildPetPrefab:SetData(
    index,
    spirit_xing_1,
    spirit_xing_2,
    petInfo,
    callback,
    room,
    currid,
    spaceid,
    currentRoomType)
    self._index = index
    self._sprite_xing_1 = spirit_xing_1
    self._sprite_xing_2 = spirit_xing_2
    self._callback = callback
    self._room = room
    self._currid = currid
    self._pet = petInfo
    self._spaceid = spaceid
    self._currentRoomType = currentRoomType

    self._pstid = petInfo:GetPstID()
    self._spPet = self:GetSpPet(self._pstid)

    self._skillState = {}
    self._grade = self._pet:GetPetGrade()
    local tab = self._pet:PetGradeNewSkill()
    for i = 1, table.count(tab) do
        self._skillState[i] = {}
        self._skillState[i].ID = tab[i].NewSkill
        self._skillState[i].grade = tab[i].Grade
        if tab[i].Grade > self._grade then
            self._skillState[i].isLock = true
        else
            self._skillState[i].isLock = false
        end
    end

    self:OnValue()
end
function UIAircraftEnterBuildPetPrefab:Constructor()
    self._spaceid = 0
end

function UIAircraftEnterBuildPetPrefab:OnHide()
    self:DetachEvent(GameEventType.AircraftEnterClearPetList, self.AircraftEnterClearPetList)
    self._spaceid = 0

    self._skillState = nil
    self._callback = nil
    self._grade = 0
    self._index = 0
    self._room = nil
    self._pet = nil
    self._pstid = 0

    --------------------------------------------
    self._multi = nil
    self._drawIcon = nil
    self._nameText = nil
    self._skills = nil
    self._enDown = nil

    self._stars = nil
end
function UIAircraftEnterBuildPetPrefab:itemOnClick()
    if self._callback then
        self._callback(self._index, self._pet, self._skillState, self._spPet)
    end
end

function UIAircraftEnterBuildPetPrefab:ShowIdxStr(idx)
    if idx == 0 then
        self._multi:SetActive(false)
    else
        self._multi:SetActive(true)
    end
end

---@return Pet
function UIAircraftEnterBuildPetPrefab:GetSpPet(pstid)
    local module = GameGlobal.GetModule(PetModule)
    local pet = module:GetPet(pstid)
    if not pet then
        return nil
    end
    local bindPet = module:GetBindPet(pet:GetTemplateID())
    if bindPet then
        local room = GameGlobal.GetModule(AircraftModule):GetPetAirRoom(bindPet)
        if room then
            return bindPet
        end
    end
    return nil
end

function UIAircraftEnterBuildPetPrefab:_IsPetSettled(tmpID)
    local spaces = Cfg.cfg_aircraft_space {}
    for i = 1, #spaces do
        ---@type AircraftRoomBase
        local roomData = airModule:GetRoom(i)
        if roomData then
            ---@type table<number,Pet>
            local settlePets = roomData:GetPets()
            if settlePets and #settlePets > 0 then
                for _, settlePet in ipairs(settlePets) do
                    if settlePet:GetTemplateID() == tmpID then
                        return true
                    end
                end
            end
        end
    end
end
