namespace NFramework.Module.UI
{
    public partial class View
    {
        public virtual void Destroy()
        {
            OnDestroy();
            DestroySubView();
            DestroyEventRecords();
            DestroyPopEvent2Parent();
            DestroyPromise();
            DestroyFacade();
        }

        protected virtual void OnDestroy()
        {
        }
    }
}