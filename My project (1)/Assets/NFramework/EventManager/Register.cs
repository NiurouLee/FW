using System;
public class BaseRegister : IEquatable<BaseRegister>, IDisposable
{
    public System.Type EventType { get; set; }
    public System.Delegate CallBack { get; set; }

    public void Dispose()
    {
    }

    public bool Equals(BaseRegister other)
    {
        return EventType == other.EventType && CallBack == other.CallBack;
    }

    internal void Invoke<T>(T e) where T : IEvent
    {
        var type = typeof(T);
        if (CallBack is Action<T> action)
        {
            action(e);
        }
    }
}

public class ConditionRegister : BaseRegister
{
    public System.Delegate Condition { get; set; }
}

public class ChannelRegister : BaseRegister
{
    public string Channel { get; set; }
}

