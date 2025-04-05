namespace NFramework.UI
{
    public partial class UIManager
    {

        /// <summary>
        /// 最后肯定会走这里，打开的话
        /// </summary>
        /// <param name="inWindowRequest"></param>
        /// <param name="inUIFacade"></param>
        /// <param name="inProvider"></param>
        private void ___OpenBase(WindowRequest inWindowRequest, UIFacade inUIFacade, IUIFacadeProvider inProvider)
        {
            var cfg = inWindowRequest.Config;
            var layer = cfg.Layer;
            var layerServices = this.layerServices[(UIlayer)layer];
            var uiFacade = inUIFacade;
            var go = uiFacade.gameObject;
            var window = inWindowRequest.Window;
            go.transform.SetParent(layerServices.Go.transform, false);
            window.SetUIFacade(uiFacade, inProvider);
            if (window is IViewSetData<IViewData> viewSetData)
            {
                viewSetData.SetData(inWindowRequest.ViewData);
            }
            window.Awake();
            window.Show();
            inWindowRequest.Deferred.Resolve(window);
        }
    }
}
