using Game;
using System;
using System.Collections.Generic;
using UnityEngine;
using Object = UnityEngine.Object;

namespace Ez.UI
{
    /// <summary>
    /// TODO 最简单版本先出一个~~~
    /// </summary>
    public abstract class UISubViewBase : EventListener, IEzDispose, IGuideItemRelease//, Core.IReusable /*这接口再处理吧，职责问题*/
    {

        // protected UIFacade m_facade;
        // private UIControllerBase m_controller;

#if UNITY_EDITOR
        private bool m_disposed = false;
        public void RestoreEnable()
        {
            m_disposed=false;
        }
#endif

        public UISubViewBase()
        {
            Core.ResMonitorUtil.Add("ui_subview", this);
        }
        /// <summary>
        /// 只是显示
        /// </summary>
        public virtual void Show()
        {

        }
        /// <summary>
        /// 只是隐藏
        /// </summary>
        public virtual void Hide()
        {

        }

        public virtual void Init()
        {
            
        }

        /// <summary>
        /// 刷新数据显示（全局刷新）
        /// </summary>
        protected virtual void Refresh()
        {

        }

        public virtual void UpateData(object item)
        {

        }
        public virtual void Update()
        {

        }

        /*

        /// <summary>
        /// 对象暂停使用（缓存复用），对称函数：Resume
        /// 功能：
        /// 1：取消事件注册
        /// 2：调用接口 OnSuspend （暂停时，可以自己做些清理在 OnSuspend 接口）
        /// </summary>
        public void Suspend()
        {
            UnRegister();
            OnSuspend();
        }

        /// <summary>
        /// 此接口不是销毁之类的拓展接口，一般复用前自己做简单清理之类的
        /// 对称函数：OnResume
        /// </summary>
        protected virtual void OnSuspend()
        {

        }

        /// <summary>
        /// 恢复对象使用，对称函数：Suspend
        /// 功能：
        /// 1：注册事件
        /// 2：调用接口 OnResume （复用时，可以自己搞些额外处理）
        /// </summary>
        public void Resume()
        {
            Register();
            OnResume();
        }

        /// <summary>
        /// 此接口用于恢复使用拓展接口，一般用于搞些额外处理
        /// 对称函数：
        /// OnSuspend
        /// </summary>
        protected virtual void OnResume()
        {

        }
        */

        /// <summary>
        /// 释放时使用，这个和构造函数调用匹配
        /// </summary>
        public void Dispose()
        {
            Core.ResMonitorUtil.Remove("ui_subview", this);
#if UNITY_EDITOR
            if (m_disposed)
            {
                DevDebuger.LogError($"{GetType().Name}", "call Dispose multi-times");
            }
            else
            {
                m_disposed = true; // 后续失败不记录
            }
#endif

            //DevDebuger.LogWarning($"{GetType().Name}", $"Dispose");

            UnRegister();
            GuideItemDisposeRelease();
            OnDispose();

            var obj = DemandDestroyObject();
            if (obj != null)
            {
#if UNITY_EDITOR
                Object.DestroyImmediate(obj);
#else
                UnityEngine.Object.Destroy(obj);
#endif
            }
        }

        /// <summary>
        /// 需求销毁的 UnityEngine.Object 对象 （移除 SubView 时会自动调用）
        /// 
        /// 注意：
        /// 一般不需要重载实现，只有 Controller 的生命周期和对象不一致的时候，再去实现
        /// 
        /// 例如：
        /// 界面上，某个 SubView 使用完成后，界面依旧在，但是 SubView 需要移除，
        /// 那么，重载一下这个 SubView 的此接口，用于销毁对象。
        /// </summary>
        /// <returns></returns>
        protected virtual UnityEngine.Object DemandDestroyObject()
        {
            return null;
        }

        protected abstract void OnDispose();

        #region 飞行特效
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
            return uiController.IsClearItemFly ? uiController.GetPrefabKey() : string.Empty;
        }
        #endregion

        #region Auto IRelease mg
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
    }
}
