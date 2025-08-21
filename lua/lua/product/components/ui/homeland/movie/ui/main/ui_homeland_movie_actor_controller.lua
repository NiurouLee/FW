---@class UIHomelandMovieActorController:UIController
_class("UIHomelandMovieActorController", UIController)
UIHomelandMovieActorController = UIHomelandMovieActorController

function UIHomelandMovieActorController:Constructor()
    self._data = nil --当前电影信息
    ---@enum ActorPageType
    self._type  = nil
    self._actorList = nil --当前电影演员列表
    self._itemList = nil  --当前电影物品列表
    self._widgets = nil  
    self._atlas = nil
end

function UIHomelandMovieActorController:OnShow(uiParams)
    self._widgets = {}
    self._type = ActorPageType.Actor
    self._data = uiParams[1]
    self._actorList = self._data.RolePosList
    self._itemList = self._data.ItemPosList
    self._atlas = self:GetAsset("UIHomelandMovie.spriteatlas", LoadType.SpriteAtlas)
    
    self:InitWidget()
    self:SetListData()
    self:SetPoster()
end

function UIHomelandMovieActorController:OnHide()
    
end

function UIHomelandMovieActorController:InitWidget()
    self._content = self:GetUIComponent("UISelectObjectPath","Content")
    self._rect = self:GetUIComponent("RectTransform","Content")
    self._moviePoster = self:GetUIComponent("RawImageLoader","moviePoster")
    self._actorObj = self:GetGameObject("rActor")
    self._itemObj = self:GetGameObject("rItem")
    self._switchBtn = self:GetUIComponent("Image","switchBtn")
end

--设置列表数据
function UIHomelandMovieActorController:SetListData()
    self._rect.anchoredPosition = Vector2(10,0)
    local list = {}
    if self._type == ActorPageType.Actor then
        list = self._actorList
    elseif self._type == ActorPageType.Item then
        list = self._itemList
    end
    self._widgets = self._content:SpawnObjects("UIHomelandMovieActorItem",#list)
    local index = 1
    for i,v in pairs(list) do
        self._widgets[index]:SetData(v,self._data,self._type == ActorPageType.Actor)
        index = index + 1
    end
end

--设置海报图片
function UIHomelandMovieActorController:SetPoster()
    self._moviePoster:LoadImage(self._data.Poster)
end

--点击切换按钮
function UIHomelandMovieActorController:SwitchBtnOnClick()
    if self._type == ActorPageType.Actor then
        self._type = ActorPageType.Item
        self._actorObj:SetActive(false)
        self._itemObj:SetActive(true)
        self._switchBtn.sprite = self._atlas:GetSprite("dy_kxyy_icon03")
    elseif self._type == ActorPageType.Item then
        self._type = ActorPageType.Actor
        self._actorObj:SetActive(true)
        self._itemObj:SetActive(false)
        self._switchBtn.sprite = self._atlas:GetSprite("dy_kxyy_icon04")
    end
    self:SetListData()
end

--返回
function UIHomelandMovieActorController:BtnBackOnClick(TT)
    self:CloseDialog()
end

