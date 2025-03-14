using Unity.VisualScripting;

namespace NFramework.UI
{
    public partial class View
    {
        private bool _AddChild(View inView)
        {
            if (inView == null)
            {
                return false;
            }

            return this.ViewRecords.TryAdd(inView);
        }

        private bool _RemoveChild(View inView)
        {
            return ViewRecords.TryRemove(inView);
        }

        private T _AddSubViewByFacade<T>(UIFacade inFacade) where T : View, new()
        {
            var result = new T();
            result.SetParent(this);
            this._AddChild(result);
            result.SetUIFacade(inFacade);
            result.Awake();
            return result;
        }

        private T _RemoveSubView<T>(T inView) where T : View
        {
            inView.Destroy();
            inView.RemoveParent();
            this._RemoveChild(inView);
            return inView;
        }
    }
}