--
---@class UIPetEquipHelper : Object
_class("UIPetEquipHelper", Object)
UIPetEquipHelper = UIPetEquipHelper

function UIPetEquipHelper.HasRefine(petId)
    local cfgs = Cfg.cfg_pet_equip_refine{PetID = petId}
    if cfgs and #cfgs > 0 then
        return true
    end
    return false
end 

function UIPetEquipHelper.GetRefineCfg(petId, lv)
    local cfgs = Cfg.cfg_pet_equip_refine{PetID = petId, Level = lv}
    if cfgs and #cfgs > 0 then
        return cfgs[1]
    end
    return nil
end

---@param pet_data MatchPet 
function UIPetEquipHelper.CheckRefineRed(pet_data)
    if not pet_data then
        return false
    end

    local pstId = pet_data:GetPstID()
    local key = UIPetEquipHelper.GetRefineRedKey(pstId)
    if UnityEngine.PlayerPrefs.HasKey(key) then
        return false
    end

    local templateId = pet_data:GetTemplateID()
    if not UIPetEquipHelper.HasRefine(templateId) then
        return false
    end

    local grade = pet_data:GetPetGrade()
    return grade >= 3
end

---@param pet_data MatchPet 
function UIPetEquipHelper.SetRefineRed(pet_data)
    local pstId = pet_data:GetPstID()
    local key = UIPetEquipHelper.GetRefineRedKey(pstId)
    UnityEngine.PlayerPrefs.SetInt(key, 1)
end

function UIPetEquipHelper.GetRefineRedKey(petPstId)
    return UIPetEquipHelper.GetRolePstId() .. petPstId
end

function UIPetEquipHelper.GetRolePstId()
    local mRole = GameGlobal.GetModule(RoleModule)
    return mRole:GetPstId()
end