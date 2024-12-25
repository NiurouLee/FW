using Proto.Promises;

public interface IUIFacadeProvider
{
    public UIFacade Alloc<T>() where T : View;
    public Promise<UIFacade> AllocAsync<T>() where T : View;
    public void Free(UIFacade inUIFacade);
}