
using System;

public static class EventManager
{
    public static EventSchedule EventSchedule = new EventSchedule();

    public static void Publish<T>(ref T e) where T : IEvent
    {
        EventSchedule.Fire(ref e);
    }

    public static void Subscribe<T>(Action<T> callback) where T : IEvent
    {
        var type = typeof(T);
        EventSchedule.Subscribe(typeof(T), new BaseRegister
        {
            EventType = typeof(T),
            CallBack = callback
        });

    }
    public static void Subscribe<T>(Action<T> callback, Func<T, bool> condition) where T : IEvent
    {
        var type = typeof(T);
        EventSchedule.Subscribe(typeof(T), new ConditionRegister
        {
            EventType = typeof(T),
            CallBack = callback,
            Condition = condition
        });

    }

    public static void Subscribe<T>(Action<T> callback, string channel) where T : IEvent
    {
        var subscribe = new ChannelRegister
        {
            EventType = typeof(T),
            CallBack = callback,
            Channel = channel
        };


    }


}
