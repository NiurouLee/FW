---@class UIN7EnemyDetailsController : UIController
_class("UIN7EnemyDetailsController", UIController)
UIN7EnemyDetailsController = UIN7EnemyDetailsController

--region 初始化
function UIN7EnemyDetailsController:Constructor()
    self._uiParams = nil
    self._cfg = Cfg.cfg_pet_skin {}
    self._pets = nil
    self._uiEnemyItemTab = {}
end
function UIN7EnemyDetailsController:OnShow(uiParams)
    self._element2Str = {
        [ElementType.ElementType_Blue] = "str_pet_filter_water_element",
        [ElementType.ElementType_Red] = "str_pet_filter_fire_element",
        [ElementType.ElementType_Green] = "str_pet_filter_sen_element",
        [ElementType.ElementType_Yellow] = "str_pet_filter_electricity_element"
    }
    self._uiParams = uiParams
    self._pets = uiParams[1]
    self:_GetComponents()
    self:_ShowEnemyIcon()
    self:_ShowSkinDetail(uiParams[2])
end
function UIN7EnemyDetailsController:OnHide()
    if self.skillItemTask then
        GameGlobal.TaskManager():KillTask(self.skillItemTask)
        self.skillItemTask = nil
    end
end
function UIN7EnemyDetailsController:_GetComponents()
    ---@type UnityEngine.GameObject
    self._content = self:GetGameObject("Content")
    self._scrollView = self:GetGameObject("scrollView")

    ---@type UnityEngine.UI.Image
    self._first = self:GetUIComponent("Image", "first")
    self._second = self:GetUIComponent("Image", "second")
    self._secondBg = self:GetUIComponent("Image", "secondBg")
    self._bgLoader = self:GetUIComponent("Image", "BgLoader")

    ---@type UILocalizationText
    self._elementText = self:GetUIComponent("UILocalizationText", "elementText")
    self._name = self:GetUIComponent("UILocalizationText", "name")

    ---@type MultiplyImageLoader
    self._cgNormal = self:GetUIComponent("MultiplyImageLoader", "cgNormal")

    local skills = self:GetUIComponent("UISelectObjectPath", "skills")
    self._skills = skills:SpawnObject("UIN7TeammateItem")
end
--endregion

--region 显示
---@private
---显示敌方全部Icon
function UIN7EnemyDetailsController:_ShowEnemyIcon()
    local uiEnemyItem = self:GetUIComponent("UISelectObjectPath", "uiEnemyItem")
    uiEnemyItem:SpawnObjects("UIN7EnemyItem", #self._pets)
    self._uiEnemyItemTab = uiEnemyItem:GetAllSpawnList()
    local pet = nil
    local skin = nil
    for i = 1, #self._uiEnemyItemTab do
        pet = Cfg.cfg_pet {ID = self._pets[i].petid}
        skin = Cfg.cfg_pet_skin {id = pet[1].SkinId}
        self._uiEnemyItemTab[i]:SetData(
            i,
            skin,
            function(index)
                self:_UIN7EnemyItemOnclick(index)
            end
        )
    end
end
---@private
---显示技能详情
function UIN7EnemyDetailsController:_ShowSkinDetail(index)
    for i = 1, #self._uiEnemyItemTab do
        self._uiEnemyItemTab[i]:SetSelectState(false)
    end
    self._uiEnemyItemTab[index]:SetSelectState(true)

    local petcfg = Cfg.cfg_pet {ID = self._pets[index].petid}[1]
    self._name:SetText(StringTable.Get(petcfg.Name))
    self._cgNormal:Load(self._pets[index].battleMe)
    self:_ShowAttribute(index, petcfg)

    local tempData = pet_data:New()
    tempData.template_id = self._pets[index].petid
    tempData.current_skin = 0
    local pet = Pet:New(tempData)
    tempData.grade = self._pets[index].grade
    tempData.level = self._pets[index].lv
    tempData.awakening = self._pets[index].awakening
    tempData.equip_lv = self._pets[index].equip
    pet:SetData(tempData)
    self._skills:SetData(pet)

    -- self.skills = self:GetUIComponent("UISelectObjectPath", "skills")
    -- self.skills:SpawnObjects("UIShopPetSkillItem", 3)
    -- self._skillsSpawns = self.skills:GetAllSpawnList()
    
    -- if self._skillsSpawns then
    --     for i, v in ipairs(self._skillsSpawns) do
    --         local have = v:Flush(i,pet)
    --     end
    -- end
end
---@private
---显示属性
function UIN7EnemyDetailsController:_ShowAttribute(index, pet)
    self._first.sprite = self._pets[index].elemt1
    if self._pets[index].elemt2 and self._pets[index].grade == pet.Element2NeedGrade then
        self._second.gameObject:SetActive(true)
        self._second.sprite = self._pets[index].elemt2
    else
        self._second.gameObject:SetActive(false)
    end
end
--endregion

--region 按钮
---@private
function UIN7EnemyDetailsController:_UIN7EnemyItemOnclick(index)
    if self._uiEnemyItemTab == nil then
        return
    end
    self._skills:HideItem()
    self:_ShowSkinDetail(index)
end

function UIN7EnemyDetailsController:bgOnClick(go)
    self:CloseDialog()
end
--endregion
