using Proto.Promises;

namespace NFramework.UI
{
    public class UIFacadeProvider : IUIFacadeProvider
    {
        public UIFacade Alloc<T>() where T : View
        {
            return null;
        }

        public Promise<UIFacade> AllocAsync<T>() where T : View
        {
            return Promise<UIFacade>.Resolved(null);
        }

        public void Free(UIFacade inUIFacade)
        {
        }
    }
}
