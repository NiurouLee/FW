using Proto.Promises;

namespace NFramework.Module.UI
{
    public interface IUIFacadeProvider
    {
        public UIFacade Alloc<T>() where T : View;
        public Promise<UIFacade> AllocAsync<T>() where T : View;
        public Promise<UIFacade> AllocAsync(string inViewID);
        public void Free(UIFacade inUIFacade);
    }
}