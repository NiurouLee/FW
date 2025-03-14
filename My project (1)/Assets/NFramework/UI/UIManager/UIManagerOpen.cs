using System.Collections.Generic;
using Proto.Promises;
using UnityEngine.PlayerLoop;

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