namespace NFramework.Module.UIModule
{
    public interface IViewSetData<T> where T : class
    {
        void SetData(T inData);
    }
}
