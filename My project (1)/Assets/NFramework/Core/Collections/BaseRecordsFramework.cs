
namespace NFramework.Core.Collections
{
    public abstract partial class BaseRecords<T>
    {
        public TM GetFrameworkModule<TM>() where TM : IFrameWorkModule
        {
            return Framework.I.G<TM>();
        }
    }
}