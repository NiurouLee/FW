using System.Collections.Generic;
using UnityEngine;

namespace NFramework.Module.UI
{

    public partial class UI
    {
        public Dictionary<UIlayer, UILayerServices> layerServices = new Dictionary<UIlayer, UILayerServices>();

        public void AwakeLayer(Canvas inCanvas)
        {
            foreach (var item in System.Enum.GetValues(typeof(UIlayer)))
            {
                UIlayer _ilayer = (UIlayer)item;
                var go = new GameObject(item.ToString());
                var trans = go.AddComponent<RectTransform>();
                trans.SetParent(uiCanvasTrf, false);
                // TransformUtils.NormalizeRectTransform(trans);
                // go.AddComponent<>
                //todo: 适配 
                UILayerServices services = new UILayerServices(_ilayer, go);
                this.layerServices.Add(_ilayer, services);
            }
        }

        private void __WindowSetUpLayer(ViewConfig inViewConfig, Window inWindow)
        {
            var layer = inViewConfig.Layer;
            var layerServices = this.layerServices[(UIlayer)layer];
            var window = inWindow;
            window.Facade.transform.SetParent(layerServices.Go.transform, false);

        }
    }
}