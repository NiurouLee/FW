namespace NFramework.Event
{
    public interface IEvent
    {
    }

    public interface IChannelEvent : IEvent
    {
        public string Channel { get; }
    }
}