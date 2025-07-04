namespace NFramework.Module.Event
{
    public delegate void RefAction<T>(ref T inItem);

    public delegate bool RefFunc<T>(ref T inItem);
}