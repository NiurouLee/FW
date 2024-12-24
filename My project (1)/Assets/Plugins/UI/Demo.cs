namespace Plugins.UI
{
    public class Demo
    {
        public struct DemoEvent : IView2ParentEvent
        {
        }

        public class DemoView : View
        {
            public DemoView()
            {
                RegisterSubEvent<DemoEvent>(onHandle);

                var e = new DemoEvent();
                PopEvent2Parent(ref e);
            }

            private bool onHandle(ref DemoEvent view2parentevent)
            {
                return true;
            }
        }
    }
}