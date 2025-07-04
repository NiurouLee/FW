using System;
using Ez.Core;
using Game.Sdk.Report;
using UnityEngine;

namespace Ez.UI
{
    public class UIData
    {
        public readonly string name;

        public UIControllerBase controller { get; private set; }
        private UIWindowLayer layer;
        private int orderInLayer;
        public UIWindowState state;
        public string parentUI;

        private int viewDidAppearFrame;
        private int showTargetFrame;


        public UIData(string pname, UIControllerBase ctrler)
        {
            name = pname;
            controller = ctrler;
            layer = controller.wndLayer;
        }

        public void AsyncSetController(UIControllerBase c)
        {
            controller = c;
            layer = controller.wndLayer;
        }

        public UIWindowLayer GetLayer() { return layer; }

        public bool IsBlur() { return controller.IsBlur(); }

        public bool IsExclusion() { return controller.IsExclusion; } // TODO


        public void AttachToLayer(Transform pl, int order)
        {
            orderInLayer = order;
            controller.AttachToLayer(pl, orderInLayer);
        }

        public void Show()
        {
            if (state == UIWindowState.Loaded)//第一次加载完需要初始化的判断逻辑
            {
                try
                {
                    controller.InitView();
                }
                catch (System.Exception e)
                {
                    Debug.LogException(e);
                    // controller.CloseSelf();
                    return;
                }

                try
                {
                    controller.Init();
                }
                catch (System.Exception e2)
                {
                    Debug.LogException(e2);
                }
            }
            state = UIWindowState.Shown;
            if (IsBlur())
            {
                var inst = Unified.Universal.Blur.UniversalBlurFeature.instance;
                if (inst != null)
                {
                    inst.triggerByScript = true;
                    inst.UpdateBlurOnce();
                }
                showTargetFrame = Time.frameCount + 2;
            }
            else
            {
                _Show();
            }
            EzCore.GetInstance().UnRegisterUpdate(Update);
            EzCore.GetInstance().RegisterUpdate(Update);
            EzCore.GetInstance().UnRegisterLateUpdate(LateUpdate);
            EzCore.GetInstance().RegisterLateUpdate(LateUpdate);
        }

        private void _Show()
        {
            try
            {
                controller.ViewWillAppear();
                controller.Show();
                controller?.RegisterEvent();
                //Game.AudioManager.GetInstance().PostEvent(Game.Audio.AudioConsts.ui_pop_open);
            }
            catch (System.Exception e)
            {
                Debuger.LogError("UIData", "OnShowError: "+name+"\n"+e.Message + "\n" + e.StackTrace);
                controller?.CloseSelf();
                return;
            }
            viewDidAppearFrame = Time.frameCount + 1;
            UIEventManager.GetInstance().Fire(UIEventID.UIShown, name);
        }


        public void Hide(bool isDestroy = false)
        {
            if (state == UIWindowState.Shown)
            {
                controller.ViewWillDisappear();
                controller.Hide();

                if (viewDidAppearFrame > 0)
                {
                    controller.ViewDidDisappear();
                }
                state = UIWindowState.Hided;
                UIEventManager.GetInstance().Fire(UIEventID.UIHided, name);
                
                EzCore.GetInstance().UnRegisterUpdate(Update);
                EzCore.GetInstance().UnRegisterLateUpdate(LateUpdate);
                //Game.AudioManager.GetInstance().PostEvent(Game.Audio.AudioConsts.ui_pop_close);
            }
            else
            {
                UIDebuger.UIWarning("UIData", $"name = {name}, state = {state}");
            }
        }

        public void Close(bool isDestroy=false)
        {
            UIDebuger.LogDetail("UIData", $"start close {name}, state = {state}");
            controller.Closeing=true;
            if (state == UIWindowState.Shown)
            {
                Hide();
            }

            if (state == UIWindowState.Hided)
            {
                controller.UnRegisterEvent();
                //编辑器模式下 系统级别报错 线上模式容错
#if UNITY_EDITOR
                controller.Dispose();
#else
                try
                {
                    controller.Dispose();

                }
                catch (System.Exception e)
                {
                    Game.DevDebuger.LogError(controller.GetType().FullName, e.Message + "\n" + e.StackTrace);
                    controller.Closeing=false;
                }
#endif
                controller.Closeing=false;
                controller = null;
                state = UIWindowState.None;
                UIEventManager.GetInstance().Fire(UIEventID.UIClose, name);
              
                // client.AssetUtil.adapter.Collect();
            }
        }

        public bool IsClosed() { return state == UIWindowState.None; }

        public void Update()
        {
            if (state == UIWindowState.Shown)
            {
                if (showTargetFrame > 0 && showTargetFrame <= Time.frameCount)
                {
                    showTargetFrame = 0;
                    this._Show();
                }

                if (viewDidAppearFrame > 0 && viewDidAppearFrame <= Time.frameCount)
                {
                    viewDidAppearFrame = 0;
                    controller.ViewDidAppear();
                    UIEventManager.GetInstance().Fire(UIEventID.UIShowed, name);
                }

                controller?.Update();
            }
        }

        public void LateUpdate()
        {
            if (state == UIWindowState.Shown)
            {
                controller.LateUpdate();
            }
        }

        public void SafeCallController(System.Action func, UIControllerBase controller, object param)
        {

        }

        public int GetOrderInLayer()
        {
            return orderInLayer;
        }

        public void OnViewOnTop(bool isTop)
        {
            // TODO@bao
        }

        public bool CanCloseState()
        {
            return state == UIWindowState.Hided||state == UIWindowState.Shown||state == UIWindowState.Destoryed;
        }
    }

    public struct UIBriefInfo
    {
        public string Name;
        public UIControllerBase controller;
        public int order;
        public UIWindowState state;
    }
}