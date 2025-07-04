namespace NFramework.Module.UI
{

   
    public interface IViewSetData<T> where T : class
    {
        void SetData(T inData);
    }
}
