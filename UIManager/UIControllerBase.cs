using client;
using Ez.Assets;
using Ez.Core;
using Game;
using gen.rawdata;
using System;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using EGraphicQuality = Game.EGraphicQuality;

namespace Ez.UI
{
    public abstract class UIControllerBase : EventListener, IGuideItemRelease
    {
        public delegate void OnControllerReady(string uiname, UIControllerBase controller);

        protected UIFacade m_facade;
        private UIControllerParam m_ctrlParam;

        public UIWindowLayer wndLayer { get; protected set; } = UIWindowLayer.CommonLayer;
        protected bool m_exclusion = false;
        protected UIViewBase _rootView;
        protected object m_param;

        /// <summary>
        /// 关闭中 关闭结束后会被置为false
        /// </summary>
        public bool Closeing;


        public virtual string GetPrefabKey()
        {
            return string.Empty;
        } // 读取配置

        private Core.BitSet32 m_flags;

        private UIBlurBackground m_Blur;

        public UIControllerBase()
        {
            m_flags = new Core.BitSet32();
            ResMonitorUtil.Add("ui_controller", this);
        }

        internal void SetParam(object param, UIControllerParam ctrlparam)
        {
            m_param = param;
            m_ctrlParam = ctrlparam;
            if (m_ctrlParam != null)
            {
                wndLayer = m_ctrlParam.layer;
            }

            AfterCreateSetParam();
        }

        // 时机很早，构造后，初始化参数 SetParam 后调用，此时：资源还未加载
        protected virtual void AfterCreateSetParam()
        {
        }

        internal bool IsBlur()
        {
            if (m_ctrlParam != null)
                return m_ctrlParam.blurBackground;
            else
                return false;
        }

        internal void InitMainView(ResHandle resHandle)
        {
            _rootView = CreateView();
            _rootView.Init(resHandle);
            m_facade = _rootView.GetFacade();
            if (m_facade != null)
            {
                var gobj = m_facade.GetGameObject("m_BtnClose");
                if (gobj != null)
                {
                    EventTriggerClick.Register(gobj,
                        (gobj) => { UIManager.GetInstance().CloseUI(this.GetType().FullName); });
                }

                OnCreateCloseBg();
            }
        }

        public int GetOrder()
        {
            if (_rootView != null)
            {
                return _rootView.GetOrderInLayer();
            }

            return 0;
        }

        /// <summary>
        /// 生成关闭背景
        /// </summary>
        protected virtual void OnCreateCloseBg()
        {
            if (!m_ctrlParam.IsFullScreen && m_ctrlParam.OutSideClose)
            {
                EventTriggerClick.Register(GetCommonCloseBg("commonCloseBg"), BgClose);
            }

            if (m_ctrlParam.layer == UIWindowLayer.CommonLayer && IsCreateBottomBg()) //在commmon层级加一个不可被点穿的背景
                GetCommonCloseBg("bottomBg");
        }

        protected virtual bool IsCreateBottomBg()
        {
            return true;
        }

        // static readonly List<string> ignorebottomBg = new List<string>() {
        //     "client.UILobbyController" ,
        //     "client.UIBattleMainController",
        //     "client.UIBuildBtnsController"
        // };

        // /// <summary>
        // /// 判断是否不需要不许点击穿透背景 目前就lobby用 后期再加
        // /// </summary>
        // /// <returns></returns>
        // bool isLobbyWindow()
        // {
        //     if (ignorebottomBg.Contains(this.GetType().FullName))
        //     {
        //         return true;
        //     }
        //     return false;
        // }

        GameObject GetCommonCloseBg(string name)
        {
            GameObject commonCloseBg = new GameObject(name);
            commonCloseBg.layer = (int)LayerMasks.UI;
            RectTransform rect = commonCloseBg.AddComponent<RectTransform>();
            commonCloseBg.transform.SetParent(m_facade.transform);
            commonCloseBg.transform.SetAsFirstSibling();
            rect.anchorMin = Vector3.zero;
            rect.anchorMax = Vector3.one;
            rect.sizeDelta = Vector3.zero;
            rect.anchoredPosition = Vector3.zero;
            commonCloseBg.AddComponent<CanvasRenderer>();
            commonCloseBg.AddComponent<EmptyGraphic>();
            return commonCloseBg;
        }

        public delegate bool TryClose();

        /// <summary>
        ///  带返回函数的 关闭尝试
        /// </summary>
        public TryClose tryClose;

        protected virtual void BgClose(GameObject go)
        {
            if (tryClose != null)
            {
                if (tryClose.Invoke())
                {
                    this.CloseSelf();
                }
            }
            else
            {
                this.CloseSelf();
            }
        }

        // 后续再看是否重载
        protected virtual UIViewBase CreateView()
        {
            return new UIViewBase();
        }

        public bool IsExclusion
        {
            get { return m_ctrlParam.IsExclusion; }
        } // TODO

        public List<int> GetResid()
        {
            return m_ctrlParam.resids;
        }

        /// <summary>
        /// 关闭UI是否清理飞行UI
        /// </summary>
        public bool IsClearItemFly 
        {
            get { return m_ctrlParam.IsClearItemFly; }
        }

        /// <summary>
        /// 一般内部有自动实现的绑定之类的代码
        /// </summary>
        public abstract void InitView();

        /// <summary>
        /// 此函数一般用于根据自己的数据，初始化一些逻辑监听等等
        /// </summary>
        public virtual void Init()
        {
            UIFacade facade = m_facade;
            if (facade != null)
            {
                foreach (var guide in facade.guides)
                {
                    (guide as IGuide)?.InitController(this);
                }
            }
        }

        public virtual void ViewWillAppear()
        {
        }

        public virtual void ViewDidAppear()
        {
        }

        //数据更新
        public virtual void UpdateParam(object param)
        {
            this.m_param = param;
        }

        public virtual void Show()
        {
            if (m_Blur != null)
            {
                m_Blur.Show();
            }

            _rootView.Show();
        }

        public virtual void Hide()
        {
            _rootView.Hide(this.Closeing);

            if (m_Blur != null)
            {
                m_Blur.Hide();
            }

            if (m_ctrlParam != null) 
            {
                if (m_ctrlParam.IsClearItemFly) 
                {
                    EM.Fire(UIEvent.FlyParamClearEvent, GetPrefabKey());
                }
            }
        }

        internal /*virtual*/ void RegisterEvent()
        {
            m_flags.Set((int)ControllerFlags.RegisterEvent);

            Register();
            if (_sumviews != null)
            {
                foreach (var view in _sumviews)
                {
                    view.Register();
                }
            }
        }

        internal /*virtual*/ void UnRegisterEvent()
        {
            m_flags.Reset((int)ControllerFlags.RegisterEvent);

            UnRegister();

            if (_sumviews != null)
            {
                foreach (var view in _sumviews)
                {
                    view.UnRegister();
                }
            }
        }

        public virtual void ViewWillDisappear()
        {
            m_flags.Set((int)ControllerFlags.WillAppear);
        }

        public virtual void ViewDidDisappear()
        {
        }


        public void AttachToLayer(Transform layerTf, int orderInLayer)
        {
            _rootView.AttachToLayer(layerTf, orderInLayer);

            if (m_ctrlParam == null)
                return;

            if (m_ctrlParam.blurBackground)
            {
                if (m_Blur != null)
                {
                    m_Blur.Dispose();
                    m_Blur = null;
                }

                m_Blur = new UIBlurBackground(layerTf, orderInLayer - 10);
                //_rootView.Hide();
            }
        }

        public virtual void Update()
        {
            if (_sumviews != null && _sumviews.Count > 0)
            {
                foreach (var item in _sumviews)
                {
                    item.Update();
                }
            }
        }

        public virtual void LateUpdate()
        {
        }

        public void SetRawImage(RawImage rawImage, string key)
        {
            GS.SetRawImage(rawImage, key);
        }

        public void SetImageOrRawImage(GameObject gobj, string key, System.Action callback = null, object param = null)
        {
            GS.SetImageOrRawImage(gobj, key, callback, param);
        }

        public void SetImage(Image img, string key, System.Action callback = null, object param = null)
        {
            GS.SetImage(img, key, callback, param);
        }

        public void SetURLImage(Image img, string key, System.Action callback = null, object param = null)
        {
            GS.SetURLImage(img, key, callback, param);
        }

        GroupSpecify _gs;

        public GroupSpecify GS
        {
            get
            {
                if (_gs == null)
                {
                    _gs = GroupSpecify.Get(this.GetType().FullName, this.m_facade.gameObject);
                }

                return _gs;
            }
        }

        public virtual void CloseSelf()
        {
            UIManager.GetInstance().CloseUI(this.GetType().FullName);
        }

        /// <summary>
        /// 是否销毁中
        /// </summary>
        public bool Disposed { get; private set; }

        /// <summary>
        /// 供UI管理器使用，不直接调用 Dispose，防止上层重写 Dispose 遗漏调用基类
        /// </summary>
        internal void Dispose()
        {
            Disposed = true;
            ResMonitorUtil.Remove("ui_controller", this);

            if (m_Blur != null)
            {
                m_Blur.Dispose();
                m_Blur = null;
            }

            RemoveAllTaskTimers();
            DisposeAllCoroutines();

            UnRegister();
            DisposeSubView();
            DisposeReleaseItem();
            GuideItemDisposeRelease();

            // 最后释放资源
            if (_groupLoader != null)
                _groupLoader.Release();
            if (_loader != null)
                _loader.Release();

            if (_gs)
            {
                _gs.DoRelease();
                _gs = null;
            }

            try
            {
                OnDispose();
            }
            catch (Exception ex)
            {
                DevDebuger.LogError(GetType().Name, ex.ToString());
            }

            if (_rootView != null)
            {
                _rootView.Dispose();
                _rootView = null;
            }
        }

        protected virtual void OnDispose()
        {
            // 此处不做实现，防止重载屏蔽
        }

        Canvas canvas;

        public int GetUiSort()
        {
            if (m_facade)
            {
                canvas ??= m_facade.GetComponent<Canvas>();
                if (canvas)
                {
                    return canvas.sortingOrder;
                }
            }

            Error("not canvas");
            return 0;
        }

        #region GameTimer

        private Dictionary<string, GameTimerInfo> _gameTimerDict;
        private HashSet<GameTimerInfo> _gameTimerList;

        /// <summary>
        /// 启动一个计时器任务,loop 0  是循环循环
        /// </summary>
        /// <param name="key">如果想在结束前停止 拿这个清理</param>
        /// <param name="intervalSeconds"></param>
        /// <param name="loop">0循环  大于 0 执行次数</param>
        /// <param name="callback">每次间隔执行</param>
        /// <param name="EndCallBack">正常全结束执行 如果提前手动remove 不执行</param>
        public void StartTaskTime(string key, float intervalSeconds, uint loop, DelegateUtils.VoidDelegate callback,
            DelegateUtils.VoidDelegate EndCallBack = null)
        {
            key = this.GetType().FullName + key;
            _gameTimerDict ??= new Dictionary<string, GameTimerInfo>();
            if (_gameTimerDict.TryGetValue(key, out GameTimerInfo timerInfo))
            {
                GameTimerManager.GetInstance().RemoveTimer(timerInfo);
                _gameTimerDict.Remove(key);
            }

            GameTimerInfo _timerInfo =
                GameTimerManager.GetInstance().AddTimer(intervalSeconds, loop, callback, EndCallBack);
            _gameTimerDict.Add(key, _timerInfo);
        }

        /// <summary>
        /// 启动一个计时器任务,loop 0  是循环循环
        /// </summary>
        /// <param name="key">如果想在结束前停止 拿这个清理</param>
        /// <param name="intervalSeconds"></param>
        /// <param name="loop">0循环  大于 0 执行次数</param>
        /// <param name="callback">每次间隔执行</param>
        /// <param name="EndCallBack">正常全结束执行 如果提前手动remove 不执行</param>
        public GameTimerInfo StartTaskTime(float intervalSeconds, uint loop, DelegateUtils.VoidDelegate callback,
            DelegateUtils.VoidDelegate EndCallBack = null)
        {
            _gameTimerList ??= new HashSet<GameTimerInfo>();
            GameTimerInfo _timerInfo =
                GameTimerManager.GetInstance().AddTimer(intervalSeconds, loop, callback, EndCallBack);
            _gameTimerList.Add(_timerInfo);
            return _timerInfo;
        }

        public void RemoveTaskTime(GameTimerInfo _timerInfo)
        {
            if (_timerInfo != null && _gameTimerList != null && _gameTimerList.Contains(_timerInfo))
            {
                GameTimerManager.GetInstance().RemoveTimer(_timerInfo);
                _gameTimerList.Remove(_timerInfo);
            }
        }

        public void RemoveTaskTime(string key)
        {
            key = this.GetType().FullName + key;
            if (_gameTimerDict != null && _gameTimerDict.TryGetValue(key, out GameTimerInfo _timerInfo))
            {
                GameTimerManager.GetInstance().RemoveTimer(_timerInfo);
                _gameTimerDict.Remove(key);
            }
        }

        public void RemoveAllTaskTimers()
        {
            if (_gameTimerDict != null)
            {
                foreach (var item in _gameTimerDict)
                {
                    GameTimerManager.GetInstance().RemoveTimer(item.Value);
                }

                _gameTimerDict.Clear();
            }

            _gameTimerDict = null;
            if (_gameTimerList != null)
            {
                foreach (var item in _gameTimerList)
                {
                    GameTimerManager.GetInstance().RemoveTimer(item);
                }

                _gameTimerList.Clear();
            }

            _gameTimerList = null;
        }

        #endregion


        #region 特效文件资源加载

        ResPoolLoader effectLoader;

        public void LoadEffect(TEffectRes res, UIEffectBind bind)
        {
            effectLoader ??= ResPoolLoader.GetInstance();
            string resid = res.Resid;
            switch (Qualty.GetQuality())
            {
                case EGraphicQuality.Standard:
                    if (!string.IsNullOrEmpty(res.ResidL))
                    {
                        resid = res.ResidL;
                    }

                    break;
                case EGraphicQuality.Medium:
                    if (!string.IsNullOrEmpty(res.ResidM))
                    {
                        resid = res.ResidM;
                    }

                    break;
                case EGraphicQuality.High:
                    if (!string.IsNullOrEmpty(res.Resid))
                    {
                        resid = res.Resid;
                    }

                    break;
                default:
                    resid = res.Resid;
                    break;
            }

            effectLoader.LoadGameObjectRes(resid, bind, OnEffectLoaded, LayerMasks.UI);
        }

        private void OnEffectLoaded(LoadObject load)
        {
            if (this.Disposed)
            {
                load.DoRelease();
                return;
            }

            if (load.gameObject)
            {
                UIEffectBind bind = load.data as UIEffectBind;
                //bind.sort = GetUiSort();
                bind.AddEffect(load);
            }
        }

        #endregion

        /**************************************************************************************************************/

        #region SubViews

        private List<UISubViewBase> _sumviews;

        /// <summary>
        /// 注意：添加 SubView 时，内部会调用 SubView 的 Init 接口
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="subView"></param>
        /// <returns></returns>
        public T AddSubView<T>(T subView) where T : UISubViewBase
        {
            if (subView == null)
                return null;

            if (AddSubViewWithoutInit(subView))
            {
                subView.Init();
            }

            return subView;
        }

        private bool AddSubViewWithoutInit(UISubViewBase subView)
        {
            if (subView == null)
            {
                DevDebuger.LogWarning(GetType().FullName, $"AddSubView is null");
                return false;
            }

            if (_sumviews == null)
            {
                _sumviews = new List<UISubViewBase>
                {
                    subView
                };
            }
            else
            {
                if (_sumviews.Contains(subView))
                {
                    DevDebuger.LogWarning(GetType().FullName, $"AddSubView is exist: {subView.GetType().FullName}");
                    return false;
                }
#if UNITY_EDITOR
                subView.RestoreEnable();
#endif
                _sumviews.Add(subView);
            }

            // 生命周期已注册过事件，那么就补上事件
            if (m_flags.Test((int)ControllerFlags.RegisterEvent))
            {
                subView.Register();
            }

            return true;
        }

        /// <summary>
        /// 注意：移除 SubView 时，内部会调用 SubView 的 Dispose 接口
        /// </summary>
        /// <param name="subView"></param>
        public void RemoveSubView(UISubViewBase subView)
        {
            if (subView == null)
            {
                DevDebuger.LogWarning(GetType().FullName, "RemoveSubView is null");
                return;
            }

            if (_sumviews == null)
                return;

            if (_sumviews.Remove(subView))
            {
                subView.Dispose();
            }

            //subView.UnRegister();
        }

        private void DisposeSubView()
        {
            if (_sumviews == null || _sumviews.Count == 0)
                return;

            while (_sumviews.Count > 0)
            {
                var index = _sumviews.Count - 1;
                var _subView = _sumviews[index];
                if (_sumviews != null)
                {
                    _subView.Dispose();
                    _sumviews.Remove(_subView);
                }
            }


            // foreach (var item in _sumviews)
            // {
            //     item.Dispose();
            // }
        }

        #endregion


        /**************************************************************************************************************/

        #region Preload

        private GroupLoader _groupLoader;

        internal GroupLoader GroupLoader()
        {
            return _groupLoader;
        }

        /// <summary>
        /// 会自动创建，一定会有返回
        /// </summary>
        /// <returns></returns>
        public GroupLoader GetGroupLoader()
        {
            if (_groupLoader == null)
            {
                _groupLoader = new GroupLoader(GetPrefabKey());
            }

            return _groupLoader;
        }

        /// <summary>
        /// 做资源预加载相关（不可以是场景），必须使用 GroupLoader
        /// </summary>
        public virtual void DoPreloadAssets()
        {
        }

        /// <summary>
        /// 获取预加载好的资源（自动释放，不要自己调用释放）
        /// </summary>
        /// <param name="assetKey"></param>
        /// <returns></returns>
        public ResHandle GetLoadedAsset(string assetKey)
        {
            if (_groupLoader != null)
                return _groupLoader.GetResHandle(assetKey);
            else
            {
                Log("There is no preloaded assets.....");
                return null;
            }
        }

        #endregion

        /**************************************************************************************************************/

        #region Load and auto release

        private RecordLoader _loader = null;

        /// <summary>
        /// 模块使用，自动管理释放
        /// </summary>
        public RecordLoader Loader
        {
            get
            {
                if (_loader == null)
                {
                    _loader = new RecordLoader(GetType().FullName);
                }

                return _loader;
            }
        }

        #endregion

        /**************************************************************************************************************/

        #region Auto IRelease mg

        private HashSet<Core.IRelease> _releaseSet;

        public void AddReleaseItem(Core.IRelease release)
        {
            if (_releaseSet == null)
                _releaseSet = new HashSet<Core.IRelease>();
            else if (_releaseSet.Contains(release))
                return;

            _releaseSet.Add(release);
        }

        private void DisposeReleaseItem()
        {
            if (_releaseSet == null)
                return;

            foreach (var item in _releaseSet)
            {
                item.Release();
            }

            _releaseSet.Clear();
        }

        private HashSet<Core.IRelease> _guideReleaseSet;

        public void GuideItemAddRelease(Core.IRelease release)
        {
            if (_guideReleaseSet == null)
                _guideReleaseSet = new HashSet<Core.IRelease>();
            else if (_guideReleaseSet.Contains(release))
                return;

            _guideReleaseSet.Add(release);
        }

        public void GuideItemDisposeRelease()
        {
            if (_guideReleaseSet == null)
                return;

            foreach (var item in _guideReleaseSet)
            {
                item?.Release();
            }

            _guideReleaseSet.Clear();
            _guideReleaseSet = null;
        }

        #endregion

        /**************************************************************************************************************/

        #region Auto Coroutine

        private HashSet<Coroutine> _coroutineSet;

        protected Coroutine StartCoroutine(System.Collections.IEnumerator routine)
        {
            if (_coroutineSet == null)
                _coroutineSet = new HashSet<Coroutine>();

            var coroutine = CoroutineManager.StartCoroutine(routine);
            _coroutineSet.Add(coroutine);
            return coroutine;
        }

        protected void StopCoroutine(Coroutine coroutine)
        {
            CoroutineManager.StopCoroutine(coroutine);
            if (_coroutineSet != null && _coroutineSet.Contains(coroutine))
            {
                _coroutineSet.Remove(coroutine);
            }
        }

        private void DisposeAllCoroutines()
        {
            if (_coroutineSet == null)
                return;

            foreach (var item in _coroutineSet)
            {
                CoroutineManager.StopCoroutine(item);
            }

            _coroutineSet.Clear();
        }

        #endregion

        /**************************************************************************************************************/

        #region Debug

        #endregion

        #region 飞行特效底层接口
        protected void PlayFlyEffect(UIControllerBase uiController, string itemId, long count, Transform start, FlyStyle flyStyle = FlyStyle.None)
        {
            EM.Fire(UIEvent.FlyParamEvent, new Tuple<string, string, long, Transform, FlyStyle>(GetCtrKey(uiController), itemId, count, start, flyStyle));
        }

        protected void PlayFlyEffect(UIControllerBase uiController, string itemId, long count, Vector3 start, bool CustomCount, FlyStyle flyStyle = FlyStyle.None)
        {
            EM.Fire(UIEvent.FlyParamEvent, new Tuple<string, string, long, Vector3, bool, FlyStyle>(GetCtrKey(uiController), itemId, count, start, CustomCount, flyStyle));
        }

        protected void PlayFlyEffect(UIControllerBase uiController, int resourseID, long count, Vector3 start, bool CustomCcount = false)
        {
            EM.Fire(UIEvent.FlyParamEvent, new Tuple<string, int, long, Vector3, bool>(GetCtrKey(uiController), resourseID, count, start, CustomCcount));
        }

        protected void PlayFlyEffect(UIControllerBase uiController, System.Type subViewType, string ak, string effectResId = "", Transform effctTransform = null)
        {
            EM.Fire(UIEvent.FlyParamSpecialEvent, new Tuple<string, Type, string, string, Transform>(GetCtrKey(uiController), subViewType, ak, effectResId, effctTransform));
        }

        protected void PlayFlyEffect(UIControllerBase uiController, System.Type subViewType, string ak, Action playEndCB, string effectResId)
        {
            EM.Fire(UIEvent.FlyParamSpecialEvent, new Tuple<string, Type, string, Action, string>(GetCtrKey(uiController), subViewType, ak, playEndCB, effectResId));
        }

        protected void PlayFlyEffect(UIControllerBase uiController, System.Type subViewType, string ak, Action playEndCB)
        {
            EM.Fire(UIEvent.FlyParamSpecialEvent, new Tuple<string, Type, string, Action>(GetCtrKey(uiController), subViewType, ak, playEndCB));
        }

        /// <summary>
        /// 根据UI设置是否返回控制key
        /// </summary>
        /// <returns></returns>
        private string GetCtrKey(UIControllerBase uiController) 
        {
            if (uiController == null) 
            {
                return string.Empty;
            }
            return m_ctrlParam.IsClearItemFly ? GetPrefabKey() : string.Empty;
        }
        #endregion
    }
}