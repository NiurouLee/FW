using Proto.Promises;
using NFramework.Core.Collections;
using NFramework.Core.ObjectPool;

namespace NFramework
{
    public class PromiseRecords : BaseRecords<Promise>, IFreeToPool
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

            }
        }
    }
}
