using Proto.Promises;

namespace NFramework.UI
{
    public partial class UIManager
    {
        public Promise<T> Open<T>()
        {
            var result = Promise<T>.NewDeferred();
            return result.Promise;
        }
    }
}