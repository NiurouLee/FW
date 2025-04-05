namespace NFramework.UI
{
    public partial class UIManager
    {
        public void Close(Window inWindow)
        {
            inWindow.Hide();
            inWindow.Destroy();
        }
    }
}