using System.Collections.Generic;
using System.Resources;
using Proto.Promises;
using UnityEngine;

namespace NFramework.UI
{
    public partial class UIManager
    {
        /// <summary>
        /// 缓存打开中、打开的windowReq
        /// </summary>
        public Dictionary<string, WindowRequest> WindowRequestDictionary = new Dictionary<string, WindowRequest>();

        public Promise<Window> Open(string inWindowName, IViewData inViewData = null)
        {
            var deferred = Promise.NewDeferred<Window>();
            var vc = this.GetViewConfig(inWindowName);
            WindowRequest request = new WindowRequest(vc);
            request.SetStage(WindowRequestStage.Construct);
            if (CheckWindowReq(request, out var outWindowRequest))
            {
                this.WindowRequestDictionary.Add(vc.Name, outWindowRequest);
                this.AsyncOpenWindow(outWindowRequest, deferred);
            }
            else
            {
                Close(outWindowRequest.Name);
                this.WindowRequestDictionary.Add(vc.Name, outWindowRequest);
                this.AsyncOpenWindow(request, deferred);
            }

            return deferred.Promise;
        }

        public Window Open<T>(string inWindowName, IViewData inViewData = null) where T : Window, new()
        {
            var windowType = typeof(T);
            var window = new T();
            var cfg = this.GetViewConfig<T>();
            var resId = cfg.AssetID;
            var gameObject = ResourceManager.Instance.Load<GameObject>(resId);
            var go = GameObject.Instantiate(gameObject);
            var uiFacade = go.GetComponent<UIFacade>();
            var provider = new UIFacadeProvider();
            window.SetUIFacade(uiFacade, provider);
            window.Awake();
            window.Show();
            return window;
        }


        private async void AsyncOpenWindow(WindowRequest outWindowRequest, Promise<Window>.Deferred deferred)
        {
            var layerID = outWindowRequest.Config.Layer;
            // this.layerServices[(UIlayer)layerID].OpenWindow();
        }

        public Promise<Window> OpenOrUpdateData(string inWindowName, IViewData inViewData = null)
        {
            var vc = this.GetViewConfig(inWindowName);
            WindowRequest request = new WindowRequest(vc);
            request.SetStage(WindowRequestStage.Construct);
            return new Promise<Window>();
        }

        private bool CheckWindowReq(WindowRequest inWindowRequest, out WindowRequest outWindowRequest)
        {
            var layer = inWindowRequest.Config.Layer;
            if (this.WindowRequestDictionary.TryGetValue(inWindowRequest.Name, out var request))
            {
                outWindowRequest = request;
                return false;
            }
            else
            {
                outWindowRequest = inWindowRequest;
                return true;
            }
        }
    }
}