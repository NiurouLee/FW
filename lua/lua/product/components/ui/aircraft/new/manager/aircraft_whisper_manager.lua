--[[
    风船自言自语控制器
]]
---@class AircraftWhisperManager:Object
_class("AircraftWhisperManager", Object)
AircraftWhisperManager = AircraftWhisperManager

---@param aircraftMain AircraftMain
function AircraftWhisperManager:Constructor(aircraftMain)
    self._main = aircraftMain

    self._nextWaitTime = 0

    --自言自语action间隔（说是要自然一点）,1秒
    self._whisperActionGaps = Cfg.cfg_global["AircraftWhisperActionGaps"].IntValue

    --10秒内不再随机到喊过话的星灵
    self._onePetWhisperTimeGaps = Cfg.cfg_aircraft_const["AircraftWhisperSeamPetGaps"].IntValue or 10000

    self._startTime = 0

    local nextTimeCfg = Cfg.cfg_global["AircraftWhisperNextWaitTime"].ArrayValue
    self._minNextTime = nextTimeCfg[1]
    self._maxNextTime = nextTimeCfg[2]

    local whisperPetCount = Cfg.cfg_global["AircraftWhisperRandomPetCount"].ArrayValue
    self._minWhisperCount = whisperPetCount[1]
    self._maxWhisperCount = whisperPetCount[2]
end
function AircraftWhisperManager:Init()
    self._nextWaitTime = self:RandomNextWaitTime()
end

--随机下次自言自语时间
function AircraftWhisperManager:RandomNextWaitTime()
    return math.random(self._minNextTime, self._maxNextTime)
end

--重置下次自言自语时间
function AircraftWhisperManager:ResetNextWaitTime()
    self._nextWaitTime = self:RandomNextWaitTime()
end

--随机自言自语星灵数
function AircraftWhisperManager:RandomWhisperPetCount()
    return math.random(self._minWhisperCount, self._maxWhisperCount)
end

function AircraftWhisperManager:Update(deltaTimeMS)
    self._startTime = self._startTime + deltaTimeMS
    if self._startTime >= self._nextWaitTime then
        self._startTime = 0

        self:ResetNextWaitTime()

        self:PlayBubble()
    end
end
function AircraftWhisperManager:Dispose()
end

--自言自语
function AircraftWhisperManager:PlayBubble()
    --当前时间，毫秒
    local time = self._main:Time()
    local actionPets = {}
    ---@type table<number,AircraftPet>
    local pets =
        self._main:GetPets(
        function(_pet)
            ---@type AircraftPet
            local pet = _pet
            local state = pet:GetState()
            if
                state == AirPetState.Wandering or state == AirPetState.OnFurniture or
                    state == AirPetState.WaitingElevator
             then
                local wisperTime = pet:GetWisperTime()
                return time - wisperTime > self._onePetWhisperTimeGaps
            end
            return false
        end,
        true
    )

    if #pets < 1 then
        AirLog("没有可进行自言自语的星灵")
        return
    end

    --随机1个或2个
    local count = self:RandomWhisperPetCount()

    if count < #pets then
        actionPets = self:RandomActionPets(pets, count)
    else
        actionPets = pets
    end

    if table.count(actionPets) <= 0 then
        Log.debug("###AircraftWhisperManager pets is nil !")
        return
    end

    for i = 1, #actionPets do
        ---@type AircraftPet
        local pet = actionPets[i]
        local state = pet:GetState()
        local wid = state
        if state == AirPetState.OnFurniture then
            wid = pet:GetFurnitureType()
        end
        if wid == 0 then
            Log.fatal("###星灵行为为空--", pet:TemplateID())
        else
            --通过行为id获取一个表情id
            local bubble = self:GetBubbleId(pet, wid)

            local cfg = Cfg.cfg_aircraft_pet_face[bubble]
            if not cfg then
                Log.fatal("###找不到配置表情配置：", bubble)
                return
            else
                local gapTime = self._whisperActionGaps * (i - 1)

                local tempPetID = pet:TemplateID()

                AirLog("星灵自言自语:", tempPetID, "，气泡id：", bubble)
                local whisperAction = AirActionFace:New(pet, bubble, gapTime)
                pet:StartViceAction(whisperAction)
                pet:SetWisperTime(time)
            end
        end
    end
end

--根据权重随机自言自语的星灵
---@param pets AircraftPet[]
function AircraftWhisperManager:RandomActionPets(pets, count)
    local actionPets = {}

    for i = 1, count do
        local all = 0
        local outpet = nil
        local weightTab = {}
        for j = 1, #pets do
            local pet = pets[j]
            local weight = pet:WisperWeight()
            if weight then
                all = all + weight
                local weightTabItem = {}
                weightTabItem.pet = pet
                weightTabItem.weight = all
                table.insert(weightTab, weightTabItem)
            end
        end

        local randomNumber = math.random(1, all)
        for i = 1, #weightTab do
            if randomNumber <= weightTab[i].weight then
                outpet = weightTab[i].pet
                break
            end
        end
        actionPets[i] = outpet

        table.removev(pets, outpet)
    end
    return actionPets
end
--获得一个气泡id
---@param pet AircraftPet
function AircraftWhisperManager:GetBubbleId(pet, wid)
    local cfg_whisper = Cfg.cfg_aircraft_furniture_bubble[wid]
    if cfg_whisper then
        local bubbles = cfg_whisper.BubbleIDs
        local showId
        --为空，根据性格随机表情
        if not bubbles then
            local cfg_pet = Cfg.cfg_aircraft_pet[pet:TemplateID()]
            if cfg_pet then
                showId = pet:GetIDWithRandomWeight(cfg_pet.CharactorFace)
            else
                Log.fatal("###[AircraftWhisperManager] cfg_aircraft_pet is nil ! id -> ", pet:TemplateID())
            end
        else
            showId = pet:GetIDWithRandomWeight(bubbles)
        end
        return showId
    else
        Log.fatal("###[AircraftWhisperManager] cfg_whisper is nil ! id -> ", wid)
    end
end
