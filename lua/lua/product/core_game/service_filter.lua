_staticClass("ServiceFilter")

ServiceFilter.RenderServices = {
    PlaySkill = true,
    Effect = true,
    Camera = true,
    Resource = true,
    CanMoveArrow = true,
    ResourcesPool = true,
    PreviewActiveSkill = true,
    EventListener = true,
    RenderEntity = true,
    LinkageRender = true,
    InnerStory = true,
    PlayBuff = true,
    Loading = true,
    PlayAI = true,
    RenderBattle = true,
    TestRobot = true,
    BoardRender = true,
    MonsterMoveRender = true,
    ChainAttackRender = true,
    PlayDamage = true,
    TransformRenderer = true,
    PlaySkillInstruction = true,
    TrapRender = true,
    EntityPool = true,
    PreviewCalcEffect = true,
    MonsterShowRender = true,
    LinkLine = true,
    Piece = true,
    Guide = true,
    RandomRender = true,
    DataListener = true,
    MonsterCreationRender = true,
    AutoTest = true,
    SpawnPieceRender = true,
    Cutscene = true,
    ChessRender = true,
    FeatureRender = true,
    SyncMoveRender = true,
    RideRender = true,
    --多格棋盘
    BoardMultiRender = true,
    PieceMulti = true,
    PartnerRender = true,

    ---预览怪物和机关
    PreviewMonsterTrap = true,
    MirageRender = true,
    PreviewLinkLine = true,
    PopStarRender = true,
}

ServiceFilter.ShareServices = {
    Config = true,
    Math = true,
    Time = true,
    UtilData = true,
    UtilCalc = true,
    UtilScopeCalc = true,
    UtilStat = true,
    AutoFight = true
}

---@param worldRunningPostion WorldRunPostion
function ServiceFilter:CheckService(serviceName, worldRunningPostion)
    if self.RenderServices[serviceName] and worldRunningPostion == WorldRunPostion.AtServer then
        return false
    else
        return true
    end
end

---获取类型
---@return ResponsibilityType
function ServiceFilter:GetServiceResponsibilityType(serviceName)
    local respType = ResponsibilityType.Logic
    if self.RenderServices[serviceName] then
        respType = ResponsibilityType.Render
    elseif self.ShareServices[serviceName] then
        respType = ResponsibilityType.Share
    end

    return respType
end
