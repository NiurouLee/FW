namespace NFramework.Core
{
    public static class ObjectPool
    {
        public static T Alloc<T>() where T : class, new()
        {
            return new T();
        }

        public static bool Free<T>(T inT)
        {
            return true;
        }
    }
}