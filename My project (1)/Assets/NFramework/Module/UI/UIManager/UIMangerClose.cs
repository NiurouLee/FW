namespace NFramework.Module.UI
{
    public partial class UI
    {
        public void Close(Window inWindow)
        {
            inWindow.Hide();
            inWindow.Destroy();
        }
    }
}