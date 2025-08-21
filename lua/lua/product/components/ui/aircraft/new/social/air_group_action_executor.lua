--[[
    @行为组执行器
]]
_class("AirGroupActionExecutor", Object)
---@class AirGroupActionExecutor:Object
AirGroupActionExecutor = AirGroupActionExecutor

function AirGroupActionExecutor:Constructor(aircraftMain, airSocialArea, removeCallBack)
    ---@type AircraftMain
    self.m_AirMain = aircraftMain
    ---@type AirSocialArea
    self.m_AirSocialArea = airSocialArea
    self.m_RemoveCallBack = removeCallBack
    ---@type AirLibMaker
    self.m_AirLibMaker = self.m_AirSocialArea:GetLibMaker()
    self.m_StateTypes = self.m_AirSocialArea:GetStateTypes()
    self.m_Machine = AirGroupActionMachine:New(self, self.m_StateTypes)
    self.m_Machine:SetProcessFinish(
        function()
            self:OnProcessFinish()
        end
    )
    -- 默认社交主行为为空
    self.m_AirSocialArea:StartAllPetAction()
    -- 支持跳状态
    self.m_Machine:ChangeNextState()
end

function AirGroupActionExecutor:Dispose(needRandom, isLeave)
    self.m_StateTypes = {}
    -- main machine
    if self.m_Machine then
        self.m_Machine:Dispose()
        self.m_Machine = nil
    end
    -- libmaker
    if self.m_AirLibMaker then
        self.m_AirLibMaker:Dispose()
        self.m_AirLibMaker = nil
    end
    --socialarea
    if self.m_AirSocialArea then
        self.m_AirSocialArea:Dispose(needRandom, isLeave)
    end
    --airmain
    self.m_AirMain = nil
end
---@param pet AircraftPet
function AirGroupActionExecutor:PlayAction(pet, action)
    pet:StartViceAction(action)
end

function AirGroupActionExecutor:GetSocialArea()
    return self.m_AirSocialArea
end

function AirGroupActionExecutor:GetPets()
    return self.m_AirSocialArea:GetPets()
end

--当前社交所在的家具
function AirGroupActionExecutor:GetAreaFurniture()
    return self.m_AirSocialArea:GetFurniture()
end

function AirGroupActionExecutor:GetLibMaker()
    return self.m_AirLibMaker
end
---@return AircraftMain
function AirGroupActionExecutor:GetAirMain()
    return self.m_AirMain
end

function AirGroupActionExecutor:GetFurniture(type)
    return self.m_AirMain:GetFurniture(type)
end

function AirGroupActionExecutor:OnProcessFinish()
    if self.m_RemoveCallBack then
        self.m_RemoveCallBack(self)
    end
end
