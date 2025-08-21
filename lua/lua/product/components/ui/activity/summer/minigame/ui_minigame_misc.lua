--勿删
--[[
---@class ScoreType
local ScoreType = {
    B = 1,
    A = 2,
    S = 4,
}
_enum("ScoreType", ScoreType)

---@class MiniGameState
local MiniGameState = 
{
    Start = 1,
    Playing = 2,
    Pause = 3,
    Skill = 4,
    Over = 5
}
_enum("MiniGameState", MiniGameState)

---@class Weight
local Weight = {
    Small = 1, --小份
    Big = 2 --大份
}
_enum("Weight", Weight)

---@class Ingredient
local Ingredient = {
    Chocolate = 1, --巧克力
    Coco = 2, --椰果
    Pudding = 3, --布丁
    Taro = 4 --芋
}
_enum("Ingredient", Ingredient)

---@class Jam
local Jam = {
    Strawberry = 1, --草莓
    Matcha = 2, --抹茶
    Biolac = 3, --炼乳
    Mango = 4 --芒果
}
_enum("Jam", Jam)

---@class OrderformStep
local OrderformStep = {
    Weight = 1, --选取分量
    Ingredient = 2, --配料
    Jam = 3, --酱料
    Delivery = 4, --上餐
}
_enum("OrderformStep", OrderformStep)

---@class OrderformState
local OrderformState = {
    Appearing = 1, --出现
    Waiting = 2, --等待
    TimeOut = 3, --超时
    TimeOutAnimation = 4, --超时动画
    Fail = 5, --失败
    Success = 6, --成功
    DisAppearing = 7 --消失
}
_enum("OrderformState", OrderformState)

---@class GuestMood
local GuestMood = {
    LookForward = 1, --期待
    Quietness = 2, --平静
    Impatient = 3, --不耐烦
    Happy = 4 --开心
}
_enum("GuestMood", GuestMood)

---@class OrderformImg
local OrderformImg =
{
    Img = 
    {
        [OrderformStep.Weight] = 
        {
            [Weight.Small] = "xiahuo_game_make_sml", 
            [Weight.Big] = "xiahuo_game_make_big" 
        },
        [OrderformStep.Ingredient] = 
        {
            [Weight.Small] = 
            {
                [Ingredient.Chocolate] = "xiahuo_game_make_sml_01",
                [Ingredient.Coco] = "xiahuo_game_make_sml_02",
                [Ingredient.Pudding] = "xiahuo_game_make_sml_03",
                [Ingredient.Taro] = "xiahuo_game_make_sml_04"
            },
            [Weight.Big] = 
            {
                [Ingredient.Chocolate] = "xiahuo_game_make_big_01",
                [Ingredient.Coco] = "xiahuo_game_make_big_02",
                [Ingredient.Pudding] = "xiahuo_game_make_big_03",
                [Ingredient.Taro] = "xiahuo_game_make_big_04"
            }
        },
        [OrderformStep.Jam] = 
        {
            [Weight.Small] = 
            {
                [Jam.Strawberry] = "xiahuo_game_make_sml_05",
                [Jam.Matcha] = "xiahuo_game_make_sml_06",
                [Jam.Biolac] = "xiahuo_game_make_sml_07",
                [Jam.Mango] = "xiahuo_game_make_sml_08",
            },
            [Weight.Big] = 
            {
                [Jam.Strawberry] = "xiahuo_game_make_big_05",
                [Jam.Matcha] = "xiahuo_game_make_big_06",
                [Jam.Biolac] = "xiahuo_game_make_big_07",
                [Jam.Mango] = "xiahuo_game_make_big_08",
            },
        }
    },
    ImgColor = 
    {
        [true] = Color(1, 1, 1, 1),
        [false] = Color(1, 1, 1, 0)
    }
}
_enum("OrderformImg", OrderformImg)

---@class Orderform
_class("Orderform", Object)
Orderform = Orderform
function Orderform:Constructor(...)
    local param = {...}
    self._weight = param[1]
    self._ingredient = param[2]
    self._jam = param[3]
    self._guest = param[4]
    self._appearingTime = 0.967
    self._timeOutAnimation = 0.233
    self._disAppearingTime = 1.433
    self._waitingTime = param[5]
    self._elapseWaitingTime = 0
    self._widgetIndex = param[6]
    self._score = 0
    self._step = OrderformStep.Weight
    self._state = OrderformState.Appearing
end
function Orderform:CanDo()
    return self._state == OrderformState.Appearing or self._state == OrderformState.Waiting
end
function Orderform:Do(step, param)
    if self._step == step and step == OrderformStep.Weight then
        self._weight = param
        self:NextStep()
        return true
    elseif self._step > OrderformStep.Weight and step == OrderformStep.Ingredient and self._ingredient <= 0 then
        self._ingredient = param
        self:NextStep()
        return true
    elseif self._step > OrderformStep.Weight and step == OrderformStep.Jam and self._jam <= 0 then
        self._jam = param
        self:NextStep()
        return true
    end
    return false
end
function Orderform:NextStep()
    self._step = self._step + 1
end
function Orderform:Done()
    self:Clear()
end
function Orderform:Clear()
    self._weight = 0
    self._ingredient = 0
    self._jam = 0
    self._guest = 0
    self._appearingTime = 0
    self._timeOutAnimation = 0
    self._disAppearingTime = 0
    self._waitingTime = 0
    self._elapseWaitingTime = 0
    self._widgetIndex = 0
    self._score = 0
    self._step = OrderformStep.Weight
    self._state = OrderformState.DisAppearing
end
function Orderform:Equal(orderform)
    return self._weight == orderform._weight and self._ingredient == orderform._ingredient and self._jam == orderform._jam
end

---@class GuestOrderformImg
local GuestOrderformImg = 
{
    MoodImg = {
        [GuestMood.LookForward] = "xiahuo_game_mood_good",
        [GuestMood.Quietness] = "xiahuo_game_mood_normal",
        [GuestMood.Impatient] = "xiahuo_game_mood_bad"
    },
    DiImg = {
        [Weight.Small] = "xiahuo_game_mood_smldi",
        [Weight.Big] = "xiahuo_game_mood_bigdi"
    },
    WeightImg = {
        [Weight.Small] = "xiahuo_game_mood_sml",
        [Weight.Big] = "xiahuo_game_mood_big",
    },
    IngredientImg = {
        [Weight.Small] = 
        {
            [Ingredient.Chocolate] = "xiahuo_game_mood_sml_01",
            [Ingredient.Coco] = "xiahuo_game_mood_sml_02",
            [Ingredient.Pudding] = "xiahuo_game_mood_sml_03",
            [Ingredient.Taro] = "xiahuo_game_mood_sml_04"
        },
        [Weight.Big] = 
        {
            [Ingredient.Chocolate] = "xiahuo_game_mood_big_01",
            [Ingredient.Coco] = "xiahuo_game_mood_big_02",
            [Ingredient.Pudding] = "xiahuo_game_mood_big_03",
            [Ingredient.Taro] = "xiahuo_game_mood_big_04"
        }
    },
    JamImg = {
        [Weight.Small] = 
        {
            [Jam.Strawberry] = "xiahuo_game_mood_sml_05",
            [Jam.Matcha] = "xiahuo_game_mood_sml_06",
            [Jam.Biolac] = "xiahuo_game_mood_sml_07",
            [Jam.Mango] = "xiahuo_game_mood_sml_08",
        },
        [Weight.Big] = 
        {
            [Jam.Strawberry] = "xiahuo_game_mood_big_05",
            [Jam.Matcha] = "xiahuo_game_mood_big_06",
            [Jam.Biolac] = "xiahuo_game_mood_big_07",
            [Jam.Mango] = "xiahuo_game_mood_big_08",
        },
    }
}
_enum("GuestOrderformImg", GuestOrderformImg)

---@class GuestImg
local GuestImg =
{
    Img = {
        [GuestMood.LookForward] = "summer_game_%s_good",
        [GuestMood.Quietness] = "summer_game_%s_normal",
        [GuestMood.Impatient] = "summer_game_%s_mad",
        [GuestMood.Happy] = "summer_game_%s_complete",
    },
    Misc = {
        ["Hand"] = "summer_game_%s_hand",
    }
}
_enum("GuestImg", GuestImg)

---@class MGAnimations
local MGAnimations = 
{
    OrderformStep = 
    {
        [OrderformStep.Weight] = "uieffUIMiniGameController_Plate_Weight",
        [OrderformStep.Ingredient] = "uieffUIMiniGameController_Plate_Ingredient",
        [OrderformStep.Jam] = "uieffUIMiniGameController_Plate_Jam",
    },
    MiniGameState = 
    {
        [MiniGameState.Start] = "uieffUIMiniGameController_Center_start",
        [MiniGameState.Over] = "uieffUIMiniGameController_Center_finish",
        [MiniGameState.Pause] = "uieffUIMiniGameController_Center_Puase",
        [MiniGameState.Skill] = 
        {
            ["Start"] = "uieffUIMiniGameController_Center_skill_start",
            ["Loop"] = "uieffUIMiniGameController_Center_skill_loop",
            ["End"] = "uieffUIMiniGameController_Center_skill_end",
        },
        ["Cd"] = "uieffUIMiniGameController_Center_start_number"
    },
    Orderform = 
    {
        ["in"] = "UIMiniGameOrderformItem_in",
        ["twinkle01"] = "UIMiniGameOrderformItem_twinkle01",
        ["out"] = "UIMiniGameOrderformItem_out",
        ["twinkle02"] = "UIMiniGameOrderformItem_twinkle02",
        ["ready"] = "UIMiniGameOrderformItem_ready"
    },
    Guest = 
    {
        [GuestMood.LookForward] = "uieffUIMiniGameController_Guest_come",
        [GuestMood.Impatient] = "uieffUIMiniGameController_Guest_go",
        [GuestMood.Happy] = "uieffUIMiniGameController_Guest_happy"
    },
    Other = 
    {
        ["Trash"] = "uieffUIMiniGameController_Trash",
        ["Score"] = "uieffUIMiniGameController_Center_PanelEff",
        ["Skill"] = "uieffUIMiniGameController_Skill_Full",
        ["Switch"] = "uieff_Activity_Summer1_MiniGame_SwitchLevel",
        ["SwitchMark"] = "uieff_Activity_Summer1_minigame_selectlevel",
    }
}
_enum("MGAnimations", MGAnimations)

---@class StepAudio
local StepAudio =
{
    [OrderformStep.Weight] = CriAudioIDConst.Summer1GameWeight,
    [OrderformStep.Ingredient] = CriAudioIDConst.Summer1GameIngredient,
    [OrderformStep.Jam] = CriAudioIDConst.Summer1GameJam,
}
_enum("StepAudio", StepAudio)
]]

