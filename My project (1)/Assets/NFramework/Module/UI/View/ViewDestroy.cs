namespace NFramework.Module.UIModule
{
    public partial class View
    {
        public virtual void Destroy()
        {
            OnDestroy();
            DestroyFacade();
            DestroyFacadeProvider();
        }

        protected virtual void OnDestroy()
        {
        }
    }
}