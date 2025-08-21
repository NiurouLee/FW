require("base_ins_r")
---@class PlayCasterTrapRoundShowWithTotalRoundInstruction: BaseInstruction
_class("PlayCasterTrapRoundShowWithTotalRoundInstruction", BaseInstruction)
PlayCasterTrapRoundShowWithTotalRoundInstruction = PlayCasterTrapRoundShowWithTotalRoundInstruction

function PlayCasterTrapRoundShowWithTotalRoundInstruction:Constructor(paramList)
    self._totalRound = paramList["totalRound"]
    self._text = paramList["text"]
end

---@param casterEntity Entity
function PlayCasterTrapRoundShowWithTotalRoundInstruction:DoInstruction(TT, casterEntity, phaseContext)
    ---@type MainWorld
    local world = casterEntity:GetOwnerWorld()

    local roundRender = casterEntity:TrapRoundInfoRender()
    if not roundRender then
        return
    end

    -- ---@type BattleStatComponent
    -- local battleStatCmpt = world:BattleStat()
    -- local curRound = battleStatCmpt:GetLevelTotalRoundCount()
    ---@type UtilDataServiceShare
    local utilStatSvc = world:GetService("UtilData")
    local round = utilStatSvc:GetStatCurWaveTotalRoundCount()

    local visible = false
    local arr = string.split(self._totalRound, "|")
    for _, round in ipairs(arr) do
        if tonumber(round) == round then
            visible = true
            break
        end
    end

    roundRender:SetIsShow(visible)

    local round_entity_id = roundRender:GetRoundInfoEntityID()
    local round_entity = world:GetEntityByID(round_entity_id)

    if not round_entity then
        return
    end

    round_entity:SetViewVisible(visible)

    if visible then
        local go = round_entity:View().ViewWrapper.GameObject
        local uiview = go:GetComponent("UIView")
        if uiview then
            local text = uiview:GetUIComponent("UILocalizationText", "CurRoundText")
            if self._text then
                text:SetText(self._text)
            else
                text:SetText("!")
            end
        end

        --强制刷新一次
        ---@type RenderEntityService
        local renderEntityService = world:GetService("RenderEntity")
        renderEntityService:SetHudPosition(casterEntity, round_entity, roundRender:GetOffset())
    end
end
