namespace NFramework.Core.ObjectPool
{
    public static class ObjectPool
    {
        public static T Alloc<T>() where T : class, new()
        {
            return new T();
        }

        public static bool Free<T>(T inT) where T : class, IFreeToPool
        {
            return true;
        }
    }
}