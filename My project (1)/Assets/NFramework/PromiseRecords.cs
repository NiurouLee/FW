using Proto.Promises;
using NFramework.Core.Collections;

namespace NFramework
{
    public class PromiseRecords : BaseRecords<Promise>
    {

        protected override void OnDestroy()
        {
            foreach (var promise in Records)
            {

            }
        }
    }
}
