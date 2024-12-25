using Ez.Assets;
using Game;
using System.Collections.Generic;
using Game.Sdk.Report;
using UnityEngine;
using UnityEngine.UI;

namespace Ez.UI
{
    /// <summary>
    /// 差插排，差动管特效。。。。
    /// </summary>
    public class UIViewBase
    {
        private ResHandle _assetRef;
        protected UIFacade _uiFacade;
        protected GameObject _gameObj;

        private int orderInLayer = 0;

        internal void Init(ResHandle assetRef)
        {
            _assetRef = assetRef;

            if (assetRef.Asset == null)
            {
                DevDebuger.LogError("UIViewBase", $"ResHandle {assetRef.AssetKey} is null");
                return;
            }

            var gobj = Object.Instantiate(assetRef.Asset as GameObject);
            Object.DontDestroyOnLoad(gobj);
            _gameObj = gobj;
            _uiFacade = gobj.GetComponent<UIFacade>();

            if (_uiFacade == null)
            {
                Debuger.LogError("UIViewBase", $"can not find the facade: {assetRef.AssetKey}, '{assetRef.Asset?.name}'");
                // UIDebuger.LogDetail("UIViewBase", $"can not find the facade: {assetRef.AssetKey}, '{assetRef.Asset?.name}'");
            }

            UIEventManager.GetInstance().Fire(UIEventID.UIViewSetGameObject, this);
        }


        public UIFacade GetFacade()
        {
            return _uiFacade;
        }

        public void AttachToLayer(Transform parent, int order)
        {
            orderInLayer = order;

            _gameObj.transform.SetParent(parent, false);
            _gameObj.transform.SetAsLastSibling();

            InitCanvasOrder();
            InitUIEffectOrder();
        }

        public int GetOrderInLayer() { return orderInLayer; }

        /**************************************************************************************************************/

        // 暂存，动态调？
        private Dictionary<Canvas, int> childrenCanvas = new Dictionary<Canvas, int>();

        private void InitCanvasOrder()
        {
            if (orderInLayer == 0)
            {
                return;
            }

            var childrenCanvasList = _gameObj.GetComponentsInChildren<Canvas>(true);
            if (childrenCanvasList != null && childrenCanvasList.Length > 0)
            {
                foreach (var child in childrenCanvasList)
                {
                    childrenCanvas.Add(child, child.sortingOrder);
                    child.sortingOrder += orderInLayer;
                    child.vertexColorAlwaysGammaSpace = true;
                }
            }

            var raycaster = _gameObj.GetComponent<UICustomGraphicRaycaster>();
            if (raycaster == null)
            {
                raycaster = _gameObj.AddComponent<UICustomGraphicRaycaster>();
            }
            raycaster.blockingMask = LayerMask.GetMask("UI");


            _gameObj.SetActive(true);
            var canvas = _gameObj.GetComponent<Canvas>();
            if (canvas == null)
            {
                canvas = _gameObj.AddComponent<Canvas>();
                canvas.additionalShaderChannels = 0;
            }

            canvas.vertexColorAlwaysGammaSpace = true; // UI 嘛，美术这么方便
            canvas.overrideSorting = true;
            canvas.sortingOrder = orderInLayer;
        }

        private Dictionary<Renderer, int> _effects;
        private void InitUIEffectOrder()
        {
            if (orderInLayer == 0)
            {
                return;
            }

            var psArray = _gameObj.GetComponentsInChildren<UnityEngine.Renderer>(true);
            if (psArray == null || psArray.Length == 0)
                return;

            _effects = new Dictionary<Renderer, int>(psArray.Length);
            foreach (var ps in psArray)
            {
                _effects.Add(ps, ps.sortingOrder);
                ps.sortingOrder = orderInLayer + ps.sortingOrder;
            }
        }

        private void InitSpriteMask()
        {

        }

        /**************************************************************************************************************/

        public void Show()
        {
            _gameObj.SetActive(true);
        }

        public void Hide(bool Closeing = false)
        {
            // 动画部分 TODO
            // _gameObj.transform.localScale = Vector3.zero;
            // _gameObj.SetActive(false);
            if (!Closeing)
            {
                _gameObj.SetActive(false);
            }
        }

        public void Dispose()
        {
            if (_gameObj != null)
            {
                // TaskTimeManager.GetInstance().AddData(1f,1,()=> {
                //
                // });
                GameObject.Destroy(_gameObj);
                _gameObj = null;
                // GameObject.Destroy(_gameObj);
                // _gameObj = null;
            }
            client.AssetUtil.adapter.UnloadAsset(_assetRef);
        }

        protected virtual void OnDispose() { }

    }


}