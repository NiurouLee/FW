using NFramework.Core.Collections;
using NFramework.Core.ObjectPool;

namespace NFramework
{
    public class PromiseRecords : BaseRecords<Proto.Promises.ICancelable>, IFreeToPool
    {
        public PromiseRecords()
        {
        }

        public void FreeToPool()
        {
        }

        protected override void OnDestroy()
        {
            foreach (var promise in Records)
            {
                promise.Cancel();
            }
        }
    }
}
