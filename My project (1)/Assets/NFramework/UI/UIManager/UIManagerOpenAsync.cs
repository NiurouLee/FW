using System.Collections.Generic;
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

        public Promise<Window> OpenAsync<T>() where T : Window, new()
        {
            var vc = this.GetViewConfig<T>();
            return _OpenAsync<T>(vc, null);
        }

        public Promise<Window> OpenAsync<T, I>(I inViewData) where T : Window, IViewSetData<I>, new() where I : IViewData
        {
            var vc = this.GetViewConfig<T>();
            return _OpenAsync<T>(vc, inViewData);
        }

        public Promise<Window> OpenAsync(string inWindowName, IViewData inViewData = null)
        {
            var vc = this.GetViewConfig(inWindowName);
            return _OpenAsync(vc, inViewData);
        }


        private Promise<Window> _OpenAsync<T>(ViewConfig inViewConfig, IViewData inViewData) where T : Window, new()
        {
            var windowRequest = new WindowRequest(inViewConfig);
            windowRequest.SetStage(WindowRequestStage.Construct);
            if (CheckWindowReq(windowRequest, out var outWindowRequest))
            {
                return outWindowRequest.Deferred.Promise;
            }
            windowRequest.SetInitData(inViewData);
            windowRequest.SetStage(WindowRequestStage.SetInitData);
            windowRequest.SetStage(WindowRequestStage.ConstructWindow);
            var window = this.CreateView<T>();
            var deferred = Promise.NewDeferred<Window>();
            windowRequest.SetPromiseDeferred(deferred);
            __OpenAsync(windowRequest, window);
            return deferred.Promise;
        }

        private Promise<Window> _OpenAsync(ViewConfig inViewConfig, IViewData inViewData)
        {
            var windowRequest = new WindowRequest(inViewConfig);
            windowRequest.SetStage(WindowRequestStage.Construct);
            if (CheckWindowReq(windowRequest, out var outWindowRequest))
            {
                return outWindowRequest.Deferred.Promise;
            }
            windowRequest.SetInitData(inViewData);
            windowRequest.SetStage(WindowRequestStage.SetInitData);
            windowRequest.SetStage(WindowRequestStage.ConstructWindow);
            var window = this.CreateView(inViewConfig) as Window;
            var deferred = Promise.NewDeferred<Window>();
            windowRequest.SetPromiseDeferred(deferred);
            __OpenAsync(windowRequest, window);
            return deferred.Promise;
        }

        private void __OpenAsync(WindowRequest inWindowRequest, Window inWindow)
        {
            inWindowRequest.SetWindow(inWindow);
            inWindowRequest.SetStage(WindowRequestStage.ConstructWindowDone);
            ___OpenAsync(inWindowRequest);
        }


        private async void ___OpenAsync(WindowRequest inWindowRequest)
        {
            //后续可以考虑使用队列逐个打开

            //记录在Request中
            //loader
            var resLoader = new ResLoadRecords();
            resLoader.Awake();
            inWindowRequest.SetResLoader(resLoader);
            //provider
            var provider = new UIFacadeProviderAssetLoader(resLoader);
            inWindowRequest.SetUIFacadeProvider(provider);
            //load && Open
            var assetID = inWindowRequest.Config.AssetID;
            var facadeGo = await resLoader.LoadAsyncAndInstantiate<GameObject>(assetID);
            var facade = facadeGo.GetComponent<UIFacade>();
            ___OpenBase(inWindowRequest, facade, provider);
        }


        private bool CheckWindowReq(WindowRequest inWindowRequest, out WindowRequest outWindowRequest)
        {
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