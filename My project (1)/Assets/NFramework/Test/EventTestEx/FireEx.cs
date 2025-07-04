using NFramework.Module.Event;


namespace NFramework.Test.EventTestEx
{
    public class FireEx
    {
        public void FireNormal()
        {
            var normalEvent2 = new NormalEvent();
            normalEvent2.ID = 2;
            Framework.Instance.GetModule<EventD>().D.Publish(ref normalEvent2);

            var normalEvent1 = new NormalEvent();
            normalEvent1.ID = 1;
            Framework.Instance.GetModule<EventD>().D.Fire(ref normalEvent1);
        }

        public void FireChannel()
        {
            var channelEvent1 = new ChannelEvent();
            Framework.Instance.GetModule<EventD>().D.Fire(ref channelEvent1);
        }
    }
}