
namespace NFramework.Module.Event
{
    public class EventM : IFrameWorkModule
    {
        public EventSchedule D = new EventSchedule();

        public override void Awake()
        {
            D = new EventSchedule();
        }
    }
}