
namespace NFramework
{
    public class FrameworkLaunch
    {
        public static FrameworkLaunch Instance { get; private set; }
        public EngineLoop EngineLoop { get; private set; }
        public void Launch()
        {
            Framework.Instance.Awake();
        }
    }
}