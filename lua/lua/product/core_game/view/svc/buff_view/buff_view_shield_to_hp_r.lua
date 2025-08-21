--[[
    护盾转血量buff表现
]]
_class("BuffViewShieldToHP", BuffViewBase)
---@class BuffViewShieldToHP:BuffViewBase
BuffViewShieldToHP = BuffViewShieldToHP

--护盾吸血效果
function BuffViewShieldToHP:PlayView(TT)
    local e = self._viewInstance:Entity()
    local absorbHP = self._buffResult:GetAddHP()
    local damageInfo=self._buffResult:GetDamageInfo()
    local curShield = self._buffResult:GetShieldToHp_CurShield()

    ---加血特效
    ---@type EffectService
    local effectService = self._world:GetService("Effect")
    effectService:CreateEffect(BattleConst.AddHealthEffect, e)

    local gridPos = e:GetGridPosition()
    ---@type BoardServiceRender
    local boardServiceRender = self._world:GetService("BoardRender")

    local renderPos = boardServiceRender:GridPos2RenderPos(gridPos)
    renderPos.y = renderPos.y + BattleConst.SingleDamageNumberShowHeight
    local petPstId = 0
    if e:PetPstID() then
        petPstId = e:PetPstID():GetPstID()
    end
    local materialEntity = e
    if e:HasTeam() then
        materialEntity = e:GetTeamLeaderPetEntity()
    end

    if e:HasHP() then 
        ---@type Entity
        local recoverEntity = e
        if e:PetPstID() then
            recoverEntity = e:Pet():GetOwnerTeamEntity()
        end
        ---@type HPComponent
        local hpCmpt = recoverEntity:HP()
        hpCmpt:SetShieldValue(curShield)
    end

    ---@type PlayDamageService
    local playDamageService = self._world:GetService("PlayDamage")

    --加血飘字
    playDamageService:AsyncUpdateHPAndDisplayDamage(materialEntity, damageInfo)

    if petPstId ~= 0 then
        GameGlobal.EventDispatcher():Dispatch(GameEventType.InOutQueue, petPstId, true)
    end

    YIELD(TT, 1000)
    if petPstId ~= 0 then
        GameGlobal.EventDispatcher():Dispatch(GameEventType.InOutQueue, petPstId, false)
    end
end
