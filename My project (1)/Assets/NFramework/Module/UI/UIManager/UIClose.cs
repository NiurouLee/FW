
namespace NFramework.Module.UI
{
    public partial class UI
    {
        public void Close<T>(T inWindow) where T : View
        {
            var vc = GetViewConfig<T>();
            var name = vc.ID;
            this.Close(name);
        }

        private void Close(string inWindowName)
        {
            var vc = GetViewConfig(inWindowName);
            if (this.CheckWindowReq(vc, out var outWindowRequest))
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