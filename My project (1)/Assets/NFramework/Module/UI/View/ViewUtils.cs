using System.Collections;

namespace NFramework.Module.UIModule
{
    public delegate bool UI2ParentEvent<T>(ref T view2ParentEvent);
    public static class ViewUtils
    {
        public static bool Check<T>(View inView, out T outComponent) where T : ViewComponent
        {
        }
        public static T CheckAndAdd<T>(View inView) where T : ViewComponent
        {
            var component = inView.GetComponent<T>();
            if (component == null)
            {
                component = inView.AddComponent<T>();
            }
            return component;
        }
      
    }
}