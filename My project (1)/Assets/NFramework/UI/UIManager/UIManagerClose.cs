using Unity.VisualScripting;

namespace NFramework.UI
{
    public partial class UIManager
    {
        public void Close<T>(T inWindow) where T : View
        {
            var vc = GetViewConfig<T>();
            var name = vc.Name;
            this.Close(name);
        }

        private void Close(string inWindowName)
        {
            var vc = GetViewConfig(inWindowName);
            var req = new WindowRequest(vc);
            if (this.CheckWindowReq(req, out var outWindowRequest))
            {
                if (outWindowRequest.Stage == WindowRequestStage.WindowOpen)
                {
                    var layerID = vc.Layer;
                    var layerService = this.layerServices[(UIlayer)layerID];
                    // layerService.CloseWindow(outWindowRequest);
                }
            }
        }
    }
}