namespace NFramework.UI
{
    public partial class View
    {
        public virtual void Destroy()
        {
            OnDestroy();
            DestroyEventRecords();
            DestroyPopEvent2Parent();
        }

        protected virtual void OnDestroy()
        {
        }
    }
}