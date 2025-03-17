using Proto.Promises;

namespace NFramework
{
    public class PromiseRecords : BaseRecords<Promise>
    {

        protected override void OnDestroy()
        {
            foreach (var promise in records)
            {
            }
        }
    }
}
