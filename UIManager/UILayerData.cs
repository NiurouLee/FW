using Game;
using System.Collections.Generic;
using UnityEngine;

namespace Ez.UI
{
    public class UILayerData
    {
        // 每个UI分配100个SortOrder范围
        public const int OneUISortOrderConst = 100;

        public readonly UIWindowLayer key;

        // 当前 Layer 的排序基础
        private readonly int _initOrderInLayer;

        public readonly Transform layerTransform;


        private FakeStack<UIData> _stack;
        private Stack<UIData> _exclusionStack;

        public UILayerData(UIWindowLayer layerOrder, Transform layerTrans)
        {
            key = layerOrder;
            _initOrderInLayer = (int)layerOrder;
            layerTransform = layerTrans;
            DevDebuger.Assert(layerTrans != null, $"error, transform is null: {layerOrder}");

            _stack = new FakeStack<UIData>(4);
            _exclusionStack = new Stack<UIData>(8);
        }

        public void PushWindow(UIData uiData, bool checkContain)
        {
            if (checkContain && this._stack.Contains(uiData))
            {
                UIDebuger.LogDetail("UILayerData",
                    $"PushWindow >>>>The UI has been shown,but in hide ,will be return {uiData.name}");

                return;
            }

            UIDebuger.LogDetail("UILayerData", $"PushWindow {uiData.name}, {_initOrderInLayer}");

            int targetOrder = uiData.GetOrderInLayer();
            if (targetOrder == 0)
            {
                targetOrder = GetOneOrderInLayer();
            }

            if (_exclusionStack.TryPeek(out UIData preTopUI))
            {
                preTopUI.OnViewOnTop(false);
            }

            if (uiData.IsExclusion())
            {
                if (_exclusionStack.Count > 0)
                {
                    var topUIdata = _exclusionStack.Peek();
                    bool finded = false;

                    foreach (var tempData in _stack)
                    {
                        if (tempData == topUIdata) { finded = true; }

                        if (finded)
                        {
                            // 子UI不受互斥逻辑影响，除非其是互斥的子UI
                            if (string.IsNullOrEmpty(tempData.parentUI) || tempData.parentUI == topUIdata.name)
                            {
                                // //暂时lobby不互斥
                                // if (topUIdata.controller.GetType().FullName != "client.UILobbyController")
                                // {
                                    HangUpUI(tempData);

                                // }
                            }
                        }
                    }
                }
                _exclusionStack.Push(uiData);
            }

            _stack.Push(uiData);
            uiData.AttachToLayer(layerTransform, targetOrder);
            uiData.Show();
        }

        public int GetOneOrderInLayer()
        {
            if (_stack.Count > 0)
            {
                return _stack.Peek().GetOrderInLayer() + OneUISortOrderConst;
            }
            else
            {
                return _initOrderInLayer;
            }
        }

        public int GetOneUISortOrder()
        {
            return OneUISortOrderConst;
        }

        public void CloseWindow(UIData uidata, bool isDestroy)
        {
            _CloseOrHideWindow(uidata, isDestroy);
        }

        public void CloseToWindow(UIData uidata, bool isDestroy)
        {
            UIDebuger.LogDetail("UILayerData", $"CloseToWindow {uidata.name} {isDestroy}");

            while (true)
            {
                if (_stack.Count <= 0)
                    break;

                var topData = _stack.Peek();
                if (topData == uidata)
                {
                    break;
                }
                CloseWindow(topData, isDestroy);
            }
        }

        private void _CloseOrHideWindow(UIData uidata, bool isDestroy)
        {
            UIDebuger.LogDetail("UILayerData", $"_CloseOrHideWindow {uidata.name} {isDestroy}");

            if (uidata.IsExclusion())
            {
                _CloseOrHideToWindow(uidata, isDestroy);
            }
            else
            {
                bool closeDataed = uidata.CanCloseState();
                if (closeDataed)
                {
                    while (true)
                    {
                        if (_stack.Count <= 0)
                            break;

                        var topData = _stack.Peek();
                        if (topData == uidata)
                        {
                            _stack.Pop();
                            break;
                        }
                        else if (uidata.IsClosed())
                        {
                            _stack.Pop();
                        }
                        else
                        {
                            _stack.Remove(uidata);
                            break;
                        }
                    }
                }
                UIManager.GetInstance().CloseUIData(uidata, isDestroy);

            }

            if (_exclusionStack.TryPeek(out UIData preTopUi) && preTopUi != null)
            {
                preTopUi.OnViewOnTop(true);
            }
        }

        private void _CloseOrHideToWindow(UIData uidata, bool isDestroy)
        {
            var _tempExclusionStack = new Stack<UIData>();
            if (uidata.IsExclusion())
            {
                var _tempStack = new Stack<UIData>();

                _exclusionStack.TryPop(out UIData topUIData);
                // 检查关闭的UI是否是最上层的互斥UI
                while (topUIData != uidata && _exclusionStack.Count > 0)
                {
                    _tempExclusionStack.Push(topUIData);
                    topUIData = _exclusionStack.Pop();
                }
                if (topUIData != uidata)
                {
                    return;
                }

                // 关闭到目标UI
                _tempExclusionStack.TryPeek(out UIData tempExclusionData);
                while (true)
                {
                    _stack.TryPop(out UIData topData);
                    if (tempExclusionData != null)
                    {
                        _tempStack.Push(topData);
                        if (topData == tempExclusionData)
                        {
                            tempExclusionData = null;
                        }
                    }
                    else
                    {
                        UIManager.GetInstance().CloseUIData(topData, isDestroy);
                        if (topData == uidata)
                        {
                            break;
                        }
                    }
                }

                while (_tempExclusionStack.Count > 0)
                {
                    _exclusionStack.Push(_tempExclusionStack.Pop());
                }
                while (_tempStack.Count > 0)
                {
                    _stack.Push(_tempStack.Pop());
                }

                // 恢复之前的互斥UI
                _exclusionStack.TryPeek(out topUIData);
                if (topUIData != null && topUIData.state != UIWindowState.Shown)
                {
                    bool finded = false;
                    foreach (var item in _stack)
                    {
                        if (item == topUIData)
                        {
                            finded = true;
                        }

                        if (finded)
                        {
                            if (item.state != UIWindowState.Shown)
                            {
                                RecoverUI(item);
                            }
                        }
                    }
                }
            }
            else
            {
                while (true)
                {
                    var topData = _stack.Peek();
                    UIManager.GetInstance().CloseUIData(topData, isDestroy);
                    if (topData == uidata)
                        break;
                }
            }
        }

        private void HangUpUI(UIData uidata)
        {
            UIManager.GetInstance().SuspendUIData(uidata);
        }

        private void RecoverUI(UIData uidata)
        {
            UIManager.GetInstance().ResumeUIData(uidata);
        }

        public UIData TopUIData
        {
            get
            {
                return _stack.Peek();
            }
        }
    }
}