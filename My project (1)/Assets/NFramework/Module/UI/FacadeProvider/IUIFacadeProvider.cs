using Proto.Promises;

namespace NFramework.Module.UIModule
{
    public interface IUIFacadeProvider
    {
        public UIFacade Alloc<T>() where T : View;
        public Promise<UIFacade> AllocAsync<T>() where T : View;
        public Promise<UIFacade> AllocAsync(string inViewID);
        public void Free(UIFacade inUIFacade);
        public void Destroy();
    }
}