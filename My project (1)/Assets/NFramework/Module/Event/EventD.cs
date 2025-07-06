
namespace NFramework.Module.Event
{
    public class EventD : IFrameWorkModule
    {
        public EventSchedule D = new EventSchedule();

        public override void Awake()
        {
            D = new EventSchedule();
        }
    }
}