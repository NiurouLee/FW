
namespace NFramework.Module.UIModule
{
    public class ViewComponent : UIObject
    {
        public View View { get; private set; }

        public void Awake(View inView)
        {
            this.View = inView;
        }

        public virtual void Awake()
        {
        }

        public void Destroy()
        {
            this.View = null;
        }
        public virtual void OnDestroy()
        {
        }

        public void Check(View inView)
        {
        }
    }
}