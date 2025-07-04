using System;
using System.Collections.Generic;
using Game;
using Game.Report;
using Game.Sdk.Report;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace Ez.UI
{
    public class UIManager : Ez.Core.Singleton<UIManager>
    {
        private Queue<PersentingData> presentingQueue;

        private Dictionary<string, UIData> uiDict;

        private GameObject uiRoot;
        private Camera uiCamera;
        private Transform uiCanvasTf;
        private Canvas uiCanvas;
        CanvasScaler scaler;
        private EventSystem eventSystem;
        private bool allowOpenUI = true;


        private Dictionary<UIWindowLayer, UILayerData> layersUIDict;

        private UIControllerParamSet m_paramSet;

        public Material DefaultGrayMaterial{get; private set;}
        public override void Init()
        {
            UIDebuger.LogKey(nameof(UIManager), "init begin");

            presentingQueue = new Queue<PersentingData>();
            uiDict = new Dictionary<string, UIData>();

            m_paramSet = new UIControllerParamSet();
            m_paramSet.Init("Generate/GameSettings/UIConfigs.txt");

            UIDebuger.LogKey(nameof(UIManager), "init finished");

            DefaultGrayMaterial = Resources.Load<Material>("Material/UISpriteDefaultGray");
        }

        public void ChangeScreenOrientation(Vector2 vector)
        {
            if (scaler)
            {
                scaler.referenceResolution = vector;
            }
        }

        public void InitUIRoot(GameObject gobj)
        {
            uiRoot = gobj;
            uiRoot.transform.localPosition = new Vector3(0, 1000, 0);
            uiRoot.transform.name = "UIRoot";
            GameObject.DontDestroyOnLoad(uiRoot);

            uiCamera = uiRoot.GetComponentInChildren<Camera>();
            uiCamera.tag = "UICamera";
            uiCanvasTf = uiRoot.transform.Find("Canvas");
            uiCanvas = uiCanvasTf.GetComponent<Canvas>();
            eventSystem = uiRoot.GetComponentInChildren<EventSystem>();
            scaler = uiCanvas.transform.GetComponent<CanvasScaler>();

            _InitLayers();
        }

        private void _InitLayers()
        {
            layersUIDict = new Dictionary<UIWindowLayer, UILayerData>();

            foreach (UIWindowLayer item in System.Enum.GetValues(typeof(UIWindowLayer)))
            {
                GameObject layerObj = new GameObject(item.ToString());
                var trans = layerObj.AddComponent<RectTransform>();
                trans.SetParent(uiCanvasTf, false);
                Ez.Core.TransformUtil.NormalizeRectTransform(trans);
                layerObj.AddComponent<SafeAreaPanel>();

                UILayerData data = new UILayerData(item, trans);
                layersUIDict.Add(data.key, data);
            }
        }

        public void InitAssembly(System.Reflection.Assembly assembly)
        {
            UIBuilder.assembly = assembly;
        }

        public System.Type GetWinType(string winSpaceName)
        {
            System.Type t = UIBuilder.assembly.GetType(winSpaceName, false, true);
            return t;
        }

        public System.Reflection.Assembly UIBuilderAssembly()
        {
            return UIBuilder.assembly;
        }

        public override void Final()
        {
            UIDebuger.LogKey(nameof(UIManager), "Final begin");

            uiCamera = null;
            uiCanvasTf = null;
            uiCanvas = null;

            // 直接怼脸关 TODO 测试
            var list = new List<UIData>(uiDict.Values);
            foreach (var item in list)
            {
                try
                {
                    item.Close();
                }
                catch (System.Exception ex)
                {
                    DevDebuger.LogError("UIManager", ex.ToString());
                }
            }

            uiDict.Clear();

            foreach (var item in layersUIDict) // 自己干的事情，自己清理
            {
                var trans = item.Value?.layerTransform;
                if (trans != null)
                {
                    GameObject.Destroy(trans.gameObject);
                }
            }

            layersUIDict.Clear();

            UIDebuger.LogKey(nameof(UIManager), "Final finished");
            UIBlurBackground.Clear();
        }


        public Camera GetUICam()
        {
            return uiCamera;
        }

        public /*UIControllerBase*/ void OpenUI(System.Type controllerType, object param = null)
        {
            // TODO@bao 拓展支持 key 和 Controller 不再强依赖
            _OpenUI(controllerType.FullName, param, string.Empty, string.Empty);
        }

        /// <summary>
        /// 推荐使用函数 OpenUI(System.Type controllerType, object param = null)
        /// </summary>
        /// <param name="uiname"></param>
        /// <param name="param"></param>
        [System.Obsolete("暂停使用这个接口先，用上面那个，主要为处理多 Controller 并存情况，留个余地")]
        public /*UIControllerBase*/ void OpenUI(string uiname, object param = null)
        {
            /*return*/

            var controllerType = UIBuilder.assembly.GetType(uiname);
            if (controllerType == null)
            {
                DevDebuger.LogWarning("UIManager", $"can not the class: {uiname}");
                return;
            }

            _OpenUI(uiname, param, string.Empty, string.Empty);
        }

        public /*UIControllerBase*/ void ReplaceUI(string newui, object param, string oldui)
        {
            /*return*/
            _OpenUI(newui, param, oldui, string.Empty);
        }

        //打开界面，如果界面打开了就只更新数据
        public void OpenUIAndUpdateParam(string uiname, object param = null)
        {
            _OpenUI(uiname, param, string.Empty, string.Empty, true);
        }

        //打开界面，如果界面打开了就只更新数据
        public void OpenUIAndUpdateParam(System.Type controllerType, object param = null)
        {
            _OpenUI(controllerType.FullName, param, string.Empty, string.Empty, true);
        }

        private UIControllerBase _OpenUI(string uiname, object param, string replaceUi, string parentUI, bool update = false)
        {
            if (!allowOpenUI)
            {
                DevDebuger.Log("UIManager",$"OpenUI Failed!AllowOpenState:{allowOpenUI}");
                return null;
            }
            UIDebuger.LogKey(nameof(_OpenUI), $"{uiname} , param: {param}, replace: {replaceUi}, parent: {parentUI}");

            BIReport.GetInstance().Open_Windows(uiname);

            if(GameConfig.IsShowLog())
                Debuger.Log(this, $"OpenUI: {uiname}");
            // 为了跳链 如果界面打开了 需要先关闭
            if (_GetUIController(uiname) != null)
            {
                if (uiDict[uiname].state == UIWindowState.Shown || uiDict[uiname].state == UIWindowState.Hided)
                {
                    if (update) //如果只是更新数据就传数据进去
                    {
                        uiDict[uiname].controller.UpdateParam(param);
                        if (uiDict[uiname].state==UIWindowState.Hided)
                        {
                            uiDict[uiname].controller.Show();
                            uiDict[uiname].state = UIWindowState.Shown;
                        }
                    }
                    else
                        CloseUI(uiname);
                }
            }

            if (!uiDict.TryGetValue(uiname, out UIData uidata))
            {
                var controller = _BuildUI(uiname, param, replaceUi);
                if (controller != null)
                {
                    if (!uiDict.TryGetValue(uiname, out uidata))
                    {
                        uidata = new UIData(uiname, controller);
                        uidata.state = UIWindowState.Loading;
                        uiDict[uiname] = uidata;
                    }

                    uidata.parentUI = parentUI;
                }
                else
                {
                    DevDebuger.LogError("_OpenUI", $"can not find the controller: {uiname}");
                }

                UIEventManager.GetInstance().Fire(UIEventID.UIAsyncBeginShown, uiname);
                return controller;
            }
            else
            {
                if (uidata.state == UIWindowState.Hided)
                {
                    UIEventManager.GetInstance().Fire(UIEventID.UIAsyncBeginShown, uiname);
                    uidata.parentUI = parentUI;
                    ShowUIData(uidata, true);
                    if (!string.IsNullOrEmpty(replaceUi))
                    {
                        //if (uidata.IsBlur()) // delay call close('replaceUi')
                        CloseUI(replaceUi);
                    }
                }
                else
                {
                    DevDebuger.LogWarning("OpenUI", $"current ui state is : {uidata.name} -- {uidata.state}");
                }

                return uidata.controller;
            }
        }

        private UIControllerBase _BuildUI(string uiname, object param, string replaceUi, string parentUi = null)
        {
            PersentingData data = new PersentingData();
            data.uiname = uiname;
            data.param = param;
            data.replaceUi = replaceUi;
            data.parentUi = parentUi;
            data.isReady = false;
            data.ctrlparam = m_paramSet.Get(uiname);

            presentingQueue.Enqueue(data);

            return UIBuilder.BuildUI(data, _OnUIControllerReady);
        }

        // 异步加载完成后的处理
        private void _OnUIControllerReady(string uiname, UIControllerBase controller)
        {
            while (true)
            {
                if (presentingQueue.Count == 0)
                {
                    break;
                }

                PersentingData presentingData = presentingQueue.Peek();
                if (!presentingData.isReady)
                {
                    break;
                }

                presentingQueue.Dequeue();
                if (presentingData.hasError)
                {
                    DevDebuger.LogError("_OnUIControllerReady", $"has error {presentingData.uiname}");
                    RemoveUIController(presentingData.uiname);
                    continue;
                }

                string currUIName = presentingData.uiname;
                if (presentingData.closed == false)
                {
                    uiDict.TryGetValue(currUIName, out UIData uidata);
                    if (uidata == null)
                    {
                        uidata = new UIData(currUIName, presentingData.controller);
                        uidata.state = UIWindowState.Loaded;
                        uiDict.Add(currUIName, uidata);
                    }
                    else
                    {
                        if (uidata.controller != presentingData.controller)
                        {
                            DevDebuger.LogWarning("_ProcessReadyController", "uiData.controller ~= presentingData.controller is not nil");
                        }

                        // TODO@bao 这里不太对劲，丢失信息
                        uidata.AsyncSetController(presentingData.controller);
                        uidata.state = UIWindowState.Loaded;
                    }

                    ShowUIData(uidata, false);
                    if (!string.IsNullOrEmpty(presentingData.replaceUi))
                    {
                        // if IsBlur........ next 2 frame
                        CloseUI(presentingData.replaceUi);
                    }
                }
                else
                {
                    // 加载中的界面被关闭 调用controllerbase的Dispose方法卸载资源 此处为容错 正常不应该出现 未加载好就关闭情况
                    RemoveUIController(currUIName);

                    DevDebuger.LogWarning("_ProcessReadyController", $"Loading state ui : {currUIName} be released！！！！");
                }
            }

            if (presentingQueue.Count == 0)
            {
                SetInputEnabled(true);
            }
        }

        private UIControllerBase _GetUIController(string uiname)
        {
            if (!uiDict.ContainsKey(uiname))
            {
                return null;
            }

            return uiDict[uiname].controller;
        }

        // 错误异常时使用
        private void RemoveUIController(string uiname)
        {
            if (uiDict.TryGetValue(uiname, out UIData uidata))
            {
#if UNITY_EDITOR
                uidata.controller?.Dispose();
#else
                try
                {
                    uidata.controller?.Dispose();
                }
                catch (System.Exception e)
                {
                    Game.DevDebuger.LogError(uiname, e.Message + "\n" + e.StackTrace);
                    uidata.controller.Closeing=false;
                }
#endif
                uiDict.Remove(uiname);
                EM.Fire(UIEventID.UIClosedError, uidata.name);
            }
        }

        public void CloseAllUIExcept(List<string> exceptList)
        {
            throw new System.Exception("not implements....");
        }

        public void CloseUI(System.Type controllerType, bool isDestroy = true)
        {
            CloseUI(controllerType.FullName, isDestroy);
        }

        public void CloseUI(string uiname, bool isDestroy = true)
        {
            UIDebuger.LogKey(nameof(CloseUI), $"{uiname} ---- {isDestroy}");

            BIReport.GetInstance().Close_Windows(uiname);

            foreach (var item in presentingQueue)
            {
                if (item.uiname == uiname)
                {
                    UIEventManager.GetInstance().Fire(UIEventID.UIBeginClosed, uiname);
                    item.closed = true;
                    return;
                }
            }

            if (!uiDict.TryGetValue(uiname, out var uidata))
            {
                return;
            }

            //DevDebuger.Assert(uidata != null, $"current uiname '{uiname}' is null");

            UIEventManager.GetInstance().Fire(UIEventID.UIBeginClosed, uiname);
            var layer = uidata.GetLayer();
            var layerData = layersUIDict[layer];
            layerData.CloseWindow(uidata, isDestroy);
        }

        public void CloseToUI(string uiname)
        {
            UIData uidata;
            if (uiDict.TryGetValue(uiname, out uidata))
            {
                var layer = uidata.GetLayer();
                var layerData = layersUIDict[layer];
                layerData.CloseToWindow(uidata, true);
            }
            else
            {
                DevDebuger.LogWarning("CloseToUI", $"{uiname} has not show, now check presenting queue");
            }
        }

        private void SetInputEnabled(bool enabled)
        {
            eventSystem.enabled = enabled;
        }

        internal void SuspendUIData(UIData uidata)
        {
            UIDebuger.LogDetail("SuspendUIData", $"{uidata.name}");

            if (uidata.state == UIWindowState.Shown)
                uidata.Hide();

            foreach (var item in uiDict)
            {
                UIData tempUi = item.Value;
                if (tempUi.parentUI == uidata.name && tempUi.state == UIWindowState.Shown)
                {
                    UIDebuger.LogDetail("SuspendUIData", $"sub ui '{tempUi.name}'");
                    tempUi.Hide();
                }
            }
        }

        internal void ResumeUIData(UIData uidata)
        {
            UIDebuger.LogDetail("ResumeUIData", $"{uidata.name}");

            if (uidata.state == UIWindowState.Hided)
                uidata.Show();

            foreach (var item in uiDict)
            {
                UIData tempUi = item.Value;
                if (tempUi.parentUI == uidata.name && tempUi.state == UIWindowState.Hided)
                {
                    UIDebuger.LogDetail("ResumeUIData", $"sub ui '{tempUi.name}'");
                    tempUi.Show();
                }
            }
        }

        private void ShowUIData(UIData uidata, bool checkContain)
        {
            UIDebuger.LogDetail("ShowUIData", uidata.name);

            var layer = uidata.GetLayer();

            var layerData = layersUIDict[layer];
            layerData.PushWindow(uidata, checkContain);
        }

        public UILayerData GetUILayerData(UIWindowLayer layer)
        {
            if (layersUIDict.TryGetValue(layer, out UILayerData data))
            {
                return data;
            }

            DevDebuger.LogError("UIManager", $"Can not find UILayerData by layer({layer})");
            return null;
        }

        internal void CloseUIData(UIData uidata, bool isDestroy)
        {
            DevDebuger.Assert(uidata != null, "UIManager:CloseUIData param error");
            UIDebuger.LogDetail("CloseUIData", $"close ui: {uidata.name}");
            if(GameConfig.IsShowLog())
                Debuger.Log(this, $"CloseUIData: {uidata.name} ---- {isDestroy}");
            if (uidata.state == UIWindowState.Shown || uidata.state == UIWindowState.Hided)
            {
                if (isDestroy)
                {
                    uidata.Close(isDestroy);
                    uiDict.Remove(uidata.name);
                }
                else if (uidata.state == UIWindowState.Shown)
                {
                    uidata.Hide();
                }
            }
            else if (uidata.state == UIWindowState.Destoryed)
            {
                uiDict.Remove(uidata.name);
            }
            else
            {
                DevDebuger.LogError("CloseUIData", $"关闭界面失败 在界面没有初始化完毕关闭界面 例如在InitView方法关闭界面 请检查逻辑  : {uidata.name} -- {uidata.state}");
                return;
            }

            List<string> toCloseUI = new List<string>();
            foreach (var item in uiDict)
            {
                var tempui = item.Value;
                if (tempui.parentUI == uidata.name && (tempui.state == UIWindowState.Shown || tempui.state == UIWindowState.Hided))
                {
                    toCloseUI.Add(tempui.name);
                }
            }

            UIEventManager.GetInstance().Fire(UIEventID.UIClosed, uidata.name);
            foreach (var item in toCloseUI)
            {
                UIDebuger.LogDetail("CloseUIData Sub", item);
                CloseUI(item, isDestroy);
            }
        }

        public bool HasUI(string uiname)
        {
            return uiDict.ContainsKey(uiname);
        }

        public void HideAll(bool isHide)
        {
            if (isHide)
            {
                UIEventManager.GetInstance().Fire(UIEventID.AllHided);
            }

            uiCamera.enabled = !isHide;
            uiCanvas.enabled = !isHide;
            eventSystem.enabled = !isHide;
        }

        public UIData GetUIData(Type type)
        {
            return GetUIData(type.FullName);
        }
        

        public UIData GetUIData(string uiname)
        {
            return uiDict.GetValueOrDefault(uiname);
        }
        
        public UIWindowState GetUIState(string uiname)
        {
            if (uiDict.TryGetValue(uiname, out UIData uidata))
            {
                return uidata.state;
            }

            return UIWindowState.None;
        }

        public void HideUI(Type uiname)
        {
            HideUI(uiname.FullName);
        }

        public void HideUI(string uiname)
        {
            if (uiDict.TryGetValue(uiname, out UIData uidata))
            {
                if (uidata.state == UIWindowState.Shown || uidata.state == UIWindowState.Hided)
                {
                    uidata.Hide();
                }
            }
        }

        /// <summary>
        /// 判断UI是否显示
        /// </summary>
        /// <param name="uiname"></param>
        /// <returns></returns>
        public bool IsUIShowState(Type uiname)
        {
            return IsUIShowState(uiname.FullName);
        }

        /// <summary>
        ///  判断UI是否显示
        /// </summary>
        /// <param name="uiname"></param>
        /// <returns></returns>
        public bool IsUIShowState(string uiname)
        {
            if (uiDict.TryGetValue(uiname, out UIData uidata))
            {
                return uidata.state == UIWindowState.Shown;
            }

            return false;
        }

        /// <summary>
        /// 判断UI是否打开
        /// </summary>
        /// <param name="uiname"></param>
        /// <returns></returns>
        public bool IsUIOpened(Type uiname)
        {
            return IsUIOpened(uiname.FullName);
        }

        /// <summary>
        ///  判断UI是否打开
        /// </summary>
        /// <param name="uiname"></param>
        /// <returns></returns>
        public bool IsUIOpened(string uiname)
        {
            if (uiDict.TryGetValue(uiname, out UIData uidata))
            {
                return uidata.state == UIWindowState.Shown || uidata.state == UIWindowState.Hided;
            }

            return false;
        }

        // 外部特殊使用，获取指定UI排序数据
        public int GetPresentingUIOrderInLayer(string uiname)
        {
            int orderInLayer = 0;
            foreach (var item in presentingQueue)
            {
                if (item.uiname == uiname && !item.closed)
                {
                    if (uiDict.TryGetValue(uiname, out UIData uidata) && uidata != null)
                    {
                        var layer = uidata.GetLayer();
                        var layerData = layersUIDict[uidata.GetLayer()];

                        int startLayer = layerData.GetOneOrderInLayer();
                        int oneUISortOrder = layerData.GetOneUISortOrder();
                        int counttemp = 0;

                        foreach (var sub in presentingQueue)
                        {
                            if (sub == item) break;

                            if (!sub.closed)
                            {
                                string name = sub.uiname;
                                if (uiDict.TryGetValue(name, out UIData uiDataTemp) && uiDataTemp != null && uiDataTemp.GetLayer() == layer)
                                {
                                    counttemp += 1;
                                }
                            }
                        }

                        orderInLayer = startLayer + oneUISortOrder * counttemp;
                    }

                    break;
                }
            }

            return orderInLayer;
        }

        public int GetUIOrderInLayer(string uiname)
        {
            if (uiDict.TryGetValue(uiname, out UIData uidata))
            {
                return uidata.GetOrderInLayer();
            }

            return 0;
        }

        public UIBriefInfo GetTopUI(HashSet<string> exceptSet)
        {
            UIBriefInfo info = new UIBriefInfo();
            info.order = -1;

            foreach (var item in uiDict)
            {
                if (exceptSet.Contains(item.Key))
                {
                    continue;
                }

                UIData data = item.Value;
                if (info.order < data.GetOrderInLayer())
                {
                    info.controller = data.controller;
                    info.order = data.GetOrderInLayer();
                    info.Name = data.name;
                    info.state = data.state;
                }
            }

            return info;
        }

        public void GetUIList(ref List<UIBriefInfo> refList)
        {
            if (refList == null)
                refList = new List<UIBriefInfo>(uiDict.Count);
            else
                refList.Clear();

            foreach (var item in uiDict)
            {
                UIData data = item.Value;
                UIBriefInfo info = new UIBriefInfo();
                info.controller = data.controller;
                info.order = data.GetOrderInLayer();
                info.Name = data.name;
                info.state = data.state;
                refList.Add(info);
            }
        }

        public float GetCanvasZ()
        {
            return uiCanvas.transform.position.z;
        }

        public float GetReferenceResolutionX()
        {
            return scaler.referenceResolution.x;
        }

        public float GetCanvasHeight()
        {
            return uiCanvas.GetComponent<RectTransform>().sizeDelta.y;
        }

        /// <summary>
        /// 使UIManager能打开UI面板,见DisableOpenUI
        /// </summary>
        public void EnableOpenUI()
        {
            allowOpenUI = true;
        }

        /// <summary>
        /// 使UIManager无法打开UI面板,EnableOpenUI
        /// </summary>
        public void DisableOpenUI()
        {
            allowOpenUI = false;
        }

        #region pure funcs

        /// <summary>
        /// 判定是否拥有全屏的界面
        /// </summary>
        /// <param name="excepts"></param>
        /// <returns></returns>
        public bool HasFullScreenUI(HashSet<string> excepts)
        {
            foreach (var kv in uiDict)
            {
                var data = kv.Value;
                if (data.state != UIWindowState.Shown)
                {
                    continue;
                }

                if (excepts.Contains(data.name))
                    continue;

                var param = m_paramSet.Get(data.name);
                if (param != null && param.IsFullScreen)
                {
                    //DevDebuger.LogWarning("FullScreen", data.name);
                    return true;
                }
            }

            return false;
        }

        #endregion
    }
}