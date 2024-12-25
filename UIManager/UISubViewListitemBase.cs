using Ez.Core;

namespace Ez.UI
{
    public abstract class UISubViewListitemBase : UISubViewBase, IListItem
    {
        public UISubViewListitemBase()
        {

        }

        public int Index { get; set; }
        public virtual bool IsSelected { get; set; }
        public object indexData { get; set; }

        public virtual void OnChangeSelect()
        {

        }
        public virtual bool CanSelect()
        {
            return true;
        }

        public override void Hide()
        {
            
        }
        public override void Show()
        {
            
        }
        public abstract void Refresh(int index, object obj = null);
    }
}
