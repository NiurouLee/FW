namespace NFramework.Module.UI
{
    public partial class View
    {
        public View Parent { get; private set; }

        private void SetParent(View inParent)
        {
            this.Parent = inParent;
        }

        private void DestroyParent()
        {
            this.Parent = null;
        }
    }
}
