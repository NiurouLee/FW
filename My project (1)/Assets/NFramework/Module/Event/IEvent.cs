namespace NFramework.Module.EventModule
{
    public interface IEvent
    {
    }

    public interface IChannelEvent : IEvent
    {
        public string Channel { get; }
    }
}