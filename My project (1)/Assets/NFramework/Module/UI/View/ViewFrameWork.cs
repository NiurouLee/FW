

namespace NFramework.Module.UI
{
    public partial class View
    {
        public TM GetFrameworkModule<TM>() where TM : IFrameWorkModule
        {
            return Framework.I.GetModule<TM>();
        }
    }
}